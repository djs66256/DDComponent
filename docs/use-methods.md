# use* API：声明式状态与副作用管理

`use*` 方法是 DDComponent 提供的 React Hooks 风格 API（定义在 `ViewPresenter+Use.swift`），将状态、副作用和视图更新器集中声明在初始化阶段，替代分散在多个生命周期方法中的传统写法。

## 为什么用 use* 而不是传统方式？

**传统方式的问题：**

- 状态散落在 `onBindView`、`onUpdate`、`onAttach` 等不同方法中，追踪困难
- 订阅（Timer、Publisher、Notification）的创建和清理分散在不同位置，容易遗漏导致内存泄漏
- 依赖关系隐式，调试时需要翻阅多个生命周期方法

**use* 方式的优势：**

- 所有状态和副作用在 `init()` 或属性初始化器中声明，一目了然
- 生命周期自动管理：订阅在 attach 时启动，detach 时自动清理，不会遗漏
- 显式依赖：`useUpdate(dependences:)` 明确声明依赖关系

## API 总览

| 方法 | 返回类型 | 用途 |
|---|---|---|
| `useState(_:)` | `State<T>` | 创建响应式状态。设置 `value` 触发 `setState` → `onUpdate` |
| `useState(_:updater:)` | `State<T>` | 状态 + 自定义更新闭包，每次变化时自动同步到 View |
| `useState(_:updateTo:)` | `State<T>` | 状态 + 直接写入 View 的 keyPath（需要 `View: AnyObject`） |
| `useState(_:publisher:)` | `State<T>` | 从 Combine Publisher 订阅值 |
| `useState(_:sequence:)` | `State<T>` | 从 AsyncSequence 订阅值 |
| `useState(_:service:publisher:)` | `State<T>` | 从 Service 懒加载 Publisher |
| `useState(_:service:sequence:)` | `State<T>` | 从 Service 懒加载 AsyncSequence |
| `useState(ObservableObject)` | `State<O>` | 观察 ObservableObject 的 `objectWillChange` |
| `useEffect(_:)` | `Effect` | 注册生命周期绑定的副作用 |
| `useUpdate(dependences:_:)` | `Updater` | 依赖驱动的视图更新器 |
| `useService(_:_:)` | `Effect` | 解析 Service 并传给副作用 |

## useState 判等策略

`useState` 通过泛型约束自动选择判等策略，相同值不会触发无意义的更新：

| 泛型约束 | 判等方式 | 示例 |
|---|---|---|
| `T: Equatable` | `==` | `Int`, `String`, `Bool` |
| `T: AnyObject` | `===` | `NSObject`, 自定义 class |
| 无约束 | 总是触发 | 非 Equatable 的值类型 |

## useState 基本用法

```swift
class MyPresenter: ViewPresenter<MyViewProtocol> {

    // 1. Equatable 值类型 — 使用 == 判等
    lazy var counter: State<Int> = useState(0)
    lazy var name = useState("Hello")

    // 2. AnyObject 引用类型 — 使用 === 判等
    lazy var selectedObject = useState(NSObject())

    // 3. 无约束（如 Date 不是 Equatable）— 总是触发
    lazy var timestamp = useState(Date())

    // 4. Optional 类型 — 类型从属性声明推断
    lazy var optionalCounter: State<Int?> = useState(nil)
    lazy var optionalName: State<String?> = useState(nil)

    override func onUpdate(view: MyViewProtocol, context: ViewUpdateContext) {
        view.countLabel.text = "\(counter.value)"
        view.nameLabel.text = name.value
        view.optionalLabel.text = optionalCounter.value.map { "\($0)" } ?? "nil"
    }
}
```

## useState 带 updater / keyPath

```swift
// updater: 每次状态变化时执行自定义闭包，直接操作 View
lazy var counterWithUpdater = useState(0, updater: { value, view, _ in
    view.counterLabel.text = "count: \(value)"
})

// Optional + updater
lazy var optionalWithUpdater = useState(nil, updater: { value, view, _ in
    view.optionalLabel.text = value ?? "nil"
})

// updateTo: 直接将值写入 View 的 keyPath（需要 View: AnyObject）
lazy var title = useState("Hello", updateTo: \.titleLabel.text)
```

## useState 订阅 Publisher

```swift
// 直接传入 Publisher
let myPublisher = PassthroughSubject<String, Never>()
lazy var pubValue = useState("(waiting)", publisher: myPublisher)

// 从 Service 获取 Publisher（懒加载，attach to root 时解析）
lazy var svcPubValue = useState("(waiting)",
    service: MyService.self,
    publisher: { $0.tickPublisher() })

// 带 updater 的 Publisher
lazy var pubWithUpdater = useState("(waiting)",
    updater: { value, view, _ in view.label.text = value },
    publisher: myPublisher)
```

