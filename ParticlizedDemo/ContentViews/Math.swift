import SwiftUI
import simd

enum Math {
    static func convertToCentered(_ geo: GeometryProxy, fromLocal point: CGPoint) -> CGPoint {
        let size = geo.size
        let centerX = size.width * 0.5
        let centerY = size.height * 0.5
        let scale = UIScreen.main.scale
        let xpx = (point.x - centerX) * scale
        let ypx = (centerY - point.y) * scale
        return CGPoint(x: xpx, y: ypx)
    }
    
    static func updateVectorFromAngle(_ angleDeg: Double) -> SIMD2<Float> {
        let rad = angleDeg * .pi / 180.0
        return SIMD2<Float>(Float(cos(rad)), Float(sin(rad)))
    }
}

