import Foundation

public struct DragFieldNode: Equatable {
    public var strength: Float
    public var enabled: Bool
    public init(strength: Float, enabled: Bool) {
        self.strength = strength
        self.enabled = enabled
    }
}

extension DragFieldNode: GPUFieldConvertible {
    func toGPU() -> GPUField {
        GPUField(
            position: .zero,
            vector: .zero,
            strength: strength,
            radius: 0,
            falloff: 0,
            minRadius: 0,
            kind: FieldKind.drag.rawValue,
            enabled: enabled ? 1 : 0
        )
    }
}

