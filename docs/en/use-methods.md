# use* API: Declarative State and Side Effect Management

The `use*` methods are React Hooks-style APIs provided by DDComponent (defined in `ViewPresenter+Use.swift`) that centralize state, side effects, and view updaters at initialization time, replacing the traditional approach of scattering logic across multiple lifecycle methods.

## Why use* instead of the traditional approach?

**Problems with the traditional approach:**

- State is scattered across methods like `onBindView`, `onUpdate`, `onAttach`, making it hard to trace
- Subscriptions (Timer, Publisher, Notification) are created and cleaned up in different places, making it easy to miss cleanups and cause memory leaks
- Dependencies are implicit; debugging requires tracing through multiple lifecycle methods

**Advantages of the use* approach:**

- All state and side effects are declared in `init()` or property initializers, making them clear at a glance
- Lifecycle is automatically managed: subscriptions start on attach and are automatically cleaned up on detach — nothing gets missed
- Explicit dependencies: `useUpdate(dependences:)` clearly declares dependency relationships

## API Overview

| Method | Return Type | Purpose |
|---|---|---|
| `useState(_:)` | `State<T>` | Create reactive state. Setting `value` triggers `setState` → `onUpdate` |
| `useState(_:updater:)` | `State<T>` | State + custom update closure, automatically syncs to View on each change |
| `useState(_:updateTo:)` | `State<T>` | State + write directly to a View keyPath (requires `View: AnyObject`) |
| `useState(_:publisher:)` | `State<T>` | Subscribe to values from a Combine Publisher |
| `useState(_:sequence:)` | `State<T>` | Subscribe to values from an AsyncSequence |
| `useState(_:service:publisher:)` | `State<T>` | Lazily load a Publisher from a Service |
| `useState(_:service:sequence:)` | `State<T>` | Lazily load an AsyncSequence from a Service |
| `useState(ObservableObject)` | `State<O>` | Observe an ObservableObject's `objectWillChange` |
| `useEffect(_:)` | `Effect` | Register a lifecycle-bound side effect |
| `useUpdate(dependences:_:)` | `Updater` | Dependency-driven view updater |
| `useService(_:_:)` | `Effect` | Resolve a Service and pass it to a side effect |

## useState Equality Check Strategies

`useState` automatically selects an equality check strategy via generic constraints, so identical values don't trigger pointless updates:

| Generic Constraint | Equality Check | Examples |
|---|---|---|
| `T: Equatable` | `==` | `Int`, `String`, `Bool` |
| `T: AnyObject` | `===` | `NSObject`, custom classes |
| No constraint | Always triggers | Non-Equatable value types |

## useState Basic Usage

```swift
class MyPresenter: ViewPresenter<MyViewProtocol> {

    // 1. Equatable value types — use == for equality
    lazy var counter: State<Int> = useState(0)
    lazy var name = useState("Hello")

    // 2. AnyObject reference types — use === for equality
    lazy var selectedObject = useState(NSObject())

    // 3. No constraint (e.g. Date is not Equatable) — always triggers
    lazy var timestamp = useState(Date())

    // 4. Optional types — type inferred from property declaration
    lazy var optionalCounter: State<Int?> = useState(nil)
    lazy var optionalName: State<String?> = useState(nil)

    override func onUpdate(view: MyViewProtocol, context: ViewUpdateContext) {
        view.countLabel.text = "\(counter.value)"
        view.nameLabel.text = name.value
        view.optionalLabel.text = optionalCounter.value.map { "\($0)" } ?? "nil"
    }
}
```

## useState with updater / keyPath

```swift
// updater: execute a custom closure on each state change, directly operating on the View
lazy var counterWithUpdater = useState(0, updater: { value, view, _ in
    view.counterLabel.text = "count: \(value)"
})

// Optional + updater
lazy var optionalWithUpdater = useState(nil, updater: { value, view, _ in
    view.optionalLabel.text = value ?? "nil"
})

// updateTo: directly write value to a View keyPath (requires View: AnyObject)
lazy var title = useState("Hello", updateTo: \.titleLabel.text)
```

## useState Subscribing to a Publisher

```swift
// Pass a Publisher directly
let myPublisher = PassthroughSubject<String, Never>()
lazy var pubValue = useState("(waiting)", publisher: myPublisher)

// Get a Publisher from a Service (lazy, resolved on attach to root)
lazy var svcPubValue = useState("(waiting)",
    service: MyService.self,
    publisher: { $0.tickPublisher() })

// Publisher with updater
lazy var pubWithUpdater = useState("(waiting)",
    updater: { value, view, _ in view.label.text = value },
    publisher: myPublisher)
```

