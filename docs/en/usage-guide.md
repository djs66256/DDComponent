# Usage Guide

## Fixed Views (Non-Reuse Scenarios)

Suitable for UI scenarios that do not require reuse, such as detail pages, single feed items, or inside reusable views.

> 📖 Demo: [01-HelloDDComponent](../../Example/DDComponent/Demos/01-HelloDDComponent/) — ViewPresenter Basics

### 1. Creating a ViewController

The ViewController must inherit from `PageViewController`:

```swift
class MyViewController: PageViewController<MyRootView, MyRootPresenter> {

    override func makeView() -> MyRootView { MyRootView() }
    override func makePresenter() -> MyRootPresenter { MyRootPresenter() }

    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        ServiceInstaller(LikeService.self, { LikeServiceImpl() })
        ServiceInstaller(DataLoader.self, { MockDataLoader() })
        PresenterInstaller(lazyLoad: true, { LikePresenter() })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.loadData()
    }
}
```

### 2. Creating a RootPresenter

The RootPresenter is responsible for organizing and driving the entire P-Tree. Using `typeBox`/`typeUnbox` to manage child Presenters is recommended:

```swift
class MyRootPresenter: RootViewPresenter<MyRootPresenterView> {

    required init() {
        super.init()
        typeBox(LikePresenter())
        typeBox(SharePresenter())
    }

    override func onBindView(_ view: MyRootPresenterView) {
        super.onBindView(view)
        (typeUnbox() as LikePresenter?)?.bindView(view.likeButton)
        (typeUnbox() as SharePresenter?)?.bindView(view.shareButton)
    }
}
```

> 📖 Demo: [04-PTreeComposition](../../Example/DDComponent/Demos/04-PTreeComposition/) — P-Tree Composition

### 3. Creating a ViewPresenter

The carrier of all logic. **The View must be defined as a protocol**. Complete Like example:

```swift
protocol LikeViewProtocol: AnyObject {
    var isLiked: Bool { get set }
    var likeCount: Int { get set }
    var onLikeTapped: (() -> Void)? { get set }
}

class LikePresenter: ViewPresenter<LikeViewProtocol> {

    struct LikeInfo { var isLiked = false; var likeCount = 0 }
    private var _likeInfo = LikeInfo()
    var likeInfo: LikeInfo {
        set { setState { _likeInfo = newValue } }
        get { _likeInfo }
    }

    func toggleLike() {
        guard let service = getService(LikeService.self) else { return }
        service.toggleLike(...) { [weak self] result in
            self?.likeInfo = result
            self?.notify(listener: LikeListener.self) { $0.onLikeChanged(result) }
        }
    }

    override func onBindView(_ view: LikeViewProtocol) {
        super.onBindView(view)
        view.onLikeTapped = { [weak self] in self?.toggleLike() }
    }

    override func onUnbindView() {
        super.onUnbindView()
        view?.onLikeTapped = nil
    }

    override func onUpdate(view: LikeViewProtocol, context: ViewUpdateContext) {
        view.isLiked = likeInfo.isLiked
        view.likeCount = likeInfo.likeCount
    }
}
```

## List Views

> 📖 Demo: [05-ListDiffUpdate](../../Example/DDComponent/Demos/05-ListDiffUpdate/) — Diff Incremental Updates

### Non-Reusable Presenters (Fixed Lists)

When list items are fixed, simply construct a one-to-one mapping of Presenters. Suitable for simple cells that do not need internal MVP decomposition.

### Reusable Presenters (Recommended)

`ReusableViewPresenter` must be used when cells require MVP decomposition:

```swift
// Item Presenter
class CommentItemPresenter: ReusableViewPresenter<CommentCellProtocol> {
    required init() { super.init() }

    var comment: Comment? { didSet { setState {} } }

    override func prepareForReuse() { comment = nil }

    override func onBindView(_ view: CommentCellProtocol) {
        view.onAvatarTapped = { [weak self] in self?.openProfile() }
    }

    override func onUpdate(view: CommentCellProtocol, context: ViewUpdateContext) {
        view.author = comment?.author
        view.content = comment?.text
    }
}

// Section Presenter
class CommentSectionPresenter: CollectionSectionPresenter {
    var comments: [Comment] = [] {
        didSet { setItems(comments.map { CommentItemPresenter().apply { $0.comment = $0 } }) }
    }
}

// Root Presenter
class CommentListRootPresenter: CollectionRootPresenter<CommentListViewProtocol> {
    let section = CommentSectionPresenter()

    override func onAttach() {
        super.onAttach()
        add(child: section)
        sections = [section]
    }
}

// ViewController
class CommentListViewController: UITablePageViewController<CommentItemPresenter> {
    override func makePresenter() -> CommentListRootPresenter { CommentListRootPresenter() }
    override func viewDidLoad() { super.viewDidLoad(); presenter.loadComments() }
}
```

