# Architecture Design

## Design Philosophy: Core Logic of Page Decomposition

### Page Decomposition by Presenter

DDComponent decomposes a page into multiple Presenters, each being an independent business logic unit. The final composed form can be viewed as:

- **P-Tree**: The tree formed by composing Presenters, representing the functional and logical organization of the page
- **V-Tree**: The UI display, the actual organization result of Views

The relationship between Presenter and View is a **weak relationship**, requiring manual binding (or auto-binding). This means we can swap in any V-Tree with the same node structure:

```
        P-Tree (unchanged)                V-Tree A              V-Tree B
   ┌──────────────────┐           ┌──────────────────┐  ┌──────────────────┐
   │  RootPresenter   │           │    RessoRootView │  │    TTMRootView   │
   │  ├ LikePresenter │── bind ───│   ├ LikeButton   │  │   ├ LikeButton   │
   │  ├ SharePresenter│── bind ───│   ├ ShareButton  │  │   ├ ShareButton  │
   │  └ CommentList   │           │   └ CommentList   │  │   └ CommentList   │
   └──────────────────┘           └──────────────────┘  └──────────────────┘
```

In pages where the functional logic is the same but the UI differs, the degree of reuse is very high. Feature reuse between Resso and TTM is a typical scenario.

### Presenter Design Philosophy

The responsibility of a Presenter is **the abstraction of business logic, the reuse of logic**. During use:

- If a Presenter provides too many capabilities and is coupled with many features, preventing reasonable convergence of logic, it indicates poor Presenter design
- View is not equivalent to UIView; View represents the **endpoint of data display and consumption** — it can be UI, or something else (e.g., an analytics service)
- When View is `Void` type, the Presenter degenerates into a **pure logic unit**

### State-Driven: View as a State Machine

Most UI layer content can be viewed as a state machine. When updating views, the most common problem is data misalignment, especially during reuse and when multiple places are modifying view state. DDComponent draws on concepts from React, SwiftUI, etc., adopting a **state-driven** view update model:

- All state changes go through the unified `setState` entry point
- Updates are delegated to the Pipeline for execution, managed globally in a unified manner
- Although direct View modification is not prohibited, it can cause issues such as the parent container being unable to perceive changes

## P-Tree and V-Tree in Detail

### P-Tree Structure

Presenters form a tree via `add(child:)`, determining the page's functional organization:

```swift
class SuperPresenter: ViewPresenter<SuperViewProtocol> {
    let likePresenter = LikePresenter()
    let sharePresenter = SharePresenter()

    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        add(child: likePresenter)
        add(child: sharePresenter)
    }

    override func onBindView(_ view: SuperViewProtocol) {
        super.onBindView(view)
        likePresenter.bindView(view.likeButton)
        sharePresenter.bindView(view.shareButton)
    }

    override func onUnbindView() {
        super.onUnbindView()
        likePresenter.unbindView()
        sharePresenter.unbindView()
    }
}
```

### Key Characteristics

- **P-Tree is the primary structure**: Presenters form a tree via `add(child:)`, determining the page's functional organization
- **V-Tree is replaceable**: The same P-Tree can bind to different V-Tree implementations
- **Weak binding**: Presenters hold weak references to Views; Views are unaware of Presenters' existence
- **Manual binding**: Currently requires manual binding, giving developers full control

## Presenter Lifecycle

All Presenters share a unified lifecycle:

```
init() → onAttach → onAttachToRoot → onBindView → onUpdate (×N) → onUnbindView → onDetach → onDetachFromRoot → deinit
```

Lifecycle methods **automatically propagate recursively** to all child Presenters:
- `attachRootPresenter` → recurses to all children
- `detachRootPresenter` → recurses to all children
- `bindView` → automatically triggers `autoBindChildrenPresenterViews`
- `unbindView` → recurses to all children

### Detailed Lifecycle Method Responsibilities

Below are the detailed responsibility boundaries for each lifecycle method.

#### 1. `init()` — Creation

**Trigger:** Presenter initialization.

| ✅ Should Do | ❌ Should NOT Do |
|---|---|
| Initialize own properties, set default values | Access `view` (not yet bound) |
| In RootPresenter, register child Presenters via `typeBox()` | Access `superPresenter` / `rootPresenter` (not yet attached) |
| | Call `getService()` / `notify()` (Pipeline does not exist) |

#### 2. `onAttach(presenter:)` / `onAttach()` — Attach to P-Tree

