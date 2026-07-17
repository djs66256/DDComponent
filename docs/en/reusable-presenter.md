# Reusable Presenter (List Scenarios)

## Overview

List reuse is a fundamental capability of client-side lists. DDComponent provides a complete reusable Presenter system, allowing Presenters to be reused just like Cells.

> 📖 Demo: [05-ListDiffUpdate](../../Example/DDComponent/Demos/05-ListDiffUpdate/) — Diff incremental update
> 📖 Demo: [06-HeaderFooter](../../Example/DDComponent/Demos/06-HeaderFooter/) — Section Header/Footer
> 📖 Demo: [10-FeedExample](../../Example/DDComponent/Demos/10-FeedExample/) — Comprehensive example

## Non-reusable Presenter vs Reusable Presenter

| | Non-reusable Presenter | Reusable Presenter |
|---|---|---|
| Use case | Fixed lists, simple Cells | Long lists, Cells requiring MVP decomposition |
| Cell-internal MVP | ❌ Cannot further decompose | ✅ Can continue nesting Presenters |
| Memory efficiency | All Presenters resident in memory | Only Presenters for visible Cells are retained |

## Reusable Presenter Base Class

Reusable Presenters must inherit from `ReusableViewPresenter` and implement `required init()` and `prepareForReuse()`:

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

## CollectionPresenter System

DDComponent provides a complete abstraction layer for list scenarios:

```
CollectionRootPresenter          ← Page level
  └── CollectionPresenter        ← Manages the sections array
       └── CollectionSectionPresenter  ← Manages the items array
            └── CollectionItemPresenter  ← Individual Cell
```

### Full Example: Comment List

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

## Incremental Update Engine

### Update Flow

```
setState { $0.reloadData() }
    │
    ▼
PartialTransactionPipeline.markDirty()
    │
    ▼
Diff computation (background queue)
    ├── Compare Section identifiers → inserts/deletes/moves
    └── Compare Item identifiers → inserts/deletes/moves/reloads
    │
    ▼
ListViewUpdateResolver (main thread)
    ├── UICollectionViewUpdateResolver
    └── UITableViewUpdateResolver
    │
    ▼
performBatchUpdates / reloadData
```

When only Cell sizes change (data source unchanged), use `invalidateContentSize` to avoid a full reload:

```swift
setState {
    // Only modified data that affects size
} context: {
    $0.invalidateContentSize = true  // Only update layout, don't reload data source
}
```

## UICollectionView Layout Configuration

Layout is controlled by `layoutInfo` at both the Item and Section levels.

### Item Layout: `UICollectionItemFlowLayoutInfo`

| Presenter Base Class | Has built-in `layoutInfo` |
|---|---|
| `UICollectionViewFlowItemPresenter<View>` | ✅ |
| `UICollectionViewFlowItemPresenterHolder<P, V>` | ✅ |
| `CollectionItemPresenter<View>` | ❌ Must manually conform to `UICollectionItemFlowPresentable` |

```swift
public struct UICollectionItemFlowLayoutInfo {
    public var calculateSizeAutomatically: Bool = true  // Auto-calculation (recommended)
    public var layoutType: LayoutType = .autoLayout
    // .autoLayout / .sizeThatFits / .intrinsicContentSize
    public var autoLayoutSizeFitting: SizeFitting = .auto
    // .auto / .containerWidth / .containerHeight / .containerSize / .unlimited
}
```

**Auto-calculation (recommended):**

```swift
class MyItem: UICollectionViewFlowItemPresenter<MyCell> {
    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = true  // Default value
    }
}
```

**Manual calculation:**

```swift
class FixedSizeItem: UICollectionViewFlowItemPresenter<FixedCell> {
    override init() { super.init(); layoutInfo.calculateSizeAutomatically = false }
    override func calculateSize(containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: 80)
    }
}
```

### Section Layout: `UICollectionViewFlowSectionLayoutInfo`

```swift
public struct UICollectionViewFlowSectionLayoutInfo {
    public var inset: UIEdgeInsets = .zero
    public var lineSpacing: CGFloat = 0
    public var itemSpacing: CGFloat = 0
    public var columnCount: Int = 1          // When >1, evenly divides width
}
```

```swift
let section = UICollectionViewFlowSectionPresenter()
section.layoutInfo.inset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
section.layoutInfo.lineSpacing = 12
section.layoutInfo.columnCount = 2   // Two-column layout
```

### Section Header/Footer Convenience API

Use the `.header` / `.footer` properties instead of `setSupplementary`:

```swift
// ✅ GOOD
let section = UICollectionViewFlowSectionPresenter()
section.header = SectionHeaderPresenter()
section.footer = SectionFooterPresenter()

// ❌ BAD
section.setSupplementary("UICollectionElementKindSectionHeader", [header])
```

**Header/Footer Presenters must inherit from `UICollectionViewFlowItemPresenter<View>`.**

## UITableView Layout Configuration

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
        layoutInfo.estimatedHeight = 120  // Estimated height to optimize scrolling performance
    }
}
```

## Reuse-Scoped Broadcast

In list scenarios, use `.reusable` to scope broadcasts:

```swift
notifyReusable(listener: CellActionListener.self) { $0.onDeleteTapped(cellIndex: index) }
// Message is scoped to the nearest reuse container, without affecting other Sections
```

## IsolatedViewPresenter

Embed Presenter components in non-DDComponent pages:

```swift
let isolated = IsolatedViewPresenter(MyLikeButton(), LikePresenter())
isolated.register(service: LikeService.self) { LikeServiceImpl() }
view.addSubview(isolated.view)
```

> 📖 Demo: [08-IsolatedPresenter](../../Example/DDComponent/Demos/08-IsolatedPresenter/)

## Key Rules

- ✅ **Section inset/spacing must be set on the Section Presenter's `layoutInfo`**
- ✅ **Item `calculateSizeAutomatically = true` combined with Auto Layout is sufficient**
- ✅ **Setting estimated height (`estimatedHeight`) significantly improves TableView scrolling performance**
- ✅ **Use `section.header = ...` / `section.footer = ...` for Section Header/Footer**
- ✅ **Header/Footer Presenters must inherit from `UICollectionViewFlowItemPresenter<View>`**
- ❌ **Do not place layout information in the View layer** — `layoutInfo` belongs to the Presenter layer

## Related Documentation

- [Architecture Design](./architecture.md) — P-Tree/V-Tree, lifecycle, UpdatePipeline
- [Usage Guide](./usage-guide.md) — Fixed views, Service/Notify
- [use* API](./use-methods.md) — Declarative state management
- [Demo Index](./demo-index.md) — All example demos
