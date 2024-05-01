//
//  AlgoContentView.swift
//  ParticlizedDemo
//
//  Created by Aleksei Gusachenko on 01.05.2024.
//

import SwiftUI
import Particlized
import SpriteKit

struct AlgoContentView: View {
    private let scene: SKScene = {
        $0.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        $0.scaleMode = .resizeFill
        $0.backgroundColor = .black
        return $0
    }(SKScene())
    
    private let text = ParticlizedText(
        text: """
        DATA STRUCTURES
        ‾‾‾ ALGORITHMS ‾‾‾
        """,
        font: UIFont(name: "AcademyEngravedLetPlain", size: 25)!,
        textColor: UIColor(red: 255 / 255, green: 21 / 255, blue: 21 / 255, alpha: 1),
        emitterNode: .init(fileNamed: "AlgoTextParticle.sks")!,
        density: 1,
        skipChance: 0
    )
    
    private let radialGravity: SKFieldNode = {
        $0.isEnabled = false
        $0.strength = -2
        $0.falloff = -0.5
        $0.region = .init(radius: 30)
        return $0
    }(SKFieldNode.radialGravityField())
    
    private let turbulence: SKFieldNode = {
        $0.isEnabled = false
        $0.strength = 10
        $0.falloff = -1
        return $0
    }(SKFieldNode.turbulenceField(withSmoothness: 0.1, animationSpeed: 100))
    
    private let linearGravity: SKFieldNode = {
        $0.isEnabled = false
        $0.strength = 1
        return $0
    }(SKFieldNode.linearGravityField(withVector: .init(x: 0, y: 1, z: 0)))
    
    private let turbulenceForLinearGravity: SKFieldNode = {
        $0.isEnabled = false
        return $0
    }(SKFieldNode.turbulenceField(withSmoothness: 0.1, animationSpeed: 1))
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .onAppear(perform: {
                    scene.addChild(text)
                    scene.addChild(radialGravity)
                    scene.addChild(turbulence)
                    scene.addChild(linearGravity)
                    scene.addChild(turbulenceForLinearGravity)
                })
        }
        .onTapGesture {
            turbulence.isEnabled = false
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
                turbulence.isEnabled = true
            }
        )
        .simultaneousGesture(
            TapGesture(count: 2)
                .onEnded { _ in
                    linearGravity.isEnabled.toggle()
                    turbulenceForLinearGravity.isEnabled.toggle()
                }
        )
        .simultaneousGesture(
            TapGesture(count: 3)
                .onEnded { _ in
                    text.particleBirthRate = 0
                }
        )
        .ignoresSafeArea()
    }
}

#Preview {
    AlgoContentView()
}
