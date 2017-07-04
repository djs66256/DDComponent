// MIT License
//
// Copyright (c) 2016 Daniel (djs66256@163.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <UIKit/UIKit.h>

// When width or height is auto, it will use collectionView.size
// When inset lineSpacing itemSpacing is auto, it will use CollectionLayout's property.
extern const CGFloat DDComponentAutomaticDimension;

@class DDCollectionViewRootComponent;
@protocol DDCollectionViewComponent <NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@end

@interface DDCollectionViewBaseComponent : NSObject <DDCollectionViewComponent>

@property (weak, nonatomic, nullable) DDCollectionViewBaseComponent *superComponent NS_SWIFT_NAME(superComponent);
@property (weak, nonatomic, nullable) DDCollectionViewRootComponent *rootComponent;

/**
 The collection host by component. It is nil before RootComponent attach to a collectionView.
 */
@property (readonly, weak, nonatomic, nullable) UICollectionView *collectionView;

/**
 Register cell should be here, and only for register! It may invoke many times.
 */
- (void)prepareCollectionView NS_REQUIRES_SUPER;

/**
 Life cycle
 Is really need?

 @param component Nil if remove from super component.
 */
//- (void)willMoveToComponent:(DDCollectionViewBaseComponent * _Nullable)component NS_REQUIRES_SUPER;
//- (void)didMoveToComponent NS_REQUIRES_SUPER;
//- (void)willMoveToRootComponent:(DDCollectionViewRootComponent * _Nullable)component NS_REQUIRES_SUPER;
//- (void)didMoveToRootComponent NS_REQUIRES_SUPER;

/**
 For ItemComponent, {item, section} is equal to indexPath.
 For SectionComponent, {item, section} is equal to first item's indexPath, or Zero.
 For SectionGroupComponent, item should always be 0, section is the first section in the component.
 */
@property (readonly, nonatomic) NSInteger item;
@property (readonly, nonatomic) NSInteger section;

@end
