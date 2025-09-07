import Foundation
import CoreGraphics
import simd

public struct NoiseFieldNode: Equatable {
    public var position: CGPoint
    public var strength: Float
    public var radius: Float
    public var smoothness: Float
    public var animationSpeed: Float
    public var minRadius: Float
    public var enabled: Bool
    public init(position: CGPoint, strength: Float, radius: Float, smoothness: Float, animationSpeed: Float, minRadius: Float = 0, enabled: Bool) {
        self.position = position
        self.strength = strength
        self.radius = radius
        self.smoothness = smoothness
        self.animationSpeed = animationSpeed
        self.minRadius = minRadius
        self.enabled = enabled
    }
}

extension NoiseFieldNode: GPUFieldConvertible {
    func toGPU() -> GPUField {
        GPUField(
            position: .init(Float(position.x), Float(position.y)),
            vector: .init(animationSpeed, 0),
            strength: strength,
            radius: radius,
            falloff: smoothness,
            minRadius: minRadius,
            kind: FieldKind.noise.rawValue,
            enabled: enabled ? 1 : 0
        )
    }
}

