# @PresenterState Macro

`@PresenterState` is a macro provided by DDComponentMacros that eliminates boilerplate code when defining state properties in Presenters.

## What problem does it solve?

In DDComponent, all state changes that affect the UI must go through `setState {}`. The traditional approach requires calling `setState` in the `didSet` of every state property:

```swift
// Traditional approach (didSet for every property)
class MyPresenter: ViewPresenter<MyViewProtocol> {
    private var count: Int = 0 {
        didSet { setState {} }
    }
    private var title: String = "" {
        didSet { setState {} }
    }
    private var isLoading: Bool = false {
        didSet { setState {} }
    }
}
```

`@PresenterState` automates this pattern:

```swift
// @PresenterState approach
class MyPresenter: ViewPresenter<MyViewProtocol> {
    @PresenterState var count: Int = 0
    @PresenterState var title: String = ""
    @PresenterState var isLoading: Bool = false
}
```

## Basic Usage

```swift
import DDComponent
import DDComponentMacrosClient

class MyPresenter: ViewPresenter<MyViewProtocol> {

    @PresenterState
    var count: Int = 0

    // Direct assignment → automatically triggers setState
    func increment() {
        count += 1  // Equivalent to setState { $count += 1 }
    }

    override func onUpdate(view: MyViewProtocol, context: ViewUpdateContext) {
        view.countLabel.text = "\(count)"
    }
}
```

## Generated Code

`@PresenterState var count: Int = 0` expands into three pieces of code:

```swift
// 1. Backing storage property (not directly accessible)
var $count: Int = 0

// 2. Computed property (publicly exposed, set auto-wraps setState)
var count: Int {
    get { $count }
    set { setState { $count = newValue } }
}

// 3. Convenience method (supports context configuration)
func setCount(
    _ newValue: Int,
    context: @escaping (inout ViewUpdateContext) -> Void = { _ in },
    completion: (() -> Void)? = nil
) {
    setState(
        updater: { $count = newValue },
        context: context,
        completion: completion
    )
}
```

## Using context to configure animations

Direct assignment uses the default context (no animation). When animation or layout refresh is needed, use the generated convenience method:

```swift
@PresenterState
var count: Int = 0

// Update with animation
setCount(count + 5) {
    $0.animated = true
    $0.invalidateLayout = true
}
```

## Comparison with traditional approach

| | Traditional `didSet` | `@PresenterState` |
|---|---|---|
| Code volume | 3 lines/property | 1 line/property |
| Animation support | `setState {} context: {}` | Generated `setXxx(_:context:)` method |
| Readability | `didSet` scattered everywhere | `@PresenterState` clear at a glance |
| Safety | Manual wrapping, easy to miss | Compile-time guarantee |

## Limitations

| Rule | Description |
|------|-------------|
| `var` only | Cannot be used with `let` (compile error) |
| Stored property only | Cannot be used with computed properties |
| Explicit type required | Must declare the type (e.g. `var count: Int = 0`), the compiler needs type information to generate code |

## Example

See Demo 12 for a complete example: `Example/DDComponent/Demos/12-PresenterState/`.

## Related Documentation

- [Usage Guide](./usage-guide.md) — Fixed views and list page development
- [Architecture](./architecture.md) — setState mechanism and UpdatePipeline
- [Swift 6 Concurrency Patterns](./swift6-patterns.md) — lazy var, MainActor
