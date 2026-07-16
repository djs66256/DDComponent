# 复用 Presenter（列表场景）

## 概述

列表的复用是客户端列表的基本能力，而与之配套的 Presenter 也需具备复用能力。DDComponent 提供了完整的复用 Presenter 体系，让 Presenter 像 Cell 一样可以被复用。

## 不复用 Presenter vs 复用 Presenter

如果 Cell 不准备采用 MVP，而是一个简单的 View，则可以采用不复用 Presenter 的形式。但这种选型只能是 Cell 比较简单的场景，一旦这样选型 Cell 内部则无法进行继续 MVP 拆分。

| | 不复用 Presenter | 复用 Presenter |
|---|---|---|
| 适用场景 | 固定列表、Cell 简单 | 长列表、Cell 需要 MVP 拆分 |
| Cell 内部 MVP | ❌ 无法继续拆分 | ✅ 可以继续嵌套 Presenter |
| 内存效率 | 所有 Presenter 常驻 | 只保留可见 Cell 的 Presenter |
| 复杂度 | 低 | 中 |

## 复用 Presenter 基类

可复用 Presenter 必须继承 `ReusableViewPresenter`：

```swift
open class ReusableViewPresenter<View>: ViewPresenter<View>, ReusablePresentable {
    required public override init()  // 必须支持 init()
    open func prepareForReuse()      // 复用时重置状态
}
```

复用 Presenter 必须：
- 继承 `ReusableViewPresenter<View>`
- 实现 `required init()`
- 重写 `prepareForReuse()` 清理状态

```swift
class CommentItemPresenter: ReusableViewPresenter<CommentCellProtocol> {
    required init() {
        super.init()
        autoBindView = false  // 复用场景下通常关闭自动绑定
    }

    var comment: Comment? {
        didSet { setState {} }
    }

    override func prepareForReuse() {
        comment = nil
        // 清理其他状态
    }

    override func onUpdate(view: CommentCellProtocol, context: ViewUpdateContext) {
        view.userName = comment?.author
        view.content = comment?.text
    }
}
```

## 数据源绑定

可复用 Presenter 需要与数据源绑定才可以展示。数据源也采用 Presenter 进行包装，从而形成完整的体系：

```
CollectionItemReusablePresenter<ItemClass, P, V>
  ├── ItemClass: 所代表的 Reusable Cell 类型
  ├── P: 复用 Presenter 类型
  └── V: 复用 Presenter 的 View
```

## CollectionPresenter 体系

DDComponent 为列表场景提供了完整的抽象层：

```
CollectionRootPresenter          ← 页面级别，持有 CollectionPresenter
  └── CollectionPresenter        ← 管理 sections 数组
       └── CollectionSectionPresenter  ← 管理 items 数组
            └── CollectionItemPresenter  ← 单个 Cell 的 Presenter
```

### CollectionPresenter

管理 Section 级别的数据：

```swift
open class CollectionPresenter<View>: ViewPresenter<View> {
    var sections: [CollectionSectionPresentable]

    func setSections(_ sections: [CollectionSectionPresentable],
                     animated: Bool = false,
                     completion: (() -> Void)? = nil)
}
```

设置 sections 会：
1. 比较新旧 sections，移除不在新数组中的旧 section
2. 将新 section 加入 children
3. 触发 `setState { $0.reloadData() }` 通知 Pipeline 更新 UI

### CollectionSectionPresenter

管理 Item 级别的数据：

```swift
class CollectionSectionPresenter: ViewPresenter<Void> {
    var items: [CollectionItemPresentable]
    var supplementaries: [String: [CollectionItemPresentable]]  // header/footer

    func setItems(_ items: [CollectionItemPresentable], animated: Bool)
    func setSupplementary(_ items: [CollectionItemPresentable],
                          for kind: String, animated: Bool)
}
```

### CollectionItemPresenter

