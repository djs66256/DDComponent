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

#import "DDTableViewSectionComponent.h"

@implementation DDTableViewSectionComponent

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.headerHeight = DDComponentAutomaticDimension;
        self.footerHeight = DDComponentAutomaticDimension;
        self.height = DDComponentAutomaticDimension;
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.height == DDComponentAutomaticDimension || isnan(self.height)) {
        return tableView.rowHeight;
    }
    else {
        return self.height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.headerHeight == DDComponentAutomaticDimension || isnan(self.headerHeight)) {
        return tableView.sectionHeaderHeight;
    }
    else {
        return self.headerHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.footerHeight == DDComponentAutomaticDimension || isnan(self.footerHeight)) {
        return tableView.sectionFooterHeight;
    }
    else {
        return self.footerHeight;
    }
}

@end


@implementation DDTableViewHeaderFooterSectionComponent

- (void)setHeaderComponent:(DDTableViewSectionComponent *)headerComponent {
    if (_headerComponent.superComponent == self) _headerComponent.superComponent = nil;
    _headerComponent = headerComponent;
    _headerComponent.superComponent = self;
    if (self.tableView) [_headerComponent prepareTableView];
}

- (void)setFooterComponent:(DDTableViewSectionComponent *)footerComponent {
    if (_footerComponent.superComponent == self) _footerComponent.superComponent = nil;
    _footerComponent = footerComponent;
    _footerComponent.superComponent = self;
    if (self.tableView) [_footerComponent prepareTableView];
}

- (void)setHeaderFooterComponent:(DDTableViewSectionComponent *)headerFooterComponent {
    if (_headerFooterComponent.superComponent == self) _headerFooterComponent.superComponent = nil;
    _headerFooterComponent = headerFooterComponent;
    _headerFooterComponent.superComponent = self;
    if (self.tableView) [_headerFooterComponent prepareTableView];
}

- (void)setHeaderHeight:(CGFloat)headerHeight {
    [super setHeaderHeight:headerHeight];
    _headerFooterComponent.headerHeight = headerHeight;
    _headerComponent.headerHeight = headerHeight;
}

- (void)setFooterHeight:(CGFloat)footerHeight {
    [super setFooterHeight:footerHeight];
    _footerComponent.footerHeight = footerHeight;
    _headerFooterComponent.footerHeight = footerHeight;
}

- (void)prepareTableView {
    [super prepareTableView];
    
    if (self.tableView) {
        [self.headerFooterComponent prepareTableView];
        [self.headerComponent prepareTableView];
        [self.footerComponent prepareTableView];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDTableViewSectionComponent *comp = self.headerComponent ?: self.headerFooterComponent;
    if ([comp respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [comp tableView:tableView heightForHeaderInSection:section];
    }
    else {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDTableViewSectionComponent *comp = self.footerComponent ?: self.headerFooterComponent;
    if ([comp respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [comp tableView:tableView heightForFooterInSection:section];
    }
    else {
        return [super tableView:tableView heightForFooterInSection:section];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDTableViewSectionComponent *comp = self.headerComponent ?: self.headerFooterComponent;
    if ([comp respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [comp tableView:tableView viewForHeaderInSection:section];
    }
    else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    DDTableViewSectionComponent *comp = self.footerComponent ?: self.headerFooterComponent;
    if ([comp respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        return [comp tableView:tableView viewForFooterInSection:section];
    }
    else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    DDTableViewSectionComponent *comp = self.headerComponent ?: self.headerFooterComponent;
    if ([comp respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)]) {
        [comp tableView:tableView willDisplayHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    DDTableViewSectionComponent *comp = self.footerComponent ?: self.headerFooterComponent;
    if ([comp respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)]) {
        [comp tableView:tableView willDisplayFooterView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    DDTableViewSectionComponent *comp = self.headerComponent ?: self.headerFooterComponent;
    if ([comp respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)]) {
        [comp tableView:tableView didEndDisplayingHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
    DDTableViewSectionComponent *comp = self.footerComponent ?: self.headerFooterComponent;
    if ([comp respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)]) {
        [comp tableView:tableView didEndDisplayingFooterView:view forSection:section];
    }
}

@end


@implementation DDTableViewItemGroupComponent

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

- (NSInteger)firstSectioniOfComponent:(id<DDTableViewComponent>)comp {
    return self.section;
}

- (NSInteger)firstRowOfComponent:(id<DDTableViewComponent>)comp {
    NSInteger row = self.row;
    if (self.tableView) {
        NSInteger section = self.section;
        for (id<DDTableViewComponent> subComp in _subComponents) {
            if (comp == subComp) {
                return row;
            }
            else {
                row += [subComp tableView:self.tableView numberOfRowsInSection:section];
            }
        }
    }
    return row;
}

- (void)prepareTableView {
    [super prepareTableView];
    if (self.tableView) {
        for (DDTableViewBaseComponent *subComp in _subComponents) {
            [subComp prepareTableView];
        }
    }
}

- (DDTableViewBaseComponent *)componentAtRow:(NSInteger)atRow {
    if (self.tableView) {
        NSInteger row = self.row;
        NSInteger section = self.section;
        for (id<DDTableViewComponent> comp in _subComponents) {
            NSInteger count = [comp tableView:self.tableView numberOfRowsInSection:section];
            if (row <= atRow && row+count > atRow) {
                return comp;
            }
            row += count;
        }
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    for (DDTableViewBaseComponent *comp in _subComponents) {
        rows += [comp tableView:tableView numberOfRowsInSection:section];
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtRow:indexPath.row];
    return [comp tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtRow:indexPath.row];
    if ([comp respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        [comp tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtRow:indexPath.row];
    if ([comp respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        [comp tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtRow:indexPath.row];
    if ([comp respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [comp tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtRow:indexPath.row];
    if ([comp respondsToSelector:@selector(tableView:shouldHighlightRowAtIndexPath:)]) {
        return [comp tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtRow:indexPath.row];
    if ([comp respondsToSelector:@selector(tableView:didHighlightRowAtIndexPath:)]) {
        [comp tableView:tableView didHighlightRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtRow:indexPath.row];
    if ([comp respondsToSelector:@selector(tableView:didUnhighlightRowAtIndexPath:)]) {
        [comp tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtRow:indexPath.row];
    if ([comp respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        return [comp tableView:tableView willSelectRowAtIndexPath:indexPath];
    }
    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtRow:indexPath.row];
    if ([comp respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
        return [comp tableView:tableView willDeselectRowAtIndexPath:indexPath];
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtRow:indexPath.row];
    if ([comp respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [comp tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtRow:indexPath.row];
    if ([comp respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
        [comp tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtRow:indexPath.row];
    if ([comp respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        return [comp tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtRow:indexPath.row];
    if ([comp respondsToSelector:@selector(tableView:editActionsForRowAtIndexPath:)]) {
        return [comp tableView:tableView editActionsForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTableViewBaseComponent *comp = [self componentAtRow:indexPath.row];
    if ([comp respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        [comp tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

@end
