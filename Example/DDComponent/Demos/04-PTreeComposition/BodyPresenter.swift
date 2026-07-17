import UIKit
import DDComponent

protocol BodyPresentable: ViewPresentable { func applyTheme(_ theme: Theme) }

final class BodyPresenter: ViewPresenter<ThemeableViewable>, BodyPresentable {
    private var theme: Theme = .light { didSet { setState {} } }
    func applyTheme(_ theme: Theme) { self.theme = theme }
    override func onUpdate(view: ThemeableViewable, context: ViewUpdateContext) {
        view.applyTheme(theme)
        view.titleLabel.text = "📝 Body\n\nP-Tree cascades theme\nfrom root → all children"
    }
}
