# use* API：声明式状态与副作用管理

`use*` 方法是 React Hooks 风格 API，将状态、副作用和视图更新器集中声明在初始化阶段，替代分散在多个生命周期方法中的传统写法。

## 为什么用 use*

**传统方式：** 状态散落在 `onBindView`、`onUpdate`、`onAttach` 等不同方法中，订阅创建和清理分离，依赖关系隐式。

**use* 方式：** 所有状态和副作用在 `init()` 或属性初始化器中声明，生命周期自动管理，依赖关系显式。

## 方法总览

| 方法 | 用途 | 返回类型 |
|---|---|---|
| `useState(_:)` | 创建响应式状态容器 | `State<T>` |
| `useState(_:updater:)` | 状态 + 自定义更新闭包 | `State<T>` |
| `useState(_:updateTo:)` | 状态 + 直接写入 View keyPath | `State<T>` |
| `useState(_:publisher:)` | 从 Combine Publisher 订阅 | `State<T>` |
| `useState(_:sequence:)` | 从 AsyncSequence 订阅 | `State<T>` |
| `useState(_:service:publisher:)` | 从 Service 获取 Publisher | `State<T>` |
| `useState(_:service:sequence:)` | 从 Service 获取 AsyncSequence | `State<T>` |
| `useState(ObservableObject)` | 观察 ObservableObject | `State<O>` |
| `useEffect(_:)` | 生命周期绑定的副作用 | `Effect` |
| `useUpdate(dependences:_:)` | 依赖驱动的视图更新器 | `Updater` |
| `useService(_:_:)` | 解析 Service 并传给副作用 | `Effect` |

## 三种判等策略

| 泛型约束 | 判等方式 | 适用场景 |
|---|---|---|
| `T: Equatable` | `==` | Int、String、Struct |
| `T: AnyObject` | `===` | 引用类型（class） |
| 无约束 | 总是触发 | 非 Equatable 的值类型 |

## 基本用法

```swift
class MyPresenter: ViewPresenter<MyViewProtocol> {

    // Equatable 值类型
    lazy var counter: State<Int> = useState(0)
    lazy var name = useState("Hello")

    // AnyObject 引用类型
    lazy var selectedObject = useState(NSObject())

    // Optional 类型
    lazy var optionalCounter: State<Int?> = useState(nil)

    // 带 updater
    lazy var counterWithUpdater = useState(0, updater: { value, view, _ in
        view.counterLabel.text = "count: \(value)"
    })

    // 带 keyPath（View: AnyObject）
    lazy var title = useState("", updateTo: \.titleLabel.text)

    // 订阅 Publisher
    lazy var pubValue = useState("(waiting)", publisher: myPublisher)

    // 从 Service 获取 Publisher
    lazy var svcPubValue = useState("(waiting)",
        service: MyService.self, publisher: { $0.tickPublisher() })

    // 订阅 AsyncSequence
    lazy var seqValue = useState(0, sequence: myAsyncStream)

    // 观察 ObservableObject
    lazy var viewModel = useState(CounterViewModel())
    // 替换对象时自动取消旧订阅、绑定新订阅
    // viewModel.value = CounterViewModel()

    // useEffect
    lazy var timerEffect = useEffect { [weak self] in
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.timestamp.value = Date() }
        }
        return { timer.invalidate() }
    }

    // useUpdate
    lazy var titleUpdate = useUpdate(dependences: title) { view, context in
        view.titleLabel.text = title.value
    }

    // useService
    lazy var svcEffect = useService(MyService.self) { service in
        service.doSomething()
        return { service.cleanup() }
    }

    override func onUpdate(view: MyViewProtocol, context: ViewUpdateContext) {
        view.countLabel.text = "\(counter.value)"
        view.nameLabel.text = name.value
    }
}
```

## 关键规则

1. **必须在 `init()` 或属性初始化器中调用**，不要在生命周期方法中调用
2. **返回的 `State`、`Effect`、`Updater` 必须存储为实例属性**
3. **Swift 6 下使用 `lazy var` + 显式类型标注**，编译器无法推断 `useState` 重载
4. **Optional 类型用 `useState(nil)`**，类型从属性声明推断
5. **ObservableObject 替换**：`state.value = newObject` 自动取消旧订阅、绑定新订阅
6. **Timer 闭包用 `MainActor.assumeIsolated`** — 非 MainActor 隔离的 Sendable 闭包
7. **`useState` 内部自动调用 `setState`**，不需要手动调用
8. **`useEffect` 清理闭包在 `onDetachFromRoot` 时自动调用**

> 📖 完整示例见 `references/examples.md` 示例 8，Demo: [11-UseMethods](../Example/DDComponent/Demos/11-UseMethods/)