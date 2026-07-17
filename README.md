# DDComponent

[![Version](https://img.shields.io/cocoapods/v/DDComponent.svg?style=flat)](https://cocoapods.org/pods/DDComponent)
[![License](https://img.shields.io/cocoapods/l/DDComponent.svg?style=flat)](https://cocoapods.org/pods/DDComponent)
[![Platform](https://img.shields.io/cocoapods/p/DDComponent.svg?style=flat)](https://cocoapods.org/pods/DDComponent)

[中文](./README-zh.md)

An MVP-based iOS page decomposition framework. Break down complex pages into independent, reusable, pluggable Presenter components.

## Why DDComponent?

| Problem | DDComponent's Solution |
|---|---|
| Multiple developers modifying the same file causes conflicts | Each feature is split into independent Presenters, no interference |
| Feature boundaries are fuzzy, no one owns quality | Presenters serve as clear logic boundaries with well-defined responsibilities |
| Same feature needs different UIs (e.g. Resso vs TTM) | P-Tree and V-Tree are separated — logic is reused, UI is swappable |
| Features need dynamic pluggability | Use the `install` DSL to assemble Presenters and Services on demand |

## Core Concepts

### P-Tree and V-Tree

```
P-Tree (Presenter Tree)        V-Tree (View Tree)
┌─────────────────┐          ┌─────────────────┐
│  RootPresenter  │ - - - - │    RootView     │
│  ├ LikePresenter │ - - - - │   ├ LikeButton  │
│  ├ SharePresenter│ - - - - │   ├ ShareButton │
│  └ CommentPresenter│ - - - │   └ CommentList │
└─────────────────┘          └─────────────────┘
```

- **P-Tree** (Presenter Tree): The functional logic structure of the page
- **V-Tree** (View Tree): The UI presentation structure
- The two are loosely bound: the same P-Tree can bind to entirely different V-Trees

### State-Driven Updates

DDComponent draws inspiration from React/SwiftUI — all UI updates must go through a single `setState` entry point, batched and executed by the UpdatePipeline:

```
Data change → setState { ... } → Pipeline scheduling → onUpdate(view:context:) → UI update
```

### Quick Example

```swift
// 1. View protocol (not UIView)
protocol LikeViewProtocol: AnyObject {
    var isLiked: Bool { get set }
    var likeCount: Int { get set }
    var onLikeTapped: (() -> Void)? { get set }
}

// 2. Presenter (business logic)
class LikePresenter: ViewPresenter<LikeViewProtocol> {
    var isLiked = false { didSet { setState {} } }

    func toggleLike() {
        getService(LikeService.self)?.toggleLike { [weak self] result in
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

// 3. Assembly
class MyViewController: PageViewController<MyRootView, MyRootPresenter> {
    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        ServiceInstaller(LikeService.self, { LikeServiceImpl() })
    }
}
```

## Installation

```ruby
pod 'DDComponent'

# Optional: @PresenterState macro
pod 'DDComponent/Macros'
```

### Claude Code Plugin

This project ships with a [Claude Code](https://claude.com/claude-code) plugin that provides DDComponent-specific development skills and a code review Agent:

| Plugin Feature | Description |
|---|---|
| `ddcomponent` skill | Guides Claude Code to build pages following the Presenter tree architecture, lifecycle conventions, and Service/Notify communication patterns |
| `code-reviewer` Agent | Reviews DDComponent code for type correctness, state design, lifecycle usage, and logic consistency |

Run in Claude Code:

```bash
# Add GitHub marketplace
/plugin marketplace add djs66256/DDComponent

# Install the plugin
/plugin install ddcomponent@ddcomponent
```

## Documentation

| You want to... | Read this |
|----------------|-----------|
| Understand the framework design philosophy | [Architecture](./docs/en/architecture.md) |
| Build pages / lists / features | [Usage Guide](./docs/en/usage-guide.md) |
| Develop list cells | [Reusable Presenter](./docs/en/reusable-presenter.md) |
| Use the Hooks-style API | [use* API](./docs/en/use-methods.md) |
| Simplify state declarations | [@PresenterState Macro](./docs/en/presenter-state-macro.md) |
| Adapt for Swift 6 | [Swift 6 Concurrency Patterns](./docs/en/swift6-patterns.md) |
| Browse example code | [Demo Index](./docs/en/demo-index.md) |

**Documentation index**: [docs/en/README.md](./docs/en/README.md)

## Testing

The framework includes 122 unit tests covering all core capabilities. Tests are located in `Example/Tests/`.

```bash
cd Example
xcodebuild test -project DDComponent.xcodeproj -scheme DDComponent-Example -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Requirements

- iOS 13.0+
- Swift 5.7+
- Xcode 14.0+

## License

DDComponent is available under the MIT license. See the LICENSE file for more info.
