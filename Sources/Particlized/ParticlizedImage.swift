//
//  ParticlizeImage.swift
//
//
//  Created by Aleksei Gusachenko on 28.04.2024.
//

import SpriteKit

/// Turn image into particles
public final class ParticlizedImage: Particlized {
    
    /// Original image
    public let image: UIImage
    
    public init(
        id: String = UUID().uuidString,
        image: UIImage,
        emitterNode: SKEmitterNode,
        numberOfPixelsPerNode: Int = 1,
        nodeSkipPercentageChance: UInt8 = 0,
        isEmittingOnStart: Bool = true
    ) {
        self.image = image
        super.init(
            id: id,
            emitterNode: emitterNode,
            numberOfPixelsPerNode: numberOfPixelsPerNode,
            nodeSkipPercentageChance: nodeSkipPercentageChance,
            isEmittingOnStart: isEmittingOnStart
        )
        
        queue.async {
            self.createParticles()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createParticles() {
        guard
            let cgImage = image.cgImage,
            let pixelData = cgImage.dataProvider?.data,
            let data = CFDataGetBytePtr(pixelData)
        else { return }
        let textImageWidth = cgImage.width
        let textImageHeight = cgImage.height
        
        let halfTextImageWidth = textImageWidth / 2
        let halfTextImageHeight = textImageHeight / 2
        
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow
        
        for x in 0..<Int(textImageWidth) {
            for y in 0..<Int(textImageHeight) {
                
                let shouldCreateParticle = (x % numberOfPixelsPerNode == 0) 
                && (y % numberOfPixelsPerNode == 0)
                && Int.random(in: 0..<100) > nodeSkipPercentageChance
                
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
    
    @inline(__always) private func pixelColor(
        data: UnsafePointer<UInt8>,
        bytesPerPixel: Int,
        bytesPerRow: Int,
        x: Int,
        y: Int
    ) -> UIColor? {
        let pixelByteOffset: Int = (bytesPerPixel * x) + (bytesPerRow * y)
        let a = CGFloat(data[pixelByteOffset+3]) / CGFloat(255.0)
        guard a > 0 else { return nil }
        let r = CGFloat(data[pixelByteOffset]) / CGFloat(255.0)
        let g = CGFloat(data[pixelByteOffset+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelByteOffset+2]) / CGFloat(255.0)
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
}
