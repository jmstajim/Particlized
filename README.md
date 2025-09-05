# Particlized (Metal Edition)

Particlized is a Swift library that turns text and images into GPU-accelerated particle systems using **Metal/MetalKit**.

This rewrite removes SpriteKit and implements a custom Metal renderer with a compute shader. It now supports:

- **Placed items**: spawn text/images at arbitrary positions.
- **Field nodes** (analogs of `SKFieldNode`): radial, linear, and turbulence fields.

## Features

- **ParticlizedText**: rasterize text/emoji to pixels and spawn particles.
- **ParticlizedImage**: sample image pixels and spawn particles.
- **MetalParticleView**: a SwiftUI-compatible view backed by `MTKView` that renders particles via Metal.
- **Field nodes**: `RadialFieldNode`, `LinearFieldNode`, `TurbulenceFieldNode`.
- Gesture-friendly demos.

## Installation

### Swift Package Manager

1. In Xcode, go to `File` → `Swift Packages` → `Add Package Dependency…`
2. Enter the repository URL (your fork).
3. Choose the `Particlized` library target.

The package requires iOS 17+. It links `Metal`, `MetalKit`, `UIKit`, and `SwiftUI`.

## Usage

### Placed Items
```swift
import Particlized

let text = ParticlizedText(text: "Hello", font: .systemFont(ofSize: 32, weight: .bold), textColor: .black)
let logo = ParticlizedImage(image: UIImage(named: "logo")!, numberOfPixelsPerNode: 3)

let spawns: [ParticlizedSpawn] = [
    .init(item: .text(text), position: CGPoint(x: 0, y: 120)),
    .init(item: .image(logo), position: CGPoint(x: -80, y: -60))
]

MetalParticleView(
    spawns: spawns,
    fields: [],
    backgroundColor: .white
)
