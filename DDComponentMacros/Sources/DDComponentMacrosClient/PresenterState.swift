/// `@PresenterState` simplifies state property declarations in `ViewPresenter` subclasses.
///
/// Given a stored property:
/// ```swift
/// @PresenterState
/// var count: Int = 0
/// ```
///
/// It expands to:
/// ```swift
/// var $count: Int = 0                    // backing storage (peer)
/// var count: Int {                       // computed property (accessor)
///     get { $count }
///     set { setState { $count = newValue } }
/// }
/// func setCount(_ newValue: Int,        // convenience method (peer)
///               context: (inout ViewUpdateContext) -> Void = { _ in },
///               completion: (() -> Void)? = nil) {
///     setState(updater: { $count = newValue }, context: context, completion: completion)
/// }
/// ```
///
/// If the original property has `willSet`/`didSet` observers, they are preserved
/// on the backing `$propertyName` storage.
@attached(peer, names: arbitrary)
@attached(accessor)
public macro PresenterState() = #externalMacro(
    module: "DDComponentMacros",
    type: "PresenterStateMacro"
)