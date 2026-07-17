# Demo 索引

DDComponent 示例应用包含 12+1 个 Demo，由浅入深演示框架的各项能力。

## Demo 列表

| # | Demo | 覆盖概念 | 难度 |
|---|------|----------|------|
| 01 | HelloDDComponent | `ViewPresenter` 基础、`setState`/`onUpdate`、生命周期日志 | ★ 入门 |
| 02 | Service & DI | Service 注册（eager/lazy）、`getService()` 查找链、全局降级 | ★ 入门 |
| 03 | Notify | 4 种广播作用域（global/children/parents/reusable）、协议接收 | ★ 入门 |
| 04 | P-Tree | P-Tree 组合、`typeBox`/`typeUnbox`、主题切换级联 | ★★ 基础 |
| 05 | List & Diff | `UICollectionViewRootPresenter`、Diff 增量更新、动画增删 | ★★ 基础 |
| 06 | Header/Footer | Section header/footer、可折叠分组、`section.header`/`.footer` API | ★★ 基础 |
| 07 | Animation & Context | 4 种动画模式、自定义 `ViewUpdateAnimator`、`ViewUpdateContext` | ★★ 基础 |
| 08 | IsolatedViewPresenter | 脱离 PageViewController 的独立 Presenter、嵌套使用 | ★★ 基础 |
| 09 | AutoBind & Shadow | 自动 View 绑定（BFS 查找）、Shadow Presenter 模式 | ★★★ 进阶 |
| 10 | Feed Example | 综合 Demo：Collection + Diff + 子 Presenter + Service + Notify | ★★★ 进阶 |
| 11 | Use Methods | 所有 12 种 `use*` 变体：useState/usEffect/useUpdate/useService | ★★★ 进阶 |
| 12 | @PresenterState | 宏消除 `didSet { setState {} }` 样板代码 | ★★ 基础 |
| — | CyclePageView | 循环页面示例（独立于 Demos/ 目录） | ★★★ 进阶 |

## 推荐学习顺序

```
入门（理解核心概念）
  └── 01 HelloDDComponent  →  理解 ViewPresenter + setState + onUpdate
  └── 02 Service & DI      →  理解依赖注入
  └── 03 Notify            →  理解 Presenter 间通信

基础（掌握页面搭建）
  └── 04 P-Tree            →  理解页面拆分与组合
  └── 12 @PresenterState   →  简化状态声明
  └── 05 List & Diff       →  列表页面开发
  └── 06 Header/Footer     →  列表分组与辅助视图
  └── 07 Animation         →  动画与更新控制
  └── 08 IsolatedPresenter →  在传统页面中嵌入组件

进阶（高级模式）
  └── 09 AutoBind & Shadow →  自动绑定与 Shadow 模式
  └── 11 Use Methods       →  React Hooks 风格声明式 API
  └── 10 Feed Example      →  综合运用所有能力
```

## 相关文档

- [架构设计](./architecture.md) — P-Tree/V-Tree、生命周期、UpdatePipeline 原理
- [使用指南](./usage-guide.md) — 固定视图、列表视图、Service/Notify 使用方法
- [复用 Presenter](./reusable-presenter.md) — 列表 Cell 复用、增量更新引擎
- [use* API](./use-methods.md) — 声明式状态与副作用管理
- [Swift 6 并发模式](./swift6-patterns.md) — lazy var、MainActor、Sendable
- [@PresenterState 宏](./presenter-state-macro.md) — 自动 setState 包装
