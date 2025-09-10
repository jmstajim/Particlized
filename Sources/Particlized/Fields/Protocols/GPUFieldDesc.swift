import Foundation
import CoreGraphics
import simd

public struct GPUFieldDesc {
    public var position: CGPoint
    public var vector: SIMD2<Float>
    public var strength: Float
    public var radius: Float
    public var falloff: Float
    public var minRadius: Float
    public var kind: PublicFieldKind
    public var enabled: Bool
    
    public init(position: CGPoint = .zero,
                vector: SIMD2<Float> = .zero,
                strength: Float = 0,
                radius: Float = 0,
                falloff: Float = 0,
                minRadius: Float = 0,
                kind: PublicFieldKind = .radial,
                enabled: Bool = true) {
        self.position = position
        self.vector = vector
        self.strength = strength
        self.radius = radius
        self.falloff = falloff
        self.minRadius = minRadius
        self.kind = kind
        self.enabled = enabled
    }
}

