# setState 与 onUpdate 深度指南

## 核心机制

`setState` 是框架最核心的机制。它标记"状态变了"，由 `ViewUpdatePipeline`（RootPresenter 持有）在合适的时机批量执行 `onUpdate`。这借鉴了 React/SwiftUI 的声明式 UI 思想。

```swift
// setState：标记状态变更，由 Pipeline 调度
setState {
    // 在这里修改状态
    self.count += 1
    self.title = "Updated"
} context: {
    // 配置这次更新的行为
    $0.animated = true              // 在 UIView.animate 中执行
    $0.invalidateLayout = true      // 更新后触发 layout
    $0.updateViewImmediately = true // 立即更新，不等 RunLoop
}

// onUpdate：Pipeline 在合适时机调用，同步状态到 View
override func onUpdate(view: MyViewProtocol, context: ViewUpdateContext) {
    view.count = count
    view.title = title
}
```

## Context Flags 参考

| Flag | 何时使用 |
|---|---|
| `animated = true` | 需要动画过渡 |
| `invalidateLayout = true` | 数据变化影响了布局 |
| `invalidateDataSource = true` | 列表数据源变了（触发 Diff + reload） |
| `invalidateContentSize = true` | 只有 Cell 尺寸变了 |
| `updateViewImmediately = true` | 需要立即更新，不等待批处理 |

## Animator 动画器

设置 `$0.animated = true` 后，可通过 `$0.animator` 指定动画器。

### 内置预设

- **SpringAnimator**: `.default`, `.bouncy`, `.gentle`, `.snappy`
- **EaseAnimator**: `.default`, `.quick`, `.slow`, `.easeIn`, `.easeOut`

```swift
setState { self.size = 150 } context: {
    $0.invalidateLayout = true
    $0.animated = true
    $0.animator = SpringAnimator.bouncy
}
```

### 自定义 Animator

```swift
class MySpringAnimator: ViewUpdateAnimator {
    func animate(with context: ViewUpdateContext, _ updater: @escaping () -> Void) {
        UIView.animate(withDuration: 0.6, delay: 0,
            usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8,
            options: [.allowUserInteraction], animations: updater)
    }
}

setState { ... } context: { $0.animated = true; $0.animator = MySpringAnimator() }
```

## 常见错误

### ❌ 直接在 setState 外部修改状态

```swift
// ❌ BAD — 没有 setState 包裹
func updateTitle(_ title: String) {
    self.title = title  // 直接修改，Pipeline 感知不到
    setState {}         // 空 setState 不解决问题
}

// ✅ GOOD
func updateTitle(_ title: String) {
    setState { self.title = title }
}
```

### ❌ 在 setState 内部执行副作用

```swift
// ❌ BAD — setState 内有副作用
setState {
    self.title = result.title
    analytics.track("title_updated")  // 副作用！应放在 setState 外部
}

// ✅ GOOD
analytics.track("title_updated")
setState { self.title = result.title }
```

### ❌ 直接修改 View

```swift
// ❌ BAD — 绕过 setState 直接修改 View
func updateTitle(_ title: String) {
    view?.titleLabel.text = title
}

// ✅ GOOD — 通过 setState → onUpdate 路径
func updateTitle(_ title: String) {
    setState { self.title = title }
}
override func onUpdate(view: MyViewProtocol, context: ViewUpdateContext) {
    view.titleLabel.text = title
}
```

### ❌ onUpdate 遗漏状态

```swift
// ❌ BAD — 遗漏了 isLoading
override func onUpdate(view: MyViewProtocol, context: ViewUpdateContext) {
    view.title = state.title
    // 缺少 view.isLoading = state.isLoading
}

// ✅ GOOD — 所有状态都同步
override func onUpdate(view: MyViewProtocol, context: ViewUpdateContext) {
    view.title = state.title
    view.isLoading = state.isLoading
}
```

## 为什么必须走 setState

直接修改 View 虽然也能工作，但会导致：
- 父容器无法感知变化
- 数据不一致（多个 View 看到不同状态）
- 列表复用时状态错乱
- 动画、布局更新等 Pipeline 功能失效

`setState` 统一入口，由 Pipeline 批量调度，保证状态一致性。

→ 详见 [docs/architecture.md](../../../../docs/architecture.md) 了解 UpdatePipeline 原理。