单个 Cell 的 Presenter，使用 **Shadow Presenter** 模式：

```swift
class CollectionItemPresenter<View>: ViewPresenter<View> {
    // 内部 Shadow Presenter 负责转发生命周期到实际的 Cell
    class ShadowPresenter: ViewPresenter<()> {
        // 转发 onBindView, onUnbindView, onUpdate 到外层
    }
}
```

## 复用 Presenter 持有者

`ReusableViewPresenterHolder` 是复用 Presenter 的容器，负责管理复用 Presenter 的绑定/解绑：

```swift
open class ReusableViewPresenterHolder<P, V>: ViewPresenter<()>
    where P: ReusableViewPresenter<V> {

    // 当前绑定的复用 Presenter 列表
    var reusedPresenters: [P]

    // 绑定一个复用 Presenter
    func bindReusablePresenter(_ presenter: P)

    // 解绑
    func unbindReusablePresenter(_ presenter: P)
    func unbindAllReusablePresenters()

    // 子类重写以响应复用 Presenter 的更新
    open func onUpdate(presenter: P, context: ViewUpdateContext)
    open func onBindReusablePresenter(_ presenter: P)
    open func onUnbindReusablePresenter(_ presenter: P)
}
```

## 完整示例：评论列表

### 1. 定义 Item Presenter（可复用）

```swift
class CommentItemPresenter: ReusableViewPresenter<CommentCellProtocol> {
    required init() { super.init() }

    var comment: Comment? {
        didSet { setState {} }
    }

    override func prepareForReuse() {
        comment = nil
    }

    override func onUpdate(view: CommentCellProtocol, context: ViewUpdateContext) {
        view.authorLabel = comment?.author
        view.contentLabel = comment?.text
        view.avatarURL = comment?.avatarURL
    }

    override func onBindView(_ view: CommentCellProtocol) {
        view.onAvatarTapped = { [weak self] in
            self?.openProfile()
        }
    }
}
```

### 2. 定义 Section Presenter

```swift
class CommentSectionPresenter: CollectionSectionPresenter {
    var comments: [Comment] = [] {
        didSet {
            setItems(comments.map { comment in
                CommentItemPresenter().apply {
                    $0.comment = comment
                }
            })
        }
    }
}
```

### 3. 定义 Root Presenter

```swift
class CommentListRootPresenter: CollectionRootPresenter<CommentListViewProtocol> {
    let sectionPresenter = CommentSectionPresenter()

    override func onAttach() {
        super.onAttach()
        add(child: sectionPresenter)
        sections = [sectionPresenter]
    }

    func loadComments() {
        api.fetchComments { [weak self] comments in
            self?.sectionPresenter.comments = comments
        }
    }
}
```

### 4. 创建 ViewController

```swift
// UITableView
class CommentListViewController: UITablePageViewController<CommentItemPresenter> {
    override func makePresenter() -> CommentListRootPresenter {
        CommentListRootPresenter()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.loadComments()
    }
}

// UICollectionView
class CommentCollectionViewController: UICollectionPageViewController<CommentItemPresenter> {
    override func makePresenter() -> CommentListRootPresenter {
        CommentListRootPresenter()
    }
}
```

## 增量更新引擎

DDComponent 的列表更新 Pipeline 包含完整的增量更新引擎：

### 更新流程

```
setState { $0.reloadData() }
    │
    ▼
PartialTrasactionPipeline.markDirty()
    │
    ▼
Diff 计算（后台队列）
    ├── 比较 Section 标识符 → inserts/deletes/moves
    └── 比较 Item 标识符 → inserts/deletes/moves/reloads
    │
    ▼
ListViewUpdateResolver（主线程）
    ├── UICollectionViewUpdateResolver
    └── UITableViewUpdateResolver
    │
    ▼
performBatchUpdates / reloadData
```

### 内容尺寸更新

当只有 Cell 尺寸变化（数据源不变）时，使用 `invalidateContentSize` 避免全量 reload：

