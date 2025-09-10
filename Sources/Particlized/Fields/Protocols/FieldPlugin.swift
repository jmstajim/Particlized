import Foundation

public protocol FieldPlugin {
    var key: String { get }
    func gpuFieldDescs(from field: PluginField) -> [GPUFieldDesc]
}

public final class FieldPluginRegistry {
    public static let shared = FieldPluginRegistry()
    private var plugins: [String: FieldPlugin] = [:]
    private init() {}
    
    public func register(_ plugin: FieldPlugin) {
        plugins[plugin.key] = plugin
    }
    
    public func plugin(for key: String) -> FieldPlugin? {
        plugins[key]
    }
}

