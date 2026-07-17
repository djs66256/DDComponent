//
//  ViewPresenter+Use.swift
//  Pods
//
//  Created by daniel on 2025/1/9.
//
//  ## Design Philosophy
//
//  The `use*` methods follow a React Hooks-like pattern, centralizing state,
//  side effects, and view updaters at initialization time (in `init()` or as
//  property initializers).
//
//  In the traditional approach, state is scattered across multiple lifecycle
//  methods (`onBindView`, `onUpdate`, `onAttach`, etc.), leading to:
//  - Forgotten cleanup on detach → memory leaks
//  - State creation, binding, and teardown spread across different methods
//  - Implicit dependencies that are hard to debug
//
//  The `use*` pattern solves this by declaring all state and effects upfront.
//  Lifecycle management is automatic: subscriptions start on attach and are
//  cleaned up on detach.
//
//  ## Usage Rules
//
//  - **Must be called in `init()` or as a property initializer.** Do NOT call
//    `use*` methods inside `onBindView` or other lifecycle callbacks.
//  - The returned `State<T>`, `Effect`, or `Updater` should be stored as an
//    instance property (`let`).
//  - State changes automatically trigger `setState` → `onUpdate`. No manual
//    calls needed.
//
//  ## Initialization Order
//
//  All `use*` methods can be used as property initializers because `ViewPresenter`
//  initializes all of its stored properties with default values before subclass
//  property initializers run:
//
//  - `useState` — accesses `self.view` (nil during init) and calls `self.setState`
//    (which only sets a private flag). Does not mutate stored properties.
//  - `useEffect` — mutates `self.effects` (already initialized as `[]`).
//  - `useUpdate` — mutates `self.updaters` (already initialized as `[]`).
//
//  If you prefer to keep `init()` explicit, assign them there instead:
//
//  ```
//  class MyPresenter: ViewPresenter<MyView> {
//      let title: State<String>
//      let effect: Effect
//
//      override init() {
//          super.init()
//          title = useState("Hello")
//          effect = useEffect { /* ... */ return nil }
//      }
//  }
//  ```
//
//  ## Typical Usage (Property Initializers)
//
//  ```
//  class MyPresenter: ViewPresenter<MyView> {
//      // useState — safe as property initializer (does not mutate self)
//      let title = useState("Hello")
//      let viewModel = useState(MyViewModel())
//
//      // useEffect — safe as property initializer (self.effects is initialized)
//      let effect = useEffect {
//          // subscribe to external events
//          return { /* cleanup */ }
//      }
//
//      // useUpdate — safe as property initializer (self.updaters is initialized)
//      let update = useUpdate(dependences: title) { view, context in
//          view.label.text = title.value
//      }
//  }
//  ```
//

import Combine
import Foundation

// MARK: - State & Basic useState
//
// `State<T>` is the core reactive value container. Setting `state.value` triggers
// `setState` → `onUpdate` automatically, so the view stays in sync with the data.
//
// `useState` comes in three equality flavors, chosen by generic constraint:
// - `T: Equatable`  → uses `==` to skip no-op updates
// - `T: AnyObject`  → uses `===` (reference equality)
// - no constraint   → always triggers (for non-Equatable value types)
extension ViewPresenter {

    /// A reactive value container that triggers view update when `value` changes.
    ///
    /// Change detection is controlled by the `isEqual` closure. When `isEqual(old, new)`
    /// returns `false`, `willSet` and `didSet` are called, and the presenter's update
    /// pipeline is notified.
    public class State<T> {

        private var _value: T
        let isEqual: (T, T) -> Bool
        private let willSet: (@MainActor (_ oldValue: T, _ newValue: T) -> Void)?
        private var didSet: (@MainActor (_ oldValue: T, _ newValue: T) -> Void)?
        fileprivate var dispose: (@MainActor () -> Void)?

        fileprivate init(
            _ value: T,
            isEqual: @escaping (T, T) -> Bool,
            willSet: (@MainActor (T, T) -> Void)? = nil,
            didSet: (@MainActor (T, T) -> Void)? = nil,
            cancel: (@MainActor () -> Void)? = nil
        ) {
            self._value = value
            self.isEqual = isEqual
            self.willSet = willSet
            self.didSet = didSet
            self.dispose = cancel
        }

        @MainActor public var value: T {
            get { _value }
            set {
                let oldValue = _value
                if !isEqual(oldValue, newValue) {
                    willSet?(oldValue, newValue)
                    _value = newValue
                    didSet?(oldValue, newValue)
                }
            }
        }

        /// Cancel all subscriptions associated with this state. After calling,
        /// the state becomes inert — setting `value` will no longer trigger updates.
        @MainActor public func cancel() {
            if let dispose = self.dispose {
                self.dispose = nil
                dispose()
            }
        }

        func addAdditionalDidSet(_ additionalDidSet: @MainActor @escaping (_ oldValue: T, _ newValue: T) -> Void) {
            if let didSet = self.didSet {
                self.didSet = { oldValue, newValue in
                    didSet(oldValue, newValue)
                    additionalDidSet(oldValue, newValue)
                }
            } else {
                self.didSet = additionalDidSet
            }
        }

        func addAdditionalDispose(_ additionalDispose: @MainActor @escaping () -> Void) {
            if let dispose = self.dispose {
                self.dispose = {
                    dispose()
                    additionalDispose()
                }
            } else {
                self.dispose = additionalDispose
            }
        }

        deinit {
            if let dispose = self.dispose {
                performOnMainActorAsync {
                    dispose()
                }
            }
        }
    }

    // MARK: T: Equatable

