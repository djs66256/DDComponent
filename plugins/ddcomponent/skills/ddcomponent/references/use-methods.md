# use* API：声明式状态与副作用管理

`use*` 方法是 React Hooks 风格的声明式 API，将状态、副作用和视图更新器集中声明在初始化阶段。

## 与传统方式对比

**传统方式：** 状态散落在 `onBindView`、`onUpdate`、`onAttach` 等不同方法中，订阅创建和清理分离，依赖关系隐式。

**use* 方式：** 所有状态和副作用在 `init()` 或属性初始化器中声明，订阅在 attach 时自动启动、detach 时自动清理，依赖关系显式。

## 方法总览

| 方法 | 用途 | 返回类型 |
|---|---|---|
| `useState(_:)` | 创建响应式状态，`.value = new` 自动触发 `setState` | `State<T>` |
| `useState(_:updater:)` | 状态 + 每次变化时执行自定义闭包 | `State<T>` |
| `useState(_:updateTo:)` | 状态 + 直接写入 View 的 keyPath | `State<T>` |
| `useState(_:publisher:)` | 从 Combine Publisher 订阅值 | `State<T>` |
| `useState(_:sequence:)` | 从 AsyncSequence 订阅值 | `State<T>` |
| `useState(_:service:publisher:)` | 从 Service 懒加载 Publisher | `State<T>` |
| `useState(_:service:sequence:)` | 从 Service 懒加载 AsyncSequence | `State<T>` |
| `useState(ObservableObject)` | 观察 ObservableObject，`objectWillChange` 时触发 | `State<O>` |
| `useEffect(_:)` | 生命周期绑定副作用，return 清理闭包 | `Effect` |
| `useUpdate(dependences:_:)` | 依赖驱动的视图更新器，仅依赖变化时执行 | `Updater` |
| `useService(_:_:)` | 懒解析 Service 并传给副作用 | `Effect` |

## 三种判等策略

`useState` 通过泛型约束自动选择：`T: Equatable` 用 `==`、`T: AnyObject` 用 `===`、无约束总是触发。

## 关键规则

1. **只能在 `init()` 或属性初始化器中调用**，不能在生命周期方法中调用
2. **返回的 `State`、`Effect`、`Updater` 必须存储为实例属性**（`let` 或 `lazy var`）
3. **Swift 6 下必须用 `lazy var` + 显式类型标注**，编译器无法推断 `useState` 重载
4. **Optional 类型用 `useState(nil)`**，类型从属性声明推断
5. **ObservableObject 替换时**：`state.value = newObject` 自动取消旧订阅、绑定新订阅
6. **Timer 闭包中访问 `@MainActor` 属性**：用 `MainActor.assumeIsolated { ... }`
7. **`useState` 内部自动调用 `setState`**，不需要手动调用
8. **`useEffect` 清理闭包在 `onDetachFromRoot` 时自动调用**，无需手动管理