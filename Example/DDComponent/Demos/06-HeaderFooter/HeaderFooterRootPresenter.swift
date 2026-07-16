import UIKit
import DDComponent

/// Shows header/footer supplementary views with collapsible sections.
final class HeaderFooterRootPresenter: UICollectionViewRootPresenter<UICollectionView> {
    private var collapsedSections: Set<Int> = []

    override func onAttach() {
        super.onAttach()
        rebuildSections()
    }

    private func rebuildSections() {
        sections = (0..<3).map { i in
            let section = UICollectionViewFlowSectionPresenter()
            section.layoutInfo.inset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            section.layoutInfo.lineSpacing = 8
            section.layoutInfo.headerReferenceSize = CGSize(width: 0, height: 44)
            section.layoutInfo.footerReferenceSize = CGSize(width: 0, height: 24)

            let header = SectionHeaderPresenter()
            header.title = "Section \(["A","B","C"][i])"
            header.isCollapsed = collapsedSections.contains(i)
            header.onTap = { [weak self] in
                guard let self = self else { return }
                if self.collapsedSections.contains(i) { self.collapsedSections.remove(i) }
                else { self.collapsedSections.insert(i) }
                self.rebuildSections()
            }
            section.setSupplementary("UICollectionElementKindSectionHeader", [header])

            let items: [CardItemPresenter]
            if collapsedSections.contains(i) {
                items = []
            } else {
                items = (0..<3).map { j in
                    let p = CardItemPresenter()
                    p.card = CardData(id: "s\(i)-\(j)", title: "Item \(j+1)", detail: "Section \(["A","B","C"][i])",
                                      color: UIColor(hue: CGFloat(i)/3.0, saturation: 0.5, brightness: 0.9, alpha: 1))
                    return p
                }
            }
            let footer = SectionFooterViewPresenter(); footer.count = items.count
            section.setSupplementary("UICollectionElementKindSectionFooter", [footer])
            section.setItems(items)
            return section
        }
    }
}

final class SectionFooterViewPresenter: UICollectionViewReusablePresenter<SectionFooterView> {
    var count: Int = 0 { didSet { setState {} } }
    override func onUpdate(view: SectionFooterView, context: ViewUpdateContext) {
        view.text = "\(count) items"
    }
}
