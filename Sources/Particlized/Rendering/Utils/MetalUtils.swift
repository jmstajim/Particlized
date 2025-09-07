import UIKit
import Metal

func makeClearColor(from color: UIColor) -> MTLClearColor {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    color.getRed(&r, green: &g, blue: &b, alpha: &a)
    return MTLClearColor(red: Double(r), green: Double(g), blue: Double(b), alpha: Double(a))
}
