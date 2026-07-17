# Swift 6 并发模式

DDComponent 框架已适配 Swift 6 完整并发检查。本文档集中说明在 DDComponent 中使用 Swift 6 的关键模式。

## 1. Presenter 初始化：lazy var + 显式类型

Swift 6 不允许在 `super.init()` 之前访问 `self`。由于 `useState` 等方法在底层会注册到 `self` 上，使用 `let` 属性初始化会报编译错误。解决方案是使用 `lazy var` 并显式标注类型。

```swift
class MyPresenter: ViewPresenter<MyViewProtocol> {

    // ✅ GOOD — lazy var + 显式类型标注
    lazy var counter: State<Int> = useState(0)
    lazy var title: State<String> = useState("")

    // ✅ GOOD — 可选类型
    lazy var selectedItem: State<Item?> = useState(nil)

    // ❌ BAD — let 在 Swift 6 下编译失败
    // let counter = useState(0)

    // ❌ BAD — lazy var 无显式类型（编译器无法推断）
    // lazy var counter = useState(0)
}
```

**原因**：`useState` 有大量重载（Equatable、AnyObject、无约束、Publisher、AsyncSequence、ObservableObject 等），编译器无法在无类型标注时正确选择重载。

## 2. Timer 回调：MainActor.assumeIsolated

`Timer.scheduledTimer` 的回调是非 MainActor 隔离的 Sendable 闭包。在该闭包中访问 Presenter 的 `@MainActor` 属性时，必须使用 `MainActor.assumeIsolated`。

```swift
// ❌ BAD — 非 MainActor 闭包中访问 @MainActor 属性
lazy var timerEffect = useEffect { [weak self] in
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        self?.timestamp.value = Date()  // 编译错误！
    }
    return { timer.invalidate() }
}

// ✅ GOOD — 使用 MainActor.assumeIsolated
lazy var timerEffect = useEffect { [weak self] in
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        MainActor.assumeIsolated {
            self?.timestamp.value = Date()
        }
    }
    return { timer.invalidate() }
}
```

**使用前提**：你确认代码在主线程上执行。Timer 回调、UIView.animate 完成回调等通常在主线程，使用 `assumeIsolated` 是安全的。

## 3. ObservableObject 订阅替换

`useState(ObservableObject)` 内部自动管理 AnyCancellable。替换对象时，框架自动取消旧订阅、绑定新订阅，无需手动管理。

```swift
lazy var viewModel = useState(MyViewModel())

// 替换：框架自动 cancel 旧订阅，bind 新订阅
viewModel.value = MyViewModel()

// 可选 ObservableObject：设为 nil 取消订阅
lazy var optionalVM: State<MyViewModel?> = useState(nil)
optionalVM.value = nil  // 取消订阅
```

## 4. @MainActor Presenter

所有 Presenter 类标记为 `@MainActor`（在基类 `ViewPresentable` 声明）。这意味着：
- Presenter 的属性和方法默认在主线程隔离
- 在非主线程回调（如网络请求回调）中修改 Presenter 状态时，确保切换回主线程
- 或使用 `await MainActor.run { ... }` 包装

## 相关文档

- [use* API](./use-methods.md) — 声明式状态管理
- [使用指南](./usage-guide.md) — 固定视图与列表页面开发
- [@PresenterState 宏](./presenter-state-macro.md) — 简化状态声明
