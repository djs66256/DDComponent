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

#import "DDTableViewSectionGroupComponent.h"

@implementation DDTableViewSectionGroupComponent

- (void)setSubComponents:(NSArray *)subComponents {
    for (DDTableViewBaseComponent *comp in _subComponents) {
        if (comp.superComponent == self) {
            comp.superComponent = nil;
        }
    }
    _subComponents = subComponents.copy;
    for (DDTableViewBaseComponent *comp in _subComponents) {
        comp.superComponent = self;
        if (self.tableView) {
            [comp prepareTableView];
        }
    }
}


- (void)prepareTableView {
    [super prepareTableView];
    if (self.tableView) {
        for (DDTableViewBaseComponent *comp in _subComponents) {
            [comp prepareTableView];
        }
    }
}

- (NSInteger)firstSectioniOfComponent:(id<DDTableViewComponent>)comp {
    NSInteger section = self.section;
    if (self.tableView) {
        for (DDTableViewBaseComponent *subComp in _subComponents) {
            if (subComp == comp) {
                return section;
            }
            else {
                section += [subComp numberOfSectionsInTableView:self.tableView];
            }
        }
    }
    return section;
}

- (void)reloadData {
    if (self.tableView) {
        [self.tableView beginUpdates];
        NSInteger sections = [self numberOfSectionsInTableView:self.tableView];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.section, sections)];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

- (DDTableViewBaseComponent *)componentAtSection:(NSInteger)atSection {
    if (self.tableView) {
        NSInteger section = self.section;
        for (DDTableViewBaseComponent *comp in _subComponents) {
            NSInteger count = [comp numberOfSectionsInTableView:self.tableView];
            if (section <= atSection && section+count > atSection) {
                return comp;
            }
            section += count;
        }
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 0;
    for (DDTableViewBaseComponent *comp in _subComponents) {
        sections += [comp numberOfSectionsInTableView:tableView];
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDTableViewBaseComponent *comp = [self componentAtSection:section];
    return [comp tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    return [comp tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    DDTableViewBaseComponent *comp = [self componentAtSection:section];
    if ([comp respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)]) {
        [comp tableView:tableView willDisplayHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    DDTableViewBaseComponent *comp = [self componentAtSection:section];
    if ([comp respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)]) {
        [comp tableView:tableView willDisplayFooterView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    DDTableViewBaseComponent *comp = [self componentAtSection:section];
    if ([comp respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)]) {
        [comp tableView:tableView didEndDisplayingHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
    DDTableViewBaseComponent *comp = [self componentAtSection:section];
    if ([comp respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)]) {
        [comp tableView:tableView didEndDisplayingFooterView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        [comp tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        [comp tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDTableViewBaseComponent *comp = [self componentAtSection:section];
    if ([comp respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [comp tableView:tableView heightForHeaderInSection:section];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDTableViewBaseComponent *comp = [self componentAtSection:section];
    if ([comp respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [comp tableView:tableView heightForFooterInSection:section];
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDTableViewBaseComponent *comp = [self componentAtSection:section];
    if ([comp respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [comp tableView:tableView viewForHeaderInSection:section];
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    DDTableViewBaseComponent *comp = [self componentAtSection:section];
    if ([comp respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        return [comp tableView:tableView viewForFooterInSection:section];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [comp tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:@selector(tableView:shouldHighlightRowAtIndexPath:)]) {
        return [comp tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:@selector(tableView:didHighlightRowAtIndexPath:)]) {
        [comp tableView:tableView didHighlightRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:@selector(tableView:didUnhighlightRowAtIndexPath:)]) {
        [comp tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        return [comp tableView:tableView willSelectRowAtIndexPath:indexPath];
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [comp tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
        return [comp tableView:tableView willDeselectRowAtIndexPath:indexPath];
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
        [comp tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        return [comp tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:@selector(tableView:editActionsForRowAtIndexPath:)]) {
        return [comp tableView:tableView editActionsForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtSection:indexPath.section];
    if ([comp respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        [comp tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

@end


@implementation DDTableViewRootComponent {
    __weak UITableView *_tableView;
    __weak id<UIScrollViewDelegate> _scrollDelegate;
}

- (UITableView *)tableView {
    return _tableView;
}

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _scrollDelegate = nil;
}

- (instancetype)initWithTableView:(UITableView *)tableView {
    return [self initWithTableView:tableView bind:YES];
}

- (instancetype)initWithTableView:(UITableView *)tableView bind:(BOOL)bind
{
    self = [super init];
    if (self) {
        _tableView = tableView;
        if (bind) {
            _scrollDelegate = tableView.delegate;
            _tableView.dataSource = self;
            _tableView.delegate = self;
        }
    }
    return self;
}

- (NSInteger)section {
    return 0;
}

- (NSInteger)row {
    return 0;
}

- (void)reloadData {
    [self.tableView reloadData];
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
