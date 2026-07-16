import UIKit
import DDComponent

/// Simple item data for header/footer demo sections.
struct SectionItemData {
    let title: String
    let color: UIColor
}

/// Inline collection item presenter — self-contained within Demo 06.
final class SectionItemPresenter: CollectionItemPresenter<SectionItemCell>, UICollectionItemFlowPresentable {
    var layoutInfo = UICollectionItemFlowLayoutInfo()
    var data: SectionItemData? { didSet { setState {} } }

    override init() { super.init(); layoutInfo.calculateSizeAutomatically = true }

    override func onUpdate(view: SectionItemCell, context: ViewUpdateContext) {
        guard let d = data else { return }
        view.label.text = d.title
        view.backgroundColor = d.color.withAlphaComponent(0.15)
    }
}

/// Inline cell for section items.
final class SectionItemCell: UICollectionViewCell {
    let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.addSubview(label)
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.snp.makeConstraints { $0.edges.equalToSuperview().inset(12) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/// Shows header/footer supplementary views with collapsible sections.
final class HeaderFooterRootPresenter: UICollectionViewRootPresenter<UICollectionView> {
    private var collapsedSections: Set<Int> = []

    override func onAttach() {
        super.onAttach()
        rebuildSections()
    }

    private func rebuildSections() {
        let names = ["A", "B", "C"]
        let colors: [UIColor] = [.systemRed, .systemGreen, .systemBlue]
        sections = (0..<3).map { i in
            let section = UICollectionViewFlowSectionPresenter()
            section.layoutInfo.inset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            section.layoutInfo.lineSpacing = 8

            let header = SectionHeaderPresenter()
            header.title = "Section \(names[i])"
            header.isCollapsed = collapsedSections.contains(i)
            header.onTap = { [weak self] in
                guard let self = self else { return }
                if self.collapsedSections.contains(i) { self.collapsedSections.remove(i) }
                else { self.collapsedSections.insert(i) }
                self.rebuildSections()
            }
            section.setSupplementary("UICollectionElementKindSectionHeader", [header as CollectionItemPresentable])

            let items: [SectionItemPresenter]
            if collapsedSections.contains(i) {
                items = []
            } else {
                items = (0..<3).map { j in
                    let p = SectionItemPresenter()
                    p.data = SectionItemData(title: "Item \(j+1)", color: colors[i])
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

final class SectionFooterViewPresenter: CollectionItemPresenter<SectionFooterView> {
    var count: Int = 0 { didSet { setState {} } }
    override func onUpdate(view: SectionFooterView, context: ViewUpdateContext) {
        view.text = "\(count) items"
    }
}
