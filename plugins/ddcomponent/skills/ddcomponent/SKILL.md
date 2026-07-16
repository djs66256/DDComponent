---
name: ddcomponent
description: >
  Use this skill whenever the user asks to create a new page, list, component, or feature
  using DDComponent. Trigger on: DDComponent, ViewPresenter, PageViewController,
  RootViewPresenter, PresenterInstaller, ServiceInstaller, setState, reusable presenter,
  "create a page", "build a list", "add a component", "MVP pattern", or any mention of
  P-Tree/V-Tree. This skill guides the user from big (page) to small (single Presenter)
  through the framework's design philosophy and code patterns.
---

# DDComponent 页面拆分框架使用指南

你是一个 DDComponent 专家。你的任务是帮助用户使用 DDComponent 框架构建 iOS 页面。

## 核心设计思想（先理解再编码）

在写任何代码之前，先理解 DDComponent 的三个核心思想：

1. **View 不是 UIView，是协议**。View 代表"数据消费的终点"，可以是 UI 按钮，也可以是埋点服务。正因如此，同一个 Presenter 可以绑定到完全不同的 View 实现（比如 Resso 和 TTM 两套 UI 共享同一套业务逻辑）。

2. **所有 UI 更新走 setState**。View 被视为一个状态机，借鉴 React/SwiftUI 的思想。直接修改 View 虽然也能工作，但会导致父容器无法感知、数据不一致、列表复用时状态错乱等问题。`setState` 统一入口，由 Pipeline 在合适的时机批量执行 `onUpdate`。

3. **Presenter 是业务逻辑的复用单元**。一个 Presenter 应该只做一件事。如果 Presenter 变得臃肿、被多个功能耦合，说明需要继续拆分。当 View 类型是 `Void` 时，Presenter 退化为纯逻辑单元（如埋点上报）。

## 决策树：我要做什么？

在开始编码前，先判断场景：

```
用户要做什么？
├── 创建一个新页面
│   ├── 固定布局（详情页、信息流单条）→ 固定视图模式
│   └── 列表（TableView/CollectionView）→ 列表模式
├── 在现有页面加一个功能模块 → 创建 Presenter，装配到父 Presenter
├── 创建一个可复用的列表 Cell → 复用 Presenter 模式
└── 在传统 VC 中嵌入一个组件 → IsolatedViewPresenter
```

## 一、创建页面（从大到小）

### 1.1 固定视图页面

这是最常用的模式。适用于详情页、固定布局页面。

**步骤：**

1. 定义 View 协议（页面需要展示什么）
2. 创建各功能 Presenter（每个功能一个）
3. 创建 RootPresenter（组装所有 Presenter）
4. 创建 PageViewController（UIKit 桥接，注册 Service）

**完整代码模板：**

```swift
// ===== Step 1: 定义 View 协议 =====
protocol MyPageViewProtocol: AnyObject {
    var likeButton: LikeViewProtocol { get }
    var shareButton: ShareViewProtocol { get }
    var commentList: CommentListViewProtocol { get }
}

// ===== Step 2: 创建各功能 Presenter =====
// 每个 Presenter 独立一个文件，见下方「创建 Presenter」章节

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
class MyPageViewController: PageViewController<MyPageRootView, MyPageRootPresenter, MyPageViewProtocol> {

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

### 1.2 列表页面（TableView / CollectionView）

适用于需要 Cell 复用的长列表。

**决策：Cell 是否需要 MVP 拆分？**
- Cell 很简单 → 不需要复用 Presenter，直接用普通 ViewPresenter
- Cell 内部还需要 MVP 拆分 → 需要复用 Presenter（继承 `ReusableViewPresenter`）

**复用 Presenter 的完整模板：**

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

## 二、创建 Presenter（功能单元）

每个 Presenter 是一个独立的业务逻辑单元。创建 Presenter 是日常开发中最频繁的操作。

### 2.1 标准 Presenter（有 UI）

```swift
// View 协议 — 定义这个 Presenter 需要消费什么数据
protocol MyFeatureViewProtocol: AnyObject {
    var title: String { get set }
    var isLoading: Bool { get set }
    var onButtonTapped: (() -> Void)? { get set }
}

// Presenter — 业务逻辑
class MyFeaturePresenter: ViewPresenter<MyFeatureViewProtocol> {

    // 状态 — 所有影响 UI 的数据
    struct State {
        var title = ""
        var isLoading = false
    }
    private var state = State()

    // 对外暴露只读状态
    var currentTitle: String { state.title }

    // 业务方法
    func loadData() {
        setState { state.isLoading = true }
        getService(DataService.self)?.fetch { [weak self] result in
            self?.setState {
                self?.state.title = result.title
                self?.state.isLoading = false
            } context: {
                $0.animated = true
            }
        }
    }

