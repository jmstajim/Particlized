//
//  SaleContentView.swift
//  ParticlizedDemo
//
//  Created by Aleksei Gusachenko on 01.05.2024.
//

import SwiftUI
import Particlized
import SpriteKit

struct SaleContentView: View {
    private let scene: SKScene = {
        $0.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        $0.scaleMode = .resizeFill
        $0.backgroundColor = .white
        return $0
    }(SKScene())
    
    private let saleText = ParticlizedText(
        text: "Sale",
        font: UIFont(name: "MuktaMahee-Bold", size: 120)!,
        textColor: nil,
        emitterNode: .init(fileNamed: "SaleTextParticle.sks")!,
        density: 1,
        skipChance: 1
    )
    
    private let offText = ParticlizedText(
        text: "50% off",
        font: UIFont(name: "SnellRoundhand", size: 60)!,
        textColor: .black,
        emitterNode: .init(fileNamed: "SaleTextParticle.sks")!,
        density: 1,
        skipChance: 0,
        isEmittingOnStart: false
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
    }(SKFieldNode.linearGravityField(withVector: .init(x: 1, y: 0, z: 0)))
    
    private let turbulenceForLinearGravity: SKFieldNode = {
        $0.isEnabled = false
        return $0
    }(SKFieldNode.turbulenceField(withSmoothness: 0.1, animationSpeed: 1))
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .onAppear(perform: {
                    scene.addChild(saleText)
                    scene.addChild(offText)
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
                    offText.isEmitting.toggle()
                    saleText.isEmitting.toggle()
                    linearGravity.isEnabled = false
                    turbulenceForLinearGravity.isEnabled = false
                }
        )
        .ignoresSafeArea()
    }
}

#Preview {
    AlgoContentView()
}
