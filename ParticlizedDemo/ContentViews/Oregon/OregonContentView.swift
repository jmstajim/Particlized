import SwiftUI
import Particlized
import simd

struct OregonContentView: View {
    enum FieldChoice: String, CaseIterable, Identifiable {
        case radial = "Radial"
        case linear = "Linear"
        case turbulence = "Turbulence"
        case vortex = "Vortex"
        case drag = "Drag"
        case velocity = "Velocity"
        case linearGravity = "Linear Gravity"
        case noise = "Noise"
        case electric = "Electric"
        case magnetic = "Magnetic"
        case spring = "Spring"
        var id: String { rawValue }
    }

    @State private var choice: FieldChoice = .radial

    @State private var radial = RadialFieldNode(position: .zero, strength: -10000, radius: 500, falloff: 0.5, minRadius: 0, enabled: false)
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
            .init(item: .text(text), position: .init(x: 0, y: 150))
        ]
    }

    private func convertToCentered(_ geo: GeometryProxy, fromGlobal point: CGPoint) -> CGPoint {
        let rect = geo.frame(in: .global)
        let centerX = rect.midX
        let centerY = rect.midY
        let scale = UIScreen.main.scale
        let xpx = (point.x - centerX) * scale
        let ypx = (centerY - point.y) * scale
        return CGPoint(x: xpx, y: ypx)
    }

    private func updateVectorFromAngle(_ angleDeg: Double) -> SIMD2<Float> {
        let rad = angleDeg * .pi / 180.0
        return SIMD2<Float>(Float(cos(rad)), Float(sin(rad)))
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
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                MetalParticleView(
                    spawns: spawns,
                    fields: [
                        .radial(radial),
                        .linear(linear),
                        .turbulence(turb),
                        .vortex(vortex),
                        .drag(dragF),
                        .velocity(velocityF),
                        .linearGravity(linearGravityF),
                        .noise(noiseF),
                        .electric(electricF),
                        .magnetic(magneticF),
                        .spring(springF)
                    ],
                    controls: controls,
                    backgroundColor: .white
                )
                .contentShape(Rectangle())
                .onAppear {
                    if spawns.isEmpty {
                        spawns = makeInitialSpawns()
                    }
                    updateAnglesFromVectorsIfNeeded()
                }
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged { value in
                            let p = convertToCentered(geo, fromGlobal: value.location)
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
                                        linear.vector = updateVectorFromAngle(linearAngleDeg)
                                    }
                                }
                            case .velocity:
                                velocityF.enabled = true
                                if let s = dragStartParticleSpace {
                                    let dx = Float(p.x - s.x), dy = Float(p.y - s.y)
                                    if hypot(Double(dx), Double(dy)) > 1e-3 {
                                        let angle = atan2(Double(dy), Double(dx)) * 180.0 / .pi
                                        velocityAngleDeg = (angle < 0 ? angle + 360 : angle)
                                        velocityF.vector = updateVectorFromAngle(velocityAngleDeg)
                                    }
                                }
                            case .linearGravity:
                                linearGravityF.enabled = true
                                if let s = dragStartParticleSpace {
                                    let dx = Float(p.x - s.x), dy = Float(p.y - s.y)
                                    if hypot(Double(dx), Double(dy)) > 1e-3 {
                                        let angle = atan2(Double(dy), Double(dx)) * 180.0 / .pi
                                        linearGravityAngleDeg = (angle < 0 ? angle + 360 : angle)
                                        linearGravityF.vector = updateVectorFromAngle(linearGravityAngleDeg)
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

                compactControlDock
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
            }
        }
    }

    // MARK: - Compact Dock (always visible)

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

    @ViewBuilder
    private var compactControlDock: some View {
        VStack(spacing: 8) {
            // Top row: field chooser + quick actions
            HStack(spacing: 8) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
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
                            .accessibilityLabel(c.rawValue)
                        }
                    }
                    .padding(.vertical, 2)
                }

                Spacer(minLength: 4)

                Button {
                    controls.homingOnlyWhenNoFields.toggle()
                } label: {
                    Image(systemName: controls.homingOnlyWhenNoFields ? "house.fill" : "house")
                        .imageScale(.large)
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary.opacity(0.25), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Homing when no fields")

                Button(role: .destructive) {
                    disableAllFields()
                } label: {
                    Image(systemName: "xmark.circle")
                        .imageScale(.large)
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary.opacity(0.25), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Disable all fields")

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { panelCollapsed.toggle() }
                } label: {
                    Image(systemName: panelCollapsed ? "chevron.up.circle" : "chevron.down.circle")
                        .imageScale(.large)
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary.opacity(0.25), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Toggle parameters")
            }

            if !panelCollapsed {
                parameterPanel
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .shadow(radius: 4, y: 2)
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

    // MARK: - Parameter Panel (compact, always visible)

    @ViewBuilder
    private var parameterPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(choice.rawValue) Parameters").font(.footnote).foregroundStyle(.secondary)

            switch choice {
            case .radial:
                Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                    GridRow { Toggle("Enabled", isOn: $radial.enabled).font(.footnote) }
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
                    GridRow { Toggle("Enabled", isOn: $linear.enabled).font(.footnote) }
                    sliderRow("Strength", value: Binding(get: { Double(linear.strength) }, set: { linear.strength = Float($0) }), range: 0...1000, format: { "\(Int($0))" })
                    sliderRow("Angle °", value: $linearAngleDeg, range: 0...360, step: 1) {
                        linear.vector = updateVectorFromAngle($0)
                        return "\(Int($0))"
                    }
                }
            case .turbulence:
                Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                    GridRow { Toggle("Enabled", isOn: $turb.enabled).font(.footnote) }
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
                    GridRow { Toggle("Enabled", isOn: $vortex.enabled).font(.footnote) }
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
                    GridRow { Toggle("Enabled", isOn: $dragF.enabled).font(.footnote) }
                    sliderRow("Strength", value: Binding(get: { Double(dragF.strength) }, set: { dragF.strength = Float($0) }), range: 0...20, format: { String(format: "%.2f", $0) })
                }
            case .velocity:
                Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                    GridRow { Toggle("Enabled", isOn: $velocityF.enabled).font(.footnote) }
                    sliderRow("Strength", value: Binding(get: { Double(velocityF.strength) }, set: { velocityF.strength = Float($0) }), range: 0...2000, format: { "\(Int($0))" })
                    sliderRow("Angle °", value: $velocityAngleDeg, range: 0...360, step: 1) {
                        velocityF.vector = updateVectorFromAngle($0)
                        return "\(Int($0))"
                    }
                }
            case .linearGravity:
                Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                    GridRow { Toggle("Enabled", isOn: $linearGravityF.enabled).font(.footnote) }
                    sliderRow("Strength", value: Binding(get: { Double(linearGravityF.strength) }, set: { linearGravityF.strength = Float($0) }), range: 0...2000, format: { "\(Int($0))" })
                    sliderRow("Angle °", value: $linearGravityAngleDeg, range: 0...360, step: 1) {
                        linearGravityF.vector = updateVectorFromAngle($0)
                        return "\(Int($0))"
                    }
                }
            case .noise:
                Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                    GridRow { Toggle("Enabled", isOn: $noiseF.enabled).font(.footnote) }
                    sliderRow("Strength",    value: Binding(get: { Double(noiseF.strength) }, set: { noiseF.strength = Float($0) }), range: 0...5000, format: { "\(Int($0))" })
                    sliderRow("Radius",      value: Binding(get: { Double(noiseF.radius) },   set: {
                        noiseF.radius = Float($0)
                    }), range: 0...1500, format: { "\(Int($0))" })
                    sliderRow("Smoothness",  value: Binding(get: { Double(noiseF.smoothness) }, set: { noiseF.smoothness = Float($0) }), range: 0...1, format: { String(format: "%.2f", $0) })
                    sliderRow("Anim speed",  value: Binding(get: { Double(noiseF.animationSpeed) }, set: { noiseF.animationSpeed = Float($0) }), range: 0...5, format: { String(format: "%.2f", $0) })
                }
            case .electric:
                Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                    GridRow { Toggle("Enabled", isOn: $electricF.enabled).font(.footnote) }
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
                    GridRow { Toggle("Enabled", isOn: $magneticF.enabled).font(.footnote) }
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
                    GridRow { Toggle("Enabled", isOn: $springF.enabled).font(.footnote) }
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

            // Homing group
            Group {
                Text("Homing").font(.footnote).foregroundStyle(.secondary)
                Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                    GridRow { Toggle("Only when no fields", isOn: $controls.homingOnlyWhenNoFields).font(.footnote) }
                    sliderRow("Homing K", value: Binding(get: { Double(controls.homingStrength) }, set: { controls.homingStrength = Float($0) }), range: 0...120, format: { "\(Int($0))" })
                    sliderRow("Damping",  value: Binding(get: { Double(controls.homingDamping) },  set: { controls.homingDamping  = Float($0) }), range: 0...20,  format: { String(format: "%.1f", $0) })
                }
            }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // Common compact slider row
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
                    .frame(width: 64, alignment: .trailing)
            }
        }
        .onChange(of: value.wrappedValue) { newVal in
            _ = onChange?(newVal)
        }
    }
}

#Preview {
    OregonContentView()
}
