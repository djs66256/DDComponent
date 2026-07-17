# @PresenterState 宏

`@PresenterState` 是 DDComponentMacros 提供的宏，用于消除在 Presenter 中定义状态属性的样板代码。

## 它解决什么问题？

在 DDComponent 中，所有影响 UI 的状态变更必须通过 `setState {}` 完成。传统写法需要在每个状态属性的 `didSet` 中调用 `setState`：

```swift
// 传统写法（每个属性都要写 didSet）
class MyPresenter: ViewPresenter<MyViewProtocol> {
    private var count: Int = 0 {
        didSet { setState {} }
    }
    private var title: String = "" {
        didSet { setState {} }
    }
    private var isLoading: Bool = false {
        didSet { setState {} }
    }
}
```

`@PresenterState` 将这一模式自动化：

```swift
// @PresenterState 写法
class MyPresenter: ViewPresenter<MyViewProtocol> {
    @PresenterState var count: Int = 0
    @PresenterState var title: String = ""
    @PresenterState var isLoading: Bool = false
}
```

## 基本用法

```swift
import DDComponent
import DDComponentMacrosClient

class MyPresenter: ViewPresenter<MyViewProtocol> {

    @PresenterState
    var count: Int = 0

    // 直接赋值 → 自动触发 setState
    func increment() {
        count += 1  // 等价于 setState { $count += 1 }
    }

    override func onUpdate(view: MyViewProtocol, context: ViewUpdateContext) {
        view.countLabel.text = "\(count)"
    }
}
```

## 生成的代码

`@PresenterState var count: Int = 0` 展开为三段代码：

```swift
// 1. 背存储属性（不可直接访问）
var $count: Int = 0

// 2. 计算属性（对外暴露，set 自动包装 setState）
var count: Int {
    get { $count }
    set { setState { $count = newValue } }
}

// 3. 便捷方法（支持 context 配置）
func setCount(
    _ newValue: Int,
    context: @escaping (inout ViewUpdateContext) -> Void = { _ in },
    completion: (() -> Void)? = nil
) {
    setState(
        updater: { $count = newValue },
        context: context,
        completion: completion
    )
}
```

## 使用 context 配置动画

直接赋值时 `setState` 使用默认 context（无动画）。需要动画或布局刷新时，使用生成的便捷方法：

```swift
@PresenterState
var count: Int = 0

// 带动画更新
setCount(count + 5) {
    $0.animated = true
    $0.invalidateLayout = true
}
```

## 与传统方式对比

| | 传统 `didSet` | `@PresenterState` |
|---|---|---|
| 代码量 | 3 行/属性 | 1 行/属性 |
| 动画支持 | `setState {} context: {}` | 生成的 `setXxx(_:context:)` 方法 |
| 可读性 | `didSet` 散落各处 | `@PresenterState` 一目了然 |
| 安全性 | 手动包裹，可能遗漏 | 编译期自动保证 |

## 限制

| 规则 | 说明 |
|------|------|
| 仅 `var` | 不能用于 `let`（编译错误） |
| 仅 stored property | 不能用于计算属性 |
| 需要显式类型 | 必须标注类型（如 `var count: Int = 0`），编译器需要类型信息来生成代码 |

## 示例

完整示例见 Demo 12：`Example/DDComponent/Demos/12-PresenterState/`。

## 相关文档

- [使用指南](./usage-guide.md) — 固定视图与列表页面开发
- [架构设计](./architecture.md) — setState 机制与 UpdatePipeline
- [Swift 6 并发模式](./swift6-patterns.md) — lazy var、MainActor
