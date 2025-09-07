# Particlized — now powered by Metal ⚡️

Particlized is a Swift library that turns text and images into GPU‑accelerated particle systems using **Metal** and **MetalKit**.

A custom Metal renderer (compute + render pipelines) for high performance and flexibility.

## Features
- **ParticlizedText** – rasterize text/emoji to pixels and spawn particles.
- **ParticlizedImage** – sample image pixels and spawn particles.
- **Field nodes** (Metal): `RadialFieldNode`, `LinearFieldNode`, `LinearGravityFieldNode`, `TurbulenceFieldNode`, `VortexFieldNode`, `NoiseFieldNode`, `ElectricFieldNode`, `MagneticFieldNode`, `SpringFieldNode`, `VelocityFieldNode`, `DragFieldNode`.
- **Homing behavior** - for smooth return to origin when fields are off.
- **SwiftUI demo** – interactive controls to tweak fields live.

## Requirements
- iOS 17+
- Swift 5.10+
- Metal‑capable device/simulator

## Installation (Swift Package Manager)
1. In Xcode: **File → Add Packages…**
2. Enter the repository URL.
3. Add the **Particlized** library target.

## Quick start
~~~swift
import Particlized
import SwiftUI

let text = ParticlizedText(
    text: "Hello, Metal!",
    font: .systemFont(ofSize: 36, weight: .bold),
    textColor: .black
)

let logo = ParticlizedImage(
    image: UIImage(named: "logo")!
)

let spawns: [ParticlizedSpawn] = [
    .init(item: .text(text), position: .init(x: 0, y: 160)),
    .init(item: .image(logo), position: .init(x: -80, y: -40))
]

let fields: [ParticlizedFieldNode] = [
    .radial(.init(position: .zero, strength: -9000, radius: 200, falloff: 0.5, minRadius: 0, enabled: false)),
    .linear(.init(vector: .init(0, -1), strength: 120, enabled: false)),
    .turbulence(.init(position: .zero, strength: 800, radius: 400, minRadius: 0, enabled: false))
]

ParticlizedView(spawns: spawns, fields: fields, backgroundColor: .white)
~~~

## Demo app
Open **ParticlizedDemo** in the repo to try live controls (field picker, sliders, homing toggle) on device or simulator.

## License

Particlized is available under the MIT license. See the LICENSE file for more info.

## Support

For any questions, issues, or feature requests, please open an issue on GitHub