**Trigger:** Added to parent Presenter via `add(child:)`. RootPresenter uses the parameterless version `onAttach()`.

| ✅ Should Do | ❌ Should NOT Do |
|---|---|
| **`add(child:)` to register child Presenters** (the core moment for building the P-Tree) | Access `view` (View may not yet be bound) |
| Initialize internal structure, create child nodes | Depend on `rootPresenter` being non-nil (parent may not yet be attached to Root) |
| | Do operations that require Pipeline |

> **Source execution order:** Inside `attachSuperPresenter()`, it first calls `onAttach` → then attaches Root → finally auto-binds View. So when `onAttach` is called, neither Root nor View is in place yet.

#### 3. `onAttachToRoot(rootPresenter:)` — Associate with RootPresenter

**Trigger:** When self or an ancestor is attached to RootPresenter, recurses to all child Presenters.

| ✅ Should Do | ❌ Should NOT Do |
|---|---|
| **Register Effects (side effects)** — Pipeline is available now, this is the best time to register Effects | Manipulate View UI (View may not be bound) |
| Listen for global events, register global Notify listeners | Assume `view` is non-nil |
| Start page-level timers, observers | |
| Obtain Service references and cache them | |

> **Effect mechanism:** `onAttachToRoot` starts the effect's `action()`, and `onDetachFromRoot` automatically calls the returned cancel function.

#### 4. `onBindView(_ view: View)` — Bind View

**Trigger:** When `bindView(_:)` / `bindWeakView(_:)` / `tryBindView(_:)` is called.

| ✅ Should Do | ❌ Should NOT Do |
|---|---|
| **Call `super.onBindView(view)` first** | Directly modify View property values (`bindView` automatically triggers the first `onUpdate`) |
| **Set View callback closures** (`view.onButtonTapped = { ... }`) | Register Effects (should be placed in `onAttachToRoot`) |
| Bind child Presenters to corresponding child Views | Call `add(child:)` (should be done in `onAttach`) |

> **Note:** `bindView()` internally automatically triggers a `setState {} context: { $0.bindView() }` to execute the first `onUpdate`; initial data does not need to be manually assigned to the View.

#### 5. `onUpdate(view: View, context: ViewUpdateContext)` — Sync State to View

**Trigger:** Called by the Pipeline after each `setState {}`. Can be called multiple times.

| ✅ Should Do | ❌ Should NOT Do |
|---|---|
| **Sync Presenter state to View** (the only correct responsibility) | **Modify the Presenter's state** (causes infinite loop) |
| Read `context` flags for conditional logic (rarely needed) | **Execute business logic** (network requests, page navigation, etc.) |
| | Modify View layout constraints (should be handled via `context.invalidateLayout`) |
| | Do time-consuming operations (frequently called during high-speed scrolling) |

> **Core principle:** `onUpdate` is an idempotent, side-effect-free pure mapping function. **Missing state sync leads to bugs where the View display is inconsistent**.

#### 6. `onUnbindView()` — Unbind View

**Trigger:** `unbindView()`, binding a new View (unbinds the old View first), `detachSuperPresenter()` (auto-unbinds), page destruction.

| ✅ Should Do | ❌ Should NOT Do |
|---|---|
| **Call `super.onUnbindView()` first** | Assume `view` is non-nil (may already be nil under weak reference scenarios) |
| **Clean up View callback closures** (set to `nil` to prevent retain cycles) | Clean up business logic (should be done in `onDetach`) |
| Clean up resources bound to the View instance (timers, etc.) | Remove Effects (should be cleaned up in `onDetachFromRoot`) |

> **Note:** `unbindView()` automatically recurses and unbinds all child Presenters.

#### 7. `onDetach()` — Remove from P-Tree

**Trigger:** `removeFromSuper()` / `remove(child:)` / `detachAllPresentersRecursive()`.

| ✅ Should Do | ❌ Should NOT Do |
|---|---|
| Release P-Tree-scoped resources (remove child Presenters) | Access `view` (already unbound at this point) |
| Cancel things registered within this Presenter's scope | Access `superPresenter` (will be set to nil afterwards) |

> **Execution order:** Inside `detachSuperPresenter()`: first `unbindView()` → then `onDetach()` → finally `detachRootPresenter()`.

#### 8. `onDetachFromRoot()` — Detach from RootPresenter

**Trigger:** When self or an ancestor is detached from RootPresenter. Recurses to child Presenters first, then calls self.

