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
        DispatchQueue.main.async {
            self.children.forEach { node in
                (node as? SKEmitterNode)?.advanceSimulationTime(sec)
            }
        }
    }
    
    public override func resetSimulation() {
        DispatchQueue.main.async {
            self.children.forEach { node in
                (node as? SKEmitterNode)?.resetSimulation()
            }
        }
    }
    
    public override var particleTexture: SKTexture? {
        get { emitterNode.particleTexture }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleTexture = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleTexture = newValue
                }
            }
        }
    }
    
    public override var particleBlendMode: SKBlendMode {
        get { emitterNode.particleBlendMode }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleBlendMode = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleBlendMode = newValue
                }
            }
        }
    }
    
    public override var particleColor: UIColor {
        get { emitterNode.particleColor }
        set {
            DispatchQueue.main.async {
                self.particleColor = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColor = newValue
                }
            }
        }
    }
    
    public override var particleColorRedRange: CGFloat {
        get { emitterNode.particleColorRedRange }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleColorRedRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorRedRange = newValue
                }
            }
        }
    }
    
    public override var particleColorGreenRange: CGFloat {
        get { emitterNode.particleColorGreenRange }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleColorGreenRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorGreenRange = newValue
                }
            }
        }
    }
    
    public override var particleColorBlueRange: CGFloat {
        get { emitterNode.particleColorBlueRange }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleColorBlueRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorBlueRange = newValue
                }
            }
        }
    }
    
    public override var particleColorAlphaRange: CGFloat {
        get { emitterNode.particleColorAlphaRange }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleColorAlphaRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorAlphaRange = newValue
                }
            }
        }
    }
    
    public override var particleColorRedSpeed: CGFloat {
        get { emitterNode.particleColorRedSpeed }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleColorRedSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorRedSpeed = newValue
                }
            }
        }
    }
    
    public override var particleColorGreenSpeed: CGFloat {
        get { emitterNode.particleColorGreenSpeed }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleColorGreenSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorGreenSpeed = newValue
                }
            }
        }
    }
    
    public override var particleColorBlueSpeed: CGFloat {
        get { emitterNode.particleColorBlueSpeed }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleColorBlueSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorBlueSpeed = newValue
                }
            }
        }
    }
    
    public override var particleColorAlphaSpeed: CGFloat {
        get { emitterNode.particleColorAlphaSpeed }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleColorAlphaSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorAlphaSpeed = newValue
                }
            }
        }
    }
    
    public override var particleColorSequence: SKKeyframeSequence? {
        get { emitterNode.particleColorSequence }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleColorSequence = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorSequence = newValue
                }
            }
        }
    }
    
    public override var particleColorBlendFactor: CGFloat {
        get { emitterNode.particleColorBlendFactor }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleColorBlendFactor = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorBlendFactor = newValue
                }
            }
        }
    }
    
    public override var particleColorBlendFactorRange: CGFloat {
        get { emitterNode.particleColorBlendFactorRange }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleColorBlendFactorRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorBlendFactorRange = newValue
                }
            }
        }
    }
    
    public override var particleColorBlendFactorSpeed: CGFloat {
        get { emitterNode.particleColorBlendFactorSpeed }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleColorBlendFactorSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorBlendFactorSpeed = newValue
                }
            }
        }
    }
    
    public override var particleColorBlendFactorSequence: SKKeyframeSequence? {
        get { emitterNode.particleColorBlendFactorSequence }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleColorBlendFactorSequence = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorBlendFactorSequence = newValue
                }
            }
        }
    }
    
    public override var particlePosition: CGPoint {
        get { emitterNode.particlePosition }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particlePosition = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particlePosition = newValue
                }
            }
        }
    }
    
    public override var particlePositionRange: CGVector {
        get { emitterNode.particlePositionRange }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particlePositionRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particlePositionRange = newValue
                }
            }
        }
    }
    
    public override var particleSpeed: CGFloat {
        get { emitterNode.particleSpeed }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleSpeed = newValue
                }
            }
        }
    }
    
    public override var particleSpeedRange: CGFloat {
        get { emitterNode.particleSpeedRange }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleSpeedRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleSpeedRange = newValue
                }
            }
        }
    }
    
    public override var emissionAngle: CGFloat {
        get { emitterNode.emissionAngle }
        set {
            DispatchQueue.main.async {
                self.emitterNode.emissionAngle = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.emissionAngle = newValue
                }
            }
        }
    }
    
    public override var emissionAngleRange: CGFloat {
        get { emitterNode.emissionAngleRange }
        set {
            DispatchQueue.main.async {
                self.emitterNode.emissionAngleRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.emissionAngleRange = newValue
                }
            }
        }
    }
    
    public override var xAcceleration: CGFloat {
        get { emitterNode.xAcceleration }
        set {
            DispatchQueue.main.async {
                self.emitterNode.xAcceleration = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.xAcceleration = newValue
                }
            }
        }
    }
    
    public override var yAcceleration: CGFloat {
        get { emitterNode.yAcceleration }
        set {
            DispatchQueue.main.async {
                self.emitterNode.yAcceleration = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.yAcceleration = newValue
                }
            }
        }
    }
    
    public override var particleBirthRate: CGFloat {
        get { emitterNode.particleBirthRate }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleBirthRate = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleBirthRate = newValue
                }
            }
        }
    }
    
    public override var numParticlesToEmit: Int {
        get { emitterNode.numParticlesToEmit }
        set {
            DispatchQueue.main.async {
                self.emitterNode.numParticlesToEmit = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.numParticlesToEmit = newValue
                }
            }
        }
    }
    
    public override var particleLifetime: CGFloat {
        get { emitterNode.particleLifetime }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleLifetime = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleLifetime = newValue
                }
            }
        }
    }
    
    public override var particleLifetimeRange: CGFloat {
        get { emitterNode.particleLifetimeRange }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleLifetimeRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleLifetimeRange = newValue
                }
            }
        }
    }
    
    public override var particleRotation: CGFloat {
        get { emitterNode.particleRotation }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleRotation = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleRotation = newValue
                }
            }
        }
    }
    
    public override var particleRotationRange: CGFloat {
        get { emitterNode.particleRotationRange }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleRotationRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleRotationRange = newValue
                }
            }
        }
    }
    
    public override var particleRotationSpeed: CGFloat {
        get { emitterNode.particleRotationSpeed }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleRotationSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleRotationSpeed = newValue
                }
            }
        }
    }
    
    public override var particleSize: CGSize {
        get { emitterNode.particleSize }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleSize = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleSize = newValue
                }
            }
        }
    }
    
    public override var particleScale: CGFloat {
        get { emitterNode.particleScale }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleScale = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleScale = newValue
                }
            }
        }
    }
    
    public override var particleScaleRange: CGFloat {
        get { emitterNode.particleScaleRange }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleScaleRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleScaleRange = newValue
                }
            }
        }
    }
    
    public override var particleScaleSpeed: CGFloat {
        get { emitterNode.particleScaleSpeed }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleScaleSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleScaleSpeed = newValue
                }
            }
        }
    }
    
    public override var particleScaleSequence: SKKeyframeSequence? {
        get { emitterNode.particleScaleSequence }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleScaleSequence = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleScaleSequence = newValue
                }
            }
        }
    }
    
    public override var particleAlpha: CGFloat {
        get { emitterNode.particleAlpha }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleAlpha = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleAlpha = newValue
                }
            }
        }
    }
    
    public override var particleAlphaRange: CGFloat {
        get { emitterNode.particleAlphaRange }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleAlphaRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleAlphaRange = newValue
                }
            }
        }
    }
    
    public override var particleAlphaSpeed: CGFloat {
        get { emitterNode.particleAlphaSpeed }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleAlphaSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleAlphaSpeed = newValue
                }
            }
        }
    }
    
    
    public override var particleAlphaSequence: SKKeyframeSequence? {
        get { emitterNode.particleAlphaSequence }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleAlphaSequence = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleAlphaSequence = newValue
                }
            }
        }
    }
    
    public override var fieldBitMask: UInt32 {
        get { emitterNode.fieldBitMask }
        set {
            DispatchQueue.main.async {
                self.emitterNode.fieldBitMask = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.fieldBitMask = newValue
                }
            }
        }
    }
    
    public override var shader: SKShader? {
        get { emitterNode.shader }
        set {
            DispatchQueue.main.async {
                self.emitterNode.shader = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.shader = newValue
                }
            }
        }
    }
    
    public override var particleZPosition: CGFloat {
        get { emitterNode.particleZPosition }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleZPosition = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleZPosition = newValue
                }
            }
        }
    }
    
    @available(iOS 9.0, *)
    public override var particleRenderOrder: SKParticleRenderOrder {
        get { emitterNode.particleRenderOrder }
        set {
            DispatchQueue.main.async {
                self.emitterNode.particleRenderOrder = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleRenderOrder = newValue
                }
            }
        }
    }
}
