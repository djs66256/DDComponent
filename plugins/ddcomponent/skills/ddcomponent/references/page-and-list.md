# 页面创建

## 固定视图页面

适用于详情页、固定布局页面。创建步骤：定义 View 协议 → 创建各功能 Presenter → 创建 RootPresenter → 创建 PageViewController。

**RootPresenter 模式：**
- 继承 `RootViewPresenter<ViewProtocol>`，在 `init()` 中用 `typeBox()` 注册子 Presenter
- 在 `onBindView` 中通过 `typeUnbox()` 取出子 Presenter，绑定到 View 协议中声明的子视图
- 子 Presenter 必须通过 `add(child:)` 加入 P-Tree

**ViewController 模式：**
- 继承 `PageViewController<RootView, RootPresenter>`
- `makeView()` 和 `makePresenter()` 负责创建
- `@PageInstallerBuilder pageInstallers` 中通过 `ServiceInstaller` 注册 Service

**IsolatedViewPresenter：** 在传统 UIViewController 中嵌入 DDComponent 组件。`IsolatedViewPresenter(view, presenter)` 包装 View-Presenter 对，手动管理 Service 注册和生命周期转发。适用于渐进式迁移。

## 列表页面（TableView / CollectionView）

三层架构：`CollectionRootPresenter` → `CollectionSectionPresenter`（sections）→ `CollectionItemPresenter` / `ReusableViewPresenter`（items）

**Cell 是否用 ReusableViewPresenter：** 核心判断标准是 Cell 内部是否有子 Presenter。有子 Presenter 必须用 `ReusableViewPresenter`（提供 `prepareForReuse()` 重置状态），无子 Presenter 也推荐统一使用。

**各层职责：**
- Item：继承 `ReusableViewPresenter<CellProtocol>`，实现 `required init()` 和 `prepareForReuse()`，数据变化通过 `didSet { setState {} }` 触发
- Section：继承 `CollectionSectionPresenter` 或 `UICollectionViewFlowSectionPresenter`，通过 `setItems(_:)` 设置 Cell 列表
- Root：继承 `CollectionRootPresenter<ViewProtocol>`，在 `onAttach()` 中 `add(child: section)` 并设置 `sections`
- ViewController：TableView 用 `UITablePageViewController<ItemPresenter>`，CollectionView 用 `UICollectionViewPageViewController`

## 自动布局计算

列表 Cell 的尺寸由 Presenter 层的 `layoutInfo` 控制，不在 View 层。

### UICollectionView Item 布局

`UICollectionItemFlowLayoutInfo` 核心字段：
- `calculateSizeAutomatically: Bool` — 默认 `true`，由 Auto Layout 约束自动推导尺寸
- `layoutType: LayoutType` — `.autoLayout`（默认）/ `.sizeThatFits` / `.intrinsicContentSize`
- `autoLayoutSizeFitting: SizeFitting` — `.auto`（默认）/ `.containerWidth`（固定宽度，高度自适应）/ `.containerHeight` / `.containerSize` / `.unlimited`

**自动计算（推荐）：** `calculateSizeAutomatically = true`（默认），Cell 配置 Auto Layout 约束即可，框架自动通过 `systemLayoutSizeFitting` 计算。

**手动计算：** `calculateSizeAutomatically = false`，必须重写 `calculateSize(containerSize:) -> CGSize` 返回固定尺寸。

### UICollectionView Section 布局

`UICollectionViewFlowSectionLayoutInfo` 字段：`inset`（内边距）、`lineSpacing`（行间距）、`itemSpacing`（列间距）、`columnCount`（列数，>1 时均分宽度）。

**Header/Footer：** 用 `section.header = ...` / `section.footer = ...` 便捷属性。Presenter 必须继承 `UICollectionViewFlowItemPresenter<View>`，不能用 `CollectionItemPresenter`。

### UITableView Item 布局

`UITableViewCellLayoutInfo` 字段：`calculateSizeAutomatically`（默认 `true`）、`layoutType`（`.autoLayout` / `.sizeThatFits`）、`estimatedHeight`（预估高度，设置后可显著提升滚动性能）。

### 关键规则

- Section 的 inset/spacing 在 Section Presenter 的 `layoutInfo` 上设置，不在 FlowLayout 上设置
- `calculateSizeAutomatically = true` 配合 Auto Layout 即可，无需手动计算
- Header/Footer Presenter 必须继承 `UICollectionViewFlowItemPresenter<View>`
- 布局信息属于 Presenter 层，不放在 View 层

## 文件结构建议

```
Feature/
├── Models/          # 数据模型
├── Presenters/      # 各功能 Presenter
├── Views/           # UIView 实现（实现 View 协议）
├── Protocols/       # View 协议定义
├── Services/        # Service 协议 + 实现
└── *ViewController.swift
```

命名规范：`XxxPresenter.swift`（继承 `ViewPresenter`）、`XxxViewController.swift`（继承 `PageViewController` 或 `UITablePageViewController`）、`XxxService.swift`（协议+实现）。View 协议可放在 Presenter 文件顶部或 `Protocols/` 目录。