| ✅ Should Do | ❌ Should NOT Do |
|---|---|
| Clean up global listener registrations | Assume `rootPresenter` is non-nil (not yet nil when called, but will be afterwards) |
| Release references obtained via Service | |

> **Effect auto-cleanup:** The base class `onDetachFromRoot()` already calls `effect.onDetach()`. Side effects registered via Effect in `onAttachToRoot` do not need manual cleanup.

#### 9. `prepareForReuse()` — Reset Before List Cell Reuse

**Trigger:** When a list cell is reused. Only `ReusableViewPresenter` has this method.

| ✅ Should Do | ❌ Should NOT Do |
|---|---|
| **Reset all Presenter state** (clear data, cancel requests, reset flags) | Manipulate View (View may still be the old one) |
| Restore to initial state | Call `setState` (triggered later when external code configures data after reset) |

### Responsibility Quick Reference

| Method | Core Responsibility | One Sentence |
|------|---------|--------|
| `init()` | Initialize own properties | Set defaults, no external dependencies |
| `onAttach` | Assemble P-Tree | `add(child:)`, create child Presenters |
| `onAttachToRoot` | Register global dependencies | Register Effects, listen for global events |
| `onBindView` | Connect View | Set callback closures, bind child Views, do **not** directly modify View values |
| `onUpdate` | Sync data | **Only** write state to View, pure mapping, no side effects |
| `onUnbindView` | Disconnect View | Clear callback closures, prevent retain cycles |
| `onDetach` | Clean up P-Tree | Remove child Presenters, clean up internal references |
| `onDetachFromRoot` | Deregister global dependencies | Framework auto-cleans Effects |
| `prepareForReuse` | Reset state | Clear data, restore to initial values |

## State-Driven View Updates

### Design Motivation

When updating views, the most common problem is **data misalignment**, especially during reuse and when multiple places are modifying view state. The view itself can be considered a massive state machine, so DDComponent recommends that all view updates adopt a state-driven approach. This concept draws from the design philosophy of frameworks like React and SwiftUI.

### The Role of setState

- **Unified update timing**: Prevents data inconsistency caused by directly modifying the View in multiple places
- **Batch updates**: Multiple `setState` calls can be merged into a single UI update
- **List scenario optimization**: Automatically handles incremental updates (Diff), animations
- **State validation**: Works with `@StateChecker` to ensure state is only modified inside `setState`
- **Macro simplification**: Works with the `@PresenterState` macro to eliminate `didSet { setState {} }` boilerplate

### Basic Usage

```swift
class MyPresenter: ViewPresenter<MyViewProtocol> {
    var count: Int = 0
    var title: String = ""

    // Property change triggers update
    var isVisible: Bool {
        didSet { setState {} }
    }

    func updateData(newCount: Int, newTitle: String) {
        setState {
            count = newCount
            title = newTitle
        } context: {
            $0.animated = true       // Update with animation
        }
    }

    override func onUpdate(view: MyViewProtocol, context: ViewUpdateContext) {
        view.count = count
        view.title = title
        view.isVisible = isVisible
    }
}
```

### UpdatePipeline: Unified Update Scheduling

All state changes are delegated to the Pipeline for execution. Only the RootPresenter has the unique Pipeline, capable of **globally and uniformly managing the UI update flow**:

```
setState {}
    │
    ▼
markDirty(presenter, context)    ← Mark Presenter as dirty
    │
    ▼
updateViewIfNeeded()             ← Trigger at the appropriate time
    │
    ▼
updateView(context:)             ← Check needsUpdate, call onUpdate
```

Pipeline strategies:
- **Fixed views**: `GlobalViewUpdatePipeline` — one global update at a time
- **List views**: `PartialTransactionPipeline` — supports incremental Diff updates

### ViewUpdateContext Configuration Options

| Property | Purpose |
|---|---|
| `updateViewImmediately` | Immediately synchronize update (default: next runloop) |
| `animated` | Execute update within `UIView.animate` block |
| `invalidateLayout` | Trigger `setNeedsLayout` after update |
| `invalidateConstraints` | Trigger `setNeedsUpdateConstraints` after update |
| `layoutImmediately` | Immediately execute `layoutIfNeeded` after update |
| `invalidateDataSource` | Mark data source changed (triggers reload in list scenarios) |
| `invalidateContentSize` | Mark content size changed (triggers layout update in list scenarios) |
| `forceDisableAnimation` | Force-disable all animations |

