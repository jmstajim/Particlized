import Foundation
import Metal
import MetalKit
import UIKit

// Helper to convert UIColor to MTLClearColor is in MetalUtils.swift

public final class ParticlizedRenderer: NSObject, MTKViewDelegate {
    public var controls: ParticlizedControls = .init()
    public var backgroundColor: UIColor = .black {
        didSet { mtkView?.clearColor = makeClearColor(from: backgroundColor) }
    }

    public func setItems(_ items: [ParticlizedItem]) {
        let spawns = items.map { ParticlizedSpawn(item: $0, position: .zero) }
        setSpawns(spawns)
    }

    public func setSpawns(_ spawns: [ParticlizedSpawn]) {
        let all = spawns.flatMap { spawn -> [Particle] in
            let base = spawn.item.particles()
            if spawn.position == .zero { return base }
            let dx = Float(spawn.position.x), dy = Float(spawn.position.y)
            return base.map { p in
                var q = p
                q.position.x += dx
                q.position.y += dy
                q.homePosition.x += dx
                q.homePosition.y += dy
                return q
            }
        }
        uploadParticles(all)
    }

    public func setFields(_ nodes: [ParticlizedFieldNode]) {
        fields = nodes
        rebuildFieldBufferIfNeeded(count: fields.count)
    }

    // MARK: - Private
    private var device: MTLDevice!
    private var commandQueue: MTLCommandQueue!
    private var library: MTLLibrary!

    private var renderPipeline: MTLRenderPipelineState!
    private var computePipeline: MTLComputePipelineState!

    private var quadBuffer: MTLBuffer!
    private var particleBuffer: MTLBuffer?
    private var uniformsBuffer: MTLBuffer!
    private var simParamsBuffer: MTLBuffer!
    private var fieldsBuffer: MTLBuffer?

    private var particleCount: Int = 0
    private var fields: [ParticlizedFieldNode] = []

    private weak var mtkView: MTKView?
    private var lastTime: CFTimeInterval = CACurrentMediaTime()
    private var accumTime: Float = 0

    public override init() {
        super.init()
        self.device = MTLCreateSystemDefaultDevice()
        self.commandQueue = device.makeCommandQueue()
        self.library = try? device.makeDefaultLibrary(bundle: .module)
        buildPipelines()
        buildQuad()
        buildUniforms()
    }

    func attach(to view: MTKView) {
        self.mtkView = view
        view.device = device
        view.delegate = self
        view.framebufferOnly = true
        view.colorPixelFormat = .bgra8Unorm
        view.clearColor = makeClearColor(from: backgroundColor)
        view.isPaused = false
        view.enableSetNeedsDisplay = false
        view.preferredFramesPerSecond = 60
    }

    private func buildPipelines() {
        guard let vs = library.makeFunction(name: "particle_vertex"),
              let fs = library.makeFunction(name: "particle_fragment"),
              let cs = library.makeFunction(name: "particle_update")
        else { return }

        let rpd = MTLRenderPipelineDescriptor()
        rpd.vertexFunction = vs
        rpd.fragmentFunction = fs
        rpd.colorAttachments[0].pixelFormat = .bgra8Unorm

        do {
            renderPipeline = try device.makeRenderPipelineState(descriptor: rpd)
            computePipeline = try device.makeComputePipelineState(function: cs)
        } catch {
            assertionFailure("Metal pipeline error: \(error)")
        }
    }

    private func buildQuad() {
        struct QuadVertex { var pos: SIMD2<Float>; var uv: SIMD2<Float> }
        let quad: [QuadVertex] = [
            .init(pos: [-0.5, -0.5], uv: [0, 0]),
            .init(pos: [ 0.5, -0.5], uv: [1, 0]),
            .init(pos: [-0.5,  0.5], uv: [0, 1]),
            .init(pos: [ 0.5,  0.5], uv: [1, 1]),
        ]
        quadBuffer = device.makeBuffer(bytes: quad, length: MemoryLayout<QuadVertex>.stride * quad.count)
    }

