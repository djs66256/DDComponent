//
//  ViewPresenter+Use.swift
//  Pods
//
//  Created by daniel on 2025/1/9.
//

import Combine
import Foundation

extension ViewPresenter {

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

extension ViewPresenter {

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

extension ViewPresenter {

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

    @discardableResult
    @MainActor public func useEffect(_ action: @escaping @MainActor () -> Void) -> Effect {
        return useEffect {
            action()
            return nil
        }
    }

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

// Observe by async sequence
extension ViewPresenter {

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

// Observe by publisher
extension ViewPresenter {

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
