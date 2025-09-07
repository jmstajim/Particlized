import Foundation

enum SpawnChoice: String, CaseIterable, Identifiable {
    case oregonCombo = "Oregon Combo"
    case oregonImage = "Oregon Image"
    case oregonText = "Oregon Text"
    case tennisBall = "Tennis Ball"
    var id: String { rawValue }
}
