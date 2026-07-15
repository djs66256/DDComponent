//
//  UIView+TTHandy.swift
//  Pods
//
//  Created by 牟爽 on 2018/5/29.
//

import Foundation
import UIKit
import SnapKit

public typealias BNCorners = UIRectCorner
public extension UIRectCorner {
    static var topHalf:UIRectCorner { [.topLeft,.topRight] }
    static var bottomHalf:UIRectCorner{ [.bottomLeft,.bottomRight] }
    static var upperHalf:UIRectCorner { topHalf }
    static var lowerHalf:UIRectCorner { bottomHalf }
    static var all:UIRectCorner { .allCorners }
}

public extension UIView {
    
    /// 添加局部圆角。当 `masksToBounds` 为 false 时，不会触发离屏渲染啊。 
    /// - Parameters:
    ///   - corners: 圆角位置
    ///   - radius: 圆角大小
    ///   - masksToBounds: 是否裁切超出圆角的部分。如果是没有 SubView 的 View，建议设置为 False。
    func roundCorners2(_ corners: UIRectCorner, radius: CGFloat, masksToBounds: Bool = true) {
        layer.masksToBounds = masksToBounds
        
        var maskedCorners: CACornerMask = []
        if corners.contains(.topLeft) {
            maskedCorners.insert(.layerMinXMinYCorner)
        }
        if corners.contains(.topRight) {
            maskedCorners.insert(.layerMaxXMinYCorner)
        }
        if corners.contains(.bottomLeft) {
            maskedCorners.insert(.layerMinXMaxYCorner)
        }
        if corners.contains(.bottomRight) {
            maskedCorners.insert(.layerMaxXMaxYCorner)
        }
        
        layer.cornerRadius = radius
        layer.maskedCorners = maskedCorners
    }
    
    func clearRoundCorners2() {
        layer.masksToBounds = false
        layer.cornerRadius = 0
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    /// 利用 Mask 的方式添加圆角。会触发离屏渲染。
    /// - Parameters:
    ///   - corners: A bitmask value that identifies the corners that you want rounded. You can use this parameter to round only a subset of the corners of the rectangle.
    ///   - radius:The radius of each corner oval. Values larger than half the rectangle’s width or height are clamped appropriately to half the width or height.
    ///
    ///  If the value of corners is bottomHalf or topHalf , radius larger than half the rectangle’s height is allowed.
//    func roundCorners(_ corners: UIRectCorner, radius: CGFloat, masksToBounds: Bool = true) {
//        let mask = CAShapeLayer()
//        
//        defer {
//            layer.mask = mask
//        }
//        
//        if bounds.height < radius*2 {
//            let size = CGSize(width: bounds.width, height: radius * 2)
//            switch corners {
//            case .bottomHalf:
//                let offset = radius*2 - bounds.height
//                mask.frame = .init(origin: .init(x:0, y:-offset), size: size)
//                mask.path = UIBezierPath(roundedRect: .init(origin: .zero, size: size),
//                                         byRoundingCorners: corners,
//                                         cornerRadii: .Square(radius)).cgPath
//                return
//            case .topHalf:
//                mask.frame = .init(origin: .zero, size: size)
//                mask.path = UIBezierPath(roundedRect: .init(origin: .zero, size: size),
//                                         byRoundingCorners: corners,
//                                         cornerRadii: .Square(radius)).cgPath
//                return
//            default:
//                // 其他情况未实现, 走默认逻辑
//                ()
//            }
//        }
//        
//        let path = UIBezierPath(roundedRect: bounds,
//                                byRoundingCorners: corners,
//                                cornerRadii: .Square(radius))
//        mask.frame = self.bounds
//        mask.path = path.cgPath
//        layer.mask = mask
//    }
    
    func clearRoundCorners() {
        layer.mask = nil
    }

    @discardableResult
    func addBottomLine(thickness: CGFloat = 1.0 / UIScreen.main.scale,
                         color: UIColor,
                         inset: UIEdgeInsets) -> UIView {
        let line = UIView()
        line.backgroundColor = color
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(inset.left)
            make.right.equalTo(self).offset(-inset.right)
            make.height.equalTo(thickness)
            make.bottom.equalToSuperview()
        }

        return line
    }

    @discardableResult
    func addTopLine(thickness: CGFloat = 1.0 / UIScreen.main.scale,
                      color: UIColor,
                      inset: UIEdgeInsets) -> UIView {
        let line = UIView()
        line.backgroundColor = color
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(inset.left)
            make.right.equalTo(self).offset(-inset.right)
            make.height.equalTo(thickness)
            make.top.equalTo(self)
        }

        return line
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            guard let color = newValue else {
                layer.borderColor = nil
                return
            }
            // Fix React-Native conflict issue
            guard String(describing: type(of: color)) != "__NSCFType" else { return }
            layer.borderColor = color.cgColor
        }
    }
    
    /// SwifterSwift: Size of view.
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            width = newValue.width
            height = newValue.height
        }
    }
    
    /// SwifterSwift: Width of view.
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    /// SwifterSwift: Height of view.
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }

    // swiftlint:disable next identifier_name
    /// SwifterSwift: x origin of view.
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }

    // swiftlint:disable next identifier_name
    /// SwifterSwift: y origin of view.
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }

    /// SwifterSwift: Border width of view; also inspectable from Storyboard.
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    /// SwifterSwift: Corner radius of view; also inspectable from Storyboard.
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100)
        }
    }
    
    /// SwifterSwift: Remove all subviews in view.
    func removeAllSubviews() {
        subviews.forEach({ $0.removeFromSuperview() })
    }
}
