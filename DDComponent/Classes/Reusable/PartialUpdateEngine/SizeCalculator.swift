//
//  SizeCalculator.swift
//  DDComponent
//
//  Created by daniel on 2022/9/26.
//

import Foundation
import UIKit

public enum Fitting {
    case containerSize(_ containerSize: CGSize)
    case width(_ width: CGFloat)
    case height(_ height: CGFloat)
    
    public init(width: CGFloat, height: CGFloat) {
        if width.isFinite && height.isFinite {
            self = .containerSize(CGSize(width: width, height: height))
        }
        else if width.isFinite {
            self = .width(width)
        }
        else if height.isFinite {
            self = .height(height)
        }
        else {
            assert(false)
            self = .containerSize(.zero)
        }
    }
}

public protocol SizeCalculatable {
    func size(for view: UIView, fitting: Fitting) -> CGSize
    
    func size(for cell: UICollectionViewCell, fitting: Fitting) -> CGSize
    func size(for cell: UITableViewCell, fitting: Fitting) -> CGSize
}

public extension SizeCalculatable {
    func size(for cell: UICollectionViewCell, fitting: Fitting) -> CGSize {
        size(for: cell as UIView, fitting: fitting)
    }
    func size(for cell: UITableViewCell, fitting: Fitting) -> CGSize {
        size(for: cell as UIView, fitting: fitting)
    }
}

@MainActor
public class SizeCalculator {
    public enum LayoutType: Int {
        case autoLayout, sizeThatFits, intrinsicContentSize
    }
    
    var calculators: [LayoutType: SizeCalculatable] = [:]
    
    init() {
        calculators[.autoLayout] = AutoLayoutCalculator()
        calculators[.sizeThatFits] = SizeToFitCalculator()
        calculators[.intrinsicContentSize] = IntrinsicContentSizeCalculator()
    }
    
    func calculator(for layoutType: LayoutType) -> SizeCalculatable? {
        calculators[layoutType]
    }
    
    public func size(for view: UIView, layoutType: LayoutType, fitting: Fitting) -> CGSize {
        var size: CGSize = .zero
        if let calculator = self.calculator(for: .autoLayout) {
            if let cell = view as? UICollectionViewCell {
                size = calculator.size(for: cell, fitting: fitting)
            }
            else if let cell = view as? UITableViewCell {
                size = calculator.size(for: cell, fitting: fitting)
            }
            else {
                size = calculator.size(for: view, fitting: fitting)
            }
        }
        else {
            assert(false, "Can not support layout type \(layoutType).")
        }
        
        assert(size.width.isFinite && size.height.isFinite)
        
        return size
    }
    
    
    private var views: [ObjectIdentifier: UIView] = [:]
    private var presenters: [ObjectIdentifier: ReusablePresentable] = [:]
    private let originSize = UIScreen.main.bounds
    
    public func dequeueView(for viewClass: UIView.Type) -> UIView {
        var view = views[ObjectIdentifier(viewClass)]
        if view == nil {
            let instance = viewClass.init(frame: originSize)
            view = instance
            views[ObjectIdentifier(viewClass)] = instance
            
        }
        if let reuse = view as? UICollectionReusableView {
            reuse.prepareForReuse()
        }
        else if let reuse = view as? UITableViewCell {
            reuse.prepareForReuse()
        } else if let reuse = view as? UITableViewHeaderFooterView {
            reuse.prepareForReuse()
        }
        return view!
    }
    
    public func dequeuePresenter(for presenterClass: ReusablePresentable.Type) -> ReusablePresentable {
        var presenter = presenters[ObjectIdentifier(presenterClass)]
        if presenter == nil {
            let instance = presenterClass.init()
            presenter = instance
            presenters[ObjectIdentifier(presenterClass)] = instance
        }
        presenter!.prepareForReuse()
        return presenter!
    }
}

class SizeToFitCalculator: SizeCalculatable {
    func size(for view: UIView, fitting: Fitting) -> CGSize {
        var size: CGSize
        switch fitting {
        case .containerSize(let s):
            size = s
        case .width(let w):
            size = CGSize(width: w, height: .infinity)
        case .height(let h):
            size = CGSize(width: .infinity, height: h)
        }
        
        return view.sizeThatFits(size)
    }
}

