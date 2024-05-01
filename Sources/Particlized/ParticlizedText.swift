//
//  ParticlizedText.swift
//
//
//  Created by Aleksei Gusachenko on 28.04.2024.
//

import SpriteKit

public class ParticlizedText: Particlized {
    public let id: String
    public let text: String
    public let font: UIFont
    public let textColor: UIColor?
    public let density: Int
    public let skipChance: Int
    
    private lazy var queue = DispatchQueue(label: "com.particlized.ParticlizedText.\(id)", qos: .userInteractive)
    
    public init(
        id: String = UUID().uuidString,
        text: String,
        font: UIFont,
        textColor: UIColor?,
        emitterNode: SKEmitterNode,
        density: Int = 1,
        skipChance: Int = 0
    ) {
        self.id = id
        self.text = text
        self.font = UIFont(name: font.fontName, size: font.pointSize / UIScreen.main.scale)!
        self.textColor = textColor
        self.density = density < 1 ? 1 : density
        self.skipChance = skipChance
        super.init(emitterNode: emitterNode)
        
        createParticles()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createParticles() {
        queue.async { [weak self] in
            guard let self else { return }
            let textImage = makeImageFromText()
            guard
                let cgImage = textImage.cgImage,
                let pixelData = cgImage.dataProvider?.data,
                let data = CFDataGetBytePtr(pixelData)
            else { return }
            let textImageWidth = cgImage.width
            let textImageHeight = cgImage.height
            
            let halfTextImageWidth = textImageWidth / 2
            let halfTextImageHeight = textImageHeight / 2
            
            let bytesPerPixel = cgImage.bitsPerPixel / 8
            let bytesPerRow = cgImage.bytesPerRow
            
            // TODO: I don’t understand why the offset changes depending on whether the text contains emoji and number or not
            let containsEmojiOrNumber =
            text.unicodeScalars.contains(where: { $0.properties.isEmoji })
            && !text.contains(where: { $0.isNumber })
            
            let redOffset = containsEmojiOrNumber ? 2 : 0
            let blueOffset = containsEmojiOrNumber ? 0 : 2
            
            for x in 0..<Int(textImageWidth) {
                for y in 0..<Int(textImageHeight) {
                    
                    let shouldCreateParticle = (x % density == 0) && (y % density == 0) && (Int.random(in: 0...skipChance) == 0)
                    guard shouldCreateParticle else { continue }
                    
                    guard let color = self.pixelColor(data: data, bytesPerPixel: bytesPerPixel, bytesPerRow: bytesPerRow, x: x, y: y, redOffset: redOffset, blueOffset: blueOffset)
                    else { continue }
                    
                    self.createPaticle(
                        x: CGFloat(x) - CGFloat(halfTextImageWidth),
                        y: CGFloat(-y) + CGFloat(halfTextImageHeight),
                        color: color
                    )
                }
            }
        }
    }
    
    private func makeImageFromText() -> UIImage {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let fontAttributes = [
            NSAttributedString.Key.font: self.font,
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: textColor ?? .red
        ]
        let attributeString = NSAttributedString(string: text, attributes: fontAttributes)
        let textSize = attributeString.size()
        let textRect = CGRect(origin: .zero, size: textSize)
        
        let renderer = UIGraphicsImageRenderer(bounds: textRect)
        let image = renderer.image { context in
            attributeString.draw(with: textRect, options: [
                .usesLineFragmentOrigin
            ], context: nil)
        }
        return image
    }
    
    @inline(__always) private func pixelColor(data: UnsafePointer<UInt8>, bytesPerPixel: Int, bytesPerRow: Int, x: Int, y: Int, redOffset: Int, blueOffset: Int) -> UIColor? {
        let pixelByteOffset: Int = (bytesPerPixel * x) + (bytesPerRow * y)
        let a = CGFloat(data[pixelByteOffset + 3]) / CGFloat(255.0)
        guard a > 0 else { return nil }
        let r = CGFloat(data[pixelByteOffset + redOffset]) / CGFloat(255.0)
        let g = CGFloat(data[pixelByteOffset + 1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelByteOffset + blueOffset]) / CGFloat(255.0)
        return UIColor(ciColor: .init(red: r, green: g, blue: b, alpha: a))
    }
    
    @inline(__always) private func createPaticle(x: CGFloat, y: CGFloat, color: UIColor) {
        let emitterNode = emitterNode.copy() as! SKEmitterNode
        if textColor != nil {
            emitterNode.particleColor = color
            emitterNode.particleColorSequence = nil
        } else {
            emitterNode.particleColor = color
        }
        emitterNode.position = CGPoint(x: x, y: y)
        DispatchQueue.main.async {
            self.addChild(emitterNode)
        }
    }
}
