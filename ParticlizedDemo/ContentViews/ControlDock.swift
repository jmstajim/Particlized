import SwiftUI
import Particlized
import simd

struct ControlDock: View {
    @Binding var choice: FieldChoice
    @Binding var controls: ParticlizedControls
    
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
    
    @Binding var linearAngleDeg: Double
    @Binding var velocityAngleDeg: Double
    @Binding var linearGravityAngleDeg: Double
    
    @Binding var panelCollapsed: Bool
    
    private func iconName(for c: FieldChoice) -> String {
        switch c {
        case .radial: return "dot.circle"
        case .linear: return "arrow.right.circle"
        case .turbulence: return "wind"
        case .vortex: return "tornado"
        case .drag: return "speedometer"
        case .velocity: return "arrowtriangle.forward.circle"
        case .linearGravity: return "arrow.down.circle"
        case .noise: return "circle.bottomrighthalf.pattern.checkered"
        case .electric: return "bolt.circle"
        case .magnetic: return "arrow.right.and.line.vertical.and.arrow.left"
        case .spring: return "arrow.triangle.2.circlepath.circle"
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if !panelCollapsed {
                parameterPanel
            }

            HStack(spacing: 8) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(FieldChoice.allCases) { c in
                            Button {
                                choice = c
                            } label: {
                                Image(systemName: iconName(for: c))
                                    .imageScale(.large)
                                    .padding(8)
                                    .background(choice == c ? Color.accentColor.opacity(0.15) : Color.clear, in: Capsule())
                                    .overlay(
                                        Capsule().stroke(choice == c ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Spacer(minLength: 4)
                
                Button {
                    controls.homingOnlyWhenNoFields.toggle()
                } label: {
                    Image(systemName: controls.homingOnlyWhenNoFields ? "house" : "house.fill")
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
                
                Button(role: .destructive) {
                    disableAllFields()
                } label: {
                    Image(systemName: "xmark.circle")
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { panelCollapsed.toggle() }
                } label: {
                    Image(systemName: panelCollapsed ? "chevron.up.circle" : "chevron.down.circle")
                        .imageScale(.large)
                        .padding(8)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 4)
            }
            .contentMargins(.horizontal, EdgeInsets.init(top: 0, leading: 16, bottom: 0, trailing: 0), for: .automatic)

        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(EdgeInsets.init(top: 8, leading: 16, bottom: 0, trailing: 16))
    }
    
    private func disableAllFields() {
        radial.enabled = false
        linear.enabled = false
        turb.enabled = false
        vortex.enabled = false
        dragF.enabled = false
        velocityF.enabled = false
        linearGravityF.enabled = false
        noiseF.enabled = false
        electricF.enabled = false
        magneticF.enabled = false
        springF.enabled = false
    }
    
    @ViewBuilder
    private var parameterPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                Text("\(choice.rawValue) Parameters").font(.footnote).foregroundStyle(.secondary)
                
                switch choice {
                case .radial:
                    Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                        Toggle("Enabled", isOn: $radial.enabled).font(.footnote)
                        sliderRow("Strength", value: Binding(get: { Double(radial.strength) }, set: { radial.strength = Float($0) }), range: -20000...20000, format: { "\(Int($0))" })
                        sliderRow("Radius",   value: Binding(get: { Double(radial.radius) },   set: {
                            radial.radius = Float($0)
                            radial.minRadius = min(radial.minRadius, max(0, radial.radius - 0.001))
                        }), range: 0...1500, format: { "\(Int($0))" })
                        sliderRow("Min radius", value: Binding(get: { Double(radial.minRadius) }, set: {
                            let clamped = min(max(0, $0), Double(radial.radius - 0.001))
                            radial.minRadius = Float(max(0, clamped))
                        }), range: 0...Double(max(radial.radius, 0)), format: { "\(Int($0))" })
                        sliderRow("Falloff",  value: Binding(get: { Double(radial.falloff) },  set: { radial.falloff  = Float($0) }), range: 0...3,    format: { String(format: "%.2f", $0) })
                    }
                case .linear:
                    Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                        Toggle("Enabled", isOn: $linear.enabled).font(.footnote)
                        sliderRow("Strength", value: Binding(get: { Double(linear.strength) }, set: { linear.strength = Float($0) }), range: 0...1000, format: { "\(Int($0))" })
                        sliderRow("Angle °", value: $linearAngleDeg, range: 0...360, step: 1, format:  {
                            linear.vector = OregonMath.updateVectorFromAngle($0)
                            return "\(Int($0))"
                        })
                    }
                case .turbulence:
                    Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                        Toggle("Enabled", isOn: $turb.enabled).font(.footnote)
                        sliderRow("Strength", value: Binding(get: { Double(turb.strength) }, set: { turb.strength = Float($0) }), range: 0...5000, format: { "\(Int($0))" })
                        sliderRow("Radius",   value: Binding(get: { Double(turb.radius) },   set: {
                            turb.radius = Float($0)
                            turb.minRadius = min(turb.minRadius, max(0, turb.radius - 0.001))
                        }), range: 0...1500, format: { "\(Int($0))" })
                        sliderRow("Min radius", value: Binding(get: { Double(turb.minRadius) }, set: {
                            let clamped = min(max(0, $0), Double(turb.radius - 0.001))
                            turb.minRadius = Float(max(0, clamped))
                        }), range: 0...Double(max(turb.radius, 0)), format: { "\(Int($0))" })
                    }
                case .vortex:
                    Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                        Toggle("Enabled", isOn: $vortex.enabled).font(.footnote)
                        sliderRow("Strength", value: Binding(get: { Double(vortex.strength) }, set: { vortex.strength = Float($0) }), range: -5000...5000, format: { "\(Int($0))" })
                        sliderRow("Radius",   value: Binding(get: { Double(vortex.radius) },   set: {
                            vortex.radius = Float($0)
                            vortex.minRadius = min(vortex.minRadius, max(0, vortex.radius - 0.001))
                        }), range: 0...1500, format: { "\(Int($0))" })
                        sliderRow("Min radius", value: Binding(get: { Double(vortex.minRadius) }, set: {
                            let clamped = min(max(0, $0), Double(vortex.radius - 0.001))
                            vortex.minRadius = Float(max(0, clamped))
                        }), range: 0...Double(max(vortex.radius, 0)), format: { "\(Int($0))" })
                        sliderRow("Falloff",  value: Binding(get: { Double(vortex.falloff) },  set: { vortex.falloff  = Float($0) }), range: 0...3,    format: { String(format: "%.2f", $0) })
                    }
                case .drag:
                    Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                        Toggle("Enabled", isOn: $dragF.enabled).font(.footnote)
                        sliderRow("Strength", value: Binding(get: { Double(dragF.strength) }, set: { dragF.strength = Float($0) }), range: 0...20, format: { String(format: "%.2f", $0) })
                    }
                case .velocity:
                    Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                        Toggle("Enabled", isOn: $velocityF.enabled).font(.footnote)
                        sliderRow("Strength", value: Binding(get: { Double(velocityF.strength) }, set: { velocityF.strength = Float($0) }), range: 0...2000, format: { "\(Int($0))" })
                        sliderRow("Angle °", value: $velocityAngleDeg, range: 0...360, step: 1, format:  {
                            velocityF.vector = OregonMath.updateVectorFromAngle($0)
                            return "\(Int($0))"
                        })
                    }
                case .linearGravity:
                    Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                        Toggle("Enabled", isOn: $linearGravityF.enabled).font(.footnote)
                        sliderRow("Strength", value: Binding(get: { Double(linearGravityF.strength) }, set: { linearGravityF.strength = Float($0) }), range: 0...2000, format: { "\(Int($0))" })
                        sliderRow("Angle °", value: $linearGravityAngleDeg, range: 0...360, step: 1, format:  {
                            linearGravityF.vector = OregonMath.updateVectorFromAngle($0)
                            return "\(Int($0))"
                        })
                    }
                case .noise:
                    Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                        Toggle("Enabled", isOn: $noiseF.enabled).font(.footnote)
                        sliderRow("Strength",    value: Binding(get: { Double(noiseF.strength) }, set: { noiseF.strength = Float($0) }), range: 0...5000, format: { "\(Int($0))" })
                        sliderRow("Radius",      value: Binding(get: { Double(noiseF.radius) },   set: {
                            noiseF.radius = Float($0)
                        }), range: 0...1500, format: { "\(Int($0))" })
                        sliderRow("Smoothness",  value: Binding(get: { Double(noiseF.smoothness) }, set: { noiseF.smoothness = Float($0) }), range: 0...1, format: { String(format: "%.2f", $0) })
                        sliderRow("Anim speed",  value: Binding(get: { Double(noiseF.animationSpeed) }, set: { noiseF.animationSpeed = Float($0) }), range: 0...5, format: { String(format: "%.2f", $0) })
                    }
                case .electric:
                    Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                        Toggle("Enabled", isOn: $electricF.enabled).font(.footnote)
                        sliderRow("Strength", value: Binding(get: { Double(electricF.strength) }, set: { electricF.strength = Float($0) }), range: -5000...5000, format: { "\(Int($0))" })
                        sliderRow("Radius",   value: Binding(get: { Double(electricF.radius) },   set: {
                            electricF.radius = Float($0)
                            electricF.minRadius = min(electricF.minRadius, max(0, electricF.radius - 0.001))
                        }), range: 0...1500, format: { "\(Int($0))" })
                        sliderRow("Min radius", value: Binding(get: { Double(electricF.minRadius) }, set: {
                            let clamped = min(max(0, $0), Double(electricF.radius - 0.001))
                            electricF.minRadius = Float(max(0, clamped))
                        }), range: 0...Double(max(electricF.radius, 0)), format: { "\(Int($0))" })
                        sliderRow("Falloff",  value: Binding(get: { Double(electricF.falloff) },  set: { electricF.falloff  = Float($0) }), range: 0...3,    format: { String(format: "%.2f", $0) })
                    }
                case .magnetic:
                    Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                        Toggle("Enabled", isOn: $magneticF.enabled).font(.footnote)
                        sliderRow("Strength", value: Binding(get: { Double(magneticF.strength) }, set: { magneticF.strength = Float($0) }), range: -5000...5000, format: { "\(Int($0))" })
                        sliderRow("Radius",   value: Binding(get: { Double(magneticF.radius) },   set: {
                            magneticF.radius = Float($0)
                            magneticF.minRadius = min(magneticF.minRadius, max(0, magneticF.radius - 0.001))
                        }), range: 0...1500, format: { "\(Int($0))" })
                        sliderRow("Min radius", value: Binding(get: { Double(magneticF.minRadius) }, set: {
                            let clamped = min(max(0, $0), Double(magneticF.radius - 0.001))
                            magneticF.minRadius = Float(max(0, clamped))
                        }), range: 0...Double(max(magneticF.radius, 0)), format: { "\(Int($0))" })
                        sliderRow("Falloff",  value: Binding(get: { Double(magneticF.falloff) },  set: { magneticF.falloff  = Float($0) }), range: 0...3,    format: { String(format: "%.2f", $0) })
                    }
                case .spring:
                    Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                        Toggle("Enabled", isOn: $springF.enabled).font(.footnote)
                        sliderRow("Strength", value: Binding(get: { Double(springF.strength) }, set: { springF.strength = Float($0) }), range: 0...50, format: { String(format: "%.2f", $0) })
                        sliderRow("Radius",   value: Binding(get: { Double(springF.radius) },   set: {
                            springF.radius = Float($0)
                            springF.minRadius = min(springF.minRadius, max(0, springF.radius - 0.001))
                        }), range: 0...1500, format: { "\(Int($0))" })
                        sliderRow("Min radius", value: Binding(get: { Double(springF.minRadius) }, set: {
                            let clamped = min(max(0, $0), Double(springF.radius - 0.001))
                            springF.minRadius = Float(max(0, clamped))
                        }), range: 0...Double(max(springF.radius, 0)), format: { "\(Int($0))" })
                        sliderRow("Falloff",  value: Binding(get: { Double(springF.falloff) },  set: { springF.falloff  = Float($0) }), range: 0...3,    format: { String(format: "%.2f", $0) })
                    }
                }
            }
            
            Group {
                Text("Homing").font(.footnote).foregroundStyle(.secondary)
                Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                    Toggle("Only when no fields", isOn: $controls.homingOnlyWhenNoFields).font(.footnote)
                    sliderRow("Strength", value: Binding(get: { Double(controls.homingStrength) }, set: { controls.homingStrength = Float($0) }), range: 0...120, format: { "\(Int($0))" })
                    sliderRow("Damping",  value: Binding(get: { Double(controls.homingDamping) },  set: { controls.homingDamping  = Float($0) }), range: 0...20,  format: { String(format: "%.1f", $0) })
                }
            }
        }
        .padding(EdgeInsets.init(top: 8, leading: 16, bottom: 0, trailing: 16))
    }
    
    @ViewBuilder
    private func sliderRow(_ title: String,
                           value: Binding<Double>,
                           range: ClosedRange<Double>,
                           step: Double? = nil,
                           onChange: ((Double) -> String)? = nil,
                           format: ((Double) -> String)? = nil) -> some View {
        GridRow {
            Text(title).font(.footnote).frame(minWidth: 64, alignment: .leading)
            HStack(spacing: 6) {
                if let step {
                    Slider(value: value, in: range, step: step)
                        .controlSize(.mini)
                } else {
                    Slider(value: value, in: range)
                        .controlSize(.mini)
                }
                Text((onChange?(value.wrappedValue)) ?? (format?(value.wrappedValue) ?? String(format: "%.2f", value.wrappedValue)))
                    .font(.footnote).foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .trailing)
            }
        }
        .onChange(of: value.wrappedValue) { newVal, _ in
            _ = onChange?(newVal)
        }
    }
}