    /// Create a reactive state for an `Equatable` value. No-op updates (where `old == new`)
    /// are skipped to avoid unnecessary view updates.
    ///
    /// Should be called in `init()` or as a property initializer.
    ///
    /// - Parameter initialValue: The initial value
    /// - Parameter willSet: Called on MainActor before the value changes
    /// - Parameter didSet: Called on MainActor after the value changes
    /// - Parameter context: Optional context passed to `setState` on each update
    /// - Returns: A `State` that triggers view update on value change
    public func useState<T>(
        _ initialValue: T,
        willSet: (@MainActor (_ oldValue: T, _ newValue: T) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: T, _ newValue: T) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil) -> State<T> where T: Equatable {
            if view != nil {
                setState(updater: {}, context: context)
            }
            return State(initialValue,
                         isEqual: { $0 == $1 },
                         willSet: willSet,
                         didSet: { [weak self] oldValue, newValue in
                didSet?(oldValue, newValue)
                guard let self else { return }
                self.setState(updater: {}, context: context)
            })
        }

    /// Create a reactive state for an optional `Equatable` value.
    ///
    /// - Parameter initialValue: The initial value, defaults to `nil`
    public func useState<T>(
        _ initialValue: T? = nil,
        willSet: (@MainActor (_ oldValue: T?, _ newValue: T?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: T?, _ newValue: T?) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil) -> State<T?> where T: Equatable {
            if view != nil {
                setState(updater: {}, context: context)
            }
            return State(initialValue,
                         isEqual: { $0 == $1 },
                         willSet: willSet,
                         didSet: { [weak self] oldValue, newValue in
                didSet?(oldValue, newValue)
                guard let self else { return }
                self.setState(updater: {}, context: context)
            })
        }

    // MARK: T: AnyObject

    /// Create a reactive state for a reference type. Uses `===` (reference equality)
    /// to skip no-op updates.
    ///
    /// - Parameter initialValue: The initial object reference
    public func useState<T>(
        _ initialValue: T,
        willSet: (@MainActor (_ oldValue: T, _ newValue: T) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: T, _ newValue: T) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil) -> State<T> where T: AnyObject {
            if view != nil {
                setState(updater: {}, context: context)
            }
            return State(initialValue,
                         isEqual: { $0 === $1 },
                         willSet: willSet,
                         didSet: { [weak self] oldValue, newValue in
                didSet?(oldValue, newValue)
                guard let self else { return }
                self.setState(updater: {}, context: context)
            })
        }

    /// Create a reactive state for an optional reference type.
    ///
    /// - Parameter initialValue: The initial object reference, defaults to `nil`
    public func useState<T>(
        _ initialValue: T? = nil,
        willSet: (@MainActor (_ oldValue: T?, _ newValue: T?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: T?, _ newValue: T?) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil) -> State<T?> where T: AnyObject {
            if view != nil {
                setState(updater: {}, context: context)
            }
            return State(initialValue, isEqual: { oldValue, newValue in
                if let newValue, let oldValue {
                    newValue === oldValue
                } else {
                    false
                }
            }, willSet: willSet, didSet: { [weak self] oldValue, newValue in
                didSet?(oldValue, newValue)
                guard let self else { return }
                self.setState(updater: {}, context: context)
            })
        }

    // MARK: Unconstrained (always triggers)

    /// Create a reactive state for any type without equality checking.
    /// Every assignment to `state.value` triggers a view update.
    ///
    /// Use this when the type is not `Equatable` and not a reference type.
    public func useState<T>(
        _ initialValue: T,
        willSet: (@MainActor (_ oldValue: T, _ newValue: T) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: T, _ newValue: T) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil) -> State<T> {
            if view != nil {
                setState(updater: {}, context: context)
            }
            return State(initialValue,
                         isEqual: { _, _ in false },
                         didSet: { [weak self] oldValue, newValue in
                didSet?(oldValue, newValue)
                guard let self else { return }
                self.setState(updater: {}, context: context)
            })
        }

    /// Create a reactive state for an optional value without equality checking.
    /// Every assignment to `state.value` triggers a view update.
    public func useState<T>(
        _ initialValue: T? = nil,
        willSet: (@MainActor (_ oldValue: T?, _ newValue: T?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: T?, _ newValue: T?) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil) -> State<T?> {
            if view != nil {
                setState(updater: {}, context: context)
            }
            return State(initialValue, isEqual: { _, _ in
                false
            }, didSet: { [weak self] oldValue, newValue in
                didSet?(oldValue, newValue)
                guard let self else { return }
                self.setState(updater: {}, context: context)
            })
        }

    // MARK: Deprecated (use useState with publisher/sequence overloads instead)
    // These are kept for backward compatibility. New code should use `useState`
    // with the `publisher:` or `sequence:` parameter instead.

    @available(*, deprecated, message: "Use useState instead")
    public func useStream<T, S>(
        _ initialValue: T,
        willSet: (@MainActor (_ oldValue: T, _ newValue: T) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: T, _ newValue: T) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        _ steam: S) -> State<T> where S: AsyncSequence, S.Element == T {
            var state = useState(initialValue, willSet: willSet, didSet: didSet, context: context)
            let task = Task { @MainActor [weak state] in
                do {
                    for try await value in steam {
                        guard let state else { return }
                        try Task.checkCancellation()
                        state.value = value
                    }
                } catch {}
            }
            state.addAdditionalDispose { task.cancel() }
            return state
        }

    @available(*, deprecated, message: "Use useState instead")
    public func useStream<T, S>(
        _ initialValue: T? = nil,
        willSet: (@MainActor (_ oldValue: T?, _ newValue: T?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: T?, _ newValue: T?) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        _ steam: S) -> State<T?> where S: AsyncSequence, S.Element == T {
            var state = useState(initialValue, willSet: willSet, didSet: didSet, context: context)
            let task = Task { @MainActor [weak state] in
                do {
                    for try await value in steam {
                        guard let state else { return }
                        try Task.checkCancellation()
                        state.value = value
                    }
                } catch {}
            }
            state.addAdditionalDispose { task.cancel() }
            return state
        }

    @available(*, deprecated, message: "Use useState instead")
    public func useSubscriber<T, P>(
        _ initialValue: T,
        willSet: (@MainActor (_ oldValue: T, _ newValue: T) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: T, _ newValue: T) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        _ publisher: P) -> State<T> where P: Publisher, P.Output == T {
            var state = useState(initialValue, willSet: willSet, didSet: didSet, context: context)
            let cancel = publisher.sink { _ in

            } receiveValue: { [weak state] value in
                guard let state else { return }
                performOnMainActorAsync {
                    state.value = value
                }
            }
            state.addAdditionalDispose { cancel.cancel() }
            return state
        }

    @available(*, deprecated, message: "Use useState instead")
    public func useSubscriber<T, P>(
        _ initialValue: T? = nil,
        willSet: (@MainActor (_ oldValue: T?, _ newValue: T?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: T?, _ newValue: T?) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        _ publisher: P) -> State<T?> where P: Publisher, P.Output == T {
            var state = useState(initialValue, willSet: willSet, didSet: didSet, context: context)
            let cancel = publisher.sink { _ in

            } receiveValue: { [weak state] value in
                guard let state else { return }
                performOnMainActorAsync {
                    state.value = value
                }
            }
            state.addAdditionalDispose { cancel.cancel() }
            return state
        }
}

// MARK: - useUpdate
//
// `useUpdate` registers an updater closure that runs during `onUpdate` whenever
// its dependent `State` values change. The updater receives the view and context
// directly, so you can update the view without storing state in the presenter.
//
// Use `useUpdate(dependences:)` (with one or more states) for dependency-driven
// updates — the updater only runs when at least one dependency has changed.
extension ViewPresenter {

    /// Register an updater that runs on every `onUpdate`. The updater is called
    /// regardless of which state changed — use `useUpdate(dependences:)` for
    /// dependency-driven updates.
    ///
    /// - Returns: An `Updater` that can be cancelled via `.cancel()`
    @discardableResult
    @MainActor public func useUpdate(
        _ updater: @escaping @MainActor (_ view: View, _ context: ViewUpdateContext) -> Void
    ) -> Updater {
        let anyUpdater = Updater(updater: updater)
        self.updaters.append(anyUpdater)

        anyUpdater.dispose = { [weak self, weak anyUpdater] in
            guard let self, let anyUpdater else { return }
            self.updaters.removeAll { $0 === anyUpdater }
        }

        return anyUpdater
    }

    // MARK: useUpdate with dependencies
    //
    // Dependency-driven updaters. The updater only runs when at least one of the
    // dependent `State` values has changed since the last update cycle.
    //
    // In Swift 6+, a variadic generic overload handles any number of dependencies.
    // Below Swift 6, individual overloads are provided for 1–9 dependencies.
#if swift(>=6)
    @discardableResult
    @MainActor public func useUpdate<each T>(
        dependences: repeat State<each T>,
        updater: @escaping @MainActor (_ view: View, _ context: ViewUpdateContext) -> Void
    ) -> Updater {
        var isChanged = true
        for dependence in repeat each dependences {
            dependence.addAdditionalDidSet { _, _ in
                isChanged = true
            }
        }
        return useUpdate { view, context in
            if isChanged {
                isChanged = false
                updater(view, context)
            }
        }
    }
#else
    @discardableResult
    @MainActor public func useUpdate<T>(
        dependences dep1: State<T>,
        updater: @escaping @MainActor (_ view: View, _ context: ViewUpdateContext) -> Void
    ) -> Updater {
        var isChanged = true
        dep1.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        return useUpdate { view, context in
            if isChanged {
                isChanged = false
                updater(view, context)
            }
        }
    }
    @discardableResult
    @MainActor public func useUpdate<T1, T2>(
        dependences dep1: State<T1>,
        _ dep2: State<T2>,
        updater: @escaping @MainActor (_ view: View, _ context: ViewUpdateContext) -> Void
    ) -> Updater {
        var isChanged = true
        dep1.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep2.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        return useUpdate { view, context in
            if isChanged {
                isChanged = false
                updater(view, context)
            }
        }
    }
    @discardableResult
    @MainActor public func useUpdate<T1, T2, T3>(
        dependences dep1: State<T1>,
        _ dep2: State<T2>,
        _ dep3: State<T3>,
        updater: @escaping @MainActor (_ view: View, _ context: ViewUpdateContext) -> Void
    ) -> Updater {
        var isChanged = true
        dep1.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep2.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep3.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        return useUpdate { view, context in
            if isChanged {
                isChanged = false
                updater(view, context)
            }
        }
    }
    @discardableResult
    @MainActor public func useUpdate<T1, T2, T3, T4>(
        dependences dep1: State<T1>,
        _ dep2: State<T2>,
        _ dep3: State<T3>,
        _ dep4: State<T4>,
        updater: @escaping @MainActor (_ view: View, _ context: ViewUpdateContext) -> Void
    ) -> Updater {
        var isChanged = true
        dep1.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep2.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep3.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep4.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        return useUpdate { view, context in
            if isChanged {
                isChanged = false
                updater(view, context)
            }
        }
    }
    @discardableResult
    @MainActor public func useUpdate<T1, T2, T3, T4, T5>(
        dependences dep1: State<T1>,
        _ dep2: State<T2>,
        _ dep3: State<T3>,
        _ dep4: State<T4>,
        _ dep5: State<T5>,
        updater: @escaping @MainActor (_ view: View, _ context: ViewUpdateContext) -> Void
    ) -> Updater {
        var isChanged = true
        dep1.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep2.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep3.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep4.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep5.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        return useUpdate { view, context in
            if isChanged {
                isChanged = false
                updater(view, context)
            }
        }
    }
    @discardableResult
    @MainActor public func useUpdate<T1, T2, T3, T4, T5, T6>(
        dependences dep1: State<T1>,
        _ dep2: State<T2>,
        _ dep3: State<T3>,
        _ dep4: State<T4>,
        _ dep5: State<T5>,
        _ dep6: State<T6>,
        updater: @escaping @MainActor (_ view: View, _ context: ViewUpdateContext) -> Void
    ) -> Updater {
        var isChanged = true
        dep1.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep2.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep3.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep4.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep5.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep6.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        return useUpdate { view, context in
            if isChanged {
                isChanged = false
                updater(view, context)
            }
        }
    }
    @discardableResult
    @MainActor public func useUpdate<T1, T2, T3, T4, T5, T6, T7>(
        dependences dep1: State<T1>,
        _ dep2: State<T2>,
        _ dep3: State<T3>,
        _ dep4: State<T4>,
        _ dep5: State<T5>,
        _ dep6: State<T6>,
        _ dep7: State<T7>,
        updater: @escaping @MainActor (_ view: View, _ context: ViewUpdateContext) -> Void
    ) -> Updater {
        var isChanged = true
        dep1.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep2.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep3.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep4.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep5.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep6.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep7.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        return useUpdate { view, context in
            if isChanged {
                isChanged = false
                updater(view, context)
            }
        }
    }
    @discardableResult
    @MainActor public func useUpdate<T1, T2, T3, T4, T5, T6, T7, T8>(
        dependences dep1: State<T1>,
        _ dep2: State<T2>,
        _ dep3: State<T3>,
        _ dep4: State<T4>,
        _ dep5: State<T5>,
        _ dep6: State<T6>,
        _ dep7: State<T7>,
        _ dep8: State<T8>,
        updater: @escaping @MainActor (_ view: View, _ context: ViewUpdateContext) -> Void
    ) -> Updater {
        var isChanged = true
        dep1.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep2.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep3.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep4.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep5.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep6.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep7.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep8.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        return useUpdate { view, context in
            if isChanged {
                isChanged = false
                updater(view, context)
            }
        }
    }
    @discardableResult
    @MainActor public func useUpdate<T1, T2, T3, T4, T5, T6, T7, T8, T9>(
        dependences dep1: State<T1>,
        _ dep2: State<T2>,
        _ dep3: State<T3>,
        _ dep4: State<T4>,
        _ dep5: State<T5>,
        _ dep6: State<T6>,
        _ dep7: State<T7>,
        _ dep8: State<T8>,
        _ dep9: State<T9>,
        updater: @escaping @MainActor (_ view: View, _ context: ViewUpdateContext) -> Void
    ) -> Updater {
        var isChanged = true
        dep1.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep2.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep3.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep4.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep5.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep6.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep7.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep8.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        dep9.addAdditionalDidSet { _, _ in
            isChanged = true
        }
        return useUpdate { view, context in
            if isChanged {
                isChanged = false
                updater(view, context)
            }
        }
    }
#endif

    // MARK: useState with updater / keyPath
    //
    // Convenience overloads that combine state creation with view binding.
    // `updater` is called on every state change with the value, view, and context.
    // `updateTo` writes the value directly to a view key path.

    /// Create a state and bind it to a custom updater. The updater runs on every
    /// state change, receiving the latest value, view, and context.
    ///
    /// ```
    /// let title = useState("Hello") { value, view, context in
    ///     view.label.text = value
    /// }
    /// ```
    @MainActor public func useState<T>(
        _ initialValue: T,
        willSet: (@MainActor (_ oldValue: T, _ newValue: T) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: T, _ newValue: T) -> Void)? = nil,
        updater: @escaping @MainActor (_ value: T, _ view: View, _ context: ViewUpdateContext) -> Void,
        context: ((inout ViewUpdateContext)->Void)? = nil) -> State<T> {
            let state = useState(initialValue, willSet: willSet, didSet: didSet, context: context)
            let up = useUpdate(dependences: state) { [weak state] view, context in
                if let state {
                    updater(state.value, view, context)
                }
            }
            state.addAdditionalDispose {
                up.cancel()
            }

            return state
        }

    /// Create an optional state and bind it to a custom updater.
    @MainActor public func useState<T>(
        _ initialValue: T? = nil,
        willSet: (@MainActor (_ oldValue: T?, _ newValue: T?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: T?, _ newValue: T?) -> Void)? = nil,
        updater: @escaping @MainActor (_ value: T?, _ view: View, _ context: ViewUpdateContext) -> Void,
        context: ((inout ViewUpdateContext)->Void)? = nil) -> State<T?> {
            let state = useState(initialValue, willSet: willSet, didSet: didSet, context: context)
            let up = useUpdate(dependences: state) { [weak state] view, context in
                if let state {
                    updater(state.value, view, context)
                }
            }
            state.addAdditionalDispose {
                up.cancel()
            }
            return state
        }

    /// Create a state and write its value directly to a view key path on every change.
    ///
    /// ```
    /// let title = useState("Hello", updateTo: \.label.text)
    /// ```
    @MainActor public func useState<T>(
        _ initialValue: T,
        willSet: (@MainActor (_ oldValue: T, _ newValue: T) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: T, _ newValue: T) -> Void)? = nil,
        updateTo keyPath: WritableKeyPath<View, T>,
        context: ((inout ViewUpdateContext)->Void)? = nil) -> State<T> where View: AnyObject {
            return useState(
                initialValue,
                willSet: willSet,
                didSet: didSet,
                updater: { value, view, _ in
                    var view = view
                    view[keyPath: keyPath] = value
                },
                context: context)
        }

    /// Create an optional state and write its value directly to a view key path on every change.
    @MainActor public func useState<T>(
        _ initialValue: T? = nil,
        willSet: (@MainActor (_ oldValue: T?, _ newValue: T?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: T?, _ newValue: T?) -> Void)? = nil,
        updateTo keyPath: WritableKeyPath<View, T?>,
        context: ((inout ViewUpdateContext)->Void)? = nil) -> State<T?> where View: AnyObject {
            return useState(
                initialValue,
                willSet: willSet,
                didSet: didSet,
                updater: { value, view, _ in
                    var view = view
                    view[keyPath: keyPath] = value
                },
                context: context)
        }
}

// MARK: - useEffect / useService
//
// `useEffect` manages side effects that are tied to the presenter's lifecycle.
// The action runs when the presenter attaches to a root, and the returned
// cleanup closure runs when it detaches.
//
// `useService` is a convenience wrapper that resolves a service from the
// presenter tree and passes it to the effect action.
extension ViewPresenter {

    /// Register a side effect tied to the presenter's lifecycle.
    ///
    /// The action runs on attach to root. Return a cleanup closure (or nil) to
    /// run on detach. The effect is automatically cancelled when the presenter
    /// is deallocated.
    ///
    /// ```
    /// let effect = useEffect {
    ///     let observer = NotificationCenter.default.addObserver(...)
    ///     return {
    ///         NotificationCenter.default.removeObserver(observer)
    ///     }
    /// }
    /// ```
    ///
    /// - Returns: An `Effect` that can be cancelled via `.cancel()`
    @discardableResult
    @MainActor public func useEffect(_ action: @escaping @MainActor () -> (@MainActor () -> Void)?) -> Effect {
        let effect = Effect {
            return action()
        }

        effect.dispose = { [weak self, weak effect] in
            guard let self else { return }
            self.effects.removeAll(where: { $0 === effect })
        }

        self.effects.append(effect)

        if hasAttachedRoot {
            effect.onAttach()
        }

        return effect
    }

    /// Register a side effect without cleanup. Equivalent to `useEffect { action(); return nil }`.
    @discardableResult
    @MainActor public func useEffect(_ action: @escaping @MainActor () -> Void) -> Effect {
        return useEffect {
            action()
            return nil
        }
    }

    /// Register a side effect that depends on a service resolved from the presenter tree.
    /// The service is looked up lazily when the presenter attaches to a root.
    ///
    /// ```
    /// useService(MyService.self) { service in
    ///     service.doSomething()
    ///     return {
    ///         service.cleanup()
    ///     }
    /// }
    /// ```
    @discardableResult
    @MainActor public func useService<ServieType>(
        _ service: ServieType.Type,
        _ action: @escaping @MainActor (ServieType) -> (@MainActor () -> Void)?) -> Effect {
            useEffect { [weak self] in
                if let service = self?.getService(service) {
                    return action(service)
                }
                return nil
            }
        }
}

// MARK: - Observe by AsyncSequence
//
// These `useState` overloads bind an `AsyncSequence` (e.g., an `AsyncStream`,
// `AsyncMapSequence`, or custom async sequence) to a `State`. Each value from
// the sequence is written to `state.value`, triggering view updates.
//
// Two variants: via a `Service` (resolved from the presenter tree) or directly
// from an `AsyncSequence` instance.
extension ViewPresenter {

    /// Subscribe to an async sequence obtained from a service. The sequence is
    /// resolved lazily when the presenter attaches to a root.
    fileprivate func observeStateUsingAsyncSequence<ValueType, ServiceType, SequenceType>(
        _ service: ServiceType.Type,
        _ state: State<ValueType>,
        _ getStream: @escaping @MainActor (ServiceType) async throws -> SequenceType)
    where SequenceType: AsyncSequence, SequenceType.Element == ValueType {
        let effect = useService(service) { [weak state] serv in
            let task = Task {
                do {
                    let stream = try await getStream(serv)
                    try await Task.checkCancellation()
                    for try await value in stream {
                        guard let state else { return }
                        state.value = value
                    }
                } catch {}
            }
            return { task.cancel() }
        }

        state.addAdditionalDispose {
            effect.cancel()
        }
    }

    public func useState<ValueType, ServiceType, SequenceType>(
        _ initialValue: ValueType,
        willSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        service: ServiceType.Type,
        sequence: @escaping @MainActor (ServiceType) async throws -> SequenceType) -> State<ValueType>
    where SequenceType: AsyncSequence, SequenceType.Element == ValueType {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, context: context)

        observeStateUsingAsyncSequence(service, state, sequence)

        return state
    }

    public func useState<ValueType, ServiceType, SequenceType>(
        _ initialValue: ValueType? = nil,
        willSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        service: ServiceType.Type,
        sequence: @escaping @MainActor (ServiceType) async throws -> SequenceType) -> State<ValueType?>
    where SequenceType: AsyncSequence, SequenceType.Element == ValueType? {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, context: context)

        observeStateUsingAsyncSequence(service, state, sequence)

        return state
    }

    public func useState<ValueType, ServiceType, SequenceType>(
        _ initialValue: ValueType,
        willSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        updater: @escaping @MainActor (_ value: ValueType, _ view: View, _ context: ViewUpdateContext) -> Void,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        service: ServiceType.Type,
        sequence: @escaping @MainActor (ServiceType) async throws -> SequenceType) -> State<ValueType>
    where SequenceType: AsyncSequence, SequenceType.Element == ValueType {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, updater: updater, context: context)

        observeStateUsingAsyncSequence(service, state, sequence)

        return state
    }

