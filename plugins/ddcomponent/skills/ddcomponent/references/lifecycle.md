# 生命周期方法职责详解

## 生命周期顺序

```
init() → onAttach → onAttachToRoot → onBindView → onUpdate (×N) → onUnbindView → onDetach → onDetachFromRoot → deinit
```

## 各方法职责

### 1. `init()` — 创建

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| 初始化自身属性、设置默认值 | 访问 `view`（尚未绑定） |
| RootPresenter 中通过 `typeBox()` 注册子 Presenter | 访问 `superPresenter` / `rootPresenter`（尚未挂载） |
| | 调用 `getService()` / `notify()`（Pipeline 不存在） |

### 2. `onAttach(presenter:)` / `onAttach()` — 挂载到 P-Tree

被 `add(child:)` 加入父 Presenter 时触发。RootPresenter 使用无参版本 `onAttach()`。

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| **`add(child:)` 注册子 Presenter**（组建 P-Tree 核心时机） | 访问 `view`（可能尚未绑定） |
| 初始化内部结构、创建子节点 | 依赖 `rootPresenter` 非空 |

> 源码执行顺序：`attachSuperPresenter()` 内部先调 `onAttach` → 再挂 Root → 最后 auto-bind View。所以 `onAttach` 时 Root 和 View 都还没就位。

### 3. `onAttachToRoot(rootPresenter:)` — 关联到 RootPresenter

自身或祖先挂到 RootPresenter 时，递归所有子 Presenter。

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| **注册 Effect（副作用）** — Pipeline 已可用 | 操作 View 的 UI（View 可能未绑定） |
| 监听全局事件、注册全局 Notify listener | 假设 `view` 非空 |
| 启动页面级别的定时器、监听 | |

### 4. `onBindView(_ view: View)` — 绑定 View

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| **先调用 `super.onBindView(view)`** | 直接修改 View 属性值（`bindView` 会自动触发首次 `onUpdate`） |
| **设置 View 的回调闭包** | 注册 Effect（应放在 `onAttachToRoot`） |
| 绑定子 Presenter 到对应的子 View | 调用 `add(child:)`（应在 `onAttach` 中完成） |

### 5. `onUpdate(view: View, context: ViewUpdateContext)` — 状态同步到 View

每次 `setState {}` 后由 Pipeline 调用。**核心原则：幂等的、无副作用的纯映射函数。**

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| **将 Presenter 状态同步到 View**（唯一正确职责） | **修改 Presenter 的状态**（造成死循环） |
| 读取 `context` flags 做条件判断 | **执行业务逻辑**（网络请求、页面跳转） |
| | 做耗时操作（高频滚动时频繁调用） |

### 6. `onUnbindView()` — 解绑 View

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| **先调用 `super.onUnbindView()`** | 假设 `view` 非空（弱引用场景下可能已是 nil） |
| **清理 View 的回调闭包**（设 `nil` 防循环引用） | 做业务逻辑清理（应在 `onDetach` 中做） |

### 7. `onDetach()` — 从 P-Tree 移除

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| 释放 P-Tree 维度的资源 | 访问 `view`（此时已 unbind） |
| 取消在此 Presenter 范围内注册的东西 | 访问 `superPresenter`（之后会被置 nil） |

### 8. `onDetachFromRoot()` — 脱离 RootPresenter

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| 清理全局 listener 注册 | 假设 `rootPresenter` 非空 |
| 释放通过 Service 获取的引用 | |

> Effect 自动清理：基类 `onDetachFromRoot()` 已调用 `effect.onDetach()`。

### 9. `prepareForReuse()` — 列表 Cell 复用前重置

仅 `ReusableViewPresenter` 有此方法。

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| **重置 Presenter 的所有状态** | 操作 View（此时 View 可能还是旧的） |
| 恢复到初始状态 | 调用 `setState`（由外部配置数据时再触发） |

## 职责速查表

| 方法 | 核心职责 | 一句话 |
|------|---------|--------|
| `init()` | 初始化自身属性 | 设置默认值，不依赖外部 |
| `onAttach` | 组装 P-Tree | `add(child:)`，创建子 Presenter |
| `onAttachToRoot` | 注册全局依赖 | 注册 Effect、监听全局事件 |
| `onBindView` | 连接 View | 设回调闭包，绑子 View，不直接改 View 值 |
| `onUpdate` | 同步数据 | 仅把状态写到 View，纯映射，无副作用 |
| `onUnbindView` | 断开 View | 清回调闭包，防循环引用 |
| `onDetach` | 清理 P-Tree | 移除子 Presenter，清理内部引用 |
| `onDetachFromRoot` | 注销全局依赖 | 框架自动清理 Effect |
| `prepareForReuse` | 重置状态 | 清空数据，恢复到初始值 |