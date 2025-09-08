import Foundation
import simd


struct SimParams {
    var deltaTime: Float
    var time: Float
    var fieldCount: UInt32
    var homingEnabled: UInt32
    var homingOnlyWhenNoFields: UInt32
    var homingStrength: Float
    var homingDamping: Float
    var particleCount: UInt32
}

struct Uniforms {
    var viewSize: SIMD2<Float>
    var isEmitting: Float
    var _padU: Float
    var mvp: simd_float4x4
}

