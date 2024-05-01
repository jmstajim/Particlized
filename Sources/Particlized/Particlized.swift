//
//  Particlized.swift
//
//
//  Created by Aleksei Gusachenko on 30.04.2024.
//

import SpriteKit

public class Particlized: SKEmitterNode {
    
    public let id: String
    public let emitterNode: SKEmitterNode
    
    public lazy var queue = DispatchQueue(label: "com.particlized.\(id)", qos: .userInteractive)
    
    public init(id: String, emitterNode: SKEmitterNode) {
        self.id = id
        self.emitterNode = emitterNode
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var isEmitting: Bool {
        get {
            queue.sync {
                guard let node = self.children.last as? SKEmitterNode else { return false }
                return node.particleBirthRate != 0
            }
        }
        set {
            queue.async {
                if newValue {
                    self.startEmitting()
                } else {
                    self.stopEmitting()
                }
            }
        }
    }
    
    public func startEmitting() {
        queue.async {
            self.children.forEach { node in
                (node as? SKEmitterNode)?.particleBirthRate = self.emitterNode.particleBirthRate
            }
        }
    }
    
    public func stopEmitting() {
        queue.async {
            self.children.forEach { node in
                (node as? SKEmitterNode)?.particleBirthRate = 0
            }
        }
    }
    
    // MARK: - SKEmitterNode overrides
    
    public override func advanceSimulationTime(_ sec: TimeInterval) {
        queue.async {
            self.children.forEach { node in
                (node as? SKEmitterNode)?.advanceSimulationTime(sec)
            }
        }
    }
    
    public override func resetSimulation() {
        queue.async {
            self.children.forEach { node in
                (node as? SKEmitterNode)?.resetSimulation()
            }
        }
    }
    
    public override var particleTexture: SKTexture? {
        get { queue.sync { emitterNode.particleTexture } }
        set {
            queue.async {
                self.emitterNode.particleTexture = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleTexture = newValue
                }
            }
        }
    }
    