```swift
setState {
    // 只修改了影响尺寸的数据
} context: {
    $0.invalidateContentSize = true  // 只更新布局，不 reload 数据源
}
```

### UICollectionView 布局信息

CollectionView 的布局由两处 `layoutInfo` 控制：**Item 级别**和 **Section 级别**。

#### Item 布局：`UICollectionItemFlowLayoutInfo`

每个 Cell（以及 Header/Footer）Presenter 都持有一个 `layoutInfo`，定义在 `UICollectionItemFlowPresentable` 协议中。框架在运行时会通过 `UICollectionViewFlowLayoutProxy` 读取这些配置来计算 Cell 的 `sizeForItemAt`。

| Presenter 基类 | 是否自带 `layoutInfo` |
|---|---|
| `UICollectionViewFlowItemPresenter<View>` | ✅ `public var layoutInfo` |
| `UICollectionViewFlowItemPresenterHolder<P, V>` | ✅，转发到 Holder 上 |
| `UICollectionViewReusableFlowItemPresenter<View>` | ✅ |
| `CollectionItemPresenter<View>` | ❌ 不含，需手动实现 `UICollectionItemFlowPresentable` |

**`UICollectionItemFlowLayoutInfo` 结构：**

```swift
public struct UICollectionItemFlowLayoutInfo {
    /// 是否自动计算 size。为 true 时框架根据 layoutType 自动计算。
    /// 为 false 时需重写 calculateSize(containerSize:) 手动返回 size。
    public var calculateSizeAutomatically: Bool = true

    /// 自动计算时使用的算法
    public var layoutType: LayoutType = .autoLayout
    public enum LayoutType {
        case autoLayout              // Auto Layout 约束计算（推荐）
        case sizeThatFits            // 调用 sizeThatFits(_:)
        case intrinsicContentSize    // 使用 intrinsicContentSize
    }

    /// 仅 layoutType = .autoLayout 时生效，控制传给 Auto Layout 的容器尺寸
    public var autoLayoutSizeFitting: SizeFitting = .auto
    public enum SizeFitting {
        case auto               // 根据 sectionInset + columnCount 自动推导
        case containerWidth     // 使用容器宽度
        case containerHeight    // 使用容器高度
        case containerSize      // 使用容器宽高
        case unlimited          // 不限制宽高
    }
}
```

**自动计算（推荐，使用 Auto Layout 约束）：**

```swift
class CardItemPresenter: UICollectionViewFlowItemPresenter<CardCell> {
    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = true  // 默认值
        // Cell 的 Auto Layout 约束决定了高度，框架自动用 containerWidth 计算
    }
}
```

**手动计算：**

```swift
class CustomSizeItem: UICollectionViewFlowItemPresenter<CustomCell> {
    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = false
    }

    override func calculateSize(containerSize: CGSize) -> CGSize {
        return CGSize(width: containerSize.width, height: 80)
    }
}
```

**非 UICollectionViewFlowItemPresenter 子类需要手动声明：**

```swift
class CardItemPresenter: CollectionItemPresenter<CardCell>, UICollectionItemFlowPresentable {
    var layoutInfo = UICollectionItemFlowLayoutInfo()
    override init() { super.init(); layoutInfo.calculateSizeAutomatically = true }
}
```

#### Section 布局：`UICollectionViewFlowSectionLayoutInfo`

Section 级别的布局信息控制 inset、间距和列数：

```swift
public struct UICollectionViewFlowSectionLayoutInfo {
    public var inset: UIEdgeInsets = .zero       // section 内边距
    public var lineSpacing: CGFloat = 0          // 行间距（垂直滚动时）
    public var itemSpacing: CGFloat = 0          // 列间距（垂直滚动时）
    public var columnCount: Int = 1              // 列数（>1 时按列均分宽度）
}
```

**使用示例：**

