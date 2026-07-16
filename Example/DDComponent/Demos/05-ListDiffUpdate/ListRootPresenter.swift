import UIKit
import DDComponent

/// Extends UICollectionViewRootPresenter to gain sections + collection management.
/// Demonstrates Diff engine via setItems(animated:).
final class ListRootPresenter: UICollectionViewRootPresenter<UICollectionView> {
    private var cards: [CardData] = CardData.generate(count: 10)
    private var nextId = 10

    override func onAttach() {
        super.onAttach()
        applyCards()
    }

    func shuffle() { cards.shuffle(); applyCards() }
    func addOne() {
        let c = CardData(id: "card-\(nextId)", title: "New #\(nextId)",
                         detail: "Inserted with diff animation",
                         color: UIColor(hue: CGFloat(nextId)/30.0, saturation: 0.7, brightness: 0.9, alpha: 1))
        nextId += 1; cards.insert(c, at: 0); applyCards()
    }
    func removeOne() {
        guard !cards.isEmpty else { return }
        cards.remove(at: Int.random(in: 0..<cards.count)); applyCards()
    }
    func reload() { cards = CardData.generate(count: 10); nextId = 10; applyCards() }

    private func applyCards() {
        let items: [CardItemPresenter] = cards.map { c in
            let p = CardItemPresenter(); p.card = c; return p
        }
        let section = UICollectionViewFlowSectionPresenter()
        section.layoutInfo.inset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        section.layoutInfo.lineSpacing = 10
        section.setItems(items, animated: true)
        sections = [section]
        print("[ListDiff] Updated: \(cards.count) cards")
    }
}
