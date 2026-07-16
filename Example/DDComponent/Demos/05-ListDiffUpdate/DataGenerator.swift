import UIKit

struct CardData {
    let id: String; let title: String; let detail: String; let color: UIColor
    static func generate(count: Int) -> [CardData] {
        (0..<count).map { i in
            CardData(id: "card-\(i)", title: "Card #\(i)",
                     detail: "Card number \(i) — demonstrating diff-based partial updates",
                     color: UIColor(hue: CGFloat(i)/CGFloat(count), saturation: 0.6, brightness: 0.9, alpha: 1))
        }
    }
}
