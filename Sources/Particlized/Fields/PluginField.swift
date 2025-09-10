import Foundation
import CoreGraphics
import simd

public struct PluginField: Equatable {
    public let pluginKey: String
    public var position: CGPoint
    public var vector: SIMD2<Float>
    public var params: [String: Float]
    public var enabled: Bool
    
    public init(pluginKey: String, position: CGPoint = .zero, vector: SIMD2<Float> = .zero, params: [String: Float] = [:], enabled: Bool = true) {
        self.pluginKey = pluginKey
        self.position = position
        self.vector = vector
        self.params = params
        self.enabled = enabled
    }
}