> 📖 Demo: [10-FeedExample](../../Example/DDComponent/Demos/10-FeedExample/) — Combined Collection + Diff + Child Presenter + Service + Notify

## Service System

Services provide page-level replaceable capabilities (networking, routing, analytics):

```swift
// Registration
@PageInstallerBuilder override var pageInstallers: PageInstaller {
    ServiceInstaller(LikeService.self, { LikeServiceImpl() })
    ServiceInstaller(DataLoader.self, lazy: false, { DataLoaderImpl() })
}

// Retrieval
getService(LikeService.self)?.toggleLike(...)
```

Lookup chain: Current Presenter → Parent Presenter → ... → RootPresenter → Global fallback

> 📖 Demo: [02-ServiceDI](../../Example/DDComponent/Demos/02-ServiceDI/) — Complete Service System

## Notify Broadcast System

Protocol-based multicast communication for inter-Presenter communication:

```swift
// Define listener protocol
protocol LikeListener: AnyObject {
    func onLikeChanged(isLiked: Bool, count: Int)
}

// Send broadcast
notify(listener: LikeListener.self) { $0.onLikeChanged(isLiked: true, count: 10) }

// Receive broadcast
extension MyPresenter: LikeListener {
    func onLikeChanged(isLiked: Bool, count: Int) { ... }
}
```

| Scope | When to Use |
|---|---|
| `.global` | Page-level events (theme switching, full-screen refresh) |
| `.children` | Parent notifies all children |
| `.parents` | Child notifies parent chain |
| `.reusable` | Communication within list cells |

> 📖 Demo: [03-NotifySystem](../../Example/DDComponent/Demos/03-NotifySystem/) — Complete Notify System

## Presenter Assembly Methods

### IdentifierViewGroupPresenter

`RootViewPresenter` inherits from it, providing `typeBox`/`typeUnbox` to store and retrieve child Presenters by type:

```swift
// Register
typeBox(LikePresenter())
typeBoxLazy({ ExpensivePresenter() })

// Retrieve
let like: LikePresenter? = typeUnbox()
```

### pageInstallers Declarative Assembly

**Note: Do not register the RootPresenter here — it is already created by `makePresenter()`.**

```swift
@PageInstallerBuilder override var pageInstallers: PageInstaller {
    PresenterInstaller(lazyLoad: true, { LikePresenter() })  // Child Presenter
    ServiceInstaller(LikeService.self, { LikeServiceImpl() })
}
```

## Key Rules

### ✅ DO

- **View must be defined as a protocol**, not a concrete UIView type
- **All UI updates go through `setState {}`**, do not directly use `view?.xxx = yyy`
- **Set up callbacks in `onBindView`, clear them in `onUnbindView`**
- **Call `super.onBindView(view)` first in `onBindView`**
- **Child Presenters must be added via `add(child:)` to join the P-Tree**
- **Use `[weak self]` in asynchronous callbacks**

### ❌ DON'T

- **Do not use UIView as the View type** (`ViewPresenter<UIButton>` ❌)
- **Do not modify state that affects the UI outside of `setState`**
- **Do not register the RootPresenter in `pageInstallers`** — `makePresenter()` already creates it
- **Do not forget to clean up callbacks in `onUnbindView`**

## setState Context Quick Reference

```swift
setState { self.count += 1 } context: {
    $0.animated = true              // Animation
    $0.invalidateLayout = true      // Layout refresh
    $0.updateViewImmediately = true // Immediate update
    $0.invalidateDataSource = true  // List data source change
    $0.invalidateContentSize = true // Content size change only
}
```

## Related Documentation

- [Architecture Design](./architecture.md) — P-Tree/V-Tree, lifecycle, UpdatePipeline
- [Reusable Presenter](./reusable-presenter.md) — List cell reuse, layoutInfo, incremental update engine
- [use* API](./use-methods.md) — Declarative state management
- [@PresenterState Macro](./presenter-state-macro.md) — Simplified state declaration
- [Swift 6 Concurrency Patterns](./swift6-patterns.md) — lazy var, MainActor
- [Demo Index](./demo-index.md) — All example demos
