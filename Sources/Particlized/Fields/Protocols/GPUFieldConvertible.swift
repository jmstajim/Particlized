import Foundation

protocol GPUFieldConvertible {
    var enabled: Bool { get }
    func toGPU() -> GPUField
}