    public func useState<ValueType, ServiceType, SequenceType>(
        _ initialValue: ValueType? = nil,
        willSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        updater: @escaping @MainActor (_ value: ValueType?, _ view: View, _ context: ViewUpdateContext) -> Void,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        service: ServiceType.Type,
        sequence: @escaping @MainActor (ServiceType) async throws -> SequenceType) -> State<ValueType?>
    where SequenceType: AsyncSequence, SequenceType.Element == ValueType? {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, updater: updater, context: context)

        observeStateUsingAsyncSequence(service, state, sequence)

        return state
    }

    public func useState<ValueType, ServiceType, SequenceType>(
        _ initialValue: ValueType,
        willSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        updateTo keyPath: WritableKeyPath<View, ValueType>,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        service: ServiceType.Type,
        sequence: @escaping @MainActor (ServiceType) async throws -> SequenceType) -> State<ValueType>
    where SequenceType: AsyncSequence, SequenceType.Element == ValueType, View: AnyObject {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, updateTo: keyPath, context: context)

        observeStateUsingAsyncSequence(service, state, sequence)

        return state
    }

    public func useState<ValueType, ServiceType, SequenceType>(
        _ initialValue: ValueType? = nil,
        willSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        updateTo keyPath: WritableKeyPath<View, ValueType?>,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        service: ServiceType.Type,
        sequence: @escaping @MainActor (ServiceType) async throws -> SequenceType) -> State<ValueType?>
    where SequenceType: AsyncSequence, SequenceType.Element == ValueType?, View: AnyObject {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, updateTo: keyPath, context: context)

        observeStateUsingAsyncSequence(service, state, sequence)

        return state
    }

    fileprivate func observeStateUsingAsyncSequence<ValueType, SequenceType>(
        _ state: State<ValueType>,
        _ stream: SequenceType)
    where SequenceType: AsyncSequence, SequenceType.Element == ValueType {
        let task = Task { [weak state] in
            do {
                try await Task.checkCancellation()
                for try await value in stream {
                    guard let state else { return }
                    state.value = value
                }
            } catch {}
        }

        state.addAdditionalDispose {
            task.cancel()
        }
    }

    public func useState<ValueType, SequenceType>(
        _ initialValue: ValueType,
        willSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        sequence: SequenceType) -> State<ValueType>
    where SequenceType: AsyncSequence, SequenceType.Element == ValueType {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, context: context)

        observeStateUsingAsyncSequence(state, sequence)

        return state
    }
    public func useState<ValueType, SequenceType>(
        _ initialValue: ValueType? = nil,
        willSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        sequence: SequenceType) -> State<ValueType?>
    where SequenceType: AsyncSequence, SequenceType.Element == ValueType? {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, context: context)

        observeStateUsingAsyncSequence(state, sequence)

        return state
    }

    public func useState<ValueType, SequenceType>(
        _ initialValue: ValueType,
        willSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        updater: @escaping @MainActor (_ value: ValueType, _ view: View, _ context: ViewUpdateContext) -> Void,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        sequence: SequenceType) -> State<ValueType>
    where SequenceType: AsyncSequence, SequenceType.Element == ValueType {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, updater: updater, context: context)

        observeStateUsingAsyncSequence(state, sequence)

        return state
    }

    public func useState<ValueType, SequenceType>(
        _ initialValue: ValueType? = nil,
        willSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        updater: @escaping @MainActor (_ value: ValueType?, _ view: View, _ context: ViewUpdateContext) -> Void,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        sequence: SequenceType) -> State<ValueType?>
    where SequenceType: AsyncSequence, SequenceType.Element == ValueType? {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, updater: updater, context: context)

        observeStateUsingAsyncSequence(state, sequence)

        return state
    }

    public func useState<ValueType, SequenceType>(
        _ initialValue: ValueType,
        willSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        updateTo keyPath: WritableKeyPath<View, ValueType>,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        sequence: SequenceType) -> State<ValueType>
    where SequenceType: AsyncSequence, SequenceType.Element == ValueType, View: AnyObject {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, updateTo: keyPath, context: context)

        observeStateUsingAsyncSequence(state, sequence)

        return state
    }

    public func useState<ValueType, SequenceType>(
        _ initialValue: ValueType? = nil,
        willSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        updateTo keyPath: WritableKeyPath<View, ValueType?>,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        sequence: SequenceType) -> State<ValueType?>
    where SequenceType: AsyncSequence, SequenceType.Element == ValueType?, View: AnyObject {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, updateTo: keyPath, context: context)

        observeStateUsingAsyncSequence(state, sequence)

        return state
    }
}

