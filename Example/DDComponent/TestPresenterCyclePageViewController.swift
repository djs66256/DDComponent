//
//  TestPresenterPageViewController.swift
//  DDComponent_Example
//
//  Created by daniel on 2022/9/16.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import DDComponent
import SnapKit

protocol TestViewProtocol: AnyObject {
    var value: Int { set get }
    var button: TestViewButton { get }
}

class TestView : PageReusableView, TestViewProtocol {
    
    var value: Int = 0 {
        didSet {
            label.text = "\(value)"
        }
    }
    var button: TestViewButton { _button }
    
    let _button = TestViewButtonImpl()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.font = .systemFont(ofSize: 30)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        addSubview(_button)
        _button.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TestReusableViewPresenter: ReusableViewPresenter<TestViewProtocol>, TestViewButtonListener {
    var value: Int = -1 {
        didSet {
            setState {}
        }
    }
    
    let buttonPresenter = TestViewButtonPresenter()
    
    required init() {
        super.init()
        add(child: buttonPresenter)
    }
    
    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        log("onAttach")
        
    }
    
    override func onDetach() {
        super.onDetach()
        log("onDetach")
    }
    
    override func onBindView(_ view: TestViewProtocol) {
        super.onBindView(view)
        log("onBindView")
        
        buttonPresenter.bindView(view.button)
    }
    
    override func onUnbindView() {
        super.onUnbindView()
        log("onUnbindView")
        
        buttonPresenter.unbindView()
    }
    
    override func onUpdate(view: TestViewProtocol, context: ViewUpdateContext) {
        view.value = value
        log("onUpdate")
    }
    
    func onSelected() {
        log("on selected")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        log("prepare for reuse")
        value = -1
        buttonPresenter.selected = false
    }
    
    func log(_ str: String) {
        print("\(value) \(Self.self) \(str)")
    }
}

/// A button example
class TestViewButtonImpl : UIView, TestViewButton {
    let button = UIButton()
    var delegate: TestViewButtonDelegate?
    var selected: Bool {
        set { button.isSelected = newValue }
        get { button.isSelected }
    }
    var title: String = "not selected" {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        button.addTarget(self, action: #selector(onClick), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func onClick() {
        delegate?.onClick()
    }
    
}

protocol TestViewButtonListener: AnyObject {
    func onSelected()
}

protocol TestViewButtonDelegate: AnyObject {
    func onClick()
}

protocol TestViewButton: AnyObject {
    var delegate: TestViewButtonDelegate? { set get }
    var selected: Bool { set get }
    var title: String { set get }
}

class TestViewButtonPresenter: ViewPresenter <TestViewButton>, TestViewButtonDelegate {
    
    var selected: Bool = false
    var title: String { selected ? "selected" : "not selected" }
    
    func onClick() {
        setState {
            selected = !selected
        }
        
        notify(listener: TestViewButtonListener.self) {
            $0.onSelected()
        }
    }
    
    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        log("onAttach")
    }
    
    override func onDetach() {
        super.onDetach()
        log("onAttach")
    }
    
    override func onBindView(_ view: TestViewButton) {
        super.onBindView(view)
        log("onBindView")
        view.delegate = self
    }
    
    override func onUnbindView() {
        super.onUnbindView()
        log("onUnbindView")
        view?.delegate = nil
    }
    
    override func onUpdate(view: TestViewButton, context: ViewUpdateContext) {
        view.selected = selected
        view.title = title
        log("onUpdate")
    }
    
    func log(_ str: String) {
        print("\(Self.self) \(str)")
    }
}


/// ========
@MainActor
class PageVM: ViewPresenter<Void>, CyclePageItemable {
    var index: Int
    var color: UIColor
    init(index: Int = 0) {
        self.index = index
        color = UIColor(red: .random(in: 0...1),
                        green: .random(in: 0...1),
                        blue: .random(in: 0...1),
                        alpha: 1)
    }
    
    var name: String {
        "\(Self.self)"
    }
    
    func isEquals(_ other: CyclePageItemable) -> Bool {
        return isCycleEquals(other)
    }
    
    func isCycleEquals(_ other: CyclePageItemable) -> Bool {
        if let other = other as? PageVM {
            return other.index == index
        }
        return false
    }
    func createView() -> CyclePageItemView {
        let pv = PageView()
        pv.superViewPresenter = self
        return pv
    }
}

