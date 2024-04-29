//
//  ContentView.swift
//  ParticlizedDemo
//
//  Created by Aleksei Gusachenko on 29.04.2024.
//

import SwiftUI
import Particlized
import SpriteKit

struct ContentView: View {
    private let scene: SKScene = {
        $0.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        $0.scaleMode = .resizeFill
        $0.backgroundColor = .white
        return $0
    }(SKScene())
    
    let text = ParticlizedText(
        text: "Hi😍📱🌄",
        font: UIFont(name: "HelveticaNeue", size: 70)!,
        textColor: .black,
        emitterNode: .init(fileNamed: "TextParticle.sks")!,
        density: 2,
        skipChance: 0
    )
    
    let image = ParticlizedImage(
        image: UIImage(named: "antalya")!,
        emitterNode: .init(fileNamed: "ImageParticle.sks")!,
        density: 6,
        skipChance: 0
    )
    
    var body: some View {
        ZStack {
            Image(.antalya)
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear(perform: {
                    scene.addChild(image)
                    image.position = .init(x: 0, y: -100)
                    scene.addChild(text)
                    text.position = .init(x: 0, y: 150)
                })
                .onTapGesture {
                }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
