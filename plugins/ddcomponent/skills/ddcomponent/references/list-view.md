# 列表视图（TableView / CollectionView）

适用于需要 Cell 复用的长列表。

## 架构概览

```
CollectionRootPresenter
  └── CollectionSectionPresenter[] (sections)
        ├── CollectionItemPresenter[] (items)
        └── UICollectionViewFlowItemPresenter[] (supplementaries: header/footer)
```

## 决策：Cell 是否需要 MVP 拆分？

- Cell 很简单 → 不需要复用 Presenter，直接用普通 ViewPresenter
- Cell 内部还需要 MVP 拆分 → 必须用 `ReusableViewPresenter`（支持 `prepareForReuse`）

## 复用 Presenter 完整模板

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

## layoutInfo 布局配置

列表场景中，Cell 的尺寸和 Section 的间距通过 `layoutInfo` 属性配置。

### UICollectionView Item 布局：`UICollectionItemFlowLayoutInfo`

| Presenter 基类 | 自带 layoutInfo |
|---|---|
| `UICollectionViewFlowItemPresenter<View>` | ✅ |
| `UICollectionViewFlowItemPresenterHolder<P, V>` | ✅ |
| `CollectionItemPresenter<View>` | ❌ 需手动 conform `UICollectionItemFlowPresentable` |

```swift
public struct UICollectionItemFlowLayoutInfo {
    public var calculateSizeAutomatically: Bool = true
    public var layoutType: LayoutType = .autoLayout
    public var autoLayoutSizeFitting: SizeFitting = .auto
}
```

**自动计算（推荐）**：

```swift
class MyItemPresenter: UICollectionViewFlowItemPresenter<MyCell> {
    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = true  // 默认值
    }
}
```

**手动计算**：

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
    public var inset: UIEdgeInsets = .zero
    public var lineSpacing: CGFloat = 0
    public var itemSpacing: CGFloat = 0
    public var columnCount: Int = 1
}
```

```swift
let section = UICollectionViewFlowSectionPresenter()
section.layoutInfo.inset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
section.layoutInfo.lineSpacing = 12
section.layoutInfo.columnCount = 2   // 两列网格
```

### Section Header/Footer 便捷 API

```swift
// Header/Footer Presenter 必须继承 UICollectionViewFlowItemPresenter<View>
class SectionHeaderPresenter: UICollectionViewFlowItemPresenter<MyHeaderView> {
    var title: String = "" { didSet { setState {} } }
    override init() { super.init(); layoutInfo.calculateSizeAutomatically = false }
    override func onUpdate(view: MyHeaderView, context: ViewUpdateContext) { view.title = title }
    override func calculateSize(containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: 44)
    }
}

// 使用
let section = UICollectionViewFlowSectionPresenter()
section.header = SectionHeaderPresenter()
section.footer = SectionFooterPresenter()
```

### UITableView Item 布局：`UITableViewCellLayoutInfo`

```swift
public struct UITableViewCellLayoutInfo {
    public var calculateSizeAutomatically: Bool = true
    public var layoutType: LayoutType = .autoLayout
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

## 关键规则

- ✅ **Section 的 inset/spacing 在 Section Presenter 的 `layoutInfo` 上设置**，不要在 FlowLayout 上直接设置
- ✅ **`calculateSizeAutomatically = true`（默认）配合 Auto Layout 即可**，无需手动计算
- ✅ **设置 `estimatedHeight` 可显著提升 TableView 滚动性能**
- ✅ **Section Header/Footer 用 `section.header/footer`**，不用 `setSupplementary`
- ✅ **Header/Footer Presenter 必须继承 `UICollectionViewFlowItemPresenter<View>`**
- ❌ **不要把布局信息放在 View 层**，`layoutInfo` 属于 Presenter 层