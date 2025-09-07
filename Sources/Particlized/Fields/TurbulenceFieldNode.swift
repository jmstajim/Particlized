import Foundation
import CoreGraphics

public struct TurbulenceFieldNode: Equatable {
    public var position: CGPoint
    public var strength: Float
    public var radius: Float
    public var smoothness: Float
    public var minRadius: Float
    public var enabled: Bool
    public init(position: CGPoint, strength: Float, radius: Float, smoothness: Float = 0.5, minRadius: Float = 0, enabled: Bool) {
        self.position = position
        self.strength = strength
        self.radius = radius
        self.smoothness = smoothness
        self.minRadius = minRadius
        self.enabled = enabled
    }
}

extension TurbulenceFieldNode {
    func toGPU() -> GPUField {
        GPUField(
            position: .init(Float(position.x), Float(position.y)),
            vector: .zero,
            strength: strength,
            radius: radius,
            falloff: 0,
            minRadius: minRadius,
            kind: FieldKind.turbulence.rawValue,
            enabled: enabled ? 1 : 0
        )
    }
}
