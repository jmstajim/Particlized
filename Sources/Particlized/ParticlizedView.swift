import SwiftUI
import MetalKit
import UIKit

public struct ParticlizedView: UIViewRepresentable {
    public var spawns: [ParticlizedSpawn]
    public var fields: [ParticlizedFieldNode]
    public var controls: ParticlizedControls
    public var backgroundColor: UIColor

    public init(scene: ParticlizedScene) {
        self.spawns = scene.spawns
        self.fields = scene.fields
        self.controls = scene.controls
        self.backgroundColor = scene.backgroundColor
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func makeUIView(context: Context) -> MTKView {
        let view = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        context.coordinator.engine.attach(to: view)
        context.coordinator.engine.setBackgroundColor(backgroundColor)
        context.coordinator.engine.setControls(controls)
        context.coordinator.engine.setFields(fields)
        context.coordinator.spawnSync.apply(spawns) { s in
            context.coordinator.engine.setSpawns(s)
        }
        return view
    }

    public func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.engine.setBackgroundColor(backgroundColor)
        context.coordinator.engine.setControls(controls)
        context.coordinator.engine.setFields(fields)
        context.coordinator.spawnSync.applyIfNeeded(spawns) { s in
            context.coordinator.engine.setSpawns(s)
        }
    }

    public final class Coordinator {
        let engine = ParticlizedEngine()
        let spawnSync = SpawnSync()
    }
}

