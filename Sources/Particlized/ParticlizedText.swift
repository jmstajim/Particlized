//
//  ParticlizedText.swift
//
//
//  Created by Aleksei Gusachenko on 28.04.2024.
//

import SpriteKit

public class ParticlizedText: SKEmitterNode {
    public let id: String
    public let text: String
    public let font: UIFont
    public let textColor: UIColor
    public let emitterNode: SKEmitterNode
    public let density: Int
    public let skipChance: Int
    
    private lazy var queue = DispatchQueue(label: "com.particlized.ParticlizedText.\(id)", qos: .userInteractive)
    
    public init(
        id: String = UUID().uuidString,
        text: String,
        font: UIFont,
        textColor: UIColor,
        emitterNode: SKEmitterNode,
        density: Int = 1,
        skipChance: Int = 0
    ) {
        self.id = id
        self.text = text
        self.font = UIFont(name: font.fontName, size: font.pointSize / UIScreen.main.scale)!
        self.textColor = textColor
        self.emitterNode = emitterNode
        self.density = density < 1 ? 1 : density
        self.skipChance = skipChance
        super.init()
        
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
            
            let bytesPerPixel = (cgImage.bitsPerPixel + 7) / 8
            let bytesPerRow = cgImage.bytesPerRow
            
            for x in 0...Int(textImageWidth) {
                for y in 0...Int(textImageHeight) {
                    let shouldCreateParticle = (x % density == 0) && (y % density == 0) && (Int.random(in: 0...skipChance) == 0)
                    guard shouldCreateParticle else { continue }
                    guard let color = self.pixelColor(data: data, bytesPerPixel: bytesPerPixel, bytesPerRow: bytesPerRow, x: x, y: y)
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
            NSAttributedString.Key.foregroundColor: textColor
        ]
        let attributeString = NSAttributedString(string: text, attributes: fontAttributes)
        let textSize = attributeString.size()
        let textRect = CGRect.init(origin: .zero, size: textSize)
        
        let renderer = UIGraphicsImageRenderer(bounds: textRect)
        let image = renderer.image { context in
            attributeString.draw(with: textRect, options: [
                .usesLineFragmentOrigin
            ], context: nil)
        }
        return image
    }
    
    @inline(__always) private func pixelColor(data: UnsafePointer<UInt8>, bytesPerPixel: Int, bytesPerRow: Int, x: Int, y: Int) -> UIColor? {
        let pixelByteOffset: Int = (bytesPerPixel * x) + (bytesPerRow * y)
        let a = CGFloat(data[pixelByteOffset+3]) / CGFloat(255.0)
        guard a > 0 else { return nil }
        let r = CGFloat(data[pixelByteOffset+2]) / CGFloat(255.0)
        let g = CGFloat(data[pixelByteOffset+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelByteOffset]) / CGFloat(255.0)
        return UIColor(ciColor: .init(red: r, green: g, blue: b, alpha: a))
    }
    
    @inline(__always) private func createPaticle(x: CGFloat, y: CGFloat, color: UIColor) {
        let emitterNode = emitterNode.copy() as! SKEmitterNode
        emitterNode.particleColor = color
        emitterNode.particleColorSequence = nil
        emitterNode.position = CGPoint(x: x, y: y)
        DispatchQueue.main.async {
            self.addChild(emitterNode)
        }
    }
    
    public override var position: CGPoint {
        get { super.position }
        set { super.position = newValue }
    }
}