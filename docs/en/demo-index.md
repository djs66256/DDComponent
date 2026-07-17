# Demo Index

The DDComponent example app includes 12+1 demos, progressively demonstrating the framework's capabilities from beginner to advanced.

## Demo List

| # | Demo | Concepts Covered | Level |
|---|------|----------|------|
| 01 | HelloDDComponent | `ViewPresenter` basics, `setState`/`onUpdate`, lifecycle logging | ★ Beginner |
| 02 | Service & DI | Service registration (eager/lazy), `getService()` lookup chain, global fallback | ★ Beginner |
| 03 | Notify | 4 broadcast scopes (global/children/parents/reusable), protocol-based receiving | ★ Beginner |
| 04 | P-Tree | P-Tree composition, `typeBox`/`typeUnbox`, cascading theme switching | ★★ Intermediate |
| 05 | List & Diff | `UICollectionViewRootPresenter`, Diff incremental updates, animated insert/delete | ★★ Intermediate |
| 06 | Header/Footer | Section header/footer, collapsible sections, `section.header`/`.footer` API | ★★ Intermediate |
| 07 | Animation & Context | 4 animation modes, custom `ViewUpdateAnimator`, `ViewUpdateContext` | ★★ Intermediate |
| 08 | IsolatedViewPresenter | Standalone Presenter independent of PageViewController, nested usage | ★★ Intermediate |
| 09 | AutoBind & Shadow | Auto View binding (BFS lookup), Shadow Presenter pattern | ★★★ Advanced |
| 10 | Feed Example | Comprehensive demo: Collection + Diff + child Presenter + Service + Notify | ★★★ Advanced |
| 11 | Use Methods | All 12 `use*` variants: useState/useEffect/useUpdate/useService | ★★★ Advanced |
| 12 | @PresenterState | Macro to eliminate `didSet { setState {} }` boilerplate | ★★ Intermediate |
| — | CyclePageView | Cycle page example (independent of Demos/ directory) | ★★★ Advanced |

## Recommended Learning Path

```
Beginner (Understand core concepts)
  └── 01 HelloDDComponent  →  Understand ViewPresenter + setState + onUpdate
  └── 02 Service & DI      →  Understand dependency injection
  └── 03 Notify            →  Understand inter-Presenter communication

Intermediate (Master page building)
  └── 04 P-Tree            →  Understand page decomposition and composition
  └── 12 @PresenterState   →  Simplify state declarations
  └── 05 List & Diff       →  List page development
  └── 06 Header/Footer     →  List grouping and supplementary views
  └── 07 Animation         →  Animation and update control
  └── 08 IsolatedPresenter →  Embed components in traditional pages

Advanced (Advanced patterns)
  └── 09 AutoBind & Shadow →  Automatic binding and Shadow pattern
  └── 11 Use Methods       →  React Hooks-style declarative API
  └── 10 Feed Example      →  Comprehensive integration of all capabilities
```

## Related Documentation

- [Architecture](./architecture.md) — P-Tree/V-Tree, lifecycle, UpdatePipeline principles
- [Usage Guide](./usage-guide.md) — Fixed views, list views, Service/Notify usage
- [Reusable Presenter](./reusable-presenter.md) — List cell reuse, incremental update engine
- [use* API](./use-methods.md) — Declarative state and side effect management
- [Swift 6 Concurrency Patterns](./swift6-patterns.md) — lazy var, MainActor, Sendable
- [@PresenterState Macro](./presenter-state-macro.md) — Automatic setState wrapping
