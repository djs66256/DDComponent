import UIKit
import DDComponent
import SnapKit

/// Shows P-Tree composition: typeBox() registers children, typeUnbox() retrieves them.
/// Theme changes cascade from root → children through the tree.
final class PTreeRootPresenter: RootViewPresenter<PTreeViewable> {
    private var isDark = false

    required init() {
        super.init()
        // typeBox: register child presenters keyed by protocol type
        typeBox(HeaderPresenter())
        typeBox(BodyPresenter())
        typeBox(FooterPresenter())
    }

    override func onBindView(_ view: PTreeViewable) {
        super.onBindView(view)

        func bind<T: ViewPresenter<ThemeableViewable>>(_ container: UIView, _ p: T) {
            let v = ThemeableContainerView(); container.addSubview(v)
            v.snp.makeConstraints { $0.edges.equalToSuperview() }; p.bindView(v)
        }

        // typeUnbox: retrieve child by protocol type
        bind(view.headerContainer, typeUnbox()! as HeaderPresenter)
        bind(view.bodyContainer, typeUnbox()! as BodyPresenter)
        bind(view.footerContainer, typeUnbox()! as FooterPresenter)

        view.themeToggle.addTarget(self, action: #selector(toggleTheme), for: .touchUpInside)
    }

    @objc private func toggleTheme() {
        isDark = !isDark
        let theme: Theme = isDark ? .dark : .light
        (typeUnbox() as HeaderPresenter?)?.applyTheme(theme)
        (typeUnbox() as BodyPresenter?)?.applyTheme(theme)
        (typeUnbox() as FooterPresenter?)?.applyTheme(theme)
        print("[PTree] Theme → \(theme.name)")
    }
}
