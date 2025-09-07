import Foundation

enum FieldKind: UInt32 {
    case radial = 0
    case linear = 1
    case turbulence = 2
    case vortex = 3
    case drag = 4
    case velocity = 5
    case linearGravity = 6
    case noise = 7
    case electric = 8
    case magnetic = 9
    case spring = 10
}

struct GPUField {
    var position: SIMD2<Float>
    var vector: SIMD2<Float>
    var strength: Float
    var radius: Float
    var falloff: Float
    var minRadius: Float
    var kind: UInt32
    var enabled: UInt32
}
