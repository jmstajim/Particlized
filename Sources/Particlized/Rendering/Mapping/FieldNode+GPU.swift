import Foundation
import UIKit
import CoreGraphics
import simd

extension ParticlizedFieldNode {
    func toGPU() -> GPUField {
        switch self {
        case .radial(let r):
            return r.toGPU()
        case .linear(let l):
            return l.toGPU()
        case .turbulence(let t):
            return t.toGPU()
        case .vortex(let v):
            return v.toGPU()
        case .drag(let d):
            return d.toGPU()
        case .velocity(let v):
            return v.toGPU()
        case .linearGravity(let g):
            return g.toGPU()
        case .noise(let n):
            return n.toGPU()
        case .electric(let e):
            return e.toGPU()
        case .magnetic(let m):
            return m.toGPU()
        case .spring(let s):
            return s.toGPU()
        case .plugin(let p):
            let arr = toGPUArray(from: p)
            return arr.first ?? GPUField(
                position: .zero, vector: .zero, strength: 0, radius: 0, falloff: 0, minRadius: 0,
                kind: PublicFieldKind.radial.rawValue, enabled: 0
            )
        }
    }
    
    func toGPUArray() -> [GPUField] {
        switch self {
        case .plugin(let p):
            return toGPUArray(from: p)
        default:
            return [toGPU()]
        }
    }
    
    private func toGPUArray(from pluginField: PluginField) -> [GPUField] {
        guard let plugin = FieldPluginRegistry.shared.plugin(for: pluginField.pluginKey) else { return [] }
        let descs = plugin.gpuFieldDescs(from: pluginField)
        return descs.map { d in
            GPUField(
                position: .init(Float(d.position.x), Float(d.position.y)),
                vector: d.vector,
                strength: d.strength,
                radius: d.radius,
                falloff: d.falloff,
                minRadius: d.minRadius,
                kind: d.kind.rawValue,
                enabled: d.enabled ? 1 : 0
            )
        }
    }
}

