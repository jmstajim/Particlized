import Foundation

enum SpawnChoice: String, CaseIterable, Identifiable {
    case oregonCombo = "Oregon Combo"
    case oregonImage = "Oregon Image"
    case oregonText = "Oregon Text"
    case emojis = "Emojis"
    var id: String { rawValue }
}