    // 生命周期：绑定 View 时设置回调
    override func onBindView(_ view: MyFeatureViewProtocol) {
        super.onBindView(view)
        view.onButtonTapped = { [weak self] in self?.loadData() }
    }

    // 生命周期：解绑 View 时清理回调（防止循环引用）
    override func onUnbindView() {
        super.onUnbindView()
        view?.onButtonTapped = nil
    }

    // 生命周期：状态变更 → 同步到 View
    override func onUpdate(view: MyFeatureViewProtocol, context: ViewUpdateContext) {
        view.title = state.title
        view.isLoading = state.isLoading
    }
}
```

### 2.2 纯逻辑 Presenter（View = Void，无 UI）

```swift
// 不需要 UI，只需要能力（如埋点、生命周期监听）
class LifecycleTracePresenter: ViewPresenter<TraceService>, PageLifecycle {

    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        bindView(getService(TraceService.self)!)  // View 就是 Service
    }

    func viewDidAppear(_ animated: Bool) {
        view?.trace(["event": "page_appear"])
    }

    func viewDidDisappear(_ animated: Bool) {
        view?.trace(["event": "page_disappear"])
    }
}
```

### 2.3 将 Presenter 装配到页面

**关键规则：`PageViewController.makePresenter()` 已经创建了 RootPresenter，不要在 `pageInstallers` 中再次注册它。** `pageInstallers` 中的 `PresenterInstaller` 用于注册 RootPresenter 的**子 Presenter**，而不是 RootPresenter 本身。

```swift
// 方式一：在 RootPresenter 的 init 中注册子 Presenter（推荐）
class MyRootPresenter: RootViewPresenter<MyViewProtocol> {
    required init() {
        super.init()
        typeBox(MyFeaturePresenter())        // 常驻 Presenter
        typeBoxLazy({ ExpensivePresenter() }) // 懒加载
    }
}

// 方式二：在 pageInstallers 中注册子 Presenter
// ⚠️ 注意：这里注册的是子 Presenter，不是 RootPresenter 本身
@PageInstallerBuilder override var pageInstallers: PageInstaller {
    PresenterInstaller(lazyLoad: true, { MyFeaturePresenter() })
}
```

## 三、代码组织建议

### 文件结构

```
Feature/
├── Models/
│   └── Comment.swift              # 数据模型
├── Presenters/
│   ├── CommentListRootPresenter.swift
│   ├── CommentSectionPresenter.swift
│   └── CommentItemPresenter.swift
├── Views/
│   ├── CommentCell.swift           # 实现 CommentCellProtocol
│   └── CommentListView.swift       # 实现 CommentListViewProtocol
├── Protocols/
│   └── CommentViewProtocols.swift  # 所有 View 协议
├── Services/
│   ├── CommentDataService.swift    # 协议 + 实现
│   └── CommentLikeService.swift
└── CommentListViewController.swift
```

### Presenter 拆分原则

判断一个 Presenter 是否应该继续拆分：

- **单一职责**：一个 Presenter 只做一件事（Like、Share、Comment 各一个）
- **独立复用**：如果某块逻辑可能在多个页面使用，就独立成 Presenter
- **独立测试**：如果某块逻辑需要单独测试，就独立成 Presenter
- **不要过度拆分**：如果两个功能总是同时出现且逻辑简单，可以放在一起

### 何时用 Service vs 直接写在 Presenter 里

- **Service**：可替换的能力（网络请求、路由跳转、埋点上报、数据持久化）
- **Presenter 内部**：无法替换的业务逻辑（状态管理、业务流程编排、UI 交互逻辑）

## 四、通信：Presenter 之间如何交互

### 场景 1：子 Presenter 需要通知父 Presenter

```swift
// 定义监听协议
protocol LikeListener: AnyObject {
    func onLikeChanged(isLiked: Bool, count: Int)
}

// 发送方（子 Presenter）
notify(listener: LikeListener.self) {
    $0.onLikeChanged(isLiked: true, count: 10)
}