### use* API: Declarative State Management

DDComponent provides a React Hooks-style `use*` API (defined in `ViewPresenter+Use.swift`), declaring state, side effects, and view updaters during the initialization phase, replacing the traditional approach of spreading them across multiple lifecycle methods.

**Core APIs:**

| Method | Return Type | Purpose |
|---|---|---|
| `useState(_:)` | `State<T>` | Create a reactive state container |
| `useEffect(_:)` | `Effect` | Register lifecycle-bound side effects |
| `useUpdate(dependences:_:)` | `Updater` | Dependency-driven view updater |
| `useService(_:_:)` | `Effect` | Resolve a Service and pass it to a side effect |

> For detailed usage, code examples, and 8 key rules, see [use* API documentation](./use-methods.md).

## RootPresenter

`RootViewPresenter` is the root node of the P-Tree; there must be exactly one. It provides global capabilities:

```
RootViewPresenter
├── Holds ViewUpdatePipeline    ← The one and only update pipeline
├── Holds PageServiceManager    ← Page-level Service registration/retrieval
├── Holds PageNotifyManager     ← Global broadcast management
└── Implements ServiceRegistrar ← Service registration interface
```

### Differences from Regular Presenter

| | ViewPresenter | RootViewPresenter |
|---|---|---|
| Parent node | Has superPresenter | None (superPresenter is always nil) |
| Lifecycle | `onAttach(presenter:)` | `onAttach()` |
| Pipeline | Inherited from parent | Owns and creates its own |
| Service | Looked up from parent | Owns its own ServiceManager |
| Notify | Delegated to parent | Owns its own NotifyManager |

You can override RootPresenter and place business logic in the Root, but the recommended approach is to decompose logic into their respective Presenters.

## PageViewController

`PageViewController` is the UIKit bridging layer, responsible for:

1. **Presenter initialization**: Calls `makePresenter()` and `presenterDidLoad()`
2. **View binding**: Calls `makeView()` and `bindView(_:)`
3. **Lifecycle forwarding**: Broadcasts `viewWillAppear` and other events to all Presenters via Notify

```swift
open class PageViewController<FrameView: UIView, Presenter: RootViewPresenterProtocol>: UIViewController {
    open func makePresenter() -> Presenter
    open func makeView() -> FrameView
    open func presenterDidLoad()    // Timing for installing Presenters and Services
}
```

### Page Lifecycle Events

`PageViewController` automatically broadcasts ViewController lifecycle events to Presenters that implement the `PageLifecycle` protocol:

```swift
class MyPresenter: ViewPresenter<MyView>, PageLifecycle {
    func viewDidAppear(_ animated: Bool) {
        // Execute when page appears, e.g., start reporting
    }
    func viewDidDisappear(_ animated: Bool) {
        // Execute when page disappears, e.g., pause reporting
    }
}
```

## Special Presenter Types

### ManagedViewPresenter

