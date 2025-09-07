import Foundation

enum FieldChoice: String, CaseIterable, Identifiable {
    case radial = "Radial"
    case turbulence = "Turbulence"
    case vortex = "Vortex"
    case noise = "Noise"
    case electric = "Electric"
    case magnetic = "Magnetic"
    case spring = "Spring"
    case linear = "Linear"
    case drag = "Drag"
    case velocity = "Velocity"
    case linearGravity = "Linear Gravity"
    var id: String { rawValue }
}

