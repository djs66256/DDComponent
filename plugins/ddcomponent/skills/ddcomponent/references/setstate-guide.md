# setState 与 onUpdate 深度指南

`setState` 是框架最核心的机制，标记"状态变了"，由 `ViewUpdatePipeline` 在合适时机批量执行 `onUpdate`。

## 基本用法

```swift
// setState：标记状态变更，由 Pipeline 调度
setState {
    self.count += 1
    self.title = "Updated"
} context: {
    $0.animated = true              // 在 UIView.animate 中执行
    $0.invalidateLayout = true      // 更新后触发 layout
    $0.updateViewImmediately = true // 立即更新，不等 RunLoop
}

// onUpdate：Pipeline 调用，同步状态到 View
override func onUpdate(view: MyViewProtocol, context: ViewUpdateContext) {
    view.count = count
    view.title = title
}
```

## Context Flags

| Flag | 用途 |
|---|---|
| `animated = true` | 动画过渡 |
| `invalidateLayout = true` | 数据变化影响布局 |
| `invalidateDataSource = true` | 列表数据源变化（触发 Diff + reload） |
| `invalidateContentSize = true` | Cell 尺寸变化 |
| `updateViewImmediately = true` | 立即更新，不等批处理 |
| `animator = SpringAnimator.bouncy` | 自定义动画器 |

## Animator 动画器

设置 `animated = true` 后，可通过 `animator` 指定动画器。

**内置预设：**

| Animator | 预设 |
|---|---|
| `SpringAnimator` | `.default`, `.bouncy`, `.gentle`, `.snappy` |
| `EaseAnimator` | `.default`, `.quick`, `.slow`, `.easeIn`, `.easeOut` |

```swift
// 使用内置预设
setState { self.size = newSize } context: {
    $0.invalidateLayout = true
    $0.animated = true
    $0.animator = SpringAnimator.bouncy
}

// 自定义 Animator：实现 ViewUpdateAnimator 协议
class MySpringAnimator: ViewUpdateAnimator {
    func animate(with context: ViewUpdateContext, _ updater: @escaping () -> Void) {
        UIView.animate(withDuration: 0.6, delay: 0,
            usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8,
            options: [.allowUserInteraction], animations: updater)
    }
}
setState { self.size = newSize } context: {
    $0.invalidateLayout = true
    $0.animated = true
    $0.animator = MySpringAnimator()
}
```

> **注意：** 使用自定义 `animator` 时必须同时设置 `animated = true`。

## 常见错误

### ❌ setState 外部修改状态

```swift
// ❌ BAD
func updateTitle(_ title: String) {
    self.title = title
    setState {}
}

// ✅ GOOD
func updateTitle(_ title: String) {
    setState { self.title = title }
}
```

### ❌ setState 内部执行副作用

```swift
// ❌ BAD
setState {
    self.title = result.title
    analytics.track("title_updated")
}

// ✅ GOOD
analytics.track("title_updated")
setState { self.title = result.title }
```

### ❌ 直接修改 View

```swift
// ❌ BAD
view?.titleLabel.text = title

// ✅ GOOD
setState { self.title = title }
// onUpdate 中: view.titleLabel.text = title
```

## 为什么必须走 setState

直接修改 View 会导致：父容器无法感知、数据不一致、列表复用时状态错乱、Pipeline 功能失效。`setState` 统一入口，由 Pipeline 批量调度，保证状态一致性。