import Foundation

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