// MARK: - Observe by Publisher
//
// These `useState` overloads bind a Combine `Publisher` to a `State`. Each
// published value is written to `state.value`, triggering view updates.
//
// Two variants: via a `Service` (resolved from the presenter tree) or directly
// from a `Publisher` instance.
extension ViewPresenter {

    /// Subscribe to a publisher obtained from a service. The publisher is
    /// resolved lazily when the presenter attaches to a root.
    fileprivate func observeStateUsingPublisher<ValueType, ServiceType, PublisherType>(
        _ service: ServiceType.Type,
        _ state: State<ValueType>,
        _ getPublisher: @escaping @MainActor (ServiceType) throws -> PublisherType)
    where PublisherType: Publisher, PublisherType.Output == ValueType {
        let effect = useService(service) { [weak state] serv in
            do {
                let publisher = try getPublisher(serv)
                let cancel = publisher.receive(on: RunLoop.main).sink { _ in } receiveValue: { [weak state] in
                    state?.value = $0
                }

                return { cancel.cancel() }
            } catch {
                return {}
            }
        }

        state.addAdditionalDispose {
            effect.cancel()
        }
    }

    public func useState<ValueType, ServiceType, PublisherType>(
        _ initialValue: ValueType,
        willSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        service: ServiceType.Type,
        publisher: @escaping @MainActor (ServiceType) throws -> PublisherType) -> State<ValueType>
    where PublisherType: Publisher, PublisherType.Output == ValueType {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, context: context)

