import UIKit
import DDComponent

/// Shows IsolatedViewPresenter: use a presenter as a standalone component,
/// then integrate it into a P-Tree via add(child:).
final class IsolatedRootPresenter: RootViewPresenter<IsolatedDemoViewable> {

    override func onBindView(_ view: IsolatedDemoViewable) {
        super.onBindView(view)

        // Create 3 independent star buttons, each wrapped in IsolatedViewPresenter.
        // IsolatedViewPresenter gives each its own pipeline and lifecycle,
        // while still participating in the P-Tree.
        for _ in 0..<3 {
            let starView = StarButton()
            let starPresenter = StarButtonPresenter()

            // IsolatedViewPresenter wraps a UIView + ViewPresenter into one unit
            let isolated = IsolatedViewPresenter(view: starView, presenter: starPresenter)

            // Attach root-like lifecycle (onAttach fires)
            isolated.attachSuperPresenter()

            // Add to P-Tree so it participates in Service/Notify/lifecycle
            add(child: isolated)

            view.stackView.addArrangedSubview(starView)
            starView.snp.makeConstraints { $0.width.height.equalTo(60) }
        }
    }
}
