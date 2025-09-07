import Foundation

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
