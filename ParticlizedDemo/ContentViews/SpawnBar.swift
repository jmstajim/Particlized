import SwiftUI

struct SpawnBar: View {
    @Binding var choice: SpawnChoice
    var onChange: (SpawnChoice) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(SpawnChoice.allCases) { c in
                        Button {
                            choice = c
                            onChange(c)
                        } label: {
                            HStack(spacing: 6) {
                                Text(label(for: c))
                                    .font(.footnote)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(choice == c ? Color.accentColor.opacity(0.15) : Color.clear, in: Capsule())
                            .overlay(
                                Capsule().stroke(choice == c ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
            }
        }
        .background(.ultraThickMaterial)
        .cornerRadius(20)
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
    }
    
    private func label(for c: SpawnChoice) -> String {
        switch c {
        case .oregonCombo: return "Image + Text"
        case .oregonImage: return "Image"
        case .oregonText:  return "Text"
        case .emojis:  return "Emojis"
        }
    }
}
