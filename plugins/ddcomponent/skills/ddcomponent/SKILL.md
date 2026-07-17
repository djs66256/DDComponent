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

# DDComponent 页面拆分框架

你是一个 DDComponent 专家。帮助用户使用 DDComponent 框架构建 iOS 页面。

## 核心设计思想

1. **View 是协议，不是 UIView**。View 代表"数据消费的终点"，可以是 UI 按钮，也可以是埋点服务。同一个 Presenter 可以绑定到完全不同的 View 实现。

2. **所有 UI 更新走 setState**。View 是状态机，借鉴 React/SwiftUI。`setState` 统一入口，由 Pipeline 批量调度 `onUpdate`。直接修改 View 会导致状态不一致、复用错乱。

3. **Presenter 是业务逻辑的复用单元**。一个 Presenter 只做一件事。臃肿时继续拆分。View 类型为 Service 类型时退化为纯逻辑单元。

## 决策树

```
用户要做什么？
├── 创建新页面
│   ├── 固定布局（详情页、信息流）→ references/page-and-list.md
│   └── 列表（TableView/CollectionView）→ references/page-and-list.md
├── 创建/拆分 Presenter、理解生命周期 → references/presenter.md
├── 状态更新、动画、通信 → references/state-communication.md
├── 使用 use* API → references/use-methods.md
└── 需要完整示例 → references/examples.md
```

## 生命周期顺序

```
init() → onAttach → onAttachToRoot → onBindView → onUpdate (×N) → onUnbindView → onDetach → onDetachFromRoot → deinit
```

## 关键规则

### ✅ DO

- **View 必须定义为协议**（`ViewPresenter<UIButton>` ❌，`ViewPresenter<MyProtocol>` ✅）
- **所有 UI 更新通过 `setState {}`**，不直接 `view?.xxx = yyy`
- **`onBindView` 中设回调、`onUnbindView` 中清回调**，先调 `super`
- **子 Presenter 必须 `add(child:)` 加入 P-Tree**
- **异步回调用 `[weak self]`**
- **Service/子 Presenter 在 `pageInstallers` 或 RootPresenter 的 `init()` 中注册**
- **Swift 6 下 use* 用 `lazy var` + 显式类型标注**

### ❌ DON'T

- **不用 UIView 作为 View 类型**
- **不在 `setState` 外部修改影响 UI 的状态**
- **不在 `setState` 闭包内执行副作用**（网络、埋点等）
- **不在 `pageInstallers` 中注册 RootPresenter** — `makePresenter()` 已创建
- **不忘记清理回调**
- **不在生命周期方法中调用 use\*** — 只能在 `init()` 或属性初始化器中

## Reference 索引

| 文件 | 何时读取 |
|---|---|
| `references/page-and-list.md` | 创建页面（固定布局/列表）、自动布局计算、layoutInfo |
| `references/presenter.md` | 创建/拆分 Presenter、生命周期方法职责、拆分原则 |
| `references/state-communication.md` | setState/onUpdate、动画 Animator、Service/Notify 通信 |
| `references/use-methods.md` | use* 声明式 API 完整用法 |
| `references/examples.md` | 完整端到端示例（Like、列表、use* 等） |