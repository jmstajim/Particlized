import SwiftUI

final class FPSCounter: ObservableObject {
    @Published var fps: Int = 0
    
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount = 0
    private var accumulator: CFTimeInterval = 0
    
    func start() {
        stop()
        let link = CADisplayLink(target: self, selector: #selector(step(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        lastTimestamp = 0
        frameCount = 0
        accumulator = 0
        fps = 0
    }
    
    @objc private func step(_ link: CADisplayLink) {
        if lastTimestamp == 0 { lastTimestamp = link.timestamp; return }
        let delta = link.timestamp - lastTimestamp
        lastTimestamp = link.timestamp
        
        frameCount += 1
        accumulator += delta
        
        if accumulator >= 1.0 {
            let current = Int(round(Double(frameCount) / accumulator))
            DispatchQueue.main.async { self.fps = current }
            frameCount = 0
            accumulator = 0
        }
    }
}

struct FPSBadge: View {
    @StateObject private var counter = FPSCounter()
    
    var body: some View {
        let value = counter.fps
        Text("\(value) FPS")
            .font(.system(.caption2, design: .monospaced))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.regularMaterial, in: Capsule())
            .overlay(
                Capsule().stroke(borderColor(for: value), lineWidth: 1)
            )
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
            .onAppear { counter.start() }
            .onDisappear { counter.stop() }
    }
    
    private func borderColor(for fps: Int) -> Color {
        switch fps {
        case ..<30: return .red
        case 30..<55: return .yellow
        default: return .green
        }
    }
}
