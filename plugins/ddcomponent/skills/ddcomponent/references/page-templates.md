# 固定视图页面

适用于详情页、固定布局页面。这是最常用的模式。

## 步骤

1. 定义 View 协议（页面需要展示什么）
2. 创建各功能 Presenter（每个功能一个）
3. 创建 RootPresenter（组装所有 Presenter）
4. 创建 PageViewController（UIKit 桥接，注册 Service）

## 完整代码模板

```swift
// ===== Step 1: 定义 View 协议 =====
protocol MyPageViewProtocol: AnyObject {
    var likeButton: LikeViewProtocol { get }
    var shareButton: ShareViewProtocol { get }
    var commentList: CommentListViewProtocol { get }
}

// ===== Step 2: 创建各功能 Presenter =====
// 每个 Presenter 独立一个文件，见 references/presenter-patterns.md

// ===== Step 3: 创建 RootPresenter =====
class MyPageRootPresenter: RootViewPresenter<MyPageViewProtocol> {

    required init() {
        super.init()
        typeBox(LikePresenter())
        typeBox(SharePresenter())
        typeBox(CommentListPresenter())
    }

    override func onAttach() {
        super.onAttach()
    }

    override func onBindView(_ view: MyPageViewProtocol) {
        super.onBindView(view)
        (typeUnbox() as LikePresenter?)?.bindView(view.likeButton)
        (typeUnbox() as SharePresenter?)?.bindView(view.shareButton)
        (typeUnbox() as CommentListPresenter?)?.bindView(view.commentList)
    }

    override func onUnbindView() {
        super.onUnbindView()
    }
}

// ===== Step 4: 创建 ViewController =====
class MyPageViewController: PageViewController<MyPageRootView, MyPageRootPresenter> {

    override func makeView() -> MyPageRootView { MyPageRootView() }
    override func makePresenter() -> MyPageRootPresenter { MyPageRootPresenter() }

    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        ServiceInstaller(DataLoader.self, { DataLoaderImpl() })
        ServiceInstaller(LikeService.self, { LikeServiceImpl() })
        ServiceInstaller(RouterService.self, { RouterServiceImpl() })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.loadData()
    }
}
```

## 在非 DDComponent 页面中嵌入 Presenter（IsolatedViewPresenter）

```swift
class LegacyViewController: UIViewController {
    let likeIsolated = IsolatedViewPresenter(LikeButton(), LikePresenter())

    override func viewDidLoad() {
        super.viewDidLoad()
        likeIsolated.register(service: LikeService.self) { LikeServiceImpl() }
        view.addSubview(likeIsolated.view)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        likeIsolated.notifyGlobal(listener: PageLifecycle.self) {
            $0.viewDidAppear(animated)
        }
    }
}
```

## 文件结构建议

```
Feature/
├── Models/
│   └── Comment.swift
├── Presenters/
│   ├── CommentListRootPresenter.swift
│   ├── CommentSectionPresenter.swift
│   └── CommentItemPresenter.swift
├── Views/
│   ├── CommentCell.swift
│   └── CommentListView.swift
├── Protocols/
│   └── CommentViewProtocols.swift
├── Services/
│   ├── CommentDataService.swift
│   └── CommentLikeService.swift
└── CommentListViewController.swift
```

## 命名规范

- `XxxPresenter.swift` — 业务逻辑，继承 `ViewPresenter<XxxProtocol>`
- `XxxViewController.swift` — 页面入口，继承 `PageViewController<...>` 或 `UITablePageViewController<...>`
- `XxxService.swift` — 服务协议 + 默认实现
- View 协议放在 Presenter 文件顶部，或单独放 `Protocols/` 目录