import SwiftUI
import Particlized
import simd
import UIKit

struct OregonContentView: View {
    @State private var choice: FieldChoice = .radial
    
    @State private var radial = RadialFieldNode(position: .zero, strength: -10000, radius: 150, falloff: 0.5, minRadius: 0, enabled: false)
    @State private var linear = LinearFieldNode(vector: .init(0, -1), strength: 120, enabled: false)
    @State private var turb   = TurbulenceFieldNode(position: .zero, strength: 1200, radius: 500, minRadius: 0, enabled: false)
    @State private var vortex = VortexFieldNode(position: .zero, strength: 800, radius: 500, falloff: 1.0, minRadius: 0, enabled: false)
    @State private var dragF  = DragFieldNode(strength: 3.0, enabled: false)
    @State private var velocityF = VelocityFieldNode(vector: .init(1, 0), strength: 120, enabled: false)
    @State private var linearGravityF = LinearGravityFieldNode(vector: .init(0, -1), strength: 150, enabled: false)
    @State private var noiseF = NoiseFieldNode(position: .zero, strength: 600, radius: 600, smoothness: 0.5, animationSpeed: 0.6, minRadius: 0, enabled: false)
    @State private var electricF = ElectricFieldNode(position: .zero, strength: 900, radius: 500, falloff: 2.0, minRadius: 0, enabled: false)
    @State private var magneticF = MagneticFieldNode(position: .zero, strength: 900, radius: 500, falloff: 2.0, minRadius: 0, enabled: false)
    @State private var springF = SpringFieldNode(position: .zero, strength: 5.0, radius: 600, falloff: 1.0, minRadius: 0, enabled: false)
    
    @State private var controls = {
        var c = ParticlizedControls()
        c.homingEnabled = true
        c.homingOnlyWhenNoFields = true
        c.homingStrength = 40
        c.homingDamping = 8
        return c
    }()
    
    @State private var spawns: [ParticlizedSpawn] = []
    @State private var dragStartParticleSpace: CGPoint? = nil
    
    @State private var linearAngleDeg: Double = 270
    @State private var velocityAngleDeg: Double = 0
    @State private var linearGravityAngleDeg: Double = 270
    
    @State private var panelCollapsed: Bool = false
    
    private func makeInitialSpawns() -> [ParticlizedSpawn] {
        let text = ParticlizedText(
            text: "Oregon 🦫",
            font: UIFont(name: "SnellRoundhand", size: 40)!,
            textColor: .white,
            numberOfPixelsPerNode: 1,
            nodeSkipPercentageChance: 0
        )
        let image = ParticlizedImage(
            image: UIImage(named: "oregon")!,
            numberOfPixelsPerNode: 1,
            nodeSkipPercentageChance: 0
        )
        return [
            .init(item: .image(image), position: .init(x: 0, y: 150)),
            .init(item: .text(text), position: .init(x: 0, y: 290))
        ]
    }
    
    private func updateAnglesFromVectorsIfNeeded() {
        let lv = linear.vector
        if hypot(Double(lv.x), Double(lv.y)) > 1e-6 {
            var d = atan2(Double(lv.y), Double(lv.x)) * 180.0 / .pi
            d.formTruncatingRemainder(dividingBy: 360)
            if d < 0 { d += 360 }
            linearAngleDeg = d
        }
        let vv = velocityF.vector
        if hypot(Double(vv.x), Double(vv.y)) > 1e-6 {
            var d = atan2(Double(vv.y), Double(vv.x)) * 180.0 / .pi
            d.formTruncatingRemainder(dividingBy: 360)
            if d < 0 { d += 360 }
            velocityAngleDeg = d
        }
        let gv = linearGravityF.vector
        if hypot(Double(gv.x), Double(gv.y)) > 1e-6 {
            var d = atan2(Double(gv.y), Double(gv.x)) * 180.0 / .pi
            d.formTruncatingRemainder(dividingBy: 360)
            if d < 0 { d += 360 }
            linearGravityAngleDeg = d
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            OregonCanvasView(
                spawns: $spawns,
                radial: $radial,
                linear: $linear,
                turb: $turb,
                vortex: $vortex,
                dragF: $dragF,
                velocityF: $velocityF,
                linearGravityF: $linearGravityF,
                noiseF: $noiseF,
                electricF: $electricF,
                magneticF: $magneticF,
                springF: $springF,
                controls: $controls,
                choice: $choice,
                dragStartParticleSpace: $dragStartParticleSpace,
                linearAngleDeg: $linearAngleDeg,
                velocityAngleDeg: $velocityAngleDeg,
                linearGravityAngleDeg: $linearGravityAngleDeg
            )
            .onAppear {
                if spawns.isEmpty {
                    spawns = makeInitialSpawns()
                }
                updateAnglesFromVectorsIfNeeded()
            }
            .ignoresSafeArea()
            
            OregonControlDock(
                choice: $choice,
                controls: $controls,
                radial: $radial,
                linear: $linear,
                turb: $turb,
                vortex: $vortex,
                dragF: $dragF,
                velocityF: $velocityF,
                linearGravityF: $linearGravityF,
                noiseF: $noiseF,
                electricF: $electricF,
                magneticF: $magneticF,
                springF: $springF,
                linearAngleDeg: $linearAngleDeg,
                velocityAngleDeg: $velocityAngleDeg,
                linearGravityAngleDeg: $linearGravityAngleDeg,
                panelCollapsed: $panelCollapsed
            )
        }
        .ignoresSafeArea()
    }
}

#Preview {
    OregonContentView()
}