`ManagedViewPresenter<View>` is a subclass of `ViewPresenter<View>`, with its own independent `ServiceManager`. Use when a Presenter needs its own Service scope (not dependent on the parent Presenter's Service lookup chain):

```swift
class SelfContainedPresenter: ManagedViewPresenter<MyViewProtocol> {
    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        // Register Services visible only within this Presenter and its subtree
        register(service: LocalCacheService.self) { LocalCacheImpl() }
    }
}
```

### IsolatedViewPresenter

`IsolatedViewPresenter` allows embedding an independent Presenter component in a non-DDComponent page (traditional UIViewController). It comes with its own independent ServiceManager, NotifyManager, and UpdatePipeline, without depending on an external RootPresenter:

```swift
// In a traditional UIViewController
let isolated = IsolatedViewPresenter(MyLikeButton(), LikePresenter())
isolated.register(service: LikeService.self) { LikeServiceImpl() }
view.addSubview(isolated.view)

// Manually forward lifecycle events
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    isolated.notifyGlobal(listener: PageLifecycle.self) {
        $0.viewDidAppear(animated)
    }
}
```

### Shadow Presenter (Inside CollectionItemPresenter)

Shadow Presenter is an **internal implementation detail** of `CollectionItemPresenter`, used to solve lifecycle management in list cell reuse scenarios:

```
Cell display:
  CollectionItemPresenter
    └── ShadowPresenter
          ├── bindView(cell)     → triggers onBindView
          └── onUpdate(cell)     → triggers onUpdate

Cell recycling:
  CollectionItemPresenter
    └── ShadowPresenter
          └── unbindView()       → triggers onUnbindView
          └── prepareForReuse()  → resets state
```

Developers typically do not need to interact with Shadow Presenter directly; the framework handles binding/unbinding automatically.

## Internal Communication Mechanisms

### Design Background

After decomposing a page, communication between modules becomes very challenging. The traditional approach is to invoke via references, but after decomposition, Presenters should not hold references to each other, as this creates new coupling. DDComponent provides two decoupled communication methods:

### Service: Page-Level Capability Bridge

Service provides **page-level** componentized service functionality for replaceable external capabilities (network requests, route navigation, analytics reporting, data persistence):

```swift
// Registration
@PageInstallerBuilder override var pageInstallers: PageInstaller {
    ServiceInstaller(LikeService.self, { LikeServiceImpl() })
    ServiceInstaller(DataLoader.self, { MockDataLoaderImpl() })
}

// Retrieval
getService(LikeService.self)?.toggleLike(...)
```

Service lookup chain: current Presenter → superPresenter → ... → RootPresenter → global fallback service

### Notify: Broadcast Communication

Protocol-based multicast communication for inter-Presenter communication. Scopes are:

| Scope | Method | Range |
|---|---|---|
| `.global` | `notifyGlobal()` | Broadcast from Root to all Presenters in the P-Tree |
| `.children` | `notifyChildren()` | Broadcast downward to all child modules |
| `.childrenAndSelf` | — | Broadcast downward, including self |
| `.parents` | `notifyParents()` | Broadcast upward through the parent chain |
| `.reusable` | `notifyReusable()` | Broadcast to the nearest reuse container scope |

```swift
// Define listener protocol
protocol LikeListener: AnyObject {
    func onLikeChanged(isLiked: Bool, count: Int)
}

// Send broadcast
notify(listener: LikeListener.self) {
    $0.onLikeChanged(isLiked: true, count: 10)
}

// Receive broadcast (simply conform to the corresponding protocol)
extension MyPresenter: LikeListener {
    func onLikeChanged(isLiked: Bool, count: Int) { ... }
}
```

### Communication Method Selection

| Scenario | Use Notify | Use Service |
|---|---|---|
| Parent ↔ Child Presenter communication | ✅ | ❌ |
| Network requests | ❌ | ✅ |
| Page navigation | ❌ | ✅ |
| Analytics reporting | ❌ | ✅ |
| Global events (theme switch, login state) | ✅ | ❌ |

## Type Hierarchy Overview

```
                    ┌──────────────────────┐
                    │  ViewPresentable     │  (Protocol)
                    │  - P-Tree management │
                    │  - View binding      │
                    │  - Lifecycle         │
                    │  - Notify / Service  │
                    └──────────┬───────────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         │                     │                     │
   ┌─────▼──────────┐  ┌──────▼──────────┐  ┌───────▼──────────────┐
   │ ViewPresenter  │  │ RootView-       │  │ ReusableView-        │
   │ <V> (base)     │  │ Presenter<V>    │  │ Presenter<V>         │
   └──┬──┬──────────┘  │ (root node)     │  │ (list reuse)         │
      │  │              └────────────────┘  └──┬───────────────────┘
      │  │                                      │
 ┌────▼┐ │ ┌──────────────────────┐  ┌──────────▼──────────────┐
 │IdVG │ │ │ PageViewController   │  │ CollectionPresenter<V>  │
 │Pres.│ │ │ (UIKit bridge)       │  │ (Collection/TableView)  │
 └─────┘ │ └──────────────────────┘  └─────────────────────────┘
         │
  ┌──────▼───────────┐  ┌──────────────────┐
  │ ManagedView-     │  │ IsolatedView-    │
  │ Presenter<V>     │  │ Presenter        │
  │ (own Service)    │  │ (standalone)     │
  └──────────────────┘  └──────────────────┘
```

## Related Documentation

- [Usage Guide](./usage-guide.md) — Fixed views, list views, installation patterns
- [Reusable Presenter](./reusable-presenter.md) — List cell reuse, incremental update engine
- [use* API](./use-methods.md) — Detailed usage of declarative state management
- [Swift 6 Concurrency Patterns](./swift6-patterns.md) — lazy var, MainActor, Sendable
- [@PresenterState Macro](./presenter-state-macro.md) — Simplifying state declarations
- [Demo Index](./demo-index.md) — List of all example demos
