# Particlized

Particlized is a Swift library that enables developers to easily turn text, emoji, or images into particles aka SKEmitterNodes

<img src="https://github.com/jmstajim/Particlized/assets/25672213/a1db709d-4178-4351-b3dc-9057030406ae" width="300" />
<img src="https://github.com/jmstajim/Particlized/assets/25672213/3916cca7-910b-4101-801a-827879aea1ba" width="300" />

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
    density: 2,
    skipChance: 0
)
```
or

```swift
let image = ParticlizedImage(
    image: UIImage(named: "oregon")!,
    emitterNode: .init(fileNamed: "ImageParticle.sks")!,
    density: 6,
    skipChance: 0
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

*TODO*

## Example

To see Particlized in action, check out the included Demo project.

## Limitations

By default, SKEmitterNodes are created for each pixel. Be mindful of device resources.

## License

Particlized is available under the MIT license. See the LICENSE file for more info.

## Support

For any questions, issues, or feature requests, please open an issue on GitHub

or reach out to [gusachenkoalexius@gmail.com](mailto:gusachenkoalexius@gmail.com) or [LinkedIn](https://www.linkedin.com/in/jmstajim/).
