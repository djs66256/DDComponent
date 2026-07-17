# DDComponent

[![Version](https://img.shields.io/cocoapods/v/DDComponent.svg?style=flat)](https://cocoapods.org/pods/DDComponent)
[![License](https://img.shields.io/cocoapods/l/DDComponent.svg?style=flat)](https://cocoapods.org/pods/DDComponent)
[![Platform](https://img.shields.io/cocoapods/p/DDComponent.svg?style=flat)](https://cocoapods.org/pods/DDComponent)

基于 MVP 模式的 iOS 页面拆分框架。将复杂页面拆分为独立、可复用、可插拔的 Presenter 组件。

## 为什么需要 DDComponent？

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

DDComponent 借鉴 React/SwiftUI 的思想，所有 UI 更新必须通过 `setState` 统一入口，由 UpdatePipeline 批量执行：

```
数据变更 → setState { ... } → Pipeline 调度 → onUpdate(view:context:) → UI 更新
```

### 快速示例

```swift
// 1. View 协议（不是 UIView）
protocol LikeViewProtocol: AnyObject {
    var isLiked: Bool { get set }
    var likeCount: Int { get set }
    var onLikeTapped: (() -> Void)? { get set }
}

// 2. Presenter（业务逻辑）
class LikePresenter: ViewPresenter<LikeViewProtocol> {
    var isLiked = false { didSet { setState {} } }

    func toggleLike() {
        getService(LikeService.self)?.toggleLike { [weak self] result in
            self?.isLiked = result
        }
    }

    override func onBindView(_ view: LikeViewProtocol) {
        view.onLikeTapped = { [weak self] in self?.toggleLike() }
    }

    override func onUpdate(view: LikeViewProtocol, context: ViewUpdateContext) {
        view.isLiked = isLiked
    }
}

// 3. 装配
class MyViewController: PageViewController<MyRootView, MyRootPresenter> {
    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        ServiceInstaller(LikeService.self, { LikeServiceImpl() })
    }
}
```

## 安装

```ruby
pod 'DDComponent'

# 可选：@PresenterState 宏
pod 'DDComponent/Macros'
```

### Claude Code 插件

本项目附带 [Claude Code](https://claude.com/claude-code) 插件，提供 DDComponent 专用的开发技能和代码审查 Agent：

| 插件内容 | 说明 |
|---|---|
| `ddcomponent` 技能 | 引导 Claude Code 按 Presenter 树架构、生命周期规范、Service/Notify 通信模式构建页面 |
| `code-reviewer` Agent | 审查 DDComponent 代码的类型正确性、状态设计、生命周期使用和逻辑一致性 |

在 Claude Code 中运行：

```bash
# 添加 GitHub marketplace
/plugin marketplace add djs66256/DDComponent

# 安装插件
/plugin install ddcomponent@ddcomponent
```
```

## 文档

| 你想... | 看这个 |
|----------|--------|
| 理解框架设计思想 | [架构设计](./docs/architecture.md) |
| 创建页面/列表/功能 | [使用指南](./docs/usage-guide.md) |
| 开发列表 Cell | [复用 Presenter](./docs/reusable-presenter.md) |
| 使用 Hooks 风格 API | [use* API](./docs/use-methods.md) |
| 简化状态声明 | [@PresenterState 宏](./docs/presenter-state-macro.md) |
| Swift 6 适配 | [Swift 6 并发模式](./docs/swift6-patterns.md) |
| 看示例代码 | [Demo 索引](./docs/demo-index.md) |

**文档索引**：[docs/README.md](./docs/README.md)

## 测试

框架包含 122 个单元测试，覆盖所有核心能力。测试位于 `Example/Tests/`。

```bash
cd Example
xcodebuild test -project DDComponent.xcodeproj -scheme DDComponent-Example -destination 'platform=iOS Simulator,name=iPhone 17'
```

## 最低要求

- iOS 13.0+
- Swift 5.7+
- Xcode 14.0+

## License

DDComponent is available under the MIT license. See the LICENSE file for more info.