    private func buildUniforms() {
        uniformsBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.stride)
        simParamsBuffer = device.makeBuffer(length: MemoryLayout<SimParams>.stride)
    }

    private func uploadParticles(_ particles: [Particle]) {
        particleCount = particles.count
        let len = max(1, particleCount) * MemoryLayout<Particle>.stride
        particleBuffer = device.makeBuffer(length: len, options: [.storageModeShared])
        if let ptr = particleBuffer?.contents().bindMemory(to: Particle.self, capacity: particleCount) {
            for i in 0..<particleCount { ptr[i] = particles[i] }
        }
    }

    private func rebuildFieldBufferIfNeeded(count: Int) {
        guard let device else { return }
        let desired = max(1, count) * MemoryLayout<GPUField>.stride
        if fieldsBuffer == nil || fieldsBuffer!.length < desired {
            fieldsBuffer = device.makeBuffer(length: desired, options: [.storageModeShared])
        }
    }

    // MARK: - MTKViewDelegate

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    public func draw(in view: MTKView) {
        guard particleCount > 0,
              let drawable = view.currentDrawable,
              let rpd = view.currentRenderPassDescriptor,
              let cmd = commandQueue.makeCommandBuffer()
        else { return }

        // Timing
        let now = CACurrentMediaTime()
        let dt = Float(now - lastTime)
        lastTime = now
        accumTime = max(0, accumTime + dt)

        // Upload fields every frame
        let gpuFields = fields.map { $0.toGPU() }
        rebuildFieldBufferIfNeeded(count: gpuFields.count)
        if let fb = fieldsBuffer, !gpuFields.isEmpty {
            fb.contents().copyMemory(from: gpuFields, byteCount: gpuFields.count * MemoryLayout<GPUField>.stride)
        }

        // Sim params
        var sp = SimParams(
            deltaTime: dt,
            time: accumTime,
            fieldCount: UInt32(gpuFields.count),
            homingEnabled: controls.homingEnabled ? 1 : 0,
            homingOnlyWhenNoFields: controls.homingOnlyWhenNoFields ? 1 : 0,
            homingStrength: controls.homingStrength,
            homingDamping: controls.homingDamping
        )
        memcpy(simParamsBuffer.contents(), &sp, MemoryLayout<SimParams>.stride)

        // Compute
        if let particleBuffer {
            let ce = cmd.makeComputeCommandEncoder()
            ce?.setComputePipelineState(computePipeline)
            ce?.setBuffer(particleBuffer, offset: 0, index: 0)
            ce?.setBuffer(fieldsBuffer, offset: 0, index: 1)
            ce?.setBuffer(simParamsBuffer, offset: 0, index: 2)

            let w = computePipeline.threadExecutionWidth
            let threadsPerTG = MTLSize(width: w, height: 1, depth: 1)
            let groups = (max(1, particleCount) + w - 1) / w
            let tgCount = MTLSize(width: groups, height: 1, depth: 1)
            ce?.dispatchThreadgroups(tgCount, threadsPerThreadgroup: threadsPerTG)
            ce?.endEncoding()
        }

        // Render
        var uni = Uniforms(
            viewSize: .init(Float(view.drawableSize.width), Float(view.drawableSize.height)),
            isEmitting: controls.isEmitting ? 1 : 0
        )
        memcpy(uniformsBuffer.contents(), &uni, MemoryLayout<Uniforms>.stride)

        let re = cmd.makeRenderCommandEncoder(descriptor: rpd)!
        re.setRenderPipelineState(renderPipeline)
        re.setVertexBuffer(quadBuffer, offset: 0, index: 0)
        re.setVertexBuffer(particleBuffer, offset: 0, index: 1)
        re.setVertexBuffer(uniformsBuffer, offset: 0, index: 2)
        re.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: particleCount)
        re.endEncoding()

        cmd.present(drawable)
        cmd.commit()
    }
}
