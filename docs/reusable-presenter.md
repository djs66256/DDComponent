# 复用 Presenter（列表场景）

## 概述

列表的复用是客户端列表的基本能力，DDComponent 提供了完整的复用 Presenter 体系，让 Presenter 像 Cell 一样可以被复用。

> 📖 Demo: [05-ListDiffUpdate](../Example/DDComponent/Demos/05-ListDiffUpdate/) — Diff 增量更新
> 📖 Demo: [06-HeaderFooter](../Example/DDComponent/Demos/06-HeaderFooter/) — Section Header/Footer
> 📖 Demo: [10-FeedExample](../Example/DDComponent/Demos/10-FeedExample/) — 综合示例

## 不复用 Presenter vs 复用 Presenter

| | 不复用 Presenter | 复用 Presenter |
|---|---|---|
| 适用场景 | 固定列表、Cell 简单 | 长列表、Cell 需要 MVP 拆分 |
| Cell 内部 MVP | ❌ 无法继续拆分 | ✅ 可以继续嵌套 Presenter |
| 内存效率 | 所有 Presenter 常驻 | 只保留可见 Cell 的 Presenter |

## 复用 Presenter 基类

可复用 Presenter 必须继承 `ReusableViewPresenter`，实现 `required init()` 和 `prepareForReuse()`：

```swift
class CommentItemPresenter: ReusableViewPresenter<CommentCellProtocol> {
    required init() { super.init() }

    var comment: Comment? { didSet { setState {} } }

    override func prepareForReuse() { comment = nil }

    override func onBindView(_ view: CommentCellProtocol) {
        view.onAvatarTapped = { [weak self] in self?.openProfile() }
    }

    override func onUpdate(view: CommentCellProtocol, context: ViewUpdateContext) {
        view.userName = comment?.author
        view.content = comment?.text
    }
}
```

## CollectionPresenter 体系

DDComponent 为列表场景提供了完整的抽象层：

```
CollectionRootPresenter          ← 页面级别
  └── CollectionPresenter        ← 管理 sections 数组
       └── CollectionSectionPresenter  ← 管理 items 数组
            └── CollectionItemPresenter  ← 单个 Cell
```

### 完整示例：评论列表

```swift
// Section Presenter
class CommentSectionPresenter: CollectionSectionPresenter {
    var comments: [Comment] = [] {
        didSet { setItems(comments.map { CommentItemPresenter().apply { $0.comment = $0 } }) }
    }
}

// Root Presenter
class CommentListRootPresenter: CollectionRootPresenter<CommentListViewProtocol> {
    let sectionPresenter = CommentSectionPresenter()

    override func onAttach() {
        super.onAttach()
        add(child: sectionPresenter)
        sections = [sectionPresenter]
    }
}

// ViewController
class CommentListViewController: UITablePageViewController<CommentItemPresenter> {
    override func makePresenter() -> CommentListRootPresenter { CommentListRootPresenter() }
    override func viewDidLoad() { super.viewDidLoad(); presenter.loadComments() }
}
```

## 增量更新引擎

### 更新流程

```
setState { $0.reloadData() }
    │
    ▼
PartialTransactionPipeline.markDirty()
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

当只有 Cell 尺寸变化（数据源不变）时，使用 `invalidateContentSize` 避免全量 reload：

```swift
setState {
    // 只修改了影响尺寸的数据
} context: {
    $0.invalidateContentSize = true  // 只更新布局，不 reload 数据源
}
```

## UICollectionView 布局配置

布局由 Item 级别和 Section 级别的 `layoutInfo` 控制。

### Item 布局：`UICollectionItemFlowLayoutInfo`

| Presenter 基类 | 是否自带 `layoutInfo` |
|---|---|
| `UICollectionViewFlowItemPresenter<View>` | ✅ |
| `UICollectionViewFlowItemPresenterHolder<P, V>` | ✅ |
| `CollectionItemPresenter<View>` | ❌ 需手动 conform `UICollectionItemFlowPresentable` |

```swift
public struct UICollectionItemFlowLayoutInfo {
    public var calculateSizeAutomatically: Bool = true  // 自动计算（推荐）
    public var layoutType: LayoutType = .autoLayout
    // .autoLayout / .sizeThatFits / .intrinsicContentSize
    public var autoLayoutSizeFitting: SizeFitting = .auto
    // .auto / .containerWidth / .containerHeight / .containerSize / .unlimited
}
```

**自动计算（推荐）：**

```swift
class MyItem: UICollectionViewFlowItemPresenter<MyCell> {
    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = true  // 默认值
    }
}
```

**手动计算：**

```swift
class FixedSizeItem: UICollectionViewFlowItemPresenter<FixedCell> {
    override init() { super.init(); layoutInfo.calculateSizeAutomatically = false }
    override func calculateSize(containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: 80)
    }
}
```

### Section 布局：`UICollectionViewFlowSectionLayoutInfo`

```swift
public struct UICollectionViewFlowSectionLayoutInfo {
    public var inset: UIEdgeInsets = .zero
    public var lineSpacing: CGFloat = 0
    public var itemSpacing: CGFloat = 0
    public var columnCount: Int = 1          // >1 时均分宽度
}
```

```swift
let section = UICollectionViewFlowSectionPresenter()
section.layoutInfo.inset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
section.layoutInfo.lineSpacing = 12
section.layoutInfo.columnCount = 2   // 两列布局
```

### Section Header/Footer 便捷 API

用 `.header` / `.footer` 属性，不要用 `setSupplementary`：

```swift
// ✅ GOOD
let section = UICollectionViewFlowSectionPresenter()
section.header = SectionHeaderPresenter()
section.footer = SectionFooterPresenter()

// ❌ BAD
section.setSupplementary("UICollectionElementKindSectionHeader", [header])
```

**Header/Footer Presenter 必须继承 `UICollectionViewFlowItemPresenter<View>`。**

## UITableView 布局配置

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

## 复用范围广播

列表场景中用 `.reusable` 限定广播范围：

```swift
notifyReusable(listener: CellActionListener.self) { $0.onDeleteTapped(cellIndex: index) }
// 消息限定在最近的复用容器范围内，不影响其他 Section
```

## IsolatedViewPresenter

在非 DDComponent 页面中嵌入 Presenter 组件：

```swift
let isolated = IsolatedViewPresenter(MyLikeButton(), LikePresenter())
isolated.register(service: LikeService.self) { LikeServiceImpl() }
view.addSubview(isolated.view)
```

> 📖 Demo: [08-IsolatedPresenter](../Example/DDComponent/Demos/08-IsolatedPresenter/)

## 关键规则

- ✅ **Section 的 inset/spacing 必须在 Section Presenter 的 `layoutInfo` 上设置**
- ✅ **Item 的 `calculateSizeAutomatically = true` 配合 Auto Layout 即可**
- ✅ **设置预估高度（`estimatedHeight`）可显著提升 TableView 滚动性能**
- ✅ **Section Header/Footer 用 `section.header = ...` / `section.footer = ...`**
- ✅ **Header/Footer Presenter 必须继承 `UICollectionViewFlowItemPresenter<View>`**
- ❌ **不要把布局信息放在 View 层**，`layoutInfo` 属于 Presenter 层

## 相关文档

- [架构设计](./architecture.md) — P-Tree/V-Tree、生命周期、UpdatePipeline
- [使用指南](./usage-guide.md) — 固定视图、Service/Notify
- [use* API](./use-methods.md) — 声明式状态管理
- [Demo 索引](./demo-index.md) — 所有示例 Demo
