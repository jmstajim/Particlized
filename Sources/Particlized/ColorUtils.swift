import UIKit
import CoreGraphics

@inline(__always)
func colorToVec4(_ color: UIColor) -> SIMD4<Float> {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
        return SIMD4<Float>(Float(r), Float(g), Float(b), Float(a))
    }
    var white: CGFloat = 0
    if color.getWhite(&white, alpha: &a) {
        let v = Float(white)
        return SIMD4<Float>(v, v, v, Float(a))
    }
    return SIMD4<Float>(1, 0, 0, 1)
}

/// Draws a CGImage into a normalized BGRA8888 buffer (byte order 32-bit little-endian, premultiplied first).
/// Returns the raw bytes (length = height * bytesPerRow), plus image metrics.
func makeNormalizedBGRABuffer(from cgImage: CGImage) -> (data: Data, width: Int, height: Int, bytesPerRow: Int)? {
    let width = cgImage.width
    let height = cgImage.height
    guard width > 0, height > 0 else { return nil }
    
    let bitsPerComponent = 8
    let bytesPerPixel = 4
    let bytesPerRow = width * bytesPerPixel
    var data = Data(count: height * bytesPerRow)
    
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
    
    let success = data.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) -> Bool in
        guard let base = ptr.baseAddress else { return false }
        guard let ctx = CGContext(
            data: base,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return false }
        
        ctx.interpolationQuality = .high
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return true
    }
    
    guard success else { return nil }
    return (data, width, height, bytesPerRow)
}
