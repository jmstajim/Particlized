import Foundation

// SOLID: Explicit protocol for GPU conversion responsibility.
// Kept internal to avoid leaking GPUField publicly.
protocol GPUFieldConvertible {
    var enabled: Bool { get }
    func toGPU() -> GPUField
}

