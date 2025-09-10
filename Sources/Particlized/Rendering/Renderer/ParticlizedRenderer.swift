import Foundation
import Metal
import MetalKit
import UIKit
import simd

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
        let gpuFields = nodes.flatMap { $0.toGPUArray() }
        let sig = hashGPUFields(gpuFields)
        if lastFieldsHash != sig || gpuFieldCount != gpuFields.count {
            rebuildFieldBufferIfNeeded(count: gpuFields.count)
            if let fb = fieldsBuffer, !gpuFields.isEmpty {
                gpuFields.withUnsafeBytes { raw in
                if let base = raw.baseAddress {
                    memcpy(fb.contents(), base, raw.count)
                }
            }
            } else if let fb = fieldsBuffer {
                memset(fb.contents(), 0, MemoryLayout<GPUField>.stride)
            }
            gpuFieldCount = gpuFields.count
            lastFieldsHash = sig
        }
    }
    
    private let inflightBuffers = 3
    private var frameIndex = 0
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
    
    private var gpuFieldCount: Int = 0
    private var lastFieldsHash: UInt64 = 0
    
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
        ensureFieldsBufferExists()
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
        let baseULen = max(256, MemoryLayout<Uniforms>.stride)
        let baseSLen = max(256, MemoryLayout<SimParams>.stride)
        let uLen = baseULen * inflightBuffers
        let sLen = baseSLen * inflightBuffers
        uniformsBuffer = device.makeBuffer(length: uLen)
        simParamsBuffer = device.makeBuffer(length: sLen)
    }
    
    private func ensureFieldsBufferExists() {
        if fieldsBuffer == nil {
            fieldsBuffer = device.makeBuffer(length: MemoryLayout<GPUField>.stride, options: [.storageModeShared])
            memset(fieldsBuffer!.contents(), 0, fieldsBuffer!.length)
            gpuFieldCount = 0
            lastFieldsHash = 0
        }
    }
    
    private func uploadParticles(_ particles: [Particle]) {
        particleCount = particles.count
        if particleCount == 0 {
            particleBuffer = nil
            return
        }
        let len = particleCount * MemoryLayout<Particle>.stride
        particleBuffer = device.makeBuffer(length: len, options: [.storageModeShared])
        if let pb = particleBuffer {
            particles.withUnsafeBytes { raw in
                if let base = raw.baseAddress {
                    memcpy(pb.contents(), base, len)
                }
            }
        }
    }
    
    private func rebuildFieldBufferIfNeeded(count: Int) {
        let desired = max(1, count) * MemoryLayout<GPUField>.stride
        if fieldsBuffer == nil || fieldsBuffer!.length < desired {
            fieldsBuffer = device.makeBuffer(length: desired, options: [.storageModeShared])
        }
        if count == 0, let fb = fieldsBuffer {
            memset(fb.contents(), 0, fb.length)
        }
    }
    
    private func particleCapacity() -> Int {
        guard let pb = particleBuffer else { return 0 }
        return pb.length / MemoryLayout<Particle>.stride
    }
    
    private func hashGPUFields(_ arr: [GPUField]) -> UInt64 {
        if arr.isEmpty { return 0 }
        var h: UInt64 = 0xcbf29ce484222325
        let p: UInt64 = 0x100000001b3
        arr.withUnsafeBufferPointer { buf in
            let byteCount = MemoryLayout<GPUField>.stride * buf.count
            let raw = UnsafeRawBufferPointer(start: buf.baseAddress, count: byteCount)
            for b in raw {
                h ^= UInt64(b)
                h &*= p
            }
        }
        return h
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    public func draw(in view: MTKView) {
        guard let commandQueue = commandQueue,
              let drawable = view.currentDrawable,
              let rpd = view.currentRenderPassDescriptor
        else { return }
        
        let now = CACurrentMediaTime()
        var dt = Float(now - lastTime)
        if !dt.isFinite || dt < 0 { dt = 0 }
        // Clamp delta to avoid large simulation steps on hitches
        dt = min(max(dt, 0), 1.0 / 30.0)
        lastTime = now
        accumTime += dt
        
        // Update uniform buffers
        let viewW = Float(view.drawableSize.width)
        let viewH = Float(view.drawableSize.height)
        let sx: Float = viewW > 0 ? (2.0 / viewW) : 0.0
        let sy: Float = viewH > 0 ? (2.0 / viewH) : 0.0
        let mvp = simd_float4x4(
            SIMD4<Float>( sx, 0, 0, 0),
            SIMD4<Float>( 0, sy, 0, 0),
            SIMD4<Float>( 0, 0, 1, 0),
            SIMD4<Float>( 0, 0, 0, 1)
        )
        var uni = Uniforms(viewSize: .init(viewW, viewH),
                           isEmitting: controls.isEmitting ? 1.0 : 0.0,
                           _padU: 0.0,
                           mvp: mvp)
        let uStride = max(256, MemoryLayout<Uniforms>.stride)
        let uOffset = uStride * frameIndex
        memcpy(uniformsBuffer.contents().advanced(by: uOffset), &uni, MemoryLayout<Uniforms>.stride)
        
        var sp = SimParams(
            deltaTime: dt,
            time: accumTime,
            fieldCount: UInt32(gpuFieldCount),
            homingEnabled: controls.homingEnabled ? 1 : 0,
            homingOnlyWhenNoFields: controls.homingOnlyWhenNoFields ? 1 : 0,
            homingStrength: controls.homingStrength,
            homingDamping: controls.homingDamping,
            particleCount: UInt32(particleCount)
        )
        let sStride = max(256, MemoryLayout<SimParams>.stride)
        let sOffset = sStride * frameIndex
        memcpy(simParamsBuffer.contents().advanced(by: sOffset), &sp, MemoryLayout<SimParams>.stride)
        
        let cmd = commandQueue.makeCommandBuffer()
        
        
        // Compute pass (update particles)
        let computeNeeded = particleCount > 0 && (gpuFieldCount > 0 || controls.homingEnabled)
        if computeNeeded, let pb = particleBuffer, let fb = fieldsBuffer, let cmd = cmd, let cp = computePipeline {
            if let ce = cmd.makeComputeCommandEncoder() {
                ce.setComputePipelineState(cp)
                ce.setBuffer(pb, offset: 0, index: 0)
                ce.setBuffer(fb, offset: 0, index: 1)
                ce.setBuffer(simParamsBuffer, offset: sOffset, index: 2)
                
                let w = max(1, cp.threadExecutionWidth)
                let maxT = max(1, cp.maxTotalThreadsPerThreadgroup)
                let desired = min(256, w * 4)
                let tptgW = min(maxT, max(w, desired))
                let tptg = MTLSize(width: tptgW, height: 1, depth: 1)
                let tg = MTLSize(width: (particleCount + tptgW - 1) / tptgW, height: 1, depth: 1)
                ce.dispatchThreadgroups(tg, threadsPerThreadgroup: tptg)
                ce.endEncoding()
            }
        }
        
        // Render pass (draw quads)
        if let cmd = cmd, let re = cmd.makeRenderCommandEncoder(descriptor: rpd) {
            re.setRenderPipelineState(renderPipeline)
            re.setVertexBuffer(quadBuffer, offset: 0, index: 0)
            if particleCount > 0, let pb = particleBuffer {
                re.setVertexBuffer(pb, offset: 0, index: 1)
            } else {
                re.setVertexBuffer(nil, offset: 0, index: 1)
            }
            re.setVertexBuffer(uniformsBuffer, offset: uOffset, index: 2)
            
            if particleCount > 0 {
                re.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: particleCount)
            }
            re.endEncoding()
            
            cmd.present(drawable)
            cmd.commit()
        }
        frameIndex = (frameIndex + 1) % inflightBuffers
    }
}

