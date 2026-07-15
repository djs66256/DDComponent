//
//  UpdateTransaction.swift
//  DDComponent
//
//  Created by daniel on 2024/1/3.
//

import Foundation

public protocol ViewUpdateTransaction {
    func updateView()
    func layoutViewIfNeeded()
    func complete()
}

@MainActor
class UpdateTransaction: ViewUpdateTransaction {
    var presenter: ViewPresentable
    var context: ViewUpdateContext
    var completions: [() -> Void] = []
    
    init(presenter: ViewPresentable, context: ViewUpdateContext, completion: (() -> Void)?) {
        self.presenter = presenter
        self.context = context
        self.completions = { if let completion { return [completion] } else { return [] } }()
    }
    
    func merge(context: ViewUpdateContext, completion: (() -> Void)?) {
        self.context.merge(context)
        if let completion {
            self.completions.append(completion)
        }
    }
    
    func merge(_ other: UpdateTransaction) {
        self.context.merge(other.context)
        self.completions.append(contentsOf: other.completions)
    }
    
    func updateView() {
        presenter.updateView(context: context)
    }
    
    func layoutViewIfNeeded() {
        if context.animated || context.layoutImmediately {
            presenter.layoutIfNeeded()
        }
    }
    
    func complete() {
        for completion in completions {
            completion()
        }
    }
}

@MainActor
class CompositeTransaction {
    
    private struct Key: Hashable {
        var presenter: ViewPresentable
        
        var hashValue: Int { presenter.hashValue }
        func hash(into hasher: inout Hasher) {
            presenter.hash(into: &hasher)
        }
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.presenter == rhs.presenter
        }
    }
    
    private var transactions: [Key: UpdateTransaction] = [:]
    
    var isDirty: Bool { !transactions.isEmpty }
    
    func clear() {
        transactions.removeAll()
    }
    
    func remove(for presenter: ViewPresentable) -> UpdateTransaction? {
        transactions.removeValue(forKey: Key(presenter: presenter))
    }
    
    func remove(for presenter: ViewPresentable, passing: (UpdateTransaction) -> Bool) -> UpdateTransaction? {
        let key = Key(presenter: presenter)
        if let transaction = transactions[key],
           passing(transaction) {
            transactions.removeValue(forKey: key)
            return transaction
        }
        return nil
    }
    
    func merge(_ other: CompositeTransaction) {
        for (key, value) in other.transactions {
            if let my = self.transactions[key] {
                my.merge(value)
            }
            else {
                self.transactions[key] = value
            }
        }
    }
    
    var invalidateDataSource: Bool {
        for (_, transaction) in transactions {
            if transaction.context.invalidateDataSource {
                return true
            }
        }
        return false
    }
    
    var invalidateContentSize: Bool {
        for (_, transaction) in transactions {
            if transaction.context.invalidateContentSize {
                return true
            }
        }
        return false
    }
    
    var mergedContext: ViewUpdateContext {
        var fullfill = ViewUpdateContext.fullfill
        for (_, transaction) in transactions {
            fullfill.merge(transaction.context)
        }
        return fullfill
    }
    
    var reloadDataContext: ViewUpdateContext {
        var fullfill = ViewUpdateContext.fullfill
        for (_, transaction) in transactions {
            if transaction.context.invalidateDataSource {
                fullfill.merge(transaction.context)
            }
        }
        return fullfill
    }
    
    var invalidateContentSizeContext: ViewUpdateContext {
        var fullfill = ViewUpdateContext.fullfill
        for (_, transaction) in transactions {
            if transaction.context.invalidateContentSize {
                fullfill.merge(transaction.context)
            }
        }
        return fullfill
    }
    
    func markDirty(presenter: ViewPresentable, context: ViewUpdateContext, _ completion: (() -> Void)?) {
        let key = Key(presenter: presenter)
        if let transaction = transactions[key] {
            transaction.merge(context: context, completion: completion)
        }
        else {
            let transaction = UpdateTransaction(presenter: presenter, context: context, completion: completion)
            transactions[key] = transaction
        }
    }
    
    func updateView() {
        for (_, transaction) in transactions {
            transaction.context.animate {
                transaction.presenter.updateViewWithoutLayout(context: transaction.context)
            }
        }
    }
    
    func layoutViewIfNeeded() {
        for (_, transaction) in transactions {
            transaction.context.animate {
                transaction.layoutViewIfNeeded()
            }
        }
    }
    
    func complete() {
        for (_, transaction) in transactions {
            for completion in transaction.completions {
                completion()
            }
        }
        transactions.removeAll()
    }
}

extension ViewUpdateContext {
    fileprivate static var fullfill: ViewUpdateContext {
        var context = ViewUpdateContext()
        context.animated = true
        return context
    }
}
