import Foundation

final class SpawnSync {
    private var lastHash: UInt64 = 0
    
    func apply(_ spawns: [ParticlizedSpawn], applier: ([ParticlizedSpawn]) -> Void) {
        applier(spawns)
        lastHash = Self.hash(spawns)
    }
    
    func applyIfNeeded(_ spawns: [ParticlizedSpawn], applier: ([ParticlizedSpawn]) -> Void) {
        let h = Self.hash(spawns)
        if h != lastHash {
            apply(spawns, applier: applier)
        }
    }
    
    func reset() { lastHash = 0 }
    
    static func hash(_ spawns: [ParticlizedSpawn]) -> UInt64 {
        var hasher = Hasher()
        hasher.combine(spawns.count)
        for s in spawns {
            switch s.item {
            case .text(let t):
                hasher.combine(1)
                hasher.combine(t.particles.count)
            case .image(let i):
                hasher.combine(2)
                hasher.combine(i.particles.count)
            }
            hasher.combine(Int(s.position.x.rounded(.towardZero)))
            hasher.combine(Int(s.position.y.rounded(.towardZero)))
        }
        return UInt64(bitPattern: Int64(hasher.finalize()))
    }
}

