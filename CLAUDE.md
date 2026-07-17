# CLAUDE.md

## Project overview

DDComponent is an iOS Swift framework (CocoaPod, `DDComponent.podspec`) that provides a **Presenter-based page decomposition architecture**. It decomposes complex `UIViewController`/`UIView` logic into smaller, composable, testable Presenter units organized in a tree structure (P-Tree), with a separate View tree (V-Tree) that can be swapped independently.

Includes `DDComponentMacros` (Swift Macro, Package.swift) providing `@PresenterState` to auto-generate `setState`-wrapped computed properties.

## Build & development

```bash
# Install dependencies
cd Example && pod install

# Open workspace
open Example/DDComponent.xcworkspace

# Run tests
xcodebuild test -project Example/DDComponent.xcodeproj -scheme DDComponent-Example -destination 'platform=iOS Simulator,name=iPhone 17'

# Lint podspec
pod lib lint DDComponent.podspec
```

The framework source lives in `DDComponent/Classes/**/*.swift`. The Example app (in `Example/DDComponent/`) demonstrates usage patterns through 12 numbered demos in `Demos/`.

## Testing

122 unit tests across 12 test suites covering all core capabilities. Tests live in `Example/Tests/`:

| Test file | Coverage |
|---|---|
| `PresenterTreeTests.swift` | P-Tree lifecycle: add/remove child, attach/detach, ordering |
| `ViewBindingTests.swift` | View binding: bind/unbind/weak/auto-bind, type matching |
| `StateUpdateTests.swift` | setState: onUpdate, pipeline, context, StateChecker |
| `NotifyTests.swift` | Notify: all scopes, sender exclusion, detach behavior |
| `ServiceTests.swift` | Service DI: register/get, lookup chain, downgrade |
| `ReusablePresenterTests.swift` | Reuse lifecycle: bind/unbind holder, prepareForReuse |
| `CollectionPresenterTests.swift` | Collection hierarchy: section/items/supplementaries |
| `DifferTests.swift` | Diff algorithm: insert/delete/move/edge cases |
| `PageNotifyManagerTests.swift` | NotifyManager: listener add/remove/weak reference |
| `PageServiceManagerTests.swift` | ServiceManager: eager/lazy, fallthrough, priority |
| `IsolatedViewPresenterTests.swift` | IsolatedViewPresenter: binding, pipeline switching |
| `ViewUpdateContextTests.swift` | ViewUpdateContext: merge flags, bindView, reloadData |

Tests use `@testable import DDComponent` and run on the `DDComponent-Example` scheme.

## Architecture

### Core tree: P-Tree and V-Tree

- **P-Tree**: Presenters form a tree via `add(child:)`. The `RootViewPresenter` is the root, holding the `ViewUpdatePipeline`, `PageServiceManager`, and `PageNotifyManager`.
- **V-Tree**: UIKit views. Presenters bind to views via `bindView(_:)` / `bindWeakView(_:)`. The same P-Tree can bind to different V-Trees (e.g., Resso vs TTM).

### Key types

| Class/Protocol | File | Purpose |
|---|---|---|
| `ViewPresentable` | `ViewPresenter.swift` | Central protocol: tree, binding, lifecycle, pipeline |
| `ViewPresenter<View>` | `ViewPresenter.swift` | Base class; generic over view type |
| `RootViewPresentable` | `RootViewPresenter.swift` | Root protocol, extends `ViewPresentable` |
| `RootViewPresenter<View>` | `RootViewPresenter.swift` | Root node; owns pipeline, services, notifications |
| `PageViewController<F, P>` | `PageViewController.swift` | UIKit bridge; forwards lifecycle via notify |
| `IdentifierViewGroupPresenter<View>` | `ViewGroupPresenter.swift` | Children accessed by key (`typeBox`/`typeUnbox`) |
| `ManagedViewPresenter<View>` | `ManagedViewPresenter.swift` | Presenter with its own Service scope |
| `IsolatedViewPresenter` | `IsolatedViewPresenter.swift` | Standalone Presenter outside PageViewController |
| `ReusableViewPresenter<View>` | `Reusable/ReusableViewPresenter.swift` | For list cell reuse; requires `init()` and `prepareForReuse()` |
| `CollectionPresenter<View>` | `Reusable/CollectionPresenters/CollectionPresenter.swift` | Manages `sections` array |
| `CollectionSectionPresenter` | `Reusable/CollectionPresenters/CollectionSectionPresenter.swift` | Manages `items` and `supplementaries` |
| `CollectionItemPresenter<View>` | `Reusable/CollectionPresenters/CollectionItemPresenter.swift` | Single cell; uses Shadow Presenter pattern |
| `ViewUpdateAnimator` | `ViewUpdateAnimators.swift` | Custom animation protocol; built-in `SpringAnimator`/`EaseAnimator` |

