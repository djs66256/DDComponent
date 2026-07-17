# 页面创建完整模板

## 固定视图页面

适用于详情页、固定布局页面。这是最常用的模式。

### 步骤

1. 定义 View 协议（页面需要展示什么）
2. 创建各功能 Presenter（每个功能一个）
3. 创建 RootPresenter（组装所有 Presenter）
4. 创建 PageViewController（UIKit 桥接，注册 Service）

### 完整代码模板

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
        // 注册子 Presenter
        typeBox(LikePresenter())
        typeBox(SharePresenter())
        typeBox(CommentListPresenter())
    }

    override func onAttach() {
        super.onAttach()
        // P-Tree 挂载后的初始化
    }

    override func onBindView(_ view: MyPageViewProtocol) {
        super.onBindView(view)
        // 绑定子 Presenter 到对应的 View
        (typeUnbox() as LikePresenter?)?.bindView(view.likeButton)
        (typeUnbox() as SharePresenter?)?.bindView(view.shareButton)
        (typeUnbox() as CommentListPresenter?)?.bindView(view.commentList)
    }

    override func onUnbindView() {
        super.onUnbindView()
        // 解绑是可选的（框架会自动处理），但显式解绑更清晰
    }
}

// ===== Step 4: 创建 ViewController =====
class MyPageViewController: PageViewController<MyPageRootView, MyPageRootPresenter> {

    override func makeView() -> MyPageRootView {
        MyPageRootView()
    }

    override func makePresenter() -> MyPageRootPresenter {
        MyPageRootPresenter()
    }

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

## 列表页面（TableView / CollectionView）

适用于需要 Cell 复用的长列表。

### 决策：Cell 是否需要 MVP 拆分？

- Cell 很简单 → 不需要复用 Presenter，直接用普通 ViewPresenter
- Cell 内部还需要 MVP 拆分 → 需要复用 Presenter（继承 `ReusableViewPresenter`）

### 复用 Presenter 的完整模板

```swift
// ===== Item Presenter（可复用） =====
class CommentItemPresenter: ReusableViewPresenter<CommentCellProtocol> {
    required init() { super.init() }

    var comment: Comment? {
        didSet { setState {} }
    }

    override func prepareForReuse() {
        comment = nil
    }

    override func onBindView(_ view: CommentCellProtocol) {
        view.onAvatarTapped = { [weak self] in self?.openProfile() }
    }

    override func onUpdate(view: CommentCellProtocol, context: ViewUpdateContext) {
        view.author = comment?.author
        view.content = comment?.text
    }

    private func openProfile() {
        getService(RouterService.self)?.openProfile(comment?.authorId)
    }
}

// ===== Section Presenter =====
class CommentSectionPresenter: CollectionSectionPresenter {
    var comments: [Comment] = [] {
        didSet {
            setItems(comments.map { CommentItemPresenter().apply { $0.comment = $0 } })
        }
    }
}

// ===== Root Presenter =====
class CommentListRootPresenter: CollectionRootPresenter<CommentListViewProtocol> {
    let section = CommentSectionPresenter()

    override func onAttach() {
        super.onAttach()
        add(child: section)
        sections = [section]
    }

    func loadComments() {
        getService(DataLoader.self)?.fetch { [weak self] comments in
            self?.section.comments = comments
        }
    }
}

// ===== ViewController =====
class CommentListViewController: UITablePageViewController<CommentItemPresenter> {
    override func makePresenter() -> CommentListRootPresenter { CommentListRootPresenter() }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.loadComments()
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