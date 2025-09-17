# Particlized — now powered by Metal ⚡️

[![Version](https://img.shields.io/github/v/release/jmstajim/Particlized?sort=semver&display_name=tag&label=version&color=217DD1&style=flat-square)](https://github.com/jmstajim/Particlized/releases/latest)

Particlized is a Swift library that turns text and images into GPU‑accelerated particle systems using **Metal** and **MetalKit**.

A custom Metal renderer (compute + render pipelines) gives high performance and flexibility.

## Features
- **ParticlizedText** – rasterize text/emoji to pixels and spawn particles.
- **ParticlizedImage** – sample image pixels and spawn particles.
- **Force fields**: `Radial`, `Linear`, `LinearGravity`, `Turbulence`, `Vortex`, `Noise`, `Electric`, `Magnetic`, `Spring`, `Velocity`, `Drag`.
- **Homing behavior** – smooth return to origin.
- **SwiftUI view** – drop-in `ParticlizedView` that renders a `ParticlizedScene`.
- **Plugin system** – add your own field type via `PluginField` and `FieldPluginRegistry`.
- **Demo app** – interactive control dock with presets.

## Requirements
- iOS 17+
- Swift 5.10+
- A Metal‑capable device/simulator

## Installation (Swift Package Manager)
1. In Xcode: **File → Add Packages…**
2. Enter this repository URL.
3. Add the **Particlized** library target to your app.

## Quick start
~~~swift
import SwiftUI
import Particlized

struct ContentView: View {
    var body: some View {
        let text = ParticlizedText(
            text: "Hello, Metal!",
            font: .systemFont(ofSize: 36, weight: .bold),
            textColor: .black,
            numberOfPixelsPerNode: 2,
            nodeSkipPercentageChance: 40 // sample fewer pixels = fewer particles
        )

        let logo = ParticlizedImage(image: UIImage(named: "logo")!)

        let spawns: [ParticlizedSpawn] = [
            .init(item: .text(text),  position: .init(x: 0,   y: 160)),
            .init(item: .image(logo), position: .init(x: -80, y: -40))
        ]

        var controls = ParticlizedControls()
        controls.homingEnabled = true
        controls.homingOnlyWhenNoFields = true
        controls.homingStrength = 40
        controls.homingDamping = 8

        var radial  = RadialFieldNode(position: .zero, strength: -6000, radius: 180, falloff: 0.8, minRadius: 0, enabled: false)
        var noise   = NoiseFieldNode(position: .zero, strength: 900, radius: 600, smoothness: 0.6, animationSpeed: 0.8, minRadius: 0, enabled: true)
        var vortex  = VortexFieldNode(position: .zero, strength: 800, radius: 400, falloff: 1.0, minRadius: 0, enabled: false)
        var gravity = LinearGravityFieldNode(vector: .init(0, -1), strength: 150, enabled: false)
        var drag    = DragFieldNode(strength: 2.5, enabled: true)

        ParticlizedView(scene: .init(
            spawns: spawns,
            fields: [
                .noise(noise),
                .radial(radial),
                .vortex(vortex),
                .linearGravity(gravity),
                .drag(drag)
            ],
            controls: controls,
            backgroundColor: .white
        ))
    }
}
~~~

## Coordinate system & units
- Coordinates are in **particle space** (pixels at device scale), centered at `(0, 0)` with **+Y up**.
- When mapping from view/touch coordinates, convert to centered pixel space (see demo’s `Math.convertToCentered`).

## Extensibility (custom fields)
You can ship custom forces without forking the library:
~~~swift
// 1) Implement a FieldPlugin
struct MyFieldPlugin: FieldPlugin {
    let key = "my.field"
    func gpuFieldDescs(from field: PluginField) -> [GPUFieldDesc] {
        // translate your high‑level params → one or more GPUFieldDesc
        // return [GPUFieldDesc(kind: .radial, strength: ..., ...)]
        return []
    }
}

// 2) Register once (e.g., at app launch)
FieldPluginRegistry.shared.register(MyFieldPlugin())

// 3) Use it in a scene
let plugin = PluginField(pluginKey: "my.field", position: .zero, vector: .init(1,0), params: ["strength": 500], enabled: true)
// ...
let fields: [ParticlizedFieldNode] = [.plugin(plugin)]
~~~

## Demo
Open the **ParticlizedDemo** target to try the interactive control dock and presets.

## License
Particlized is available under the MIT license. See the LICENSE file for more info.

## Support
For any questions, issues, or feature requests, please open an issue on GitHub
or reach out to [gusachenkoalexius@gmail.com](mailto:gusachenkoalexius@gmail.com) or [LinkedIn](https://www.linkedin.com/in/jmstajim/).
