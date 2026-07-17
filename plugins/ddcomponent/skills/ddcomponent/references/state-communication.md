# 状态管理、动画与通信

## setState 与 onUpdate

`setState` 是 DDComponent 最核心的机制。它借鉴 React/SwiftUI 的声明式思想：View 是状态的函数，状态变更不直接修改 View，而是通过 Pipeline 批量调度 `onUpdate` 同步。

这保证了：多次状态变更合并为一次 View 更新、父容器能感知子 Presenter 的状态变化、列表复用时状态不污染、动画和布局由 Pipeline 统一管理。

**使用方式：**
- 修改状态：`setState { self.value = newValue }` — 闭包内只做状态修改，不含副作用
- 配置行为：`setState { ... } context: { $0.animated = true }` — 通过 context 控制动画、布局
- 同步 View：`override func onUpdate(view: View, context: ViewUpdateContext)` — 纯映射，把状态写入 View

### Context Flags

| Flag | 用途 |
|---|---|
| `animated = true` | 动画过渡 |
| `invalidateLayout = true` | 数据变化影响布局 |
| `invalidateDataSource = true` | 列表数据源变化（触发 Diff + reload） |
| `invalidateContentSize = true` | 仅 Cell 尺寸变化 |
| `updateViewImmediately = true` | 立即更新，不等批处理 |
| `animator = SpringAnimator.bouncy` | 指定动画器 |

## 动画

### Pipeline 动画机制

Pipeline 更新分两步：先 `updateView`（更新 View 属性），再 `layoutViewIfNeeded`（应用 Auto Layout 约束）。第二步仅在 `animated = true` 或 `layoutImmediately = true` 时进入动画块，因此使用自定义动画器时必须同时设置 `animated = true`。

### 内置 Animator

| Animator | 预设 | 说明 |
|---|---|---|
| `SpringAnimator` | `.default` / `.bouncy` / `.gentle` / `.snappy` | 弹簧动画，模拟物理弹性 |
| `EaseAnimator` | `.default` / `.quick` / `.slow` / `.easeIn` / `.easeOut` | 缓动动画，控制加速度曲线 |

`SpringAnimator` 适合需要"弹跳感"的场景（如点赞动画、卡片展开）。`EaseAnimator` 适合常规过渡（如颜色渐变、透明度变化）。

### 自定义 Animator

实现 `ViewUpdateAnimator` 协议，提供 `animate(with context:_:)` 方法。在方法内调用 `UIView.animate` 执行自定义动画，框架自动传入 updater 闭包。使用自定义动画器时必须同时设置 `$0.animated = true`。

### 常见错误

1. **setState 外部修改状态**：`self.title = x; setState {}` — 状态变更必须放在 setState 闭包内
2. **setState 内部执行副作用**：网络请求、埋点上报放在 setState 外部，setState 只做纯状态修改
3. **直接修改 View**：`view?.label.text = x` — 绕过 setState 导致 Pipeline 感知不到
4. **onUpdate 遗漏状态**：新增状态属性但忘记在 onUpdate 中同步，导致 View 展示不一致
5. **onUpdate 中执行业务逻辑**：onUpdate 高频调用（滚动时频繁触发），只做纯映射
6. **动画无效**：使用了自定义 animator 但忘记设置 `animated = true`

## 通信：Service 与 Notify

两种通信机制：**Service**（依赖注入）和 **Notify**（事件广播）。核心判断：**这个能力是否可替换？** 可替换用 Service，不可替换用 Notify。

| 场景 | 用 Notify | 用 Service |
|---|---|---|
| 父 ↔ 子 Presenter 通信 | ✅ | ❌ |
| 网络请求 / 页面跳转 / 埋点 | ❌ | ✅ |
| 全局事件（主题切换、登录状态） | ✅ | ❌ |

### Notify

基于协议的事件广播。发送方定义协议，通过 `notify(listener: Protocol.self) { $0.method(...) }` 发送，接收方实现协议即可。

**作用域：** `.global`（页面内所有 Presenter）、`.children`（`notifyChildren` 向下广播）、`.parents`（向父链传递）、`.reusable`（列表 Cell 范围内）。

### Service

用于可替换的外部能力。注册方式：`@PageInstallerBuilder pageInstallers`（推荐）、`presenterDidLoad` 中 `presenter.install {}`、直接 `register(service:)`。

**获取：** `getService(Protocol.self)` 返回可选类型。**查找链：** 当前 Presenter → 父 → ... → RootPresenter → 全局降级。**时机：** 必须在 `presenterDidLoad()` 或 `pageInstallers` 中注册。

### 常见错误

- 用 Service 做 Presenter 间通信 → 改用 Notify
- 用 Notify 做网络请求 → 改用 Service
- Service 注册太晚 → 移到 `pageInstallers`