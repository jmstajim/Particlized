import UIKit

/// Turn image into particles (Metal backed)
public final class ParticlizedImage {
    public let id: String
    public let image: UIImage
    public let numberOfPixelsPerNode: Int
    public let nodeSkipPercentageChance: UInt8
    
    public private(set) var particles: [Particle] = []
    
    public init(
        id: String = UUID().uuidString,
        image: UIImage,
        numberOfPixelsPerNode: Int = 1,
        nodeSkipPercentageChance: UInt8 = 0
    ) {
        self.id = id
        self.image = image
        self.numberOfPixelsPerNode = max(1, numberOfPixelsPerNode)
        self.nodeSkipPercentageChance = nodeSkipPercentageChance
        self.particles = Self.buildParticles(
            image: image,
            pixelStride: self.numberOfPixelsPerNode,
            skipChance: self.nodeSkipPercentageChance
        )
    }
    
    private static func wangHash(_ v: UInt32) -> UInt32 {
        var x = v &* 0x27d4eb2d
        x ^= x >> 15
        x &*= 0x85ebca6b
        x ^= x >> 13
        x &*= 0xc2b2ae35
        x ^= x >> 16
        return x
    }

    private static func shouldSkip(x: Int, y: Int, thresholdPercent: UInt8) -> Bool {
        let v = UInt32((x & 0xffff) << 16) ^ UInt32(y & 0xffff)
        let h = Self.wangHash(v)
        let r = UInt8(truncatingIfNeeded: h & 0xff) % 100
        return r < thresholdPercent
    }
    
    private static func buildParticles(
        image: UIImage,
        pixelStride: Int,
        skipChance: UInt8,
    ) -> [Particle] {
        guard let cgImage = image.cgImage,
              let buf = makeNormalizedBGRABuffer(from: cgImage) else { return [] }
        
        let width = buf.width
        let height = buf.height
        let bytesPerRow = buf.bytesPerRow
        
        let halfW = Float(width) / 2
        let halfH = Float(height) / 2
        
        var result: [Particle] = []
        result.reserveCapacity((width * height) / max(1, (pixelStride * pixelStride)))
        
        buf.data.withUnsafeBytes { (rawPtr: UnsafeRawBufferPointer) in
            let ptr = rawPtr.bindMemory(to: UInt8.self).baseAddress!
            
            // Buffer is BGRA8888 by construction. Sample in BGRA order.
            for x in Swift.stride(from: 0, to: width, by: pixelStride) {
                for y in Swift.stride(from: 0, to: height, by: pixelStride) {
                    if Self.shouldSkip(x: x, y: y, thresholdPercent: skipChance) { continue }
                    let off = x * 4 + y * bytesPerRow
                    let b = Float(ptr[off + 0]) / 255.0
                    let g = Float(ptr[off + 1]) / 255.0
                    let r = Float(ptr[off + 2]) / 255.0
                    let a = Float(ptr[off + 3]) / 255.0
                    if a <= 0 { continue }
                    
                    let color = SIMD4<Float>(r, g, b, a)
                    let px = Float(x) - halfW
                    let py = -(Float(y) - halfH)
                    result.append(Particle(position: .init(px, py), velocity: .zero, color: color, size: 2, homePosition: .init(px, py)))
                }
            }
        }
        return result
    }
}
