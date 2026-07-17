//
//  UICollectionViewEngine+FlowLayout.swift
//  DDComponent
//
//  Created by daniel on 2022/9/18.
//

import Foundation
import UIKit

extension UICollectionItemFlowLayoutInfo.LayoutType {
    var sizeCalculatorLayoutType : SizeCalculator.LayoutType {
        if self == .autoLayout {
            return .autoLayout
        }
        else {
            return .sizeThatFits
        }
    }
}

open class UICollectionViewFlowLayoutProxy: UICollectionViewDelegateProxy, UICollectionViewDelegateFlowLayout {
    
    private var flowLayout: UICollectionViewFlowLayout? {
        collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    private var containerSize: CGSize {
        assert(flowLayout != nil)
        if let flowLayout = flowLayout {
            let inset = collectionView.contentInset
            if flowLayout.scrollDirection == .horizontal {
                return CGSize(width: .infinity, height: collectionView.frame.height - inset.top - inset.bottom)
            }
            else {
                return CGSize(width: collectionView.frame.width - inset.left - inset.right, height: .infinity)
            }
        }
        return .zero
    }
    
    private func containerSize(at section: Int) -> CGSize {
        if let flowLayout = flowLayout,
           let p: UICollectionViewFlowSectionPresentable = dataSource.section(at: section) {
            let inset = p.layoutInfo.inset
            let containerSize = self.containerSize
            var size = CGSize(width: containerSize.width - inset.left - inset.right,
                              height: containerSize.height - inset.top - inset.bottom)
            let columnCount = p.layoutInfo.columnCount
            if columnCount > 1 {
                if flowLayout.scrollDirection == .vertical {
                    size.width = floor((size.width - CGFloat(columnCount - 1) * p.layoutInfo.itemSpacing) / CGFloat(columnCount))
                }
                else {
                    size.height = floor((size.height - CGFloat(columnCount - 1) * p.layoutInfo.itemSpacing) / CGFloat(columnCount))
                }
            }
            return size
        }
        
        return .zero
    }
    
    private func calculateItemSize(_ presenter: UICollectionItemFlowPresentable, containerSize: CGSize) -> CGSize {
        let info = presenter.layoutInfo
        if info.calculateSizeAutomatically {
            return calculateItemSizeAutomatically(presenter, info.layoutType.sizeCalculatorLayoutType, containerSize)
        }
        else {
            return presenter.calculateSize(containerSize: containerSize)
        }
    }
    
    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let item: UICollectionItemFlowPresentable = dataSource.item(at: indexPath) {
            if let cachedSize = sizeCache[item] {
                return cachedSize
            }
            else {
                let containerSize = containerSize(at: indexPath.section)
                let calculatedSize = calculateItemSize(item, containerSize: containerSize)
                sizeCache[item] = calculatedSize
                return calculatedSize
            }
        }
        return .zero
    }
    
    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let p: UICollectionViewFlowSectionPresentable = dataSource.section(at: section) {
            return p.layoutInfo.inset
        }
        
        return .zero
    }
    
    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let p: UICollectionViewFlowSectionPresentable = dataSource.section(at: section) {
            return p.layoutInfo.lineSpacing
        }
        
        return 0
    }
    
    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let p: UICollectionViewFlowSectionPresentable = dataSource.section(at: section) {
            return p.layoutInfo.itemSpacing
        }
        
        return 0
    }
    
    public func headerPresenter(at section: Int) -> UICollectionItemFlowPresentable? {
        dataSource.supplementary(for: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: section))
    }
    
    public func footerPresenter(at section: Int) -> UICollectionItemFlowPresentable? {
        dataSource.supplementary(for: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: section))
    }
    
    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let item: UICollectionItemFlowPresentable = headerPresenter(at: section) {
            if let cachedSize = sizeCache[item] {
                return cachedSize
            }
            else {
                let calculatedSize = calculateItemSize(item, containerSize: containerSize)
                sizeCache[item] = calculatedSize
                return calculatedSize
            }
        }
        
        return .zero
    }
    
    @available(iOS 6.0, *)
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let item: UICollectionItemFlowPresentable = footerPresenter(at: section) {
            return calculateItemSize(item, containerSize: containerSize)
        }
        
        return .zero
    }
}

