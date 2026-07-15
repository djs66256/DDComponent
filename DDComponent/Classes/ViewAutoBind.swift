//
//  ViewAutoBind.swift
//  DDComponent
//
//  Created by daniel on 2023/5/18.
//

import Foundation

@MainActor
public protocol ViewAutoBindable {
    func findView<T>() -> T?
}

@MainActor
struct ViewAutoBinder {
    func findChildView<T>(presenter: ViewPresentable) -> T? {
        if let customView = presenter.anyView as? ViewAutoBindable {
            return customView.findView()
        }
        else if let view = nearestUIView(presenter: presenter) {
            // Child presenter & super presenter are bound to same view.
            // Child presenter is a shadow presenter at this situation.
            if let v = view as? T {
                return v
            }
            return findViewBFS(views: view.subviews)
        }
        else {
            return nil
        }
    }
    
    private func nearestUIView(presenter: ViewPresentable?) -> UIView? {
        guard let presenter = presenter else {
            return nil
        }
        
        if let view = presenter.anyView as? UIView {
            return view
        }
        else {
            return nearestUIView(presenter: presenter.superPresenter)
        }
    }
    
    private func findViewBFS<T>(views: [UIView]) -> T? {
        if (views.isEmpty) {
            return nil
        }
            
        var subviews = [UIView]()
        for view in views {
            if let v = view as? T {
                return v
            }
            subviews.append(contentsOf: view.subviews)
        }
        return findViewBFS(views: subviews)
    }
}
