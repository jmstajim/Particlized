//
//  ParticlizedText.swift
//
//  Created by Aleksei Gusachenko on 28.04.2024.
//

import UIKit

/// Turn text and emoji into particles (Metal backed)
public final class ParticlizedText {
    public let text: String
    public let font: UIFont
    /// Optional tint. If provided, monochrome glyphs (mask-only) will be tinted,
    /// but already-colored pixels (emoji/colored glyphs) will keep their original colors.
    public let textColor: UIColor?

    public let numberOfPixelsPerNode: Int
    public let nodeSkipPercentageChance: UInt8
    public let isEmittingOnStart: Bool

    public private(set) var particles: [Particle] = []

    public init(
        id: String = UUID().uuidString,
        text: String,
        font: UIFont,
        textColor: UIColor? = nil,
        numberOfPixelsPerNode: Int = 1,
        nodeSkipPercentageChance: UInt8 = 0,
        isEmittingOnStart: Bool = true
    ) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.numberOfPixelsPerNode = max(1, numberOfPixelsPerNode)
        self.nodeSkipPercentageChance = nodeSkipPercentageChance
        self.isEmittingOnStart = isEmittingOnStart
        self.particles = Self.buildParticles(
            text: text,
            font: self.font,
            tintColor: textColor,
            pixelStride: self.numberOfPixelsPerNode,
            skipChance: self.nodeSkipPercentageChance,
            isEmitting: isEmittingOnStart
        )
    }

    private static func buildParticles(
        text: String,
        font: UIFont,
        tintColor: UIColor?,
        pixelStride: Int,
        skipChance: UInt8,
        isEmitting: Bool
    ) -> [Particle] {
        let image = render(text: text, font: font) // render WITHOUT foreground tint
        guard let cgImage = image.cgImage,
              let buf = makeNormalizedBGRABuffer(from: cgImage) else { return [] }

        let width = buf.width
        let height = buf.height
        let bytesPerRow = buf.bytesPerRow

        let halfW = Float(width) / 2
        let halfH = Float(height) / 2

        var tintVec: SIMD4<Float>? = nil
        if let tintColor { tintVec = colorToVec4(tintColor) }

        var result: [Particle] = []
        result.reserveCapacity((width * height) / max(1, (pixelStride * pixelStride)))

        buf.data.withUnsafeBytes { (rawPtr: UnsafeRawBufferPointer) in
            let ptr = rawPtr.bindMemory(to: UInt8.self).baseAddress!

            for x in Swift.stride(from: 0, to: width, by: pixelStride) {
                for y in Swift.stride(from: 0, to: height, by: pixelStride) {
                    if Int.random(in: 0..<100) < Int(skipChance) { continue }
                    let off = x * 4 + y * bytesPerRow

                    // BGRA8888
                    let b = Float(ptr[off + 0]) / 255.0
                    let g = Float(ptr[off + 1]) / 255.0
                    let r = Float(ptr[off + 2]) / 255.0
                    let a = Float(ptr[off + 3]) / 255.0
                    if a <= 0 { continue }

                    let rgbSum = r + g + b
                    var outR = r, outG = g, outB = b, outA = a

                    if rgbSum <= 1e-5, let t = tintVec {
                        // Monochrome mask pixel: apply tint color, preserve alpha.
                        outR = t.x
                        outG = t.y
                        outB = t.z
                        outA = min(1.0, a * t.w)
                    } else if let t = tintVec {
                        // Already-colored pixel (emoji, colored glyph) -> keep color, optionally modulate by tint alpha only.
                        outA = min(1.0, a * max(t.w, 1e-6))
                    }

                    let px = Float(x) - halfW
                    let py = -(Float(y) - halfH)
                    let colorVec = SIMD4<Float>(outR, outG, outB, isEmitting ? outA : 0)
                    result.append(Particle(position: .init(px, py), velocity: .zero, color: colorVec, size: 2, homePosition: .init(px, py)))
                }
            }
        }
        return result
    }

    private static func render(text: String, font: UIFont) -> UIImage {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraph
        ]

        let attr = NSAttributedString(string: text, attributes: attrs)
        let size = attr.size()
        let bounds = CGRect(origin: .zero, size: size)
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        format.preferredRange = .standard // sRGB
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
        return renderer.image { _ in
            UIColor.clear.setFill()
            UIBezierPath(rect: bounds).fill()
            attr.draw(with: bounds, options: [.usesLineFragmentOrigin], context: nil)
        }
    }
}