## useState 订阅 AsyncSequence

```swift
// 直接传入 AsyncSequence（如 AsyncStream）
lazy var seqValue = useState(0, sequence: myAsyncStream)

// 从 Service 获取 AsyncSequence
lazy var svcSeqValue = useState(0,
    service: MyService.self,
    sequence: { $0.tickSequence() })
```

## useState 观察 ObservableObject

`ObservableObject` 是 Combine 的标准可观察协议。`useState` 订阅其 `objectWillChange` publisher，与 DDComponent 的 `setState` → `onUpdate` 模型匹配。

```swift
class CounterViewModel: ObservableObject {
    @Published var count: Int = 0
    @Published var label: String = "zero"
}

// 基本观察：objectWillChange 时自动触发 setState → onUpdate
lazy var viewModel = useState(CounterViewModel())

// 可选 ObservableObject
lazy var optionalVM: State<CounterViewModel?> = useState(nil)

// 替换对象：自动取消旧订阅，绑定新订阅
viewModel.value = CounterViewModel()   // old cancelled, new subscribed
optionalVM.value = nil                  // 取消订阅

// 带 updater
lazy var vmWithUpdater = useState(CounterViewModel(),
    updater: { value, view, _ in view.label.text = value.label })

// 带 keyPath
lazy var vmWithKeyPath = useState(CounterViewModel(),
    updateTo: \.headerViewModel)

// 在 onUpdate 中读取最新值
override func onUpdate(view: MyView, context: ViewUpdateContext) {
    view.countLabel.text = "\(viewModel.value.count)"
    view.nameLabel.text = viewModel.value.label
}
```

## useEffect 管理副作用

副作用在 `onAttachToRoot` 时启动，`onDetachFromRoot` 时自动调用清理闭包。

```swift
// 带清理的副作用
lazy var timerEffect = useEffect { [weak self] in
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        MainActor.assumeIsolated { self?.timestamp.value = Date() }
    }
    return { timer.invalidate() }  // detach 时自动调用
}

// 无清理的副作用
lazy var logEffect = useEffect { print("[MyPresenter] attached to root") }
```

## useUpdate 依赖驱动更新

只有当依赖的 State 变化时才执行 updater，避免不必要的 View 更新。

```swift
// 单依赖
lazy var titleUpdate = useUpdate(dependences: title) { view, context in
    view.titleLabel.text = title.value
}

// 多依赖：任一依赖变化时执行
lazy var combinedUpdate = useUpdate(dependences: title, counter) { view, context in
    view.titleLabel.text = title.value
    view.countLabel.text = "\(counter.value)"
}
```

## useService 懒加载 Service

Service 在 attach to root 时才解析，避免 init 时 Service 还未注册。

```swift
lazy var svcEffect = useService(MyService.self) { service in
    service.startMonitoring()
    return { service.stopMonitoring() }  // detach 时自动调用
}
```

## 关键规则

1. **必须在 `init()` 或属性初始化器中调用** — 不能在 `onBindView` 等生命周期方法中调用
2. **返回值必须存储为实例属性** — `State`、`Effect`、`Updater` 必须有 `let` 或 `lazy var` 持有，否则立即释放
3. **Swift 6 下使用 `lazy var` + 显式类型标注** — `useState` 重载多，编译器无法推断类型；`let` 在 `super.init()` 前不可用
4. **Optional 类型用 `useState(nil)`** — 类型从 `State<Int?>` 声明推断，不需要显式泛型参数
5. **ObservableObject 替换** — `state.value = newObject` 自动取消旧订阅、绑定新订阅，不需手动管理 `AnyCancellable`
6. **Timer 闭包用 `MainActor.assumeIsolated`** — 非 MainActor 的 Sendable 闭包中访问 `@MainActor` 属性时必须使用
7. **useUpdate 依赖必须完整** — updater 中读取的所有 State 都应声明在 `dependences` 中，否则遗漏的 State 变化时不会触发更新
8. **useState 不会自动同步到 View** — 需要在 `onUpdate` 中读取 `state.value`，或使用 `updater`/`keyPath` 参数

## 完整示例

完整演示代码见 Demo 11：`Example/DDComponent/Demos/11-UseMethods/`，包含所有 12 种 use* 变体的完整用法。

## 相关文档

- [架构设计](./architecture.md) — UpdatePipeline、setState 机制
- [使用指南](./usage-guide.md) — 固定视图与列表页面开发
- [Swift 6 并发模式](./swift6-patterns.md) — lazy var、MainActor、Timer 闭包
- [@PresenterState 宏](./presenter-state-macro.md) — 简化状态声明
