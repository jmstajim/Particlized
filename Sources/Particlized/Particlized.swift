//
//  Particlized.swift
//
//  Metal core: particle types, renderer, utilities.
//
//

import Foundation
import Metal
import MetalKit
import UIKit

public struct Particle {
    public var position: SIMD2<Float>
    public var velocity: SIMD2<Float>
    public var color: SIMD4<Float>
    public var size: Float
    public var lifetime: Float
    public var homePosition: SIMD2<Float>
    public init(position: SIMD2<Float>, velocity: SIMD2<Float>, color: SIMD4<Float>, size: Float, homePosition: SIMD2<Float>? = nil) {
        self.position = position
        self.velocity = velocity
        self.color = color
        self.size = size
        self.lifetime = 0
        self.homePosition = homePosition ?? position
    }
}

public struct ParticlizedControls: Equatable {
    public var radialEnabled: Bool = false
    public var radialStrength: Float = 80.0
    public var radialCenter: CGPoint = .zero

    public var linearEnabled: Bool = false
    public var linearVector: SIMD2<Float> = .init(0, -30)

    public var turbulenceEnabled: Bool = false
    public var turbulenceStrength: Float = 20.0

    public var isEmitting: Bool = true

    // Homing controls
    public var homingEnabled: Bool = true
    public var homingStrength: Float = 40.0
    public var homingDamping: Float = 8.0
    public var homingOnlyWhenNoFields: Bool = true

    public init() {}
}

public enum ParticlizedItem {
    case text(ParticlizedText)
    case image(ParticlizedImage)

    func particles() -> [Particle] {
        switch self {
        case .text(let t): return t.particles
        case .image(let i): return i.particles
        }
    }
}

// Internal GPU mirrors
fileprivate enum FieldKind: UInt32 {
    case radial = 0
    case linear = 1
    case turbulence = 2
    case vortex = 3
    case drag = 4
    case velocity = 5
    case linearGravity = 6
    case noise = 7
    case electric = 8
    case magnetic = 9
    case spring = 10
}

fileprivate struct GPUField {
    var position: SIMD2<Float>
    var vector: SIMD2<Float>
    var strength: Float
    var radius: Float
    var falloff: Float
    var minRadius: Float
    var kind: UInt32
    var enabled: UInt32
}

fileprivate struct SimParams {
    var deltaTime: Float
    var time: Float
    var fieldCount: UInt32
    var homingEnabled: UInt32
    var homingOnlyWhenNoFields: UInt32
    var homingStrength: Float
    var homingDamping: Float
}

fileprivate struct Uniforms {
    var viewSize: SIMD2<Float>
    var isEmitting: Float
}

// Helper: convert UIColor to MTLClearColor
fileprivate func makeClearColor(from color: UIColor) -> MTLClearColor {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    color.getRed(&r, green: &g, blue: &b, alpha: &a)
    return MTLClearColor(red: Double(r), green: Double(g), blue: Double(b), alpha: Double(a))
}

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

        // Upload fields every frame
        let gpuFields = fields.map { $0.toGPU() }
        rebuildFieldBufferIfNeeded(count: gpuFields.count)
        if let fb = fieldsBuffer, !gpuFields.isEmpty {
            fb.contents().copyMemory(from: gpuFields, byteCount: gpuFields.count * MemoryLayout<GPUField>.stride)
        }

        // Sim params (include homing controls)
        var sp = SimParams(
            deltaTime: dt,
            time: Float(now),
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

// MARK: - Mapping helpers

extension ParticlizedFieldNode {
    fileprivate func toGPU() -> GPUField {
        switch self {
        case .radial(let r):
            return GPUField(
                position: .init(Float(r.position.x), Float(r.position.y)),
                vector: .zero,
                strength: r.strength,
                radius: r.radius,
                falloff: r.falloff,
                minRadius: r.minRadius,
                kind: FieldKind.radial.rawValue,
                enabled: r.enabled ? 1 : 0
            )
        case .linear(let l):
            return GPUField(
                position: .zero,
                vector: l.vector,
                strength: l.strength,
                radius: 0,
                falloff: 0,
                minRadius: 0,
                kind: FieldKind.linear.rawValue,
                enabled: l.enabled ? 1 : 0
            )
        case .turbulence(let t):
            return GPUField(
                position: .init(Float(t.position.x), Float(t.position.y)),
                vector: .zero,
                strength: t.strength,
                radius: t.radius,
                falloff: 0,
                minRadius: t.minRadius,
                kind: FieldKind.turbulence.rawValue,
                enabled: t.enabled ? 1 : 0
            )
        case .vortex(let v):
            return GPUField(
                position: .init(Float(v.position.x), Float(v.position.y)),
                vector: .zero,
                strength: v.strength,
                radius: v.radius,
                falloff: v.falloff,
                minRadius: v.minRadius,
                kind: FieldKind.vortex.rawValue,
                enabled: v.enabled ? 1 : 0
            )
        case .drag(let d):
            return GPUField(
                position: .zero,
                vector: .zero,
                strength: d.strength,
                radius: 0,
                falloff: 0,
                minRadius: 0,
                kind: FieldKind.drag.rawValue,
                enabled: d.enabled ? 1 : 0
            )
        case .velocity(let v):
            return GPUField(
                position: .zero,
                vector: v.vector,
                strength: v.strength,
                radius: 0,
                falloff: 0,
                minRadius: 0,
                kind: FieldKind.velocity.rawValue,
                enabled: v.enabled ? 1 : 0
            )
        case .linearGravity(let g):
            return GPUField(
                position: .zero,
                vector: g.vector,
                strength: g.strength,
                radius: 0,
                falloff: 0,
                minRadius: 0,
                kind: FieldKind.linearGravity.rawValue,
                enabled: g.enabled ? 1 : 0
            )
        case .noise(let n):
            return GPUField(
                position: .init(Float(n.position.x), Float(n.position.y)),
                vector: .init(n.animationSpeed, 0),
                strength: n.strength,
                radius: n.radius,
                falloff: n.smoothness,
                minRadius: n.minRadius,
                kind: FieldKind.noise.rawValue,
                enabled: n.enabled ? 1 : 0
            )
        case .electric(let e):
            return GPUField(
                position: .init(Float(e.position.x), Float(e.position.y)),
                vector: .zero,
                strength: e.strength,
                radius: e.radius,
                falloff: e.falloff,
                minRadius: e.minRadius,
                kind: FieldKind.electric.rawValue,
                enabled: e.enabled ? 1 : 0
            )
        case .magnetic(let m):
            return GPUField(
                position: .init(Float(m.position.x), Float(m.position.y)),
                vector: .zero,
                strength: m.strength,
                radius: m.radius,
                falloff: m.falloff,
                minRadius: m.minRadius,
                kind: FieldKind.magnetic.rawValue,
                enabled: m.enabled ? 1 : 0
            )
        case .spring(let s):
            return GPUField(
                position: .init(Float(s.position.x), Float(s.position.y)),
                vector: .zero,
                strength: s.strength,
                radius: s.radius,
                falloff: s.falloff,
                minRadius: s.minRadius,
                kind: FieldKind.spring.rawValue,
                enabled: s.enabled ? 1 : 0
            )
        }
    }
}