        observeStateUsingPublisher(service, state, publisher)

        return state
    }

    public func useState<ValueType, ServiceType, PublisherType>(
        _ initialValue: ValueType? = nil,
        willSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        service: ServiceType.Type,
        publisher: @escaping @MainActor (ServiceType) throws -> PublisherType) -> State<ValueType?>
    where PublisherType: Publisher, PublisherType.Output == ValueType? {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, context: context)

        observeStateUsingPublisher(service, state, publisher)

        return state
    }

    public func useState<ValueType, ServiceType, PublisherType>(
        _ initialValue: ValueType,
        willSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        updater: @escaping @MainActor (_ value: ValueType, _ view: View, _ context: ViewUpdateContext) -> Void,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        service: ServiceType.Type,
        publisher: @escaping @MainActor (ServiceType) throws -> PublisherType) -> State<ValueType>
    where PublisherType: Publisher, PublisherType.Output == ValueType {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, updater: updater, context: context)

        observeStateUsingPublisher(service, state, publisher)

        return state
    }

    public func useState<ValueType, ServiceType, PublisherType>(
        _ initialValue: ValueType? = nil,
        willSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        updater: @escaping @MainActor (_ value: ValueType?, _ view: View, _ context: ViewUpdateContext) -> Void,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        service: ServiceType.Type,
        publisher: @escaping @MainActor (ServiceType) throws -> PublisherType) -> State<ValueType?>
    where PublisherType: Publisher, PublisherType.Output == ValueType? {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, updater: updater, context: context)

        observeStateUsingPublisher(service, state, publisher)

        return state
    }

    public func useState<ValueType, ServiceType, PublisherType>(
        _ initialValue: ValueType,
        willSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        updateTo keyPath: WritableKeyPath<View, ValueType>,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        service: ServiceType.Type,
        publisher: @escaping @MainActor (ServiceType) throws -> PublisherType) -> State<ValueType>
    where PublisherType: Publisher, PublisherType.Output == ValueType, View: AnyObject {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, updateTo: keyPath, context: context)

        observeStateUsingPublisher(service, state, publisher)

        return state
    }

    public func useState<ValueType, ServiceType, PublisherType>(
        _ initialValue: ValueType? = nil,
        willSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        updateTo keyPath: WritableKeyPath<View, ValueType?>,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        service: ServiceType.Type,
        publisher: @escaping @MainActor (ServiceType) throws -> PublisherType) -> State<ValueType?>
    where PublisherType: Publisher, PublisherType.Output == ValueType?, View: AnyObject {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, updateTo: keyPath, context: context)

        observeStateUsingPublisher(service, state, publisher)

        return state
    }


    // MARK: -

    fileprivate func observeStateUsingPublisher<ValueType, PublisherType>(
        _ state: State<ValueType>,
        _ publisher: PublisherType)
    where PublisherType: Publisher, PublisherType.Output == ValueType {
        let cancel = publisher.receive(on: RunLoop.main).sink { _ in } receiveValue: { [weak state] in
            state?.value = $0
        }

        state.addAdditionalDispose {
            cancel.cancel()
        }
    }

    public func useState<ValueType, PublisherType>(
        _ initialValue: ValueType,
        willSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        publisher: PublisherType) -> State<ValueType>
    where PublisherType: Publisher, PublisherType.Output == ValueType {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, context: context)

        observeStateUsingPublisher(state, publisher)

        return state
    }

    public func useState<ValueType, PublisherType>(
        _ initialValue: ValueType? = nil,
        willSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        publisher: PublisherType) -> State<ValueType?>
    where PublisherType: Publisher, PublisherType.Output == ValueType? {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, context: context)

        observeStateUsingPublisher(state, publisher)

        return state
    }

    public func useState<ValueType, PublisherType>(
        _ initialValue: ValueType,
        willSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        updater: @escaping @MainActor (_ value: ValueType, _ view: View, _ context: ViewUpdateContext) -> Void,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        publisher: PublisherType) -> State<ValueType>
    where PublisherType: Publisher, PublisherType.Output == ValueType {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, updater: updater, context: context)

        observeStateUsingPublisher(state, publisher)

        return state
    }

    public func useState<ValueType, PublisherType>(
        _ initialValue: ValueType? = nil,
        willSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        updater: @escaping @MainActor (_ value: ValueType?, _ view: View, _ context: ViewUpdateContext) -> Void,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        publisher: PublisherType) -> State<ValueType?>
    where PublisherType: Publisher, PublisherType.Output == ValueType? {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, updater: updater, context: context)

        observeStateUsingPublisher(state, publisher)

        return state
    }

    public func useState<ValueType, PublisherType>(
        _ initialValue: ValueType,
        willSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType, _ newValue: ValueType) -> Void)? = nil,
        updateTo keyPath: WritableKeyPath<View, ValueType>,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        publisher: PublisherType) -> State<ValueType>
    where PublisherType: Publisher, PublisherType.Output == ValueType, View: AnyObject {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, updateTo: keyPath, context: context)

        observeStateUsingPublisher(state, publisher)

        return state
    }

    public func useState<ValueType, PublisherType>(
        _ initialValue: ValueType? = nil,
        willSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        didSet: (@MainActor (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void)? = nil,
        updateTo keyPath: WritableKeyPath<View, ValueType?>,
        context: ((inout ViewUpdateContext)->Void)? = nil,
        publisher: PublisherType) -> State<ValueType?>
    where PublisherType: Publisher, PublisherType.Output == ValueType?, View: AnyObject {
        let state = useState(initialValue, willSet: willSet, didSet: didSet, updateTo: keyPath, context: context)

        observeStateUsingPublisher(state, publisher)

        return state
    }
}

