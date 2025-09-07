import Foundation

protocol ParticlizedField {
    var enabled: Bool { get }
    func toGPU() -> GPUField
}
