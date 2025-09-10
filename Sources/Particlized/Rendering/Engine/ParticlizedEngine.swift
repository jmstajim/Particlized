import Foundation
import MetalKit
import UIKit

public final class ParticlizedEngine {
    private let renderer = ParticlizedRenderer()
    
    public init() {}
    
    public func attach(to view: MTKView) {
        renderer.attach(to: view)
    }
    
    public func apply(scene: ParticlizedScene) {
        setControls(scene.controls)
        setBackgroundColor(scene.backgroundColor)
        setFields(scene.fields)
        setSpawns(scene.spawns)
    }
    
    public func setSpawns(_ spawns: [ParticlizedSpawn]) {
        renderer.setSpawns(spawns)
    }
    
    public func setFields(_ fields: [ParticlizedFieldNode]) {
        renderer.setFields(fields)
    }
    
    public func setControls(_ controls: ParticlizedControls) {
        renderer.controls = controls
    }
    
    public func setBackgroundColor(_ color: UIColor) {
        renderer.backgroundColor = color
    }
}