// MARK: - Observe ObservableObject
//
// `ObservableObject` is the standard Combine protocol for observable models.
// Its `objectWillChange` publisher emits **before** any `@Published` property changes,
// which maps naturally to DDComponent's update model:
//
//   objectWillChange → setState(updater: {}) → mark dirty → onUpdate reads latest values
//
// The subscription is managed via `useEffect`, so it auto-cancels when the presenter
// detaches from its root. Replacing the object via `state.value = newObject` cancels
// the old subscription and binds the new one automatically.
extension ViewPresenter {

    // MARK: Basic

    /// Observe an `ObservableObject`, triggering view update on every `objectWillChange`.
    ///
    /// The returned `State<O>` wraps the object. Read properties from `state.value` in
    /// your `onUpdate` or `useUpdate` — by then the values reflect the latest change.
    ///
    /// ```
    /// class MyPresenter: ViewPresenter<MyView> {
    ///     let viewModel = useState(MyViewModel())
    ///
    ///     override func onUpdate(view: MyView, context: ViewUpdateContext) {
    ///         view.label.text = viewModel.value.title
    ///     }
    ///
    ///     func refresh() {
    ///         viewModel.value = NewViewModel() // old subscription auto-cancelled
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter object: The `ObservableObject` to observe
    /// - Parameter context: Optional context to pass to `setState` on each update
    /// - Returns: A `State` wrapping the object. Replace via `state.value` to re-bind.
    @MainActor public func useState<O: ObservableObject>(
        _ object: O,
        context: ((inout ViewUpdateContext)->Void)? = nil) -> State<O> {
        if view != nil {
            setState(updater: {}, context: context)
        }

        var cancellable: AnyCancellable?

        let state = State<O>(
            object,
            isEqual: { $0 === $1 },
            willSet: { _, _ in
                // Cancel old subscription before replacing the object
                cancellable?.cancel()
            },
            didSet: { [weak self] _, newValue in
                guard let self else { return }
                // Bind new object's objectWillChange to setState
                cancellable = newValue.objectWillChange
                    .receive(on: RunLoop.main)
                    .sink { [weak self] _ in
                        self?.setState(updater: {}, context: context)
                    }
                self.setState(updater: {}, context: context)
            }
        )

        // Initial subscription for the first object
        cancellable = object.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.setState(updater: {}, context: context)
            }

