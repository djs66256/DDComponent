import UIKit
import DDComponent

/// Simple item data for header/footer demo sections.
struct SectionItemData {
    let title: String
    let color: UIColor
}

/// Inline collection item presenter — self-contained within Demo 06.
final class SectionItemPresenter: UICollectionViewFlowItemPresenter<SectionItemCell> {
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

/// SectionFooter presenter — uses UICollectionViewFlowItemPresenter so it's compatible with section.footer = ...
final class SectionFooterViewPresenter: UICollectionViewFlowItemPresenter<SectionFooterView> {
    var count: Int = 0 { didSet { setState {} } }

    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = false
    }

    override func onUpdate(view: SectionFooterView, context: ViewUpdateContext) {
        view.text = "\(count) items"
    }

    override func calculateSize(containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: 30)
    }
}

/// Shows header/footer supplementary views with collapsible sections.
/// Uses section.header = ... / section.footer = ... convenience API (preferred over raw setSupplementary).
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

            // ✅ section.header = ... (convenience API, preferred)
            let header = SectionHeaderPresenter()
            header.title = "Section \(names[i])"
            header.isCollapsed = collapsedSections.contains(i)
            header.onTap = { [weak self] in
                guard let self = self else { return }
                if self.collapsedSections.contains(i) { self.collapsedSections.remove(i) }
                else { self.collapsedSections.insert(i) }
                self.rebuildSections()
            }
            section.header = header

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
            section.setItems(items)

            // ✅ section.footer = ... (convenience API, preferred)
            let footer = SectionFooterViewPresenter(); footer.count = items.count
            section.footer = footer

            return section
        }
    }
}
