import UIKit
import DDComponent

@MainActor
protocol CyclePageDemoViewable: AnyObject {
    var cyclePageView: CyclePageView { get }
}

@MainActor
final class CyclePageDemoView: UIView, CyclePageDemoViewable {
    lazy var cyclePageView = CyclePageView(UIScrollView())

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(cyclePageView)
        cyclePageView.frame = bounds
        cyclePageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

@MainActor
final class CyclePageRootPresenter: RootViewPresenter<CyclePageDemoViewable>, CyclePageDataSource, CyclePageDelegate {
    private lazy var data: [PageData] = (0..<15).map { PageData(index: $0) }

    override func onBindView(_ view: CyclePageDemoViewable) {
        super.onBindView(view)
        view.cyclePageView.dataSource = self
        view.cyclePageView.delegate = self
        view.cyclePageView.currentItem = data[0]
    }

    func prev(_ page: CyclePageView, current: CyclePageItemable) -> CyclePageItemable? {
        guard let d = current as? PageData, d.index > 0 else { return nil }
        return data[d.index - 1]
    }
    func next(_ page: CyclePageView, current: CyclePageItemable) -> CyclePageItemable? {
        guard let d = current as? PageData, d.index + 1 < data.count else { return nil }
        return data[d.index + 1]
    }
    func goPrev(_ page: CyclePageView, item: CyclePageItemable) -> Bool { true }
    func goNext(_ page: CyclePageView, item: CyclePageItemable) -> Bool { true }
    func goCurrent(_ page: CyclePageView, item: CyclePageItemable) {}
    func skipItem(_ page: CyclePageView, item: CyclePageItemable) {}
    func itemsChanged(_ page: CyclePageView, oldItems: [CyclePageItemable], newItems: [CyclePageItemable]) {}
    func currentWillChanged(_ page: CyclePageView, oldItem: CyclePageItemable?, newItem: CyclePageItemable?) {}
    func currentChanged(_ page: CyclePageView) {}
    func currentRefresh(_ page: CyclePageView) {}
    func itemViewDidLayout(_ page: CyclePageView, itemView: CyclePageItemView) {}
}
