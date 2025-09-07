import Foundation

struct SimParams {
    var deltaTime: Float
    var time: Float
    var fieldCount: UInt32
    var homingEnabled: UInt32
    var homingOnlyWhenNoFields: UInt32
    var homingStrength: Float
    var homingDamping: Float
}

struct Uniforms {
    var viewSize: SIMD2<Float>
    var isEmitting: Float
}
