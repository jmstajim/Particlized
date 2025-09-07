import SwiftUI
import simd

enum OregonMath {
    static func convertToCentered(_ geo: GeometryProxy, fromGlobal point: CGPoint) -> CGPoint {
        let rect = geo.frame(in: .global)
        let centerX = rect.midX
        let centerY = rect.midY
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

