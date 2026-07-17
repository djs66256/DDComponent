# Presenter 模式与生命周期

## Presenter 类型

### 标准 Presenter（有 UI）

继承 `ViewPresenter<ViewProtocol>`，View 必须定义为协议。核心模式：
- **状态集中管理**：用 `struct State` 封装所有影响 UI 的数据
- **setState 驱动更新**：所有状态变更通过 `setState {}` 通知 Pipeline
- **onUpdate 同步 View**：在 `onUpdate` 中把所有状态写到 View，纯映射函数，无副作用
- **onBindView 设回调**：设置 View 的回调闭包，连接用户交互
- **onUnbindView 清回调**：清理回调闭包，防止循环引用

### 纯逻辑 Presenter（无 UI）

继承 `ViewPresenter<ServiceType>`，View 泛型参数设为实际需要的 Service 类型。在 `onAttach` 中通过 `bindView(getService(...))` 将 Service 绑定为 View，不需要 `onUpdate`。典型场景：埋点上报、生命周期监听、全局事件处理。

### 复用 Presenter（列表 Cell）

继承 `ReusableViewPresenter<CellProtocol>`，用于列表 Cell 复用。必须实现 `required init()` 和 `prepareForReuse()`。`prepareForReuse()` 中重置所有状态到初始值，避免复用污染。如果 Cell 有子 Presenter，必须用此类型。

## 装配到页面

- **RootPresenter 的 `init()` 中**（推荐）：`typeBox(Presenter())` 常驻，`typeBoxLazy({ ... })` 懒加载
- **pageInstallers 中**：`PresenterInstaller(lazyLoad: true, { Presenter() })`，注册的是子 Presenter 不是 RootPresenter

## 拆分原则

- **单一职责**：一个 Presenter 只做一件事。用 `// MARK:` 分隔不同功能时说明该拆了
- **独立复用**：可能在多个页面使用的逻辑，独立成 Presenter
- **独立测试**：需要单独测试的逻辑，独立成 Presenter
- **不要过度拆分**：总是同时出现且逻辑简单的两个功能，放一起即可

## Service vs Presenter 内部

- **Service**：可替换的外部能力（网络、路由、埋点、持久化）
- **Presenter 内部**：不可替换的业务逻辑（状态管理、流程编排、UI 交互）

## Swift Macro：@PresenterState

`@PresenterState` 是 `DDComponentMacros` 提供的宏，消除状态属性的样板代码。需要 `import DDComponentMacrosClient`。

**解决的问题：** 传统写法每个状态属性都要写 `didSet { setState {} }`，`@PresenterState` 将其自动化——直接赋值即自动触发 `setState`。

**使用方式：** `@PresenterState var count: Int = 0`，直接 `count += 1` 等价于 `setState { $count += 1 }`。

**Context 支持：** 宏自动生成 `setXxx(_:context:completion:)` 便捷方法，如 `setCount(newValue) { $0.animated = true }`，用于需要动画或布局刷新的场景。

**展开原理：** 生成三段代码——背存储属性 `$count`、计算属性 `count`（set 自动包装 `setState`）、便捷方法 `setCount(_:context:)`。

**限制：** 仅 `var` stored property、需要显式类型标注。不能用于 `let` 或计算属性。

## @StateChecker 属性包装器

`@StateChecker` 是框架内置的属性包装器，在运行时断言状态修改必须在 `setState {}` 闭包内进行。如果直接修改 `@StateChecker` 标记的属性（不在 `setState` 内），会触发 assert 崩溃。

和 `@PresenterState` 的区别：`@StateChecker` 是运行时安全检查（防止误用），`@PresenterState` 是编译期代码生成（消除样板）。

## 生命周期

### 生命周期顺序

```
init() → onAttach → onAttachToRoot → onBindView → onUpdate (×N) → onUnbindView → onDetach → onDetachFromRoot → deinit
```

### 各方法职责

**`init()`** — 初始化自身属性、设置默认值。RootPresenter 在此通过 `typeBox()` 注册子 Presenter。不能访问 `view`、`superPresenter`、`rootPresenter`，不能调用 `getService()` / `notify()`（Pipeline 不存在）。

**`onAttach`** — 被 `add(child:)` 加入父 Presenter 时触发。**组建 P-Tree 的核心时机**：通过 `add(child:)` 注册子 Presenter。不能访问 `view`（尚未绑定），不能依赖 `rootPresenter` 非空。源码执行顺序：`onAttach` → 挂 Root → auto-bind View，所以 `onAttach` 时 Root 和 View 都还没就位。

**`onAttachToRoot`** — 自身或祖先挂到 RootPresenter 时递归触发。**Pipeline 此时已可用，是注册 Effect 的最佳时机**：注册副作用、监听全局事件、缓存 Service 引用。不能假设 `view` 非空。

**`onBindView`** — 连接 View 的唯一时机。先调用 `super.onBindView(view)`，设置 View 的回调闭包，绑定子 Presenter 到子 View。不直接修改 View 属性值（`bindView` 会自动触发首次 `onUpdate`），不在此注册 Effect 或 `add(child:)`。

**`onUpdate`** — 每次 `setState {}` 后由 Pipeline 调用。**核心原则：幂等的、无副作用的纯映射函数**。仅将 Presenter 状态同步到 View，不修改状态、不执行业务逻辑、不做耗时操作。

**`onUnbindView`** — 先调用 `super.onUnbindView()`，清理 View 的回调闭包（设 `nil` 防循环引用）。不假设 `view` 非空，不做业务逻辑清理。

**`onDetach`** — 从 P-Tree 移除。释放 P-Tree 维度资源，不能访问 `view`（已 unbind）。

**`onDetachFromRoot`** — 脱离 RootPresenter。基类已自动调用 `effect.onDetach()`，Effect 注册的副作用无需手动清理。

**`prepareForReuse()`** — 仅 `ReusableViewPresenter`。重置所有状态到初始值，取消请求。不操作 View，不调用 `setState`。

### 职责速查

| 方法 | 一句话 |
|------|--------|
| `init()` | 设置默认值，不依赖外部 |
| `onAttach` | `add(child:)` 组建 P-Tree |
| `onAttachToRoot` | 注册 Effect、监听全局事件 |
| `onBindView` | 设回调闭包，不直接改 View 值 |
| `onUpdate` | 仅把状态写到 View，纯映射 |
| `onUnbindView` | 清回调闭包，防循环引用 |
| `onDetach` | 清理 P-Tree 内部引用 |
| `onDetachFromRoot` | 框架自动清理 Effect |
| `prepareForReuse` | 重置状态到初始值 |