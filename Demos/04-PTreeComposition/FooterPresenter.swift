import UIKit
import DDComponent

protocol FooterPresentable: ViewPresentable { func applyTheme(_ theme: Theme) }

final class FooterPresenter: ViewPresenter<ThemeableViewable>, FooterPresentable {
    private var theme: Theme = .light { didSet { setState {} } }
    func applyTheme(_ theme: Theme) { self.theme = theme }
    override func onUpdate(view: ThemeableViewable, context: ViewUpdateContext) {
        view.applyTheme(theme); view.titleLabel.text = "🔽 Footer"
    }
}
