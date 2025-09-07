import Foundation
import CoreGraphics

public struct ParticlizedSpawn {
    public var item: ParticlizedItem
    public var position: CGPoint
    
    public init(item: ParticlizedItem, position: CGPoint) {
        self.item = item
        self.position = position
    }
}
