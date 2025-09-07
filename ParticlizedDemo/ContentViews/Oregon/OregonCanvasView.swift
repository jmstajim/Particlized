import SwiftUI
import Particlized
import simd

struct OregonCanvasView: View {
    @Binding var spawns: [ParticlizedSpawn]
    @Binding var radial: RadialFieldNode
    @Binding var linear: LinearFieldNode
    @Binding var turb: TurbulenceFieldNode
    @Binding var vortex: VortexFieldNode
    @Binding var dragF: DragFieldNode
    @Binding var velocityF: VelocityFieldNode
    @Binding var linearGravityF: LinearGravityFieldNode
    @Binding var noiseF: NoiseFieldNode
    @Binding var electricF: ElectricFieldNode
    @Binding var magneticF: MagneticFieldNode
    @Binding var springF: SpringFieldNode
    @Binding var controls: ParticlizedControls
    @Binding var choice: FieldChoice
    @Binding var dragStartParticleSpace: CGPoint?
    
    @Binding var linearAngleDeg: Double
    @Binding var velocityAngleDeg: Double
    @Binding var linearGravityAngleDeg: Double
    
    var body: some View {
        GeometryReader { geo in
            MetalParticleView(
                spawns: spawns,
                fields: [
                    .radial(radial),
                    .noise(noiseF),
                    .turbulence(turb),
                    .vortex(vortex),
                    .electric(electricF),
                    .magnetic(magneticF),
                    .spring(springF),
                    .linearGravity(linearGravityF),
                    .linear(linear),
                    .drag(dragF),
                    .velocity(velocityF)
                ],
                controls: controls,
                backgroundColor: .white
            )
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in
                        let p = OregonMath.convertToCentered(geo, fromGlobal: value.location)
                        if dragStartParticleSpace == nil { dragStartParticleSpace = p }
                        
                        switch choice {
                        case .radial:
                            radial.enabled = true
                            radial.position = p
                        case .turbulence:
                            turb.enabled = true
                            turb.position = p
                        case .vortex:
                            vortex.enabled = true
                            vortex.position = p
                        case .noise:
                            noiseF.enabled = true
                            noiseF.position = p
                        case .electric:
                            electricF.enabled = true
                            electricF.position = p
                        case .magnetic:
                            magneticF.enabled = true
                            magneticF.position = p
                        case .spring:
                            springF.enabled = true
                            springF.position = p
                        case .linear:
                            linear.enabled = true
                            if let s = dragStartParticleSpace {
                                let dx = Float(p.x - s.x), dy = Float(p.y - s.y)
                                if hypot(Double(dx), Double(dy)) > 1e-3 {
                                    let angle = atan2(Double(dy), Double(dx)) * 180.0 / .pi
                                    linearAngleDeg = (angle < 0 ? angle + 360 : angle)
                                    linear.vector = OregonMath.updateVectorFromAngle(linearAngleDeg)
                                }
                            }
                        case .velocity:
                            velocityF.enabled = true
                            if let s = dragStartParticleSpace {
                                let dx = Float(p.x - s.x), dy = Float(p.y - s.y)
                                if hypot(Double(dx), Double(dy)) > 1e-3 {
                                    let angle = atan2(Double(dy), Double(dx)) * 180.0 / .pi
                                    velocityAngleDeg = (angle < 0 ? angle + 360 : angle)
                                    velocityF.vector = OregonMath.updateVectorFromAngle(velocityAngleDeg)
                                }
                            }
                        case .linearGravity:
                            linearGravityF.enabled = true
                            if let s = dragStartParticleSpace {
                                let dx = Float(p.x - s.x), dy = Float(p.y - s.y)
                                if hypot(Double(dx), Double(dy)) > 1e-3 {
                                    let angle = atan2(Double(dy), Double(dx)) * 180.0 / .pi
                                    linearGravityAngleDeg = (angle < 0 ? angle + 360 : angle)
                                    linearGravityF.vector = OregonMath.updateVectorFromAngle(linearGravityAngleDeg)
                                }
                            }
                        case .drag:
                            dragF.enabled = true
                        }
                    }
                    .onEnded { _ in
                        dragStartParticleSpace = nil
                        switch choice {
                        case .radial: radial.enabled = false
                        case .linear: linear.enabled = false
                        case .turbulence: turb.enabled = false
                        case .vortex: vortex.enabled = false
                        case .drag: dragF.enabled = false
                        case .velocity: velocityF.enabled = false
                        case .linearGravity: linearGravityF.enabled = false
                        case .noise: noiseF.enabled = false
                        case .electric: electricF.enabled = false
                        case .magnetic: magneticF.enabled = false
                        case .spring: springF.enabled = false
                        }
                    }
            )
            .ignoresSafeArea()
        }
    }
}