// 接收方（父 Presenter 实现协议即可）
extension MyRootPresenter: LikeListener {
    func onLikeChanged(isLiked: Bool, count: Int) {
        // 更新页面级别的状态
        updateTotalLikeCount()
    }
}
```

### 场景 2：父 Presenter 需要通知所有子 Presenter

```swift
// 向下广播到所有子 Presenter
notifyChildren(listener: ThemeListener.self) {
    $0.onThemeChanged(.dark)
}
```

### 场景 3：需要外部能力（网络、路由、埋点等）

```swift
// 用 Service，不要直接依赖具体实现
getService(DataLoader.self)?.fetch { ... }
getService(RouterService.self)?.navigate(to: .profile)
```

### 通信方式选择

| 场景 | 用 Notify | 用 Service |
|---|---|---|
| 父 ↔ 子 Presenter 通信 | ✅ | ❌ |
| 网络请求 | ❌ | ✅ |
| 页面跳转 | ❌ | ✅ |
| 埋点上报 | ❌ | ✅ |
| 全局事件（主题切换、登录状态） | ✅ | ❌ |

## 五、关键规则（必须遵守）

### ✅ DO

- **View 必须定义为协议**，不能是具体 UIView 类型
- **所有 UI 更新通过 `setState {}`**，不要直接 `view?.xxx = yyy`
- **`onBindView` 中设置回调，`onUnbindView` 中清空回调**
- **`onBindView` 中先调用 `super.onBindView(view)`**
- **子 Presenter 必须 `add(child:)` 才能加入 P-Tree**，否则收不到生命周期
- **Service 和子 Presenter 在 `pageInstallers` 中注册，或在 RootPresenter 的 `init()` 和 `presenterDidLoad()` 中注册**
- **异步回调中使用 `[weak self]`**

### ❌ DON'T

- **不要用 UIView 作为 View 类型**（`ViewPresenter<UIButton>` ❌）
- **不要在 `setState` 外部修改会影响 UI 的状态**
- **不要在 `viewDidLoad` 之前注册 Service**（时机不对）
- **不要忘记在 `onUnbindView` 中清理回调**
- **不要在 `pageInstallers` 中注册 RootPresenter** — `PageViewController.makePresenter()` 已经创建了它。`pageInstallers` 中注册的是子 Presenter

## 六、setState 和 onUpdate 详解

这是框架最核心的机制，必须正确理解：

```swift
// setState：标记"状态变了"，由 Pipeline 调度
setState {
    // 在这里修改状态
    self.count += 1
    self.title = "Updated"
} context: {
    // 配置这次更新的行为
    $0.animated = true           // 在 UIView.animate 中执行
    $0.invalidateLayout = true   // 更新后触发 layout
    $0.updateViewImmediately = true // 立即更新，不等 RunLoop
}

// onUpdate：Pipeline 在合适时机调用，同步状态到 View
override func onUpdate(view: MyViewProtocol, context: ViewUpdateContext) {
    view.count = count
    view.title = title
}
```

**常用 Context 配置：**

| Flag | 何时使用 |
|---|---|
| `animated = true` | 需要动画过渡 |
| `invalidateLayout = true` | 数据变化影响了布局 |
| `invalidateDataSource = true` | 列表数据源变了（触发 Diff + reload） |
| `invalidateContentSize = true` | 只有 Cell 尺寸变了 |
| `updateViewImmediately = true` | 需要立即更新，不等待批处理 |
| `animator = MyAnimator()` | 自定义动画器（替代默认 0.3s UIView.animate） |

**自定义 Animator：** 管道分两步执行——`updateView`（更新属性）和 `layoutViewIfNeeded`（应用约束布局）。第二步只在 `animated = true` 或 `layoutImmediately = true` 时进入动画块。因此使用自定义 `animator` 时必须同时设置 `animated = true`：

```swift
// ❌ BAD — animator 没配 animated，layoutIfNeeded 不在动画块内，约束变更无动画
$0.invalidateLayout = true
$0.animator = BounceAnimator()

// ✅ GOOD — 同时设 animated = true（animator 优先级高于默认 0.3s）
$0.invalidateLayout = true
$0.animated = true
$0.animator = BounceAnimator()

