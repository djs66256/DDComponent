import UIKit
import DDComponent

protocol HeaderPresentable: ViewPresentable { func applyTheme(_ theme: Theme) }

final class HeaderPresenter: ViewPresenter<ThemeableViewable>, HeaderPresentable {
    private var theme: Theme = .light { didSet { setState {} } }
    func applyTheme(_ theme: Theme) { self.theme = theme }
    override func onUpdate(view: ThemeableViewable, context: ViewUpdateContext) {
        view.applyTheme(theme); view.titleLabel.text = "📋 Header"
    }
}
