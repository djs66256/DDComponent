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

#import "DDCollectionViewStatusComponent.h"
#import "DDCollectionViewComponent+Private.h"

@implementation DDCollectionViewStatusComponent {
    NSMutableDictionary<NSString *, DDCollectionViewBaseComponent *> *_componentDict;
@protected
    NSUInteger _numberOfSections; // cache
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _componentDict = [NSMutableDictionary new];
    }
    return self;
}

- (NSInteger)firstItemOfSubComponent:(id<DDCollectionViewComponent>)subComp {
    return self.item;
}

- (NSInteger)firstSectionOfSubComponent:(id<DDCollectionViewComponent>)subComp {
    return self.section;
}

- (void)setCollectionView:(UICollectionView *)collectionView {
    [super setCollectionView:collectionView];
    [_componentDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, DDCollectionViewBaseComponent * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj setCollectionView:collectionView];
    }];
}

- (void)prepareCollectionView {
    [super prepareCollectionView];
    if (self.collectionView) {
        [_componentDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, DDCollectionViewBaseComponent * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj prepareCollectionView];
        }];
    }
}

- (DDCollectionViewBaseComponent *)currentComponent {
    return [self componentForState:self.currentState];
}

- (void)setComponent:(DDCollectionViewBaseComponent *)comp forState:(NSString *)state {
    if (state) {
        DDCollectionViewBaseComponent *oldComp = _componentDict[state];
        if (comp) {
            if (oldComp.superComponent == self) _componentDict[state].superComponent = nil;
            comp.superComponent = self;
            [_componentDict setObject:comp forKey:state];
            if (self.collectionView) {
                [comp prepareCollectionView];
            }
        }
        else {
            if (oldComp.superComponent == self) _componentDict[state].superComponent = nil;
            [_componentDict removeObjectForKey:state];
        }
    }
}

- (DDCollectionViewBaseComponent *)componentForState:(NSString *)state {
    if (state) {
        DDCollectionViewBaseComponent *comp = [_componentDict objectForKey:state];
        return comp;
    }
    return nil;
}

#pragma mark - CollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    _numberOfSections = [self.currentComponent numberOfSectionsInCollectionView:collectionView];
    return _numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.currentComponent collectionView:collectionView numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    return [comp collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    return [comp collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView shouldHighlightItemAtIndexPath:indexPath];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView didHighlightItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView didUnhighlightItemAtIndexPath:indexPath];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView shouldSelectItemAtIndexPath:indexPath];
    }
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView shouldDeselectItemAtIndexPath:indexPath];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView willDisplaySupplementaryView:view forElementKind:elementKind atIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView layout:collectionViewLayout referenceSizeForFooterInSection:section];
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView layout:collectionViewLayout referenceSizeForHeaderInSection:section];
    }
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:section];
    }
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView layout:collectionViewLayout minimumLineSpacingForSectionAtIndex:section];
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    DDCollectionViewBaseComponent *comp = self.currentComponent;
    if ([comp respondsToSelector:_cmd]) {
        return [comp collectionView:collectionView layout:collectionViewLayout minimumInteritemSpacingForSectionAtIndex:section];
    }
    return 0;
}

- (NSString *)debugDescription {
    NSMutableString *desc = [[NSMutableString alloc] initWithString:self.description];
    if (_componentDict.count > 0) {
        [_componentDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, DDCollectionViewBaseComponent * _Nonnull obj, BOOL * _Nonnull stop) {
            [desc appendString:@"\n  "];
            [desc appendString:[key isEqualToString:self.currentState] ? @"*" : @"-"];
            [desc appendString:@"["];
            [desc appendString:key];
            [desc appendString:@"] "];
            [desc appendString:[[obj.debugDescription componentsSeparatedByString:@"\n"] componentsJoinedByString:@"\n    "]];
        }];
    }
    return desc;
}

@end


@implementation DDCollectionViewHeaderFooterStatusComponent

