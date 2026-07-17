import UIKit
import DDComponent

@MainActor
final class PageData: ViewPresenter<Void>, CyclePageItemable {
    let index: Int
    let color: UIColor

    init(index: Int) {
        self.index = index
        color = UIColor(hue: CGFloat(index)/15.0, saturation: 0.7, brightness: 0.9, alpha: 1)
    }

    var name: String { "page-\(index)" }
    func isEquals(_ other: CyclePageItemable) -> Bool { isCycleEquals(other) }
    func isCycleEquals(_ other: CyclePageItemable) -> Bool { (other as? PageData)?.index == index }
    func createView() -> CyclePageItemView { PageItemView() }
}

@MainActor
final class PageItemView: CyclePageItemView {
    var isCurrent: Bool = false
    var displayView: UIView {
        if _view == nil {
            let v = UILabel()
            v.text = "Page \(index + 1)"
            v.font = .systemFont(ofSize: 32, weight: .bold)
            v.textAlignment = .center
            v.textColor = .white
            _view = v
        }
        return _view!
    }
    private var _view: UIView?
    private var index: Int = 0

    func attach(_ item: CyclePageItemable) {
        if let d = item as? PageData { index = d.index; displayView.backgroundColor = d.color }
    }
    func reuse() { _view?.backgroundColor = nil }
}
