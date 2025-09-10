import Foundation
import UIKit

public struct ParticlizedScene {
    public var spawns: [ParticlizedSpawn]
    public var fields: [ParticlizedFieldNode]
    public var controls: ParticlizedControls
    public var backgroundColor: UIColor
    
    public init(spawns: [ParticlizedSpawn] = [],
                fields: [ParticlizedFieldNode] = [],
                controls: ParticlizedControls = .init(),
                backgroundColor: UIColor = .black) {
        self.spawns = spawns
        self.fields = fields
        self.controls = controls
        self.backgroundColor = backgroundColor
    }
}

