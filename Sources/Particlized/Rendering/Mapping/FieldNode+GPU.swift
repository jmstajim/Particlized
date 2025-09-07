import Foundation
import UIKit

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
        }
    }
}
