//
//  Particlized.swift
//
//
//  Created by Aleksei Gusachenko on 30.04.2024.
//

import SpriteKit

public class Particlized: SKEmitterNode {
    
    public let emitterNode: SKEmitterNode
    
    public init(emitterNode: SKEmitterNode) {
        self.emitterNode = emitterNode
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SKEmitterNode overrides
    
    
    public override func advanceSimulationTime(_ sec: TimeInterval) {
        children.forEach { node in
            (node as? SKEmitterNode)?.advanceSimulationTime(sec)
        }
    }
    
    public override func resetSimulation() {
        children.forEach { node in
            (node as? SKEmitterNode)?.resetSimulation()
        }
    }
    
    public override var particleTexture: SKTexture? {
        get { emitterNode.particleTexture }
        set {
            emitterNode.particleTexture = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleTexture = newValue
            }
        }
    }
    
    public override var particleBlendMode: SKBlendMode {
        get { emitterNode.particleBlendMode }
        set {
            emitterNode.particleBlendMode = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleBlendMode = newValue
            }
        }
    }
    
    public override var particleColor: UIColor {
        get { emitterNode.particleColor }
        set {
            self.particleColor = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleColor = newValue
            }
        }
    }
    
    public override var particleColorRedRange: CGFloat {
        get { emitterNode.particleColorRedRange }
        set {
            emitterNode.particleColorRedRange = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleColorRedRange = newValue
            }
        }
    }
    
    public override var particleColorGreenRange: CGFloat {
        get { emitterNode.particleColorGreenRange }
        set {
            emitterNode.particleColorGreenRange = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleColorGreenRange = newValue
            }
        }
    }
    
    public override var particleColorBlueRange: CGFloat {
        get { emitterNode.particleColorBlueRange }
        set {
            emitterNode.particleColorBlueRange = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleColorBlueRange = newValue
            }
        }
    }
    
    public override var particleColorAlphaRange: CGFloat {
        get { emitterNode.particleColorAlphaRange }
        set {
            emitterNode.particleColorAlphaRange = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleColorAlphaRange = newValue
            }
        }
    }
    
    public override var particleColorRedSpeed: CGFloat {
        get { emitterNode.particleColorRedSpeed }
        set {
            emitterNode.particleColorRedSpeed = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleColorRedSpeed = newValue
            }
        }
    }
    
    public override var particleColorGreenSpeed: CGFloat {
        get { emitterNode.particleColorGreenSpeed }
        set {
            emitterNode.particleColorGreenSpeed = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleColorGreenSpeed = newValue
            }
        }
    }
    
    public override var particleColorBlueSpeed: CGFloat {
        get { emitterNode.particleColorBlueSpeed }
        set {
            emitterNode.particleColorBlueSpeed = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleColorBlueSpeed = newValue
            }
        }
    }
    
    public override var particleColorAlphaSpeed: CGFloat {
        get { emitterNode.particleColorAlphaSpeed }
        set {
            emitterNode.particleColorAlphaSpeed = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleColorAlphaSpeed = newValue
            }
        }
    }
    
    public override var particleColorSequence: SKKeyframeSequence? {
        get { emitterNode.particleColorSequence }
        set {
            emitterNode.particleColorSequence = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleColorSequence = newValue
            }
        }
    }
    
    public override var particleColorBlendFactor: CGFloat {
        get { emitterNode.particleColorBlendFactor }
        set {
            emitterNode.particleColorBlendFactor = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleColorBlendFactor = newValue
            }
        }
    }
    
    public override var particleColorBlendFactorRange: CGFloat {
        get { emitterNode.particleColorBlendFactorRange }
        set {
            emitterNode.particleColorBlendFactorRange = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleColorBlendFactorRange = newValue
            }
        }
    }
    
    public override var particleColorBlendFactorSpeed: CGFloat {
        get { emitterNode.particleColorBlendFactorSpeed }
        set {
            emitterNode.particleColorBlendFactorSpeed = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleColorBlendFactorSpeed = newValue
            }
        }
    }
    
    public override var particleColorBlendFactorSequence: SKKeyframeSequence? {
        get { emitterNode.particleColorBlendFactorSequence }
        set {
            emitterNode.particleColorBlendFactorSequence = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleColorBlendFactorSequence = newValue
            }
        }
    }
    
    public override var particlePosition: CGPoint {
        get { emitterNode.particlePosition }
        set {
            emitterNode.particlePosition = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particlePosition = newValue
            }
        }
    }
    
    public override var particlePositionRange: CGVector {
        get { emitterNode.particlePositionRange }
        set {
            emitterNode.particlePositionRange = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particlePositionRange = newValue
            }
        }
    }
    
    public override var particleSpeed: CGFloat {
        get { emitterNode.particleSpeed }
        set {
            emitterNode.particleSpeed = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleSpeed = newValue
            }
        }
    }
    
    public override var particleSpeedRange: CGFloat {
        get { emitterNode.particleSpeedRange }
        set {
            emitterNode.particleSpeedRange = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleSpeedRange = newValue
            }
        }
    }
    
    public override var emissionAngle: CGFloat {
        get { emitterNode.emissionAngle }
        set {
            emitterNode.emissionAngle = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.emissionAngle = newValue
            }
        }
    }
    
    public override var emissionAngleRange: CGFloat {
        get { emitterNode.emissionAngleRange }
        set {
            emitterNode.emissionAngleRange = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.emissionAngleRange = newValue
            }
        }
    }
    
    public override var xAcceleration: CGFloat {
        get { emitterNode.xAcceleration }
        set {
            emitterNode.xAcceleration = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.xAcceleration = newValue
            }
        }
    }
    
    public override var yAcceleration: CGFloat {
        get { emitterNode.yAcceleration }
        set {
            emitterNode.yAcceleration = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.yAcceleration = newValue
            }
        }
    }
    
    public override var particleBirthRate: CGFloat {
        get { emitterNode.particleBirthRate }
        set {
            emitterNode.particleBirthRate = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleBirthRate = newValue
            }
        }
    }
    
    public override var numParticlesToEmit: Int {
        get { emitterNode.numParticlesToEmit }
        set {
            emitterNode.numParticlesToEmit = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.numParticlesToEmit = newValue
            }
        }
    }
    
    public override var particleLifetime: CGFloat {
        get { emitterNode.particleLifetime }
        set {
            emitterNode.particleLifetime = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleLifetime = newValue
            }
        }
    }
    
    public override var particleLifetimeRange: CGFloat {
        get { emitterNode.particleLifetimeRange }
        set {
            emitterNode.particleLifetimeRange = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleLifetimeRange = newValue
            }
        }
    }
    
    public override var particleRotation: CGFloat {
        get { emitterNode.particleRotation }
        set {
            emitterNode.particleRotation = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleRotation = newValue
            }
        }
    }
    
    public override var particleRotationRange: CGFloat {
        get { emitterNode.particleRotationRange }
        set {
            emitterNode.particleRotationRange = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleRotationRange = newValue
            }
        }
    }
    
    public override var particleRotationSpeed: CGFloat {
        get { emitterNode.particleRotationSpeed }
        set {
            emitterNode.particleRotationSpeed = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleRotationSpeed = newValue
            }
        }
    }
    
    public override var particleSize: CGSize {
        get { emitterNode.particleSize }
        set {
            emitterNode.particleSize = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleSize = newValue
            }
        }
    }
    
    public override var particleScale: CGFloat {
        get { emitterNode.particleScale }
        set {
            emitterNode.particleScale = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleScale = newValue
            }
        }
    }
    
    public override var particleScaleRange: CGFloat {
        get { emitterNode.particleScaleRange }
        set {
            emitterNode.particleScaleRange = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleScaleRange = newValue
            }
        }
    }
    
    public override var particleScaleSpeed: CGFloat {
        get { emitterNode.particleScaleSpeed }
        set {
            emitterNode.particleScaleSpeed = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleScaleSpeed = newValue
            }
        }
    }
    
    public override var particleScaleSequence: SKKeyframeSequence? {
        get { emitterNode.particleScaleSequence }
        set {
            emitterNode.particleScaleSequence = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleScaleSequence = newValue
            }
        }
    }
    
    public override var particleAlpha: CGFloat {
        get { emitterNode.particleAlpha }
        set {
            emitterNode.particleAlpha = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleAlpha = newValue
            }
        }
    }
    
    public override var particleAlphaRange: CGFloat {
        get { emitterNode.particleAlphaRange }
        set {
            emitterNode.particleAlphaRange = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleAlphaRange = newValue
            }
        }
    }
    
    public override var particleAlphaSpeed: CGFloat {
        get { emitterNode.particleAlphaSpeed }
        set {
            emitterNode.particleAlphaSpeed = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleAlphaSpeed = newValue
            }
        }
    }
    
    
    public override var particleAlphaSequence: SKKeyframeSequence? {
        get { emitterNode.particleAlphaSequence }
        set {
            emitterNode.particleAlphaSequence = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleAlphaSequence = newValue
            }
        }
    }
    
    public override var fieldBitMask: UInt32 {
        get { emitterNode.fieldBitMask }
        set {
            emitterNode.fieldBitMask = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.fieldBitMask = newValue
            }
        }
    }
    
    public override var shader: SKShader? {
        get { emitterNode.shader }
        set {
            emitterNode.shader = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.shader = newValue
            }
        }
    }
    
    public override var particleZPosition: CGFloat {
        get { emitterNode.particleZPosition }
        set {
            emitterNode.particleZPosition = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleZPosition = newValue
            }
        }
    }
    
    @available(iOS 9.0, *)
    public override var particleRenderOrder: SKParticleRenderOrder {
        get { emitterNode.particleRenderOrder }
        set {
            emitterNode.particleRenderOrder = newValue
            children.forEach { node in
                (node as? SKEmitterNode)?.particleRenderOrder = newValue
            }
        }
    }
}