## useState Subscribing to an AsyncSequence

```swift
// Pass an AsyncSequence directly (e.g. AsyncStream)
lazy var seqValue = useState(0, sequence: myAsyncStream)

// Get an AsyncSequence from a Service
lazy var svcSeqValue = useState(0,
    service: MyService.self,
    sequence: { $0.tickSequence() })
```

## useState Observing an ObservableObject

`ObservableObject` is Combine's standard observable protocol. `useState` subscribes to its `objectWillChange` publisher, matching DDComponent's `setState` → `onUpdate` model.

```swift
class CounterViewModel: ObservableObject {
    @Published var count: Int = 0
    @Published var label: String = "zero"
}

// Basic observation: automatically triggers setState → onUpdate on objectWillChange
lazy var viewModel = useState(CounterViewModel())

// Optional ObservableObject
lazy var optionalVM: State<CounterViewModel?> = useState(nil)

// Replace object: automatically cancels the old subscription, binds the new one
viewModel.value = CounterViewModel()   // old cancelled, new subscribed
optionalVM.value = nil                  // cancels subscription

// With updater
lazy var vmWithUpdater = useState(CounterViewModel(),
    updater: { value, view, _ in view.label.text = value.label })

// With keyPath
lazy var vmWithKeyPath = useState(CounterViewModel(),
    updateTo: \.headerViewModel)

// Read the latest value in onUpdate
override func onUpdate(view: MyView, context: ViewUpdateContext) {
    view.countLabel.text = "\(viewModel.value.count)"
    view.nameLabel.text = viewModel.value.label
}
```

## useEffect Managing Side Effects

Side effects start on `onAttachToRoot` and automatically call the cleanup closure on `onDetachFromRoot`.

```swift
// Side effect with cleanup
lazy var timerEffect = useEffect { [weak self] in
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        MainActor.assumeIsolated { self?.timestamp.value = Date() }
    }
    return { timer.invalidate() }  // automatically called on detach
}

// Side effect without cleanup
lazy var logEffect = useEffect { print("[MyPresenter] attached to root") }
```

## useUpdate Dependency-Driven Updates

The updater only executes when the dependent State changes, avoiding unnecessary View updates.

```swift
// Single dependency
lazy var titleUpdate = useUpdate(dependences: title) { view, context in
    view.titleLabel.text = title.value
}

// Multiple dependencies: executes when any dependency changes
lazy var combinedUpdate = useUpdate(dependences: title, counter) { view, context in
    view.titleLabel.text = title.value
    view.countLabel.text = "\(counter.value)"
}
```

## useService Lazy Service Loading

The Service is resolved on attach to root, avoiding issues where the Service is not yet registered at init time.

```swift
lazy var svcEffect = useService(MyService.self) { service in
    service.startMonitoring()
    return { service.stopMonitoring() }  // automatically called on detach
}
```

## Key Rules

1. **Must be called in `init()` or property initializers** — cannot be called in lifecycle methods like `onBindView`
2. **Return values must be stored as instance properties** — `State`, `Effect`, `Updater` must be held by a `let` or `lazy var`, otherwise they are immediately released
3. **Use `lazy var` + explicit type annotation under Swift 6** — `useState` has many overloads, so the compiler cannot infer the type; `let` is not available before `super.init()`
4. **Use `useState(nil)` for Optional types** — the type is inferred from the `State<Int?>` declaration, no explicit generic parameter needed
5. **ObservableObject replacement** — `state.value = newObject` automatically cancels the old subscription and binds the new one; no manual `AnyCancellable` management needed
6. **Use `MainActor.assumeIsolated` in Timer closures** — required when accessing `@MainActor` properties from non-MainActor Sendable closures
7. **useUpdate dependencies must be complete** — all State values read in the updater must be declared in `dependences`, otherwise changes to omitted State values will not trigger updates
8. **useState does not automatically sync to the View** — you need to read `state.value` in `onUpdate`, or use the `updater`/`keyPath` parameters

## Complete Example

See Demo 11 for complete demonstration code: `Example/DDComponent/Demos/11-UseMethods/`, which includes full usage of all 12 use* variants.

## Related Documentation

- [Architecture Design](./architecture.md) — UpdatePipeline, setState mechanism
- [Usage Guide](./usage-guide.md) — Fixed views and list page development
- [Swift 6 Concurrency Patterns](./swift6-patterns.md) — lazy var, MainActor, Timer closures
- [@PresenterState Macro](./presenter-state-macro.md) — Simplified state declaration