class IntrinsicContentSizeCalculator: SizeCalculatable {
    func size(for view: UIView, fitting: Fitting) -> CGSize {
        var size: CGSize = view.intrinsicContentSize
        switch fitting {
        case .containerSize(let s):
            size.width = size.width < 0 ? s.width : min(s.width, size.width)
            size.height = size.height < 0 ? s.height : min(s.height, size.height)
        case .width(let w):
            size.width = size.width < 0 ? w : min(w, size.width)
        case .height(let h):
            size.height = size.height < 0 ? h : min(h, size.height)
        }
        
        return size
    }
}

class AutoLayoutCalculator: SizeCalculatable {
    func size(for view: UIView, fitting: Fitting) -> CGSize {
        var activeConstraints: [NSLayoutConstraint] = []
        switch fitting {
        case .containerSize(let s):
            if s.width.isFinite {
                let width = view.helperConstraints.lessThanWidth()
                width.constant = s.width
                width.isActive = true
                activeConstraints.append(width)
            }
            if s.height.isFinite {
                let height = view.helperConstraints.lessThanHeight()
                height.constant = s.height
                height.isActive = true
                activeConstraints.append(height)
            }
        case .width(let w):
            if w.isFinite, let width = view.helperConstraints.equalToWidth(createIfNeeded: true) {
                width.constant = w
                width.isActive = true
                activeConstraints.append(width)
            }
        case .height(let h):
            if h.isFinite, let height = view.helperConstraints.equalToHeight(createIfNeeded: true) {
                height.constant = h
                height.isActive = true
                activeConstraints.append(height)
            }
        }
        let size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        for activeConstraint in activeConstraints {
            activeConstraint.isActive = false
        }
        return size
    }
    
    func size(for cell: UICollectionViewCell, fitting: Fitting) -> CGSize {
        size(for: cell.contentView, fitting: fitting)
    }
    
    func size(for cell: UITableViewCell, fitting: Fitting) -> CGSize {
        size(for: cell.contentView, fitting: fitting)
    }
}

private extension UIView {
    struct CalculatorHelperConstraints {
        let view: UIView
        
        nonisolated(unsafe) private static var equalToWidthKey = 0
        nonisolated(unsafe) private static var equalToHeightKey = 0
        nonisolated(unsafe) private static var lessThanWidthKey = 0
        nonisolated(unsafe) private static var lessThanHeightKey = 0
        private static let defaultConstraintConstant = 1000.0
        func equalToWidth(createIfNeeded: Bool) -> NSLayoutConstraint? {
            if createIfNeeded {
                return constraint(for: view, key: &Self.equalToWidthKey) { view in
                    NSLayoutConstraint(item: view,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: Self.defaultConstraintConstant)
                }
            }
            else {
                return constraint(for: view, key: &Self.equalToWidthKey)
            }
        }
        func equalToHeight(createIfNeeded: Bool) -> NSLayoutConstraint? {
            if createIfNeeded {
                return constraint(for: view, key: &Self.equalToHeightKey) { view in
                    NSLayoutConstraint(item: view,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: Self.defaultConstraintConstant)
                }
            }
            else {
                return constraint(for: view, key: &Self.equalToHeightKey)
            }
        }
        func lessThanWidth() -> NSLayoutConstraint {
            constraint(for: view, key: &Self.lessThanWidthKey) { view in
                NSLayoutConstraint(item: view,
                                   attribute: .width,
                                   relatedBy: .lessThanOrEqual,
                                   toItem: nil,
                                   attribute: .notAnAttribute,
                                   multiplier: 1,
                                   constant: 0)
            }!
        }
        func lessThanHeight() -> NSLayoutConstraint {
            constraint(for: view, key: &Self.lessThanHeightKey) { view in
                NSLayoutConstraint(item: view,
                                   attribute: .height,
                                   relatedBy: .lessThanOrEqual,
                                   toItem: nil,
                                   attribute: .notAnAttribute,
                                   multiplier: 1,
                                   constant: 0)
            }!
        }
        
        private func constraint(for view: UIView,
                                key: UnsafeRawPointer,
                                _ creation: ((UIView)->NSLayoutConstraint)? = nil) -> NSLayoutConstraint? {
            if let constraint = objc_getAssociatedObject(view, key) as? NSLayoutConstraint {
                return constraint
            }
            else if let creation = creation {
                let constraint = creation(view)
                constraint.isActive = false
                view.addConstraint(constraint)
                objc_setAssociatedObject(view, key, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return constraint
            }
            else {
                return nil
            }
        }
    }
    
    var helperConstraints: CalculatorHelperConstraints {
        CalculatorHelperConstraints(view: self)
    }
}
