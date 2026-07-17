# DDComponent Documentation

[中文](../zh/README.md)

DDComponent is an iOS page decomposition framework based on the MVP pattern. It decomposes complex pages into independent, reusable, pluggable Presenter components.

## Quick Start

```
pod 'DDComponent'
```

```swift
// 1. View protocol
protocol LikeViewProtocol: AnyObject {
    var isLiked: Bool { get set }
    var onLikeTapped: (() -> Void)? { get set }
}

// 2. Presenter (business logic)
class LikePresenter: ViewPresenter<LikeViewProtocol> {
    var isLiked = false { didSet { setState {} } }

    func toggleLike() {
        api.toggleLike { [weak self] result in
            self?.isLiked = result
        }
    }

    override func onBindView(_ view: LikeViewProtocol) {
        view.onLikeTapped = { [weak self] in self?.toggleLike() }
    }

    override func onUpdate(view: LikeViewProtocol, context: ViewUpdateContext) {
        view.isLiked = isLiked
    }
}

// 3. ViewController
class MyVC: PageViewController<MyView, MyRootPresenter> {
    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        ServiceInstaller(LikeService.self, { LikeServiceImpl() })
    }
}
```

## Learning Path

### Beginner (understanding core concepts)

| Order | Document | What you'll learn |
|-------|----------|-------------------|
| 1 | [Architecture Design](./architecture.md) | P-Tree/V-Tree, lifecycle, setState, UpdatePipeline |
| 2 | [Usage Guide](./usage-guide.md) | Fixed views, list views, Service/Notify usage |
| 3 | Demo [01](../../Example/DDComponent/Demos/01-HelloDDComponent/) | Minimal example |

### Intermediate (mastering page assembly)

| Order | Document | What you'll learn |
|-------|----------|-------------------|
| 4 | [Reusable Presenter](./reusable-presenter.md) | List cell reuse, diff engine, layoutInfo |
| 5 | [@PresenterState Macro](./presenter-state-macro.md) | Simplifying state declarations |
| 6 | [use* API](./use-methods.md) | Declarative state and side effect management |
| 7 | Demos [04](../../Example/DDComponent/Demos/04-PTreeComposition/) -> [10](../../Example/DDComponent/Demos/10-FeedExample/) | Complete examples |

### Advanced (diving deeper)

| Order | Document | What you'll learn |
|-------|----------|-------------------|
| 8 | [Swift 6 Concurrency Patterns](./swift6-patterns.md) | lazy var, MainActor, Sendable |
| 9 | [Demo Index](./demo-index.md) | Overview of all 12 demos |

## I want to do X, what should I read?

| I want to... | Read this |
|--------------|-----------|
| Understand the framework's design philosophy | [Architecture Design](./architecture.md) |
| Create a simple page | [Usage Guide](./usage-guide.md) -> "Fixed Views" |
| Create a list page | [Usage Guide](./usage-guide.md) -> "List Views" |
| Understand P-Tree and V-Tree | [Architecture Design](./architecture.md) -> "P-Tree and V-Tree in Detail" |
| Understand Presenter lifecycle | [Architecture Design](./architecture.md) -> "Lifecycle Method Responsibilities in Detail" |
| Animate state changes | [Usage Guide](./usage-guide.md) -> "setState Context Quick Reference" |
| Communicate between Presenters | [Usage Guide](./usage-guide.md) -> "Service System" / "Notify Broadcast System" |
| Create list cells | [Reusable Presenter](./reusable-presenter.md) |
| Use React Hooks-style API | [use* API](./use-methods.md) |
| Simplify `didSet { setState {} }` boilerplate | [@PresenterState Macro](./presenter-state-macro.md) |
| Use correctly under Swift 6 | [Swift 6 Concurrency Patterns](./swift6-patterns.md) |
| Embed a component in a traditional VC | [Usage Guide](./usage-guide.md) -> "IsolatedViewPresenter" |
| Browse example code | [Demo Index](./demo-index.md) |

## Project Structure

```
DDComponent/
  Classes/
    ViewPresenter.swift              # Base class for all Presenters
    ViewPresenter+Use.swift          # use* declarative API
    RootViewPresenter.swift          # Root Presenter, manages Service and Notify
    PageViewController.swift         # UIKit bridge base class
    ViewGroupPresenter.swift         # Access child Presenters by identifier
    PresenterInstaller.swift         # Declarative assembly DSL (Result Builder)
    ViewUpdateContext.swift          # View update configuration
    ViewUpdateAnimators.swift        # Built-in animators (Spring / Ease)
    ViewPresenterNotifiable.swift    # Notify broadcast system
    ViewAutoBind.swift               # Automatic view binding
    Service.swift                    # Page-level service (DI)
    PageServiceManager.swift         # Service manager
    PageNotifyManager.swift          # Notify manager
    ManagedViewPresenter.swift       # Presenter with its own Service scope
    IsolatedViewPresenter.swift      # Standalone component (no RootPresenter dependency)
    UpdatePipeline/                  # Update pipeline implementation
    Reusable/                        # Reusable Presenter (list scenarios)
```
