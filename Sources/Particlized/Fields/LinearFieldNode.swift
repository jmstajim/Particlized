import Foundation
import simd

public struct LinearFieldNode: Equatable {
    public var vector: SIMD2<Float>
    public var strength: Float
    public var enabled: Bool
    public init(vector: SIMD2<Float>, strength: Float, enabled: Bool) {
        self.vector = vector
        self.strength = strength
        self.enabled = enabled
    }
}

extension LinearFieldNode {
    func toGPU() -> GPUField {
        GPUField(
            position: .zero,
            vector: vector,
            strength: strength,
            radius: 0,
            falloff: 0,
            minRadius: 0,
            kind: FieldKind.linear.rawValue,
            enabled: enabled ? 1 : 0
        )
    }
}
