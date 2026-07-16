# DDComponent

[![Version](https://img.shields.io/cocoapods/v/DDComponent.svg?style=flat)](https://cocoapods.org/pods/DDComponent)
[![License](https://img.shields.io/cocoapods/l/DDComponent.svg?style=flat)](https://cocoapods.org/pods/DDComponent)
[![Platform](https://img.shields.io/cocoapods/p/DDComponent.svg?style=flat)](https://cocoapods.org/pods/DDComponent)

基于 MVP 模式的 iOS 页面拆分框架。将复杂页面拆分为独立、可复用、可插拔的 Presenter 组件。

## 为什么需要 DDComponent？

随着业务复杂度增长，一个页面往往包含多个方向的业务逻辑：

| 问题 | DDComponent 的解法 |
|---|---|
| 多人修改同一文件导致冲突 | 每个功能拆分为独立的 Presenter，互不干扰 |
| 功能边界模糊，无人对质量负责 | Presenter 是明确的逻辑边界，职责清晰 |
| 同一功能不同 UI（如 Resso vs TTM） | P-Tree 与 V-Tree 分离，逻辑复用，UI 可替换 |
| 功能需要动态插拔 | 通过 `install` DSL 按需装配 Presenter 和 Service |

## 核心概念

### P-Tree 与 V-Tree

```
P-Tree (Presenter 树)          V-Tree (View 树)
┌─────────────────┐          ┌─────────────────┐
│  RootPresenter  │ - - - - │    RootView     │
│  ├ LikePresenter │ - - - - │   ├ LikeButton  │
│  ├ SharePresenter│ - - - - │   ├ ShareButton │
│  └ CommentPresenter│ - - - │   └ CommentList │
└─────────────────┘          └─────────────────┘
```

- **P-Tree**（Presenter 树）：页面的功能逻辑组织结构
- **V-Tree**（View 树）：UI 展示结构
- 两者弱绑定：相同的 P-Tree 可以绑定到完全不同的 V-Tree

### 状态驱动更新

DDComponent 借鉴 React/SwiftUI 的设计思想，将 View 视为**状态机**。所有 UI 更新必须通过 `setState` 统一入口，由 UpdatePipeline 在合适的时机批量执行，避免多处直接修改 View 导致的数据不一致：

```
数据变更 → setState { ... } → Pipeline 调度 → onUpdate(view:context:) → UI 更新
```

```swift
class MyPresenter: ViewPresenter<MyViewProtocol> {
    var count = 0
    var title = ""

    // 属性变更自动触发更新
    var isVisible: Bool {
        didSet { setState {} }
    }

    func loadData() {
        api.fetch { [weak self] result in
            self?.setState {
                self?.count = result.count
                self?.title = result.title
            } context: {
                $0.animated = true  // 带动画更新
            }
        }
    }

    override func onUpdate(view: MyViewProtocol, context: ViewUpdateContext) {
        view.count = count
        view.title = title
        view.isVisible = isVisible
    }
}
```

**为什么必须用 setState？**
- **统一更新时机**：所有变更由 Pipeline 全局调度，避免数据不对齐
- **批量合并**：多个 `setState` 在一次 RunLoop 中合并为一次 UI 更新
- **列表增量更新**：自动 Diff 数据源，执行 `performBatchUpdates` 而非全量 reload
- **状态安全**：配合 `@StateChecker` 编译期保证状态只在 `setState` 内修改

### 快速示例

```swift
// 1. 定义 View 协议（数据消费的终点，不是 UIView）
protocol LikeViewProtocol: AnyObject {
    var isLiked: Bool { get set }
    var likeCount: Int { get set }
    var onLikeTapped: (() -> Void)? { get set }
}

// 2. 实现 Presenter（业务逻辑 + 状态驱动更新）
class LikePresenter: ViewPresenter<LikeViewProtocol> {
    struct LikeInfo {
        var isLiked = false
        var likeCount = 0
    }

    private var _likeInfo = LikeInfo()
    var likeInfo: LikeInfo {
        get { _likeInfo }
        set { setState { _likeInfo = newValue } }
    }

    func toggleLike() {
        guard let service = getService(LikeService.self) else { return }
        service.toggleLike { [weak self] result in
            self?.likeInfo = result  // 通过 setState 触发 UI 更新
            self?.notify(listener: LikeListener.self) { $0.onLikeChanged(result) }
        }
    }

    override func onBindView(_ view: LikeViewProtocol) {
        view.onLikeTapped = { [weak self] in self?.toggleLike() }
    }

    override func onUpdate(view: LikeViewProtocol, context: ViewUpdateContext) {
        view.isLiked = likeInfo.isLiked
        view.likeCount = likeInfo.likeCount
    }
}

// 3. 装配页面
class MyViewController: PageViewController<MyRootView, MyRootPresenter, MyRootPresenterView> {
    override var pageInstallers: PageInstaller {
        ServiceInstaller(LikeService.self, { LikeServiceImpl() })
        PresenterInstaller { LikePresenter() }
    }
}
```

## 安装

```ruby
pod 'DDComponent'
```

## 文档

| 文档 | 内容 |
|---|---|
| [架构设计](./docs/architecture.md) | P-Tree/V-Tree、生命周期、状态驱动更新、Service/Notify |
| [使用指南](./docs/usage-guide.md) | 固定视图、列表视图、Service 与 Notify、装配方式 |
| [复用 Presenter](./docs/reusable-presenter.md) | 列表 Cell 复用、CollectionPresenter 体系、增量更新引擎 |

## 测试

框架包含 122 个单元测试，覆盖所有核心能力。测试位于 `Example/Tests/` 目录下。

```bash
# 运行全部测试
cd Example
xcodebuild test -project DDComponent.xcodeproj -scheme DDComponent-Example -destination 'platform=iOS Simulator,name=iPhone 17'
```

| 测试套件 | 覆盖能力 |
|---|---|
| PresenterTreeTests | P-Tree 生命周期：add/remove child、attach/detach |
| ViewBindingTests | View 绑定：bind/unbind/weak/auto-bind |
| StateUpdateTests | setState：onUpdate、Pipeline、ViewUpdateContext |
| NotifyTests | Notify 通信：所有作用域、sender 排除 |
| ServiceTests | Service DI：register/get、lookup chain、downgrade |
| ReusablePresenterTests | 复用 Presenter：bind/unbind holder、prepareForReuse |
| CollectionPresenterTests | Collection 层级：section/items/supplementaries |
| DifferTests | Diff 算法：增/删/移/复杂场景 |
| PageNotifyManagerTests | NotifyManager：listener 管理、弱引用 |
| PageServiceManagerTests | ServiceManager：eager/lazy、fallthrough |
| IsolatedViewPresenterTests | 独立 Presenter：绑定、Pipeline 切换 |
| ViewUpdateContextTests | ViewUpdateContext：flag merge、bindView |

## 最低要求

- iOS 13.0+
- Swift 5.7+
- Xcode 14.0+

## License

DDComponent is available under the MIT license. See the LICENSE file for more info.