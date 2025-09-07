import Foundation

public struct Particle {
    public var position: SIMD2<Float>
    public var velocity: SIMD2<Float>
    public var color: SIMD4<Float>
    public var size: Float
    public var lifetime: Float
    public var homePosition: SIMD2<Float>
    
    public init(position: SIMD2<Float>, velocity: SIMD2<Float>, color: SIMD4<Float>, size: Float, homePosition: SIMD2<Float>? = nil) {
        self.position = position
        self.velocity = velocity
        self.color = color
        self.size = size
        self.lifetime = 0
        self.homePosition = homePosition ?? position
    }
}
