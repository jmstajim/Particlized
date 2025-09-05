//
//  MetalParticleView.swift
//  Particlized
//

import SwiftUI
import MetalKit

public struct MetalParticleView: UIViewRepresentable {
    public var spawns: [ParticlizedSpawn]
    public var fields: [ParticlizedFieldNode]
    public var controls: ParticlizedControls
    public var backgroundColor: UIColor

    public init(spawns: [ParticlizedSpawn], fields: [ParticlizedFieldNode], controls: ParticlizedControls, backgroundColor: UIColor) {
        self.spawns = spawns
        self.fields = fields
        self.controls = controls
        self.backgroundColor = backgroundColor
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func makeUIView(context: Context) -> MTKView {
        let view = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        if context.coordinator.renderer == nil {
            let renderer = ParticlizedRenderer()
            renderer.attach(to: view)
            context.coordinator.renderer = renderer
            context.coordinator.apply(spawns: spawns, to: renderer) // initial upload
        } else {
            context.coordinator.renderer?.attach(to: view)
        }
        return view
    }

    public func updateUIView(_ uiView: MTKView, context: Context) {
        guard let renderer = context.coordinator.renderer else { return }

        // These don't recreate buffers:
        renderer.controls = controls
        renderer.backgroundColor = backgroundColor
        renderer.setFields(fields)

        // Upload spawns only if changed (hash-based)
        context.coordinator.applyIfNeeded(spawns: spawns, to: renderer)
    }

    public final class Coordinator {
        var renderer: ParticlizedRenderer?
        private var lastSpawnsHash: Int? = nil

        func hash(spawns: [ParticlizedSpawn]) -> Int {
            var hasher = Hasher()
            hasher.combine(spawns.count)
            for s in spawns {
                switch s.item {
                case .text(let t):
                    hasher.combine(Int(bitPattern: Unmanaged.passUnretained(t).toOpaque()))
                case .image(let i):
                    hasher.combine(Int(bitPattern: Unmanaged.passUnretained(i).toOpaque()))
                }
                hasher.combine(s.position.x.native)
                hasher.combine(s.position.y.native)
            }
            return hasher.finalize()
        }

        func apply(spawns: [ParticlizedSpawn], to renderer: ParticlizedRenderer) {
            renderer.setSpawns(spawns)
            lastSpawnsHash = hash(spawns: spawns)
        }

        func applyIfNeeded(spawns: [ParticlizedSpawn], to renderer: ParticlizedRenderer) {
            let h = hash(spawns: spawns)
            if lastSpawnsHash != h {
                apply(spawns: spawns, to: renderer)
            }
        }
    }
}
