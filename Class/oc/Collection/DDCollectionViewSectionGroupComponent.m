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

#import "DDCollectionViewSectionGroupComponent.h"

@implementation DDCollectionViewSectionGroupComponent

- (void)setSubComponents:(NSArray *)subComponents {
    for (DDCollectionViewBaseComponent *comp in _subComponents) {
        if (comp.superComponent == self) {
            comp.superComponent = nil;
        }
    }
    _subComponents = subComponents.copy;
    for (DDCollectionViewBaseComponent *comp in _subComponents) {
        comp.superComponent = self;
        if (self.collectionView) {
            [comp prepareCollectionView];
        }
    }
}

- (void)prepareCollectionView {
    [super prepareCollectionView];
    if (self.collectionView) {
        for (DDCollectionViewBaseComponent *comp in _subComponents) {
            [comp prepareCollectionView];
        }
    }
}

- (NSInteger)firstSectionOfSubComponent:(id<DDCollectionViewComponent>)subComp {
    NSInteger section = self.section;
    if (self.collectionView) {
        for (DDCollectionViewBaseComponent *comp in _subComponents) {
            if (comp == subComp) {
                return section;
            }
            else {
                section += [comp numberOfSectionsInCollectionView:self.collectionView];
            }
        }
    }
    return section;
}

- (DDCollectionViewBaseComponent *)componentAtSection:(NSInteger)atSection {
    if (self.collectionView) {
        NSInteger section = self.section;
        for (DDCollectionViewBaseComponent *comp in _subComponents) {
            NSInteger count = [comp numberOfSectionsInCollectionView:self.collectionView];
            if (section <= atSection && section+count > atSection) {
                return comp;
            }
            section += count;
        }
    }
    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger sections = 0;
    for (DDCollectionViewBaseComponent *comp in _subComponents) {
        sections += [comp numberOfSectionsInCollectionView:collectionView];
    }
    return sections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:section];
    return [comp collectionView:collectionView numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    return [comp collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    return [comp collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView shouldHighlightItemAtIndexPath:indexPath];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView didHighlightItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView didUnhighlightItemAtIndexPath:indexPath];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView shouldSelectItemAtIndexPath:indexPath];
    }
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView shouldDeselectItemAtIndexPath:indexPath];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView willDisplaySupplementaryView:view forElementKind:elementKind atIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:section];
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView layout:collectionViewLayout referenceSizeForFooterInSection:section];
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:section];
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView layout:collectionViewLayout referenceSizeForHeaderInSection:section];
    }
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:section];
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:section];
    }
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:section];
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView layout:collectionViewLayout minimumLineSpacingForSectionAtIndex:section];
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    DDCollectionViewBaseComponent *comp = [self componentAtSection:section];
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView layout:collectionViewLayout minimumInteritemSpacingForSectionAtIndex:section];
    }
    return 0;
}

- (NSString *)debugDescription {
    NSMutableString *desc = [[NSMutableString alloc] initWithString:self.description];
    if (self.subComponents.count > 0) {
        [desc appendString:@"\n  [SubComponents]"];
        for (DDCollectionViewBaseComponent *comp in self.subComponents) {
            [desc appendString:@"\n    "];
            NSArray *descs = [comp.debugDescription componentsSeparatedByString:@"\n"];
            [desc appendString:[descs componentsJoinedByString:@"\n    "]];
        }
    }
    return desc;
}

@end

@interface DDCollectionViewRootComponent ()
@property (nonatomic, readwrite, weak) UICollectionView *collectionView;
@property (nonatomic, weak) id<UIScrollViewDelegate> scrollDelegate;
@end

@implementation DDCollectionViewRootComponent
@synthesize collectionView = _collectionView;

- (void)dealloc
{
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
    _scrollDelegate = nil;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    return [self initWithCollectionView:collectionView bind:YES];
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView bind:(BOOL)bind
{
    self = [super init];
    if (self) {
        self.collectionView = collectionView;
        if (bind) {
            self.scrollDelegate = collectionView.delegate;
            collectionView.dataSource = self;
            collectionView.delegate = self;
        }
    }
    return self;
}

- (DDCollectionViewBaseComponent *)superComponent {
    return nil;
}

- (DDCollectionViewRootComponent *)rootComponent {
    return self;
}

- (NSInteger)section {
    return 0;
}

- (NSInteger)item {
    return 0;
}

- (void)reloadData {
    [self.collectionView reloadData];
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([_scrollDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_scrollDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([_scrollDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_scrollDelegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([_scrollDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [_scrollDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([_scrollDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_scrollDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([_scrollDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [_scrollDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([_scrollDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_scrollDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([_scrollDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [_scrollDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if ([_scrollDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [_scrollDelegate scrollViewShouldScrollToTop:scrollView];
    }
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if ([_scrollDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [_scrollDelegate scrollViewDidScrollToTop:scrollView];
    }
}

@end
