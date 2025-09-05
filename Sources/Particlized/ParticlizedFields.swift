import Foundation
import UIKit
import simd
import CoreGraphics

public struct RadialFieldNode: Equatable {
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

public struct VortexFieldNode: Equatable {
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

public struct DragFieldNode: Equatable {
    public var strength: Float
    public var enabled: Bool
    public init(strength: Float, enabled: Bool) {
        self.strength = strength
        self.enabled = enabled
    }
}

public struct VelocityFieldNode: Equatable {
    public var vector: SIMD2<Float>
    public var strength: Float
    public var enabled: Bool
    public init(vector: SIMD2<Float>, strength: Float, enabled: Bool) {
        self.vector = vector
        self.strength = strength
        self.enabled = enabled
    }
}

public struct LinearGravityFieldNode: Equatable {
    public var vector: SIMD2<Float>
    public var strength: Float
    public var enabled: Bool
    public init(vector: SIMD2<Float>, strength: Float, enabled: Bool) {
        self.vector = vector
        self.strength = strength
        self.enabled = enabled
    }
}

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

public struct MagneticFieldNode: Equatable {
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

public struct SpringFieldNode: Equatable {
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

public enum ParticlizedFieldNode: Equatable {
    case radial(RadialFieldNode)
    case linear(LinearFieldNode)
    case turbulence(TurbulenceFieldNode)
    case vortex(VortexFieldNode)
    case drag(DragFieldNode)
    case velocity(VelocityFieldNode)
    case linearGravity(LinearGravityFieldNode)
    case noise(NoiseFieldNode)
    case electric(ElectricFieldNode)
    case magnetic(MagneticFieldNode)
    case spring(SpringFieldNode)
}

public struct ParticlizedSpawn {
    public var item: ParticlizedItem
    public var position: CGPoint
    
    public init(item: ParticlizedItem, position: CGPoint) {
        self.item = item
        self.position = position
    }
}
