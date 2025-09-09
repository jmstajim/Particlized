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
        case cycloneEye = "Cyclone Eye"
        case ionosphere = "Ionosphere"
        case thermalConvection = "Thermal Convection"
        case coronalLoops = "Coronal Loops"
        case jetStream = "Jet Stream"
        case lavaLamp = "Lava Lamp"
        case hydrothermalPlume = "Hydrothermal Plume"
        case crystalLattice = "Crystal Lattice"
        case electrolysis = "Electrolysis"
        case goldenSpiral = "Golden Spiral"
        case dustDevil = "Dust Devil"
        case solarFlare = "Solar Flare"
        case kelvinHelmholtz = "Kelvin-Helmholtz"
        case rayleighTaylor = "Rayleigh–Taylor"
        case karmanStreet = "Kármán Street"
        case bowShock = "Bow Shock"
        case ferrofluid = "Ferrofluid"
        case ionThruster = "Ion Thruster"
        case galaxyDisk = "Galaxy Disk"
        case murmuration = "Murmuration"
        case supercell = "Supercell"
        case snowfall = "Snowfall"
        case planktonBloom = "Plankton Bloom"
        case cyclotron = "Cyclotron"
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
        case .cycloneEye:
            vortex.enabled = true
            vortex.position = .zero
            vortex.radius = 820
            vortex.minRadius = 120
            vortex.falloff = 1.15
            vortex.strength = 1800
            
            radial.enabled = true
            radial.position = .zero
            radial.radius = 260
            radial.minRadius = 30
            radial.falloff = 1.3
            radial.strength = -2400
            
            dragF.enabled = true
            dragF.strength = 2.1
            
            noiseF.enabled = true
            noiseF.radius = 900
            noiseF.smoothness = 0.7
            noiseF.animationSpeed = 0.6
            noiseF.strength = 220
            
        case .ionosphere:
            electricF.enabled = true
            electricF.position = .zero
            electricF.radius = 980
            electricF.minRadius = 120
            electricF.falloff = 1.5
            electricF.strength = 1200
            
            magneticF.enabled = true
            magneticF.position = .zero
            magneticF.radius = 980
            magneticF.minRadius = 80
            magneticF.falloff = 1.35
            magneticF.strength = 900
            
            velocityF.enabled = true
            velocityF.vector = .init(1, 0)
            velocityAngleDeg = 0
            velocityF.strength = 380
            
            noiseF.enabled = true
            noiseF.radius = 1400
            noiseF.smoothness = 0.85
            noiseF.animationSpeed = 0.8
            noiseF.strength = 260
            
            dragF.enabled = true
            dragF.strength = 1.9
            
        case .thermalConvection:
            linearGravityF.enabled = true
            linearGravityF.vector = .init(0, -1)
            linearGravityAngleDeg = 270
            linearGravityF.strength = 180
            
            linear.enabled = true
            linear.vector = .init(0, 1)
            linearAngleDeg = 90
            linear.strength = 160
            
            vortex.enabled = true
            vortex.radius = 520
            vortex.minRadius = 160
            vortex.falloff = 1.0
            vortex.strength = 600
            
            noiseF.enabled = true
            noiseF.radius = 700
            noiseF.smoothness = 0.55
            noiseF.animationSpeed = 0.9
            noiseF.strength = 200
            
            dragF.enabled = true
            dragF.strength = 2.6
            
        case .coronalLoops:
            magneticF.enabled = true
            magneticF.radius = 900
            magneticF.minRadius = 180
            magneticF.falloff = 1.6
            magneticF.strength = 1400
            
            electricF.enabled = true
            electricF.radius = 700
            electricF.minRadius = 140
            electricF.falloff = 1.9
            electricF.strength = 1100
            
            springF.enabled = true
            springF.radius = 680
            springF.minRadius = 60
            springF.falloff = 1.3
            springF.strength = 6.2
            
            dragF.enabled = true
            dragF.strength = 1.4
            
        case .jetStream:
            velocityF.enabled = true
            velocityF.vector = .init(1, 0)
            velocityAngleDeg = 0
            velocityF.strength = 800
            
            noiseF.enabled = true
            noiseF.radius = 1500
            noiseF.smoothness = 0.92
            noiseF.animationSpeed = 0.5
            noiseF.strength = 240
            
            vortex.enabled = true
            vortex.radius = 380
            vortex.minRadius = 90
            vortex.falloff = 1.1
            vortex.strength = 260
            
            dragF.enabled = true
            dragF.strength = 2.3
            
        case .lavaLamp:
            springF.enabled = true
            springF.radius = 520
            springF.minRadius = 40
            springF.falloff = 1.9
            springF.strength = 8.0
            
            velocityF.enabled = true
            velocityF.vector = .init(0, 1)
            velocityAngleDeg = 90
            velocityF.strength = 300
            
            linearGravityF.enabled = true
            linearGravityF.vector = .init(0, -1)
            linearGravityAngleDeg = 270
            linearGravityF.strength = 140
            
            noiseF.enabled = true
            noiseF.radius = 450
            noiseF.smoothness = 0.35
            noiseF.animationSpeed = 0.4
            noiseF.strength = 160
            
            dragF.enabled = true
            dragF.strength = 3.8
            
        case .hydrothermalPlume:
            velocityF.enabled = true
            velocityF.vector = .init(0, 1)
            velocityAngleDeg = 90
            velocityF.strength = 520
            
            turb.enabled = true
            turb.radius = 520
            turb.minRadius = 80
            turb.strength = 900
            
            radial.enabled = true
            radial.radius = 820
            radial.minRadius = 120
            radial.falloff = 1.4
            radial.strength = 900
            
            noiseF.enabled = true
            noiseF.radius = 680
            noiseF.smoothness = 0.4
            noiseF.animationSpeed = 0.7
            noiseF.strength = 180
            
            dragF.enabled = true
            dragF.strength = 3.0
            
        case .crystalLattice:
            springF.enabled = true
            springF.radius = 840
            springF.minRadius = 120
            springF.falloff = 1.2
            springF.strength = 10.0
            
            radial.enabled = true
            radial.radius = 980
            radial.minRadius = 280
            radial.falloff = 1.8
            radial.strength = -3000
            
            noiseF.enabled = true
            noiseF.radius = 380
            noiseF.smoothness = 0.15
            noiseF.animationSpeed = 0.2
            noiseF.strength = 110
            
            dragF.enabled = true
            dragF.strength = 2.4
            
        case .electrolysis:
            electricF.enabled = true
            electricF.radius = 1000
            electricF.minRadius = 160
            electricF.falloff = 1.4
            electricF.strength = 1700
            
            magneticF.enabled = true
            magneticF.radius = 820
            magneticF.minRadius = 120
            magneticF.falloff = 1.2
            magneticF.strength = 800
            
            turb.enabled = true
            turb.radius = 420
            turb.minRadius = 60
            turb.strength = 420
            
            dragF.enabled = true
            dragF.strength = 3.6
            
        case .goldenSpiral:
            vortex.enabled = true
            vortex.radius = 1000
            vortex.minRadius = 100
            vortex.falloff = 1.618
            vortex.strength = 1600
            
            radial.enabled = true
            radial.radius = 760
            radial.minRadius = 80
            radial.falloff = 1.0
            radial.strength = 2400
            
            dragF.enabled = true
            dragF.strength = 1.7
            
            noiseF.enabled = true
            noiseF.radius = 600
            noiseF.smoothness = 0.6
            noiseF.animationSpeed = 0.5
            noiseF.strength = 150
            
        case .dustDevil:
            vortex.enabled = true
            vortex.radius = 520
            vortex.minRadius = 60
            vortex.falloff = 1.05
            vortex.strength = 2200
            
            linear.enabled = true
            linear.vector = .init(1, 0)
            linearAngleDeg = 0
            linear.strength = 180
            
            noiseF.enabled = true
            noiseF.radius = 720
            noiseF.smoothness = 0.3
            noiseF.animationSpeed = 1.2
            noiseF.strength = 300
            
            dragF.enabled = true
            dragF.strength = 1.2
            
        case .solarFlare:
            radial.enabled = true
            radial.radius = 1200
            radial.minRadius = 140
            radial.falloff = 1.2
            radial.strength = 7200
            
            electricF.enabled = true
            electricF.radius = 760
            electricF.minRadius = 120
            electricF.falloff = 1.8
            electricF.strength = 1400
            
            magneticF.enabled = true
            magneticF.radius = 900
            magneticF.minRadius = 160
            magneticF.falloff = 1.5
            magneticF.strength = 1000
            
            turb.enabled = true
            turb.radius = 540
            turb.minRadius = 80
            turb.strength = 1300
            
            dragF.enabled = true
            dragF.strength = 1.1
            
        // New batch below
        case .kelvinHelmholtz:
            velocityF.enabled = true
            velocityF.vector = .init(1, 0)
            velocityAngleDeg = 0
            velocityF.strength = 900
            
            linear.enabled = true
            linear.vector = .init(-1, 0)
            linearAngleDeg = 180
            linear.strength = 120
            
            vortex.enabled = true
            vortex.radius = 420
            vortex.minRadius = 70
            vortex.falloff = 1.08
            vortex.strength = 420
            
            noiseF.enabled = true
            noiseF.radius = 900
            noiseF.smoothness = 0.75
            noiseF.animationSpeed = 0.7
            noiseF.strength = 180
            
            dragF.enabled = true
            dragF.strength = 2.0
            
        case .rayleighTaylor:
            linearGravityF.enabled = true
            linearGravityF.vector = .init(0, -1)
            linearGravityAngleDeg = 270
            linearGravityF.strength = 400
            
            velocityF.enabled = true
            velocityF.vector = .init(0, 1)
            velocityAngleDeg = 90
            velocityF.strength = 520
            
            turb.enabled = true
            turb.radius = 680
            turb.minRadius = 120
            turb.strength = 1100
            
            noiseF.enabled = true
            noiseF.radius = 1200
            noiseF.smoothness = 0.5
            noiseF.animationSpeed = 1.3
            noiseF.strength = 300
            
            dragF.enabled = true
            dragF.strength = 2.4
            
        case .karmanStreet:
            velocityF.enabled = true
            velocityF.vector = .init(1, 0)
            velocityAngleDeg = 0
            velocityF.strength = 700
            
            vortex.enabled = true
            vortex.radius = 380
            vortex.minRadius = 60
            vortex.falloff = 1.02
            vortex.strength = 520
            
            noiseF.enabled = true
            noiseF.radius = 680
            noiseF.smoothness = 0.4
            noiseF.animationSpeed = 1.5
            noiseF.strength = 220
            
            dragF.enabled = true
            dragF.strength = 1.6
            
        case .bowShock:
            velocityF.enabled = true
            velocityF.vector = .init(1, 0)
            velocityAngleDeg = 0
            velocityF.strength = 950
            
            radial.enabled = true
            radial.radius = 300
            radial.minRadius = 40
            radial.falloff = 2.2
            radial.strength = 5000
            
            turb.enabled = true
            turb.radius = 520
            turb.minRadius = 90
            turb.strength = 1000
            
            dragF.enabled = true
            dragF.strength = 2.2
            
        case .ferrofluid:
            magneticF.enabled = true
            magneticF.radius = 680
            magneticF.minRadius = 50
            magneticF.falloff = 2.2
            magneticF.strength = 2000
            
            springF.enabled = true
            springF.radius = 420
            springF.minRadius = 20
            springF.falloff = 1.8
            springF.strength = 7.5
            
            noiseF.enabled = true
            noiseF.radius = 300
            noiseF.smoothness = 0.25
            noiseF.animationSpeed = 0.3
            noiseF.strength = 120
            
            dragF.enabled = true
            dragF.strength = 2.0
            
        case .ionThruster:
            electricF.enabled = true
            electricF.radius = 900
            electricF.minRadius = 150
            electricF.falloff = 1.4
            electricF.strength = 2200
            
            velocityF.enabled = true
            velocityF.vector = .init(1, 0)
            velocityAngleDeg = 0
            velocityF.strength = 600
            
            dragF.enabled = true
            dragF.strength = 1.3
            
            noiseF.enabled = true
            noiseF.radius = 500
            noiseF.smoothness = 0.6
            noiseF.animationSpeed = 0.5
            noiseF.strength = 140
            
        case .galaxyDisk:
            vortex.enabled = true
            vortex.radius = 1200
            vortex.minRadius = 120
            vortex.falloff = 1.2
            vortex.strength = 2200
            
            radial.enabled = true
            radial.radius = 900
            radial.minRadius = 80
            radial.falloff = 0.8
            radial.strength = 800
            
            dragF.enabled = true
            dragF.strength = 0.9
            
            noiseF.enabled = true
            noiseF.radius = 800
            noiseF.smoothness = 0.8
            noiseF.animationSpeed = 0.4
            noiseF.strength = 120
            
        case .murmuration:
            springF.enabled = true
            springF.radius = 900
            springF.minRadius = 140
            springF.falloff = 1.1
            springF.strength = 5.0
            
            velocityF.enabled = true
            velocityF.vector = .init(1, 0)
            velocityAngleDeg = 0
            velocityF.strength = 260
            
            noiseF.enabled = true
            noiseF.radius = 700
            noiseF.smoothness = 0.7
            noiseF.animationSpeed = 0.9
            noiseF.strength = 180
            
            dragF.enabled = true
            dragF.strength = 1.1
            
        case .supercell:
            velocityF.enabled = true
            velocityF.vector = .init(0, 1)
            velocityAngleDeg = 90
            velocityF.strength = 750
            
            vortex.enabled = true
            vortex.radius = 620
            vortex.minRadius = 120
            vortex.falloff = 1.1
            vortex.strength = 1400
            
            linearGravityF.enabled = true
            linearGravityF.vector = .init(0, -1)
            linearGravityAngleDeg = 270
            linearGravityF.strength = 160
            
            radial.enabled = true
            radial.radius = 520
            radial.minRadius = 80
            radial.falloff = 1.7
            radial.strength = -2600
            
            dragF.enabled = true
            dragF.strength = 1.8
            
        case .snowfall:
            linearGravityF.enabled = true
            linearGravityF.vector = .init(0, -1)
            linearGravityAngleDeg = 270
            linearGravityF.strength = 600
            
            velocityF.enabled = true
            velocityF.vector = .init(0, -1)
            velocityAngleDeg = 270
            velocityF.strength = 120
            
            noiseF.enabled = true
            noiseF.radius = 1400
            noiseF.smoothness = 0.95
            noiseF.animationSpeed = 0.2
            noiseF.strength = 140
            
            dragF.enabled = true
            dragF.strength = 4.2
            
        case .planktonBloom:
            noiseF.enabled = true
            noiseF.radius = 1400
            noiseF.smoothness = 0.88
            noiseF.animationSpeed = 0.35
            noiseF.strength = 260
            
            springF.enabled = true
            springF.radius = 680
            springF.minRadius = 60
            springF.falloff = 1.6
            springF.strength = 6.0
            
            radial.enabled = true
            radial.radius = 860
            radial.minRadius = 120
            radial.falloff = 1.4
            radial.strength = -1600
            
            dragF.enabled = true
            dragF.strength = 2.1
            
        case .cyclotron:
            magneticF.enabled = true
            magneticF.radius = 1000
            magneticF.minRadius = 160
            magneticF.falloff = 1.3
            magneticF.strength = 1600
            
            electricF.enabled = true
            electricF.radius = 900
            electricF.minRadius = 140
            electricF.falloff = 1.6
            electricF.strength = 1300
            
            vortex.enabled = true
            vortex.radius = 700
            vortex.minRadius = 100
            vortex.falloff = 1.2
            vortex.strength = 900
            
            dragF.enabled = true
            dragF.strength = 1.5
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
