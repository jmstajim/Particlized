//
//  ContentView.swift
//  ParticlizedDemo
//
//  Created by Aleksei Gusachenko on 29.04.2024.
//

import SwiftUI
import Particlized
import SpriteKit

struct OregonContentView: View {
    private let scene: SKScene = {
        $0.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        $0.scaleMode = .resizeFill
        $0.backgroundColor = .white
        return $0
    }(SKScene())
    
    private let text = ParticlizedText(
        text: "Oregon 🦫",
        font: UIFont(name: "SnellRoundhand", size: 40)!,
        textColor: .red,
        emitterNode: .init(fileNamed: "OregonTextParticle.sks")!,
        numberOfPixelsPerNode: 2,
        nodeSkipPercentageChance: 0
    )
    
    private let image = ParticlizedImage(
        image: UIImage(named: "oregon")!,
        emitterNode: .init(fileNamed: "OregonImageParticle.sks")!,
        numberOfPixelsPerNode: 6,
        nodeSkipPercentageChance: 0
    )
    
    private let radialGravity: SKFieldNode = {
        $0.isEnabled = false
        $0.strength = 5
        $0.falloff = 1
        return $0
    }(SKFieldNode.radialGravityField())
    
    private let noise: SKFieldNode = {
        $0.isEnabled = false
        $0.strength = 4
        $0.falloff = 1
        return $0
    }(SKFieldNode.noiseField(withSmoothness: 1, animationSpeed: 10))
    
    private let linearGravity: SKFieldNode = {
        $0.isEnabled = false
        $0.strength = 1
        return $0
    }(SKFieldNode.linearGravityField(withVector: .init(x: 0, y: 1, z: 0)))
    
    private let turbulence: SKFieldNode = {
        $0.isEnabled = false
        return $0
    }(SKFieldNode.turbulenceField(withSmoothness: 0.4, animationSpeed: 1))
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .onAppear(perform: {
                    scene.addChild(image)
                    scene.addChild(text)
                    text.position = .init(x: 0, y: -220)
                    scene.addChild(radialGravity)
                    scene.addChild(noise)
                    scene.addChild(linearGravity)
                    scene.addChild(turbulence)
                })
        }
        .onTapGesture {
            noise.isEnabled = false
        }
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    let fieldLocation = scene.convertPoint(fromView: value.location)
                    radialGravity.position = fieldLocation
                    radialGravity.isEnabled = true
                }
                .onEnded { dragGestureValue in
                    radialGravity.isEnabled = false
                }
            
        )
        .onLongPressGesture(
            perform: {
                noise.isEnabled = true
            }
        )
        .simultaneousGesture(
            TapGesture(count: 2)
                .onEnded { _ in
                    linearGravity.isEnabled.toggle()
                    turbulence.isEnabled.toggle()
                }
        )
        .simultaneousGesture(
            TapGesture(count: 3)
                .onEnded { _ in
                    text.isEmitting.toggle()
                    image.isEmitting.toggle()
                }
        )
        .ignoresSafeArea()
    }
}

#Preview {
    OregonContentView()
}
