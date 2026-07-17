# DDComponent 文档

[English](../en/README.md)

DDComponent 是一个基于 MVP 模式的 iOS 页面拆分框架。将复杂页面拆分为独立、可复用、可插拔的 Presenter 组件。

## 快速开始

```
pod 'DDComponent'
```

```swift
// 1. View 协议
protocol LikeViewProtocol: AnyObject {
    var isLiked: Bool { get set }
    var onLikeTapped: (() -> Void)? { get set }
}

// 2. Presenter（业务逻辑）
class LikePresenter: ViewPresenter<LikeViewProtocol> {
    var isLiked = false { didSet { setState {} } }

    func toggleLike() {
        api.toggleLike { [weak self] result in
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

// 3. ViewController
class MyVC: PageViewController<MyView, MyRootPresenter> {
    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        ServiceInstaller(LikeService.self, { LikeServiceImpl() })
    }
}
```

## 学习路径

### 入门（理解核心概念）

| 顺序 | 文档 | 学什么 |
|------|------|--------|
| 1 | [架构设计](./architecture.md) | P-Tree/V-Tree、生命周期、setState、UpdatePipeline |
| 2 | [使用指南](./usage-guide.md) | 固定视图、列表视图、Service/Notify 使用 |
| 3 | Demo [01](../../Example/DDComponent/Demos/01-HelloDDComponent/) | 最简示例 |

### 进阶（掌握页面搭建）

| 顺序 | 文档 | 学什么 |
|------|------|--------|
| 4 | [复用 Presenter](./reusable-presenter.md) | 列表 Cell 复用、Diff 引擎、layoutInfo |
| 5 | [@PresenterState 宏](./presenter-state-macro.md) | 简化状态声明 |
| 6 | [use* API](./use-methods.md) | 声明式状态与副作用管理 |
| 7 | Demos [04](../../Example/DDComponent/Demos/04-PTreeComposition/) → [10](../../Example/DDComponent/Demos/10-FeedExample/) | 完整示例 |

### 高级（深入细节）

| 顺序 | 文档 | 学什么 |
|------|------|--------|
| 8 | [Swift 6 并发模式](./swift6-patterns.md) | lazy var、MainActor、Sendable |
| 9 | [Demo 索引](./demo-index.md) | 全部 12 个 Demo 概览 |

## 我想做 X，看什么文档？

| 我想... | 看这个 |
|----------|--------|
| 理解框架的设计思想 | [架构设计](./architecture.md) |
| 创建一个简单页面 | [使用指南](./usage-guide.md) → "固定视图" |
| 创建一个列表页面 | [使用指南](./usage-guide.md) → "列表视图" |
| 理解 P-Tree 和 V-Tree | [架构设计](./architecture.md) → "P-Tree 与 V-Tree 详解" |
| 理解 Presenter 的生命周期 | [架构设计](./architecture.md) → "生命周期方法职责详解" |
| 让状态变化带动画 | [使用指南](./usage-guide.md) → "setState Context 速查" |
| 在 Presenter 之间通信 | [使用指南](./usage-guide.md) → "Service 系统" / "Notify 广播系统" |
| 创建列表 Cell | [复用 Presenter](./reusable-presenter.md) |
| 使用 React Hooks 风格的 API | [use* API](./use-methods.md) |
| 简化 `didSet { setState {} }` 样板 | [@PresenterState 宏](./presenter-state-macro.md) |
| 在 Swift 6 下正确使用 | [Swift 6 并发模式](./swift6-patterns.md) |
| 在传统 VC 中嵌入一个组件 | [使用指南](./usage-guide.md) → "IsolatedViewPresenter" |
| 看示例代码 | [Demo 索引](./demo-index.md) |

## 项目结构

```
DDComponent/
  Classes/
    ViewPresenter.swift              # 所有 Presenter 的基类
    ViewPresenter+Use.swift          # use* 声明式 API
    RootViewPresenter.swift          # 根 Presenter，管理 Service 和 Notify
    PageViewController.swift         # UIKit 桥接基类
    ViewGroupPresenter.swift         # 支持按标识符存取子 Presenter
    PresenterInstaller.swift         # 声明式装配 DSL（Result Builder）
    ViewUpdateContext.swift          # 视图更新配置
    ViewUpdateAnimators.swift        # 内置动画器（Spring / Ease）
    ViewPresenterNotifiable.swift    # 通知广播系统
    ViewAutoBind.swift               # 自动 View 绑定
    Service.swift                    # 页面级服务（DI）
    PageServiceManager.swift         # 服务管理器
    PageNotifyManager.swift          # 通知管理器
    ManagedViewPresenter.swift       # 自带 Service 作用域的 Presenter
    IsolatedViewPresenter.swift      # 独立组件（不依赖 RootPresenter）
    UpdatePipeline/                  # 更新管线实现
    Reusable/                        # 可复用 Presenter（列表场景）
```
