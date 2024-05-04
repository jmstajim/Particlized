# Particlized

Particlized is a Swift library that enables developers to easily turn text, emoji, or images into particles aka SKEmitterNodes.

[See more examples on YouTube](https://youtu.be/JRN9YDiMbXU)

<img src="https://github.com/jmstajim/Particlized/assets/25672213/b6c73d67-aed7-4ed3-8a5d-78ab1c44b477" width="280" />
<img src="https://github.com/jmstajim/Particlized/assets/25672213/0dccc7b6-7861-4957-9eab-edd133e2b9cd" width="280" />


<img src="https://github.com/jmstajim/Particlized/assets/25672213/660407cc-d1de-4264-9c06-89ffb13f29f8" width="280" />
<img src="https://github.com/jmstajim/Particlized/assets/25672213/64999983-e118-449d-8483-b00becd32eb1" width="280" />

## Features

- **ParticlizedText:** turn text and emoji into particles.
- **ParticlizedImage:** turn image into particles.

## Installation

### Swift Package Manager

1. In Xcode, go to `File` > `Swift Packages` > `Add Package Dependency...`
2. Enter the repository URL (https://github.com/jmstajim/Particlized.git).
3. Follow the steps to specify versioning, branch, or tag.
4. Click `Finish`.

### CocoaPods

*TODO*

## Usage

1. Import Particlized module into your view controller:

```swift
import Particlized
```

2. Create a Particlized instance:

```swift
let text = ParticlizedText(
    text: "Oregon 🦫",
    font: UIFont(name: "SnellRoundhand", size: 40)!,
    textColor: .red,
    emitterNode: .init(fileNamed: "TextParticle.sks")!,
    numberOfPixelsPerNode: 2,
    nodeSkipPercentageChance: 0
)
```
or

```swift
let image = ParticlizedImage(
    image: UIImage(named: "oregon")!,
    emitterNode: .init(fileNamed: "ImageParticle.sks")!,
    numberOfPixelsPerNode: 6,
    nodeSkipPercentageChance: 0
)
```

3. Add the Particlized object to your SKScene:

```swift
scene.addChild(text)
```

```swift
scene.addChild(image)
```

## Customization

The behavior of the Particlized object is overridden from SKEmitterNode, but has not been tested and may not work as expected.

## Example

To see Particlized in action, check out the included Demo project.
Check ParticlizedDemoApp.swift to choose a scene.

Gestures to try:
* Tap gesture x1, x2, x3 times
* Long press gesture
* Drag gesture

## Limitations

By default, SKEmitterNodes are created for each pixel. Be mindful of device resources.

## License

Particlized is available under the MIT license. See the LICENSE file for more info.

## Support

For any questions, issues, or feature requests, please open an issue on GitHub

or reach out to [gusachenkoalexius@gmail.com](mailto:gusachenkoalexius@gmail.com) or [LinkedIn](https://www.linkedin.com/in/jmstajim/).