### Lifecycle order

```
init() → onAttach(presenter:) → onAttachToRoot() → onBindView(_:) → onUpdate(view:context:) [×N] → onUnbindView() → onDetach() → onDetachFromRoot() → deinit
```

Each method has clear responsibilities — see `docs/architecture.md` for the complete lifecycle responsibilities table.

### State-driven updates

All UI updates go through `setState(updater:context:completion:)`. The `ViewUpdatePipeline` (owned by RootPresenter) batches and schedules updates. `ViewUpdateContext` controls animation, layout invalidation, and data-source reload behavior.

```swift
setState { self.count += 1 } context: {
    $0.animated = true              // Animate
    $0.invalidateLayout = true      // Trigger layout
    $0.invalidateDataSource = true  // Diff + reload (lists)
    $0.updateViewImmediately = true // Skip runloop batching
}
```

### use* API (React Hooks-like pattern)

`ViewPresenter+Use.swift` provides `useState`, `useEffect`, `useUpdate`, `useService` for centralized state/effect management at init time. See `docs/use-methods.md` for full details.

Key constraints:
- Must be called in `init()` or as property initializer
- With Swift 6, use `lazy var` with explicit type annotation
- Timer callbacks must use `MainActor.assumeIsolated` for `@MainActor` properties
- Optional values: `useState(nil)` — type inferred from property declaration

### @PresenterState macro

`@PresenterState var count: Int = 0` expands to a computed property whose setter auto-wraps `setState`, plus a `setCount(_:context:completion:)` convenience method. Lives in `DDComponentMacros/`. See `docs/presenter-state-macro.md`.

### Communication

- **Service** (`Service.swift`): Page-scoped DI. Register via `ServiceInstaller` or `register(service:lazy:_:)`. Lookup chain: current → parent → ... → RootPresenter → global downgrade.
- **Notify** (`ViewPresenterNotifiable.swift`): Protocol-based multicast. Scopes: `.global`, `.children`, `.childrenAndSelf`, `.parents`, `.reusable`. Send via `notify(listener:scope:_:)`; receive by conforming to the listener protocol.

### Reusable / list views

`ReusableViewPresenter<View>` for cell reuse. `CollectionPresenter` → `CollectionSectionPresenter` → `CollectionItemPresenter` hierarchy. `PartialTransactionPipeline` diffs data sources on a background queue, then applies batch updates via `ListViewUpdateResolver`.

### Dependency injection DSL

`@PageInstallerBuilder` result builder with `PresenterInstaller` and `ServiceInstaller`. Used in `PageViewController.pageInstallers`.

## Documentation

| Doc | Content |
|---|---|
| `docs/README.md` | Index with learning paths and quick-find table |
| `docs/architecture.md` | P-Tree/V-Tree, full lifecycle reference, Service/Notify, type hierarchy |
| `docs/usage-guide.md` | How to build pages, lists, use Service/Notify, assembly patterns |
| `docs/reusable-presenter.md` | List cell reuse, CollectionPresenter system, layoutInfo, diff engine |
| `docs/use-methods.md` | Complete useState/usEffect/useUpdate/useService reference |
| `docs/presenter-state-macro.md` | @PresenterState macro usage guide |
| `docs/swift6-patterns.md` | Swift 6 concurrency patterns (lazy var, MainActor.assumeIsolated) |
| `docs/demo-index.md` | All 12 demos with concepts and difficulty |

## File conventions

- All framework source in `DDComponent/Classes/`
- `UpdatePipeline/` — view update scheduling and diffing
- `Reusable/` — reusable presenters, collection abstractions, UITableView/UICollectionView bridges, partial update engine
- Macro source in `DDComponentMacros/Sources/`
- Example code in `Example/DDComponent/`