```swift
let section = UICollectionViewFlowSectionPresenter()
section.layoutInfo.inset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
section.layoutInfo.lineSpacing = 12
section.layoutInfo.itemSpacing = 8
section.layoutInfo.columnCount = 2  // 两列布局

section.setItems(items)
sections = [section]
```

### UITableView 布局信息

TableView Cell 的高度由 `UITableViewCellLayoutInfo` 控制：

| Presenter 基类 | 是否自带 `layoutInfo` |
|---|---|
| `UITableViewItemPresenter<V>` | ✅ `public var layoutInfo` |
| `UITableViewItemPresenterHolder<P, V>` | ✅ |
| `UITableViewItemReusablePresenter<View>` | ✅ |

**`UITableViewCellLayoutInfo` 结构：**

```swift
public struct UITableViewCellLayoutInfo {
    /// 是否自动计算高度。为 true 时根据 layoutType 自动计算。
    public var calculateSizeAutomatically: Bool = true

    /// 自动计算时使用的算法
    public var layoutType: LayoutType = .autoLayout
    public enum LayoutType {
        case autoLayout      // Auto Layout 约束计算
        case sizeThatFits    // 调用 sizeThatFits(_:)
    }

    /// 预估高度（用于优化 TableView 滚动性能）
    public var estimatedHeight: CGFloat = UITableView.automaticDimension
}
```

**自动计算（推荐）：**

```swift
class CommentItem: UITableViewItemPresenter<CommentCell> {
    override init() {
        super.init()
        // calculateSizeAutomatically = true 是默认值
        layoutInfo.estimatedHeight = 120  // 设置预估高度提升滚动性能
    }
}
```

**手动计算：**

```swift
class FixedHeightItem: UITableViewItemPresenter<FixedCell> {
    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = false
    }

    override func calculateHeight(containerSize: CGSize) -> CGFloat {
        return 60  // 固定高度
    }
}
```

## 复用范围广播

列表场景中，常常只需要在同一个 Section 或同一个 Cell 内部通信。使用 `.reusable` 作用域限定广播范围：

```swift
// 在 Cell 的 Presenter 中发送
notifyReusable(listener: CellActionListener.self) {
    $0.onDeleteTapped(cellIndex: index)
}

// 消息会被限定在最近的复用容器范围内
// 不会传播到其他 Section 或无关的 Presenter
```

## Shadow Presenter 原理

Shadow Presenter 是 CollectionItemPresenter 的**内部实现细节**，用于解决复用场景下的生命周期管理：

```
Cell 显示时:
  CollectionItemPresenter
    └── ShadowPresenter
          ├── bindView(cell)     → 触发 onBindView
          └── onUpdate(cell)     → 触发业务 Presenter 的 onUpdate

Cell 回收时:
  CollectionItemPresenter
    └── ShadowPresenter
          └── unbindView()       → 触发 onUnbindView
          └── prepareForReuse()  → 重置状态
```

开发者通常不需要直接操作 Shadow Presenter，框架自动处理绑定/解绑。只需要在 Item Presenter 中重写 `onBindView`、`onUnbindView`、`prepareForReuse` 即可。

## IsolatedViewPresenter

当你需要在非 DDComponent 页面中使用 Presenter 组件时，可以使用 `IsolatedViewPresenter`。它自带独立的 ServiceManager、NotifyManager 和 UpdatePipeline，不依赖外部的 RootPresenter：

```swift
// 在传统 UIViewController 中嵌入一个 Presenter 组件
let isolated = IsolatedViewPresenter(
    MyLikeButton(),
    LikePresenter()
)

// 注册服务
isolated.register(service: LikeService.self) { LikeServiceImpl() }

// 绑定生命周期
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    isolated.notifyGlobal(listener: PageLifecycle.self) {
        $0.viewDidAppear(animated)
    }
}
```

适合在渐进式迁移中，在传统页面中逐步引入 DDComponent 的 Presenter 组件。