// 自定义 Animator 实现
final class BounceAnimator: ViewUpdateAnimator {
    func animate(with context: ViewUpdateContext, _ updater: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.6, delay: 0,
            usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8,
            options: [.allowUserInteraction],
            animations: updater
        )
    }
}
```

## 七、layoutInfo：列表 Cell 和 Section 的布局配置

列表场景中，Cell 的尺寸和 Section 的间距通过 `layoutInfo` 属性配置。每个 Item/Section Presenter 都持有自己的 `layoutInfo`，框架在运行时读取并应用到 `UICollectionViewLayout` 或 `UITableView` 的 delegate 方法。

### UICollectionView Item 布局：`UICollectionItemFlowLayoutInfo`

| Presenter 基类 | 自带 layoutInfo |
|---|---|
| `UICollectionViewFlowItemPresenter<View>` | ✅ |
| `UICollectionViewFlowItemPresenterHolder<P, V>` | ✅ |
| `CollectionItemPresenter<View>` | ❌ 需手动 conform `UICollectionItemFlowPresentable` |

```swift
public struct UICollectionItemFlowLayoutInfo {
    public var calculateSizeAutomatically: Bool = true  // 自动计算（推荐）
    public var layoutType: LayoutType = .autoLayout       // .autoLayout / .sizeThatFits / .intrinsicContentSize
    public var autoLayoutSizeFitting: SizeFitting = .auto // .auto / .containerWidth / .containerHeight / .containerSize / .unlimited
}
```

**自动计算（推荐）**：Cell 使用 Auto Layout 约束，框架自动推导高度：

```swift
class CardItemPresenter: UICollectionViewFlowItemPresenter<CardCell> {
    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = true  // 默认值，可不写
    }
}
```

**手动计算**：当 `calculateSizeAutomatically = false` 时，必须重写 `calculateSize(containerSize:)`：

```swift
class FixedSizeItem: UICollectionViewFlowItemPresenter<FixedCell> {
    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = false
    }
    override func calculateSize(containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: 80)
    }
}
```

### UICollectionView Section 布局：`UICollectionViewFlowSectionLayoutInfo`

```swift
public struct UICollectionViewFlowSectionLayoutInfo {
    public var inset: UIEdgeInsets = .zero   // section 内边距
    public var lineSpacing: CGFloat = 0      // 行间距
    public var itemSpacing: CGFloat = 0      // 列间距
    public var columnCount: Int = 1          // 列数（>1 时均分宽度）
}
```

```swift
let section = UICollectionViewFlowSectionPresenter()
section.layoutInfo.inset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
section.layoutInfo.lineSpacing = 12
section.layoutInfo.columnCount = 2   // 两列布局
```

### UICollectionView Section Header/Footer 便捷 API

`UICollectionViewFlowSectionPresenter` 提供 `.header` / `.footer` 属性，比 `setSupplementary(_:_:)` 更简洁：

```swift
public extension UICollectionViewFlowSectionPresenter {
    var header: UICollectionViewItemPresentable?   // get/set，单元素便捷访问
    var footer: UICollectionViewItemPresentable?   // get/set，单元素便捷访问
}
```

**Header/Footer Presenter 必须继承 `UICollectionViewFlowItemPresenter<View>`（或实现 `UICollectionItemFlowPresentable`），不能用 `CollectionItemPresenter<View>`。**

```swift
// ✅ GOOD — 用 .header/.footer 便捷属性
let section = UICollectionViewFlowSectionPresenter()
let header = SectionHeaderPresenter()
header.title = "评论"
section.header = header

let footer = SectionFooterPresenter(); footer.count = 10
section.footer = footer

// ❌ BAD — 避免直接操作 supplementaries 字典
section.setSupplementary("UICollectionElementKindSectionHeader", [header])
section.setSupplementary("UICollectionElementKindSectionFooter", [footer])
```

### UITableView Item 布局：`UITableViewCellLayoutInfo`

| Presenter 基类 | 自带 layoutInfo |
|---|---|
| `UITableViewItemPresenter<V>` | ✅ |
| `UITableViewItemPresenterHolder<P, V>` | ✅ |

```swift
public struct UITableViewCellLayoutInfo {
    public var calculateSizeAutomatically: Bool = true
    public var layoutType: LayoutType = .autoLayout  // .autoLayout / .sizeThatFits
    public var estimatedHeight: CGFloat = UITableView.automaticDimension
}
```

```swift
class CommentItem: UITableViewItemPresenter<CommentCell> {
    override init() {
        super.init()
        layoutInfo.estimatedHeight = 120  // 预估高度，优化滚动性能
    }
}
```

### 关键规则

- ✅ **Section 的 inset/spacing 必须在 Section Presenter 的 `layoutInfo` 上设置**，不要在 UICollectionViewFlowLayout 上直接设置
- ✅ **Item 的 `calculateSizeAutomatically = true`（默认）配合 Auto Layout 约束即可**，无需手动计算
- ✅ **设置预估高度（`estimatedHeight`）可显著提升 TableView 滚动性能**
- ✅ **Section Header/Footer 用 `section.header = ...` / `section.footer = ...`**，不要用 `setSupplementary(_:_:)`
- ✅ **Header/Footer Presenter 必须继承 `UICollectionViewFlowItemPresenter<View>`**，不能用 `CollectionItemPresenter<View>`
- ❌ **不要把布局信息放在 View 层**，`layoutInfo` 属于 Presenter 层

## 八、新文件创建时的命名和模板

当用户要求创建新功能时，按以下结构产出文件：

- `XxxPresenter.swift` — 业务逻辑，继承 `ViewPresenter<XxxProtocol>`
- `XxxViewController.swift` — 页面入口，继承 `PageViewController<...>` 或 `UITablePageViewController<...>`
- `XxxService.swift` — 服务协议 + 默认实现
- View 协议可以放在 Presenter 文件顶部，也可以单独放 `Protocols/` 目录

详细代码示例参考 `references/examples.md`。当用户需要看具体例子时，引导他们阅读该文件。