    public override var particleBlendMode: SKBlendMode {
        get { queue.sync { emitterNode.particleBlendMode } }
        set {
            queue.async {
                self.emitterNode.particleBlendMode = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleBlendMode = newValue
                }
            }
        }
    }
    
    public override var particleColor: UIColor {
        get { queue.sync { emitterNode.particleColor } }
        set {
            queue.async {
                self.particleColor = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColor = newValue
                }
            }
        }
    }
    
    public override var particleColorRedRange: CGFloat {
        get { queue.sync { emitterNode.particleColorRedRange } }
        set {
            queue.async {
                self.emitterNode.particleColorRedRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorRedRange = newValue
                }
            }
        }
    }
    
    public override var particleColorGreenRange: CGFloat {
        get { queue.sync { emitterNode.particleColorGreenRange } }
        set {
            queue.async {
                self.emitterNode.particleColorGreenRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorGreenRange = newValue
                }
            }
        }
    }
    
    public override var particleColorBlueRange: CGFloat {
        get { queue.sync { emitterNode.particleColorBlueRange } }
        set {
            queue.async {
                self.emitterNode.particleColorBlueRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorBlueRange = newValue
                }
            }
        }
    }
    
    public override var particleColorAlphaRange: CGFloat {
        get { queue.sync { emitterNode.particleColorAlphaRange } }
        set {
            queue.async {
                self.emitterNode.particleColorAlphaRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorAlphaRange = newValue
                }
            }
        }
    }
    
    public override var particleColorRedSpeed: CGFloat {
        get { queue.sync { emitterNode.particleColorRedSpeed } }
        set {
            queue.async {
                self.emitterNode.particleColorRedSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorRedSpeed = newValue
                }
            }
        }
    }
    
    public override var particleColorGreenSpeed: CGFloat {
        get { queue.sync { emitterNode.particleColorGreenSpeed } }
        set {
            queue.async {
                self.emitterNode.particleColorGreenSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorGreenSpeed = newValue
                }
            }
        }
    }
    
    public override var particleColorBlueSpeed: CGFloat {
        get { queue.sync { emitterNode.particleColorBlueSpeed } }
        set {
            queue.async {
                self.emitterNode.particleColorBlueSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorBlueSpeed = newValue
                }
            }
        }
    }
    
    public override var particleColorAlphaSpeed: CGFloat {
        get { queue.sync { emitterNode.particleColorAlphaSpeed } }
        set {
            queue.async {
                self.emitterNode.particleColorAlphaSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorAlphaSpeed = newValue
                }
            }
        }
    }
    
    public override var particleColorSequence: SKKeyframeSequence? {
        get { queue.sync { emitterNode.particleColorSequence } }
        set {
            queue.async {
                self.emitterNode.particleColorSequence = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorSequence = newValue
                }
            }
        }
    }
    
    public override var particleColorBlendFactor: CGFloat {
        get { queue.sync { emitterNode.particleColorBlendFactor } }
        set {
            queue.async {
                self.emitterNode.particleColorBlendFactor = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorBlendFactor = newValue
                }
            }
        }
    }
    
    public override var particleColorBlendFactorRange: CGFloat {
        get { queue.sync { emitterNode.particleColorBlendFactorRange } }
        set {
            queue.async {
                self.emitterNode.particleColorBlendFactorRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorBlendFactorRange = newValue
                }
            }
        }
    }
    
    public override var particleColorBlendFactorSpeed: CGFloat {
        get { queue.sync { emitterNode.particleColorBlendFactorSpeed } }
        set {
            queue.async {
                self.emitterNode.particleColorBlendFactorSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorBlendFactorSpeed = newValue
                }
            }
        }
    }
    
    public override var particleColorBlendFactorSequence: SKKeyframeSequence? {
        get { queue.sync { emitterNode.particleColorBlendFactorSequence } }
        set {
            queue.async {
                self.emitterNode.particleColorBlendFactorSequence = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleColorBlendFactorSequence = newValue
                }
            }
        }
    }
    
    public override var particlePosition: CGPoint {
        get { queue.sync { emitterNode.particlePosition } }
        set {
            queue.async {
                self.emitterNode.particlePosition = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particlePosition = newValue
                }
            }
        }
    }
    
    public override var particlePositionRange: CGVector {
        get { queue.sync { emitterNode.particlePositionRange } }
        set {
            queue.async {
                self.emitterNode.particlePositionRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particlePositionRange = newValue
                }
            }
        }
    }
    
    public override var particleSpeed: CGFloat {
        get { queue.sync { emitterNode.particleSpeed } }
        set {
            queue.async {
                self.emitterNode.particleSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleSpeed = newValue
                }
            }
        }
    }
    
    public override var particleSpeedRange: CGFloat {
        get { queue.sync { emitterNode.particleSpeedRange } }
        set {
            queue.async {
                self.emitterNode.particleSpeedRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleSpeedRange = newValue
                }
            }
        }
    }
    
    public override var emissionAngle: CGFloat {
        get { queue.sync { emitterNode.emissionAngle } }
        set {
            queue.async {
                self.emitterNode.emissionAngle = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.emissionAngle = newValue
                }
            }
        }
    }
    
    public override var emissionAngleRange: CGFloat {
        get { queue.sync { emitterNode.emissionAngleRange } }
        set {
            queue.async {
                self.emitterNode.emissionAngleRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.emissionAngleRange = newValue
                }
            }
        }
    }
    
    public override var xAcceleration: CGFloat {
        get { queue.sync { emitterNode.xAcceleration } }
        set {
            queue.async {
                self.emitterNode.xAcceleration = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.xAcceleration = newValue
                }
            }
        }
    }
    
    public override var yAcceleration: CGFloat {
        get { queue.sync { emitterNode.yAcceleration } }
        set {
            queue.async {
                self.emitterNode.yAcceleration = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.yAcceleration = newValue
                }
            }
        }
    }
    
    public override var particleBirthRate: CGFloat {
        get { queue.sync { emitterNode.particleBirthRate } }
        set {
            queue.async {
                self.emitterNode.particleBirthRate = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleBirthRate = newValue
                }
            }
        }
    }
    
    public override var numParticlesToEmit: Int {
        get { queue.sync { emitterNode.numParticlesToEmit } }
        set {
            queue.async {
                self.emitterNode.numParticlesToEmit = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.numParticlesToEmit = newValue
                }
            }
        }
    }
    
    public override var particleLifetime: CGFloat {
        get { queue.sync { emitterNode.particleLifetime } }
        set {
            queue.async {
                self.emitterNode.particleLifetime = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleLifetime = newValue
                }
            }
        }
    }
    
    public override var particleLifetimeRange: CGFloat {
        get { queue.sync { emitterNode.particleLifetimeRange } }
        set {
            queue.async {
                self.emitterNode.particleLifetimeRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleLifetimeRange = newValue
                }
            }
        }
    }
    
    public override var particleRotation: CGFloat {
        get { queue.sync { emitterNode.particleRotation } }
        set {
            queue.async {
                self.emitterNode.particleRotation = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleRotation = newValue
                }
            }
        }
    }
    
    public override var particleRotationRange: CGFloat {
        get { queue.sync { emitterNode.particleRotationRange } }
        set {
            queue.async {
                self.emitterNode.particleRotationRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleRotationRange = newValue
                }
            }
        }
    }
    
    public override var particleRotationSpeed: CGFloat {
        get { queue.sync { emitterNode.particleRotationSpeed } }
        set {
            queue.async {
                self.emitterNode.particleRotationSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleRotationSpeed = newValue
                }
            }
        }
    }
    
    public override var particleSize: CGSize {
        get { queue.sync { emitterNode.particleSize } }
        set {
            queue.async {
                self.emitterNode.particleSize = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleSize = newValue
                }
            }
        }
    }
    
    public override var particleScale: CGFloat {
        get { queue.sync { emitterNode.particleScale } }
        set {
            queue.async {
                self.emitterNode.particleScale = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleScale = newValue
                }
            }
        }
    }
    
    public override var particleScaleRange: CGFloat {
        get { queue.sync { emitterNode.particleScaleRange } }
        set {
            queue.async {
                self.emitterNode.particleScaleRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleScaleRange = newValue
                }
            }
        }
    }
    
    public override var particleScaleSpeed: CGFloat {
        get { queue.sync { emitterNode.particleScaleSpeed } }
        set {
            queue.async {
                self.emitterNode.particleScaleSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleScaleSpeed = newValue
                }
            }
        }
    }
    
    public override var particleScaleSequence: SKKeyframeSequence? {
        get { queue.sync { emitterNode.particleScaleSequence } }
        set {
            queue.async {
                self.emitterNode.particleScaleSequence = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleScaleSequence = newValue
                }
            }
        }
    }
    
    public override var particleAlpha: CGFloat {
        get { queue.sync { emitterNode.particleAlpha } }
        set {
            queue.async {
                self.emitterNode.particleAlpha = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleAlpha = newValue
                }
            }
        }
    }
    
    public override var particleAlphaRange: CGFloat {
        get { queue.sync { emitterNode.particleAlphaRange } }
        set {
            queue.async {
                self.emitterNode.particleAlphaRange = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleAlphaRange = newValue
                }
            }
        }
    }
    
    public override var particleAlphaSpeed: CGFloat {
        get { queue.sync { emitterNode.particleAlphaSpeed } }
        set {
            queue.async {
                self.emitterNode.particleAlphaSpeed = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleAlphaSpeed = newValue
                }
            }
        }
    }
    
    
    public override var particleAlphaSequence: SKKeyframeSequence? {
        get { queue.sync { emitterNode.particleAlphaSequence } }
        set {
            queue.async {
                self.emitterNode.particleAlphaSequence = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleAlphaSequence = newValue
                }
            }
        }
    }
    
    public override var fieldBitMask: UInt32 {
        get { queue.sync { emitterNode.fieldBitMask } }
        set {
            queue.async {
                self.emitterNode.fieldBitMask = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.fieldBitMask = newValue
                }
            }
        }
    }
    
    public override var shader: SKShader? {
        get { queue.sync { emitterNode.shader } }
        set {
            queue.async {
                self.emitterNode.shader = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.shader = newValue
                }
            }
        }
    }
    
    public override var particleZPosition: CGFloat {
        get { queue.sync { emitterNode.particleZPosition } }
        set {
            queue.async {
                self.emitterNode.particleZPosition = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleZPosition = newValue
                }
            }
        }
    }
    
    @available(iOS 9.0, *)
    public override var particleRenderOrder: SKParticleRenderOrder {
        get { queue.sync { emitterNode.particleRenderOrder } }
        set {
            queue.async {
                self.emitterNode.particleRenderOrder = newValue
                self.children.forEach { node in
                    (node as? SKEmitterNode)?.particleRenderOrder = newValue
                }
            }
        }
    }
}