@MainActor
class PageView: CyclePageItemView {
    
    weak var superViewPresenter: ViewPresentable?
    
    weak var vm: PageVM?
    
    var isCurrent: Bool = false
    
    var displayView: UIView = TestView()
    
    var presenter = TestReusableViewPresenter()
    
    func attach(_ item: CyclePageItemable) {
        vm = item as? PageVM
        let view = displayView as! TestView
        view.backgroundColor = vm?.color
        presenter.value = vm?.index ?? 0
        
        superViewPresenter?.add(child: presenter)
        
        presenter.bindView(view)
        presenter.updateViewIfNeeded()
    }
    
    func reuse() {
        presenter.unbindView()
        presenter.removeFromSuper()
        (displayView as! TestView).prepareForReuse()
        presenter.prepareForReuse()
        vm = nil
    }
}

// Page Root Presenter
@MainActor
protocol TestPresenterPageView {
    var pageView: CyclePageView { get }
    func setupUI()
}

@MainActor
class TestPresenterPageViewImpl : UIView, TestPresenterPageView {
    lazy var pageView = CyclePageView(UIScrollView())//PageScrollView()
    func setupUI() {
        self.backgroundColor = .white

        self.addSubview(pageView)
        pageView.frame = self.bounds
        pageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
    }
}

@MainActor
class TestCyclePageRootPresenter: RootViewPresenter<TestPresenterPageView> {
    typealias View = TestPresenterPageView
    
    class CyclePageProxy: NSObject, CyclePageDelegate, CyclePageDataSource {
        
        var dataSource: [PageVM] = [] {
            didSet {
                pageView?.currentItem = dataSource.count > 0 ? dataSource[0] : nil
            }
        }
        var currentIndex: Int = 0 {
            didSet {
                pageView?.currentItem = dataSource[currentIndex]
            }
        }
        
        weak var pageView: CyclePageView? {
            didSet {
                pageView?.delegate = self
                pageView?.dataSource = self
            }
        }
        
        func prev(_ page: CyclePageView, current: CyclePageItemable) -> CyclePageItemable? {
            if let vm = current as? PageVM {
                let index = vm.index - 1
                if index >= 0 {
                    return dataSource[index]
                }
            }
            return nil
        }
        func next(_ page: CyclePageView, current: CyclePageItemable) -> CyclePageItemable? {
            if let vm = current as? PageVM {
                let index = vm.index + 1
                if index < dataSource.count {
                    return dataSource[index]
                }
            }
            return nil
        }
        
        func goPrev(_ page: CyclePageView, item: CyclePageItemable) -> Bool {
            true
        }
        func goNext(_ page: CyclePageView, item: CyclePageItemable) -> Bool {
            true
        }
        func goCurrent(_ page: CyclePageView, item: CyclePageItemable) {
            
        }
        func skipItem(_ page: CyclePageView, item: CyclePageItemable) {
            
        }
        func itemsChanged(_ page: CyclePageView,
                        oldItems: [CyclePageItemable],
                          newItems: [CyclePageItemable]) {
            
        }
        func currentWillChanged(_ page: CyclePageView,
                               oldItem: CyclePageItemable?,
                                newItem: CyclePageItemable?) {
            
        }
        func currentChanged(_ page: CyclePageView) {
            
        }
        func currentRefresh(_ page: CyclePageView) {
            
        }
        func itemViewDidLayout(_ page: CyclePageView,
                               itemView: CyclePageItemView) {
            
        }
    }
    
    lazy var proxy = CyclePageProxy()
    
    lazy var dataSource: [PageVM] = (0...10).map {
        PageVM(index: $0)
    }
    
    override func onAttach() {
        super.onAttach()
        
//        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.dataSource.forEach { add(child: $0) }
            self.proxy.dataSource = self.dataSource
//        }
    }

    override func onBindView(_ view: View) {
        super.onBindView(view)
        
        proxy.pageView = view.pageView
        proxy.currentIndex = 0
    }
    
    override func onUnbindView() {
        super.onUnbindView()
        proxy.pageView = nil
    }
}

class TestPresenterCyclePageViewController: PageViewController<TestPresenterPageViewImpl, TestCyclePageRootPresenter, TestPresenterPageView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frameView.setupUI()
        
    }
}
