import Foundation
import CoreGraphics

public struct ParticlizedControls: Equatable {
    public var radialEnabled: Bool = false
    public var radialStrength: Float = 80.0
    public var radialCenter: CGPoint = .zero

    public var linearEnabled: Bool = false
    public var linearVector: SIMD2<Float> = .init(0, -30)

    public var turbulenceEnabled: Bool = false
    public var turbulenceStrength: Float = 20.0

    public var isEmitting: Bool = true

    // Homing controls
    public var homingEnabled: Bool = true
    public var homingStrength: Float = 40.0
    public var homingDamping: Float = 8.0
    public var homingOnlyWhenNoFields: Bool = true

    public init() {}
}