        state.addAdditionalDispose {
            cancellable?.cancel()
        }

        return state
    }

    /// Observe an optional `ObservableObject`, triggering view update on every `objectWillChange`.
    ///
    /// Set `state.value = nil` to unsubscribe, or `state.value = newObject` to replace
    /// (old subscription is auto-cancelled). When `nil`, no update is triggered.
    ///
    /// ```
    /// let viewModel = useState(Optional<MyViewModel>(nil))
    ///
    /// viewModel.value = MyViewModel()  // subscribe + trigger update
    /// viewModel.value = nil            // unsubscribe + trigger update
    /// ```
    ///
    /// - Parameter object: The optional `ObservableObject` to observe
    /// - Parameter context: Optional context to pass to `setState` on each update
    /// - Returns: A `State` wrapping the optional object.
    @MainActor public func useState<O: ObservableObject>(
        _ object: O?,
        context: ((inout ViewUpdateContext)->Void)? = nil) -> State<O?> {
        if view != nil {
            setState(updater: {}, context: context)
        }

        var cancellable: AnyCancellable?

        let state = State<O?>(
            object,
            isEqual: { oldValue, newValue in
                if let oldValue, let newValue {
                    return oldValue === newValue
                } else {
                    return oldValue == nil && newValue == nil
                }
            },
            willSet: { _, _ in
                // Cancel old subscription before replacing the object
                cancellable?.cancel()
            },
            didSet: { [weak self] _, newValue in
                guard let self else { return }
                // Only subscribe if the new value is non-nil
                if let newValue {
                    cancellable = newValue.objectWillChange
                        .receive(on: RunLoop.main)
                        .sink { [weak self] _ in
                            self?.setState(updater: {}, context: context)
                        }
                }
                self.setState(updater: {}, context: context)
            }
        )

        // Initial subscription — only if the first object is non-nil
        if let object {
            cancellable = object.objectWillChange
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    self?.setState(updater: {}, context: context)
                }
        }

        state.addAdditionalDispose {
            cancellable?.cancel()
        }

        return state
    }

    // MARK: With updater

    /// Observe an `ObservableObject` with a custom updater that runs on each change.
    ///
    /// ```
    /// useState(viewModel) { value, view, context in
    ///     view.titleLabel.text = value.title
    ///     view.detailLabel.text = value.detail
    /// }
    /// ```
    ///
    /// - Parameter object: The `ObservableObject` to observe
    /// - Parameter updater: Called on each `objectWillChange` with the latest value and view
    /// - Parameter context: Optional context to pass to `setState` on each update
    /// - Returns: A `State` wrapping the object.
    @MainActor public func useState<O: ObservableObject>(
        _ object: O,
        updater: @escaping @MainActor (_ value: O, _ view: View, _ context: ViewUpdateContext) -> Void,
        context: ((inout ViewUpdateContext)->Void)? = nil) -> State<O> {
        let state = useState(object, context: context)
        let up = useUpdate(dependences: state) { [weak state] view, ctx in
            if let state {
                updater(state.value, view, ctx)
            }
        }
        state.addAdditionalDispose {
            up.cancel()
        }
        return state
    }

    /// Observe an optional `ObservableObject` with a custom updater that runs on each change.
    ///
    /// - Parameter object: The optional `ObservableObject` to observe
    /// - Parameter updater: Called on each `objectWillChange` with the latest value (nil if unset) and view
    /// - Parameter context: Optional context to pass to `setState` on each update
    /// - Returns: A `State` wrapping the optional object.
    @MainActor public func useState<O: ObservableObject>(
        _ object: O?,
        updater: @escaping @MainActor (_ value: O?, _ view: View, _ context: ViewUpdateContext) -> Void,
        context: ((inout ViewUpdateContext)->Void)? = nil) -> State<O?> {
        let state = useState(object, context: context)
        let up = useUpdate(dependences: state) { [weak state] view, ctx in
            if let state {
                updater(state.value, view, ctx)
            }
        }
        state.addAdditionalDispose {
            up.cancel()
        }
        return state
    }

    // MARK: With keyPath

    /// Observe an `ObservableObject` and write its value directly to a view's key path on each change.
    ///
    /// ```
    /// useState(viewModel, updateTo: \.titleLabel.text)
    /// ```
    ///
    /// - Parameter object: The `ObservableObject` to observe
    /// - Parameter keyPath: The view's key path to update with the object's value
    /// - Parameter context: Optional context to pass to `setState` on each update
    /// - Returns: A `State` wrapping the object.
    @MainActor public func useState<O: ObservableObject>(
        _ object: O,
        updateTo keyPath: WritableKeyPath<View, O>,
        context: ((inout ViewUpdateContext)->Void)? = nil) -> State<O> where View: AnyObject {
        return useState(object, updater: { value, view, _ in
            var view = view
            view[keyPath: keyPath] = value
        }, context: context)
    }

    /// Observe an optional `ObservableObject` and write its value directly to a view's key path on each change.
    ///
    /// ```
    /// useState(viewModel, updateTo: \.headerViewModel)
    /// ```
    ///
    /// - Parameter object: The optional `ObservableObject` to observe
    /// - Parameter keyPath: The view's key path to update with the object's value
    /// - Parameter context: Optional context to pass to `setState` on each update
    /// - Returns: A `State` wrapping the optional object.
    @MainActor public func useState<O: ObservableObject>(
        _ object: O?,
        updateTo keyPath: WritableKeyPath<View, O?>,
        context: ((inout ViewUpdateContext)->Void)? = nil) -> State<O?> where View: AnyObject {
        return useState(object, updater: { value, view, _ in
            var view = view
            view[keyPath: keyPath] = value
        }, context: context)
    }
}
