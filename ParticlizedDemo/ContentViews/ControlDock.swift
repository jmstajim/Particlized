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

    @State private var suspendedSet: Set<FieldChoice> = []
    @State private var isSuspended: Bool = false
    
    @State private var activePreset: Preset? = nil
    @State private var presetSnapshot: FieldsSnapshot? = nil
    
    struct FieldsSnapshot {
        var controls: ParticlizedControls
        var radial: RadialFieldNode
        var linear: LinearFieldNode
        var turb: TurbulenceFieldNode
        var vortex: VortexFieldNode
        var dragF: DragFieldNode
        var velocityF: VelocityFieldNode
        var linearGravityF: LinearGravityFieldNode
        var noiseF: NoiseFieldNode
        var electricF: ElectricFieldNode
        var magneticF: MagneticFieldNode
        var springF: SpringFieldNode
        var linearAngleDeg: Double
        var velocityAngleDeg: Double
        var linearGravityAngleDeg: Double
    }
    
    func makeSnapshot() -> FieldsSnapshot {
        FieldsSnapshot(
            controls: controls,
            radial: radial,
            linear: linear,
            turb: turb,
            vortex: vortex,
            dragF: dragF,
            velocityF: velocityF,
            linearGravityF: linearGravityF,
            noiseF: noiseF,
            electricF: electricF,
            magneticF: magneticF,
            springF: springF,
            linearAngleDeg: linearAngleDeg,
            velocityAngleDeg: velocityAngleDeg,
            linearGravityAngleDeg: linearGravityAngleDeg
        )
    }
    
    func restoreSnapshot(_ s: FieldsSnapshot) {
        controls = s.controls
        radial = s.radial
        linear = s.linear
        turb = s.turb
        vortex = s.vortex
        dragF = s.dragF
        velocityF = s.velocityF
        linearGravityF = s.linearGravityF
        noiseF = s.noiseF
        electricF = s.electricF
        magneticF = s.magneticF
        springF = s.springF
        linearAngleDeg = s.linearAngleDeg
        velocityAngleDeg = s.velocityAngleDeg
        linearGravityAngleDeg = s.linearGravityAngleDeg
    }
    
    func clearFieldsEnabled() {
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
    
    enum Preset: String, CaseIterable, Identifiable {
        case rainfall = "Rain"
        case magneto = "Magneto"
        case fireflies = "Fireflies"
        case sandstorm = "Sandstorm"
        case fountain = "Fountain"
        case blackHole = "Black Hole"
        case thunderstorm = "Thunderstorm"
        case spiralBurst = "Spiral"
        case galaxy = "Galaxy"
        var id: String { rawValue }
    }
    
    func iconName(for c: FieldChoice) -> String {
        switch c {
        case .radial: return "dot.radiowaves.left.and.right"
        case .linear: return "arrow.right"
        case .turbulence: return "wind"
        case .vortex: return "tornado"
        case .drag: return "speedometer"
        case .velocity: return "arrowtriangle.forward.circle"
        case .magnetic: return "arrow.right.and.line.vertical.and.arrow.left"
        case .linearGravity: return "arrow.down"
        case .noise: return "aqi.medium"
        case .electric: return "bolt"
        case .spring: return "scribble"
        }
    }
    
    func isActive(_ c: FieldChoice) -> Bool {
        switch c {
        case .radial: return radial.enabled
        case .linear: return linear.enabled
        case .turbulence: return turb.enabled
        case .vortex: return vortex.enabled
        case .drag: return dragF.enabled
        case .velocity: return velocityF.enabled
        case .linearGravity: return linearGravityF.enabled
        case .noise: return noiseF.enabled
        case .electric: return electricF.enabled
        case .magnetic: return magneticF.enabled
        case .spring: return springF.enabled
        }
    }
    
    func setEnabled(_ enabled: Bool, for c: FieldChoice) {
        switch c {
        case .radial: radial.enabled = enabled
        case .linear: linear.enabled = enabled
        case .turbulence: turb.enabled = enabled
        case .vortex: vortex.enabled = enabled
        case .drag: dragF.enabled = enabled
        case .velocity: velocityF.enabled = enabled
        case .linearGravity: linearGravityF.enabled = enabled
        case .noise: noiseF.enabled = enabled
        case .electric: electricF.enabled = enabled
        case .magnetic: magneticF.enabled = enabled
        case .spring: springF.enabled = enabled
        }
    }
    
    func toggleSuspendFields() {
        if !isSuspended {
            suspendedSet = []
            for c in FieldChoice.allCases {
                if isActive(c) { suspendedSet.insert(c) }
                setEnabled(false, for: c)
            }
            isSuspended = true
        } else {
            for c in suspendedSet {
                setEnabled(true, for: c)
            }
            suspendedSet.removeAll()
            isSuspended = false
        }
    }
    
    func disableAllFields() {
        if activePreset != nil, let snap = presetSnapshot {
            restoreSnapshot(snap)
            activePreset = nil
            presetSnapshot = nil
            return
        }
        activePreset = nil
        presetSnapshot = nil
        clearFieldsEnabled()
    }
    
    func applyPreset(_ p: Preset) {
        if activePreset == p {
            if let snap = presetSnapshot { restoreSnapshot(snap) }
            activePreset = nil
            presetSnapshot = nil
            return
        }
        if activePreset == nil {
            presetSnapshot = makeSnapshot()
        } else if let snap = presetSnapshot {
            restoreSnapshot(snap)
            presetSnapshot = makeSnapshot()
        }
        configurePreset(p)
        activePreset = p
    }
    
    func configurePreset(_ p: Preset) {
        clearFieldsEnabled()
        controls.homingEnabled = false
        
        switch p {
        case .rainfall:
            linearGravityF.enabled = true
            linearGravityAngleDeg = 270
            linearGravityF.vector = Math.updateVectorFromAngle(linearGravityAngleDeg)
            linearGravityF.strength = 600
            
            velocityF.enabled = true
            velocityAngleDeg = 0
            velocityF.vector = Math.updateVectorFromAngle(velocityAngleDeg)
            velocityF.strength = 120
            
            turb.enabled = true
            turb.position = .zero
            turb.radius = 0
            turb.minRadius = 0
            turb.strength = 320
            
            noiseF.enabled = true
            noiseF.position = .zero
            noiseF.radius = 0
            noiseF.smoothness = 0.6
            noiseF.animationSpeed = 1.2
            noiseF.strength = 5000
            
            dragF.enabled = true
            dragF.strength = 3.0
            
        case .magneto:
            magneticF.enabled = true
            magneticF.position = .zero
            magneticF.radius = 600
            magneticF.minRadius = 0
            magneticF.falloff = 1.5
            magneticF.strength = 2000
            
            electricF.enabled = true
            electricF.position = .zero
            electricF.radius = 600
            electricF.minRadius = 0
            electricF.falloff = 1.0
            electricF.strength = -1800
            
            dragF.enabled = true
            dragF.strength = 1.0

        case .fireflies:
            controls.homingEnabled = true
            controls.homingOnlyWhenNoFields = false
            controls.homingStrength = 60
            controls.homingDamping = 12
            
            noiseF.enabled = true
            noiseF.position = .zero
            noiseF.radius = 0
            noiseF.smoothness = 0.6
            noiseF.animationSpeed = 1.2
            noiseF.strength = 5000
            
            turb.enabled = true
            turb.position = .zero
            turb.radius = 400
            turb.minRadius = 0
            turb.strength = 200
            
            dragF.enabled = true
            dragF.strength = 0.5
            
        case .sandstorm:
            velocityF.enabled = true
            velocityAngleDeg = 0
            velocityF.vector = Math.updateVectorFromAngle(velocityAngleDeg)
            velocityF.strength = 800
            
            turb.enabled = true
            turb.position = .zero
            turb.radius = 1200
            turb.minRadius = 0
            turb.strength = 1200
            
            noiseF.enabled = true
            noiseF.position = .zero
            noiseF.radius = 1000
            noiseF.smoothness = 0.5
            noiseF.animationSpeed = 1.0
            noiseF.strength = 300
            
            linearGravityF.enabled = true
            linearGravityAngleDeg = 270
            linearGravityF.vector = Math.updateVectorFromAngle(linearGravityAngleDeg)
            linearGravityF.strength = 200
            
            dragF.enabled = true
            dragF.strength = 4.0

        case .fountain:
            velocityF.enabled = true
            velocityAngleDeg = 90
            velocityF.vector = Math.updateVectorFromAngle(velocityAngleDeg)
            velocityF.strength = 600
            
            radial.enabled = true
            radial.position = .zero
            radial.radius = 700
            radial.minRadius = 0
            radial.falloff = 1.0
            radial.strength = 1500
            
            turb.enabled = true
            turb.position = .zero
            turb.radius = 700
            turb.minRadius = 0
            turb.strength = 500
            
            dragF.enabled = true
            dragF.strength = 2.5
            
        case .blackHole:
            radial.enabled = true
            radial.position = .zero
            radial.radius = 400
            radial.minRadius = 0
            radial.falloff = 0.8
            radial.strength = -12000
            
            vortex.enabled = true
            vortex.position = .zero
            vortex.radius = 500
            vortex.minRadius = 0
            vortex.falloff = 0.9
            vortex.strength = -3000
            
            electricF.enabled = true
            electricF.position = .zero
            electricF.radius = 400
            electricF.minRadius = 0
            electricF.falloff = 1.0
            electricF.strength = -1000
            
            dragF.enabled = true
            dragF.strength = 4.0
            
            noiseF.enabled = true
            noiseF.position = .zero
            noiseF.radius = 400
            noiseF.smoothness = 0.5
            noiseF.animationSpeed = 0.4
            noiseF.strength = 150

        case .thunderstorm:            
            turb.enabled = true
            turb.position = .zero
            turb.radius = 1200
            turb.minRadius = 0
            turb.strength = 1500

            noiseF.enabled = true
            noiseF.position = .zero
            noiseF.radius = 800
            noiseF.smoothness = 0.6
            noiseF.animationSpeed = 1.0
            noiseF.strength = 400
            
            dragF.enabled = true
            dragF.strength = 3.5

        case .spiralBurst:
            vortex.enabled = true
            vortex.position = .zero
            vortex.radius = 1200
            vortex.minRadius = 0
            vortex.falloff = 0.9
            vortex.strength = 3000
            
            radial.enabled = true
            radial.position = .zero
            radial.radius = 1200
            radial.minRadius = 0
            radial.falloff = 0.9
            radial.strength = 6000
            
            electricF.enabled = true
            electricF.position = .zero
            electricF.radius = 900
            electricF.minRadius = 0
            electricF.falloff = 1.1
            electricF.strength = 1200
            
            dragF.enabled = true
            dragF.strength = 1.0

        case .galaxy:
            vortex.enabled = true
            vortex.position = .zero
            vortex.radius = 400
            vortex.minRadius = 0
            vortex.falloff = 1.0
            vortex.strength = 2600
            
            radial.enabled = true
            radial.position = .zero
            radial.radius = 600
            radial.minRadius = 0
            radial.falloff = 1.1
            radial.strength = 2200
            
            electricF.enabled = true
            electricF.position = .zero
            electricF.radius = 500
            electricF.minRadius = 0
            electricF.falloff = 1.0
            electricF.strength = 300
            
            dragF.enabled = true
            dragF.strength = 0.9
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if !panelCollapsed {
                parameterPanel
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Preset.allCases) { p in
                        Button { applyPreset(p) } label: {
                            Text(p.rawValue)
                                .font(.footnote)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background((activePreset == p) ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08), in: Capsule())
                                .overlay(Capsule().stroke((activePreset == p) ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
            }
            
            HStack(spacing: 8) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(FieldChoice.allCases) { c in
                            Button {
                                choice = c
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: iconName(for: c))
                                        .imageScale(.large)
                                        .foregroundStyle(choice == c ? Color.accentColor : (isActive(c) ? Color.green : Color.primary))
                                        .padding(8)
                                        .background(choice == c ? Color.accentColor.opacity(0.15) : Color.clear, in: Capsule())
                                    if isActive(c) {
                                        Circle().frame(width: 6, height: 6).offset(x: 2, y: -2)
                                    }
                                }
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

                Button {
                    toggleSuspendFields()
                } label: {
                    Image(systemName: isSuspended ? "play.circle" : "pause.circle")
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
                
                Button(role: .destructive) {
                    disableAllFields()
                } label: {
                    Image(systemName: "xmark.circle").imageScale(.large)
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
            .contentMargins(.horizontal, EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0), for: .automatic)
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(EdgeInsets.init(top: 8, leading: 16, bottom: 0, trailing: 16))
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
                            linear.vector = Math.updateVectorFromAngle($0)
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
                            velocityF.vector = Math.updateVectorFromAngle($0)
                            return "\(Int($0))"
                        })
                    }
                case .linearGravity:
                    Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                        Toggle("Enabled", isOn: $linearGravityF.enabled).font(.footnote)
                        sliderRow("Strength", value: Binding(get: { Double(linearGravityF.strength) }, set: { linearGravityF.strength = Float($0) }), range: 0...2000, format: { "\(Int($0))" })
                        sliderRow("Angle °", value: $linearGravityAngleDeg, range: 0...360, step: 1, format:  {
                            linearGravityF.vector = Math.updateVectorFromAngle($0)
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
