# CLAUDE.md

## Project overview

DDComponent is an iOS Swift framework (CocoaPod, `DDComponent.podspec`) that provides a **Presenter-based page decomposition architecture**. It decomposes complex `UIViewController`/`UIView` logic into smaller, composable, testable Presenter units organized in a tree structure (P-Tree), with a separate View tree (V-Tree) that can be swapped independently.

## Build & development

```bash
# Install dependencies
cd Example && pod install

# Open workspace
open Example/DDComponent.xcworkspace

# Lint podspec
pod lib lint DDComponent.podspec
```

The framework source lives in `DDComponent/Classes/**/*.swift`. The Example app (in `Example/DDComponent/`) demonstrates usage patterns.

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
| `PageViewController<F, P, V>` | `PageViewController.swift` | UIKit bridge; forwards lifecycle via notify |
| `IdentifierViewGroupPresenter<View>` | `ViewGroupPresenter.swift` | Children accessed by key (`typeBox`/`typeUnbox`) |
| `ReusableViewPresenter<View>` | `Reusable/ReusableViewPresenter.swift` | For list cell reuse; requires `init()` and `prepareForReuse()` |
| `CollectionPresenter<View>` | `Reusable/CollectionPresenters/CollectionPresenter.swift` | Manages `sections` array |
| `CollectionSectionPresenter` | `Reusable/CollectionPresenters/CollectionSectionPresenter.swift` | Manages `items` and `supplementaries` |
| `CollectionItemPresenter<View>` | `Reusable/CollectionPresenters/CollectionItemPresenter.swift` | Single cell; uses Shadow Presenter pattern |

### Lifecycle order

```
init() → onAttach(presenter:) → onAttachToRoot() → onBindView(_:) → onUpdate(view:context:) [×N] → onUnbindView() → onDetachFromRoot() → onDetach() → deinit
```

### State-driven updates

All UI updates go through `setState(updater:context:completion:)`. The `ViewUpdatePipeline` (owned by RootPresenter) batches and schedules updates. `ViewUpdateContext` controls animation, layout invalidation, and data-source reload behavior.

### Communication

- **Service** (`Service.swift`): Page-scoped DI. Register via `ServiceInstaller` or `register(service:lazy:_:)`. Lookup chain: current → parent → ... → RootPresenter → global downgrade.
- **Notify** (`ViewPresenterNotifiable.swift`): Protocol-based multicast. Scopes: `.global`, `.children`, `.childrenAndSelf`, `.parents`, `.reusable`. Send via `notify(listener:scope:_:)`; receive by conforming to the listener protocol.

### Reusable / list views

`ReusableViewPresenter<View>` for cell reuse. `CollectionPresenter` → `CollectionSectionPresenter` → `CollectionItemPresenter` hierarchy. `PartialTrasactionPipeline` diffs data sources on a background queue, then applies batch updates via `ListViewUpdateResolver`.

### Dependency injection DSL

`@PageInstallerBuilder` result builder with `PresenterInstaller` and `ServiceInstaller`. Used in `PageViewController.pageInstallers`.

## Documentation

Detailed docs are in `docs/`: architecture, usage guide, reusable presenters.

## File conventions

- All framework source in `DDComponent/Classes/`
- `UpdatePipeline/` — view update scheduling and diffing
- `Reusable/` — reusable presenters, collection abstractions, UITableView/UICollectionView bridges, partial update engine
- Example code in `Example/DDComponent/`