- (void)setHeaderComponent:(DDCollectionViewSectionComponent *)headerComponent {
    if (_headerComponent.superComponent == self) _headerComponent.superComponent = nil;
    _headerComponent = headerComponent;
    _headerComponent.superComponent = self;
    if (self.collectionView) [_headerComponent prepareCollectionView];
}

- (void)setFooterComponent:(DDCollectionViewSectionComponent *)footerComponent {
    if (_footerComponent.superComponent == self) _footerComponent.superComponent = nil;
    _footerComponent = footerComponent;
    _footerComponent.superComponent = self;
    if (self.collectionView) [_footerComponent prepareCollectionView];
}

- (void)setHeaderFooterComponent:(DDCollectionViewSectionComponent *)headerFooterComponent {
    if (_headerFooterComponent.superComponent == self) _headerFooterComponent.superComponent = nil;
    _headerFooterComponent = headerFooterComponent;
    _headerFooterComponent.superComponent = self;
    if (self.collectionView) [_headerFooterComponent prepareCollectionView];
}

- (void)setCollectionView:(UICollectionView *)collectionView {
    [super setCollectionView:collectionView];
    self.headerComponent.collectionView = collectionView;
    self.footerComponent.collectionView = collectionView;
    self.headerFooterComponent.collectionView = collectionView;
}

- (void)prepareCollectionView {
    [super prepareCollectionView];
    if (self.collectionView) {
        [_headerFooterComponent prepareCollectionView];
        [_headerComponent prepareCollectionView];
        [_footerComponent prepareCollectionView];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        DDCollectionViewBaseComponent *comp = _headerComponent ?: _headerFooterComponent;
        if ([comp respondsToSelector:_cmd]) {
            return [comp collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
        }
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        DDCollectionViewBaseComponent *comp = _footerComponent ?: _headerFooterComponent;
        if ([comp respondsToSelector:_cmd]) {
            return [comp collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
        }
    }
    NSAssert(false, @"%@ is nil!", kind);
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    // header appear at first component
    if (self.section == section) {
        DDCollectionViewBaseComponent *comp = _headerComponent ?: _headerFooterComponent;
        if ([comp respondsToSelector:_cmd]) {
            return [comp collectionView:collectionView layout:collectionViewLayout referenceSizeForHeaderInSection:section];
        }
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    // footer appear at last component
    if (self.section + _numberOfSections - 1 == section) {
        DDCollectionViewBaseComponent *comp = _footerComponent ?: _headerFooterComponent;
        if ([comp respondsToSelector:_cmd]) {
            return [comp collectionView:collectionView layout:collectionViewLayout referenceSizeForFooterInSection:section];
        }
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = nil;
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        comp = _headerComponent ?: _headerFooterComponent;
    }
    else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        comp = _footerComponent ?: _headerFooterComponent;
    }
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView willDisplaySupplementaryView:view forElementKind:elementKind atIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    DDCollectionViewBaseComponent *comp = nil;
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        comp = _headerComponent ?: _headerFooterComponent;
    }
    else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        comp = _footerComponent ?: _headerFooterComponent;
    }
    if ([comp respondsToSelector:_cmd]) {
        [comp collectionView:collectionView didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
    }
}

- (NSString *)debugDescription {
    NSMutableString *desc = [[NSMutableString alloc] initWithString:[super debugDescription]];
    if (self.headerComponent) {
        [desc appendString:@"\n  [Header] "];
        [desc appendString:[[self.headerComponent.debugDescription componentsSeparatedByString:@"\n"] componentsJoinedByString:@"\n    "]];
    }
    if (self.footerComponent) {
        [desc appendString:@"\n  [Footer] "];
        [desc appendString:[[self.footerComponent.debugDescription componentsSeparatedByString:@"\n"] componentsJoinedByString:@"\n    "]];
    }
    if (self.headerFooterComponent) {
        [desc appendString:@"\n  [HeaderFooter] "];
        [desc appendString:[[self.headerFooterComponent.debugDescription componentsSeparatedByString:@"\n"] componentsJoinedByString:@"\n    "]];
    }
    return desc;
}

@end

