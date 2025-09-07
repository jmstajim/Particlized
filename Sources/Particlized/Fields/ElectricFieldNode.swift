import Foundation
import CoreGraphics

public struct ElectricFieldNode: Equatable {
    public var position: CGPoint
    public var strength: Float
    public var radius: Float
    public var falloff: Float
    public var minRadius: Float
    public var enabled: Bool
    public init(position: CGPoint, strength: Float, radius: Float, falloff: Float, minRadius: Float = 0, enabled: Bool) {
        self.position = position
        self.strength = strength
        self.radius = radius
        self.falloff = falloff
        self.minRadius = minRadius
        self.enabled = enabled
    }
}

extension ElectricFieldNode: GPUFieldConvertible {
    func toGPU() -> GPUField {
        GPUField(
            position: .init(Float(position.x), Float(position.y)),
            vector: .zero,
            strength: strength,
            radius: radius,
            falloff: falloff,
            minRadius: minRadius,
            kind: FieldKind.electric.rawValue,
            enabled: enabled ? 1 : 0
        )
    }
}

