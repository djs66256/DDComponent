# Swift 6 Concurrency Patterns

The DDComponent framework has been adapted for Swift 6 complete concurrency checking. This document covers the key patterns for using DDComponent with Swift 6.

## 1. Presenter Initialization: `lazy var` + Explicit Types

Swift 6 does not allow accessing `self` before `super.init()`. Since methods like `useState` internally register on `self`, using `let` properties for initialization will cause a compilation error. The solution is to use `lazy var` with explicit type annotations.

```swift
class MyPresenter: ViewPresenter<MyViewProtocol> {

    // ✅ GOOD — lazy var + explicit type annotation
    lazy var counter: State<Int> = useState(0)
    lazy var title: State<String> = useState("")

    // ✅ GOOD — Optional types
    lazy var selectedItem: State<Item?> = useState(nil)

    // ❌ BAD — let fails to compile under Swift 6
    // let counter = useState(0)

    // ❌ BAD — lazy var without explicit type (compiler cannot infer)
    // lazy var counter = useState(0)
}
```

**Reason**: `useState` has many overloads (Equatable, AnyObject, unconstrained, Publisher, AsyncSequence, ObservableObject, etc.), and the compiler cannot select the correct overload without a type annotation.

## 2. Timer Callbacks: `MainActor.assumeIsolated`

`Timer.scheduledTimer` callbacks are non-MainActor-isolated Sendable closures. When accessing a Presenter's `@MainActor` properties inside such a closure, you must use `MainActor.assumeIsolated`.

```swift
// ❌ BAD — accessing @MainActor properties in a non-MainActor closure
lazy var timerEffect = useEffect { [weak self] in
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        self?.timestamp.value = Date()  // Compilation error!
    }
    return { timer.invalidate() }
}

// ✅ GOOD — using MainActor.assumeIsolated
lazy var timerEffect = useEffect { [weak self] in
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        MainActor.assumeIsolated {
            self?.timestamp.value = Date()
        }
    }
    return { timer.invalidate() }
}
```

**Prerequisite**: You are certain the code executes on the main thread. Timer callbacks, `UIView.animate` completion callbacks, etc., typically run on the main thread, so using `assumeIsolated` is safe.

## 3. ObservableObject Subscription Replacement

`useState(ObservableObject)` automatically manages `AnyCancellable` internally. When replacing the object, the framework automatically cancels the old subscription and binds the new one — no manual management is needed.

```swift
lazy var viewModel = useState(MyViewModel())

// Replacement: framework auto-cancels old subscription, binds new one
viewModel.value = MyViewModel()

// Optional ObservableObject: setting to nil cancels the subscription
lazy var optionalVM: State<MyViewModel?> = useState(nil)
optionalVM.value = nil  // Cancels subscription
```

## 4. @MainActor Presenter

All Presenter classes are marked `@MainActor` (declared on the base class `ViewPresentable`). This means:
- Presenter properties and methods are main-thread-isolated by default
- When modifying Presenter state in non-main-thread callbacks (e.g., network request callbacks), ensure you switch back to the main thread
- Alternatively, wrap with `await MainActor.run { ... }`

## Related Documentation

- [use* API](./use-methods.md) — Declarative state management
- [Usage Guide](./usage-guide.md) — Fixed-view and list page development
- [@PresenterState Macro](./presenter-state-macro.md) — Simplified state declaration
