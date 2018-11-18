//
//  DDTableViewSectionComponent.m
//  DDTableViewComponent
//
//  Created by daniel on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#import "DDTableViewSectionComponent.h"
#import "DDTableViewRootComponent.h"
#import "DDTableViewCompositeComponentProtocol.h"
#import "DDTableViewComponentCache.h"
#import "DDTableViewComponentInternal.h"

using namespace DD::TableViewComponent;

@implementation DDTableViewSectionComponent
@dynamic superComponent;

- (NSInteger)convertSection:(NSInteger)section toSuperComponent:(DDTableViewBaseComponent *)comp {
    if (self == comp) return section;
    return [self.superComponent convertSection:section fromComponent:self toSuperComponent:comp];
}

- (NSInteger)convertSection:(NSInteger)section fromComponent:(DDTableViewBaseComponent *)from toSuperComponent:(DDTableViewBaseComponent *)comp {
    return [self convertSection:section toSuperComponent:comp];
}

- (NSInteger)convertSection:(NSInteger)section toSubComponent:(DDTableViewBaseComponent *)comp {
    if (self == comp) return section;
    return NSNotFound;
}

- (NSInteger)convertToGlobalSection:(NSInteger)section {
    if (DDTableViewRootComponent *root = self.rootComponent) {
        return [self convertSection:section toSuperComponent:root];
    }
    else {
        return NSNotFound;
    }
}

- (NSInteger)convertFromGlobalSection:(NSInteger)section {
    if (DDTableViewRootComponent *root = self.rootComponent) {
        return [root convertSection:section toSubComponent:self];
    }
    else {
        return NSNotFound;
    }
}

- (nullable UITableViewHeaderFooterView *)headerViewForSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    if (auto root = self.rootComponent) {
        auto globalSection = [self convertSection:section toSuperComponent:root];
        return [root.tableView headerViewForSection:globalSection];
    }
    return nil;
}

- (nullable UITableViewHeaderFooterView *)footerViewForSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    if (auto root = self.rootComponent) {
        auto globalSection = [self convertSection:section toSuperComponent:root];
        return [root.tableView footerViewForSection:globalSection];
    }
    return nil;
}

@end

@implementation DDTableViewHeaderFooterSectionComponent {
    @protected
    HeaderFooterCache _headerFooterCache;
}
#pragma mark - component
- (void)setHeader:(DDTableViewItemComponent *)header {
    if (_header != header) {
        if (_header.superComponent == self) {
            _header.superComponent = nil;
        }
        
        _header = header;
        
        _header.superComponent = self;
        UITableView *tableView = self.rootComponent.tableView;
        if (tableView) [_header prepareCells:tableView];
    }
}

- (void)setFooter:(DDTableViewItemComponent *)footer {
    if (_footer != footer) {
        if (_footer.superComponent == self) {
            _footer.superComponent = nil;
        }
        
        _footer = footer;
        
        _footer.superComponent = self;
        UITableView *tableView = self.rootComponent.tableView;
        if (tableView) [_footer prepareCells:tableView];
    }
}

- (void)prepareCells:(UITableView *)tableView {
    [super prepareCells:tableView];
    [_header prepareCells:tableView];
    [_footer prepareCells:tableView];
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toSuperComponent:(DDTableViewBaseComponent *)comp {
    if (_header == comp || _footer == comp) {
        return indexPath;
    }
    return [super convertIndexPath:indexPath toSuperComponent:comp];
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toSubComponent:(DDTableViewBaseComponent *)comp {
    if (_header == comp || _footer == comp) {
        return indexPath;
    }
    return [super convertIndexPath:indexPath toSubComponent:comp];
}

- (NSInteger)convertSection:(NSInteger)section toSuperComponent:(DDTableViewBaseComponent *)comp {
    if (_header == comp || _footer == comp) return section;
    return [super convertSection:section toSuperComponent:comp];
}

- (NSInteger)convertSection:(NSInteger)section toSubComponent:(DDTableViewBaseComponent *)comp {
    if (_header == comp || _footer == comp) return section;
    return [super convertSection:section toSubComponent:comp];
}

#pragma mark - composite protocol
- (void)rebuildCache {
    _headerFooterCache.fill(self, self.header, self.footer);
}

- (const DD::TableViewComponent::TableViewResponds *)respondsInfo {
    return _headerFooterCache.myResponds();
}

#pragma mark - dataSource
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    auto rs = _headerFooterCache.headerResponds();
    if (rs->titleForHeaderInSection) {
        return [_header tableView:tableView titleForHeaderInSection:section];
    }
    return nil;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    auto rs = _headerFooterCache.footerResponds();
    if (rs->titleForFooterInSection) {
        return [_footer tableView:tableView titleForHeaderInSection:section];
    }
    return nil;
}

#pragma mark - delegate
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    auto rs = _headerFooterCache.headerResponds();
    if (rs->willDisplayHeaderView) {
        [_header tableView:tableView willDisplayHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    auto rs = _headerFooterCache.footerResponds();
    if (rs->willDisplayFooterView) {
        [_footer tableView:tableView willDisplayFooterView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    auto rs = _headerFooterCache.headerResponds();
    if (rs->willDisplayCell) {
        [_header tableView:tableView didEndDisplayingHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    auto rs = _headerFooterCache.footerResponds();
    if (rs->willDisplayCell) {
        [_footer tableView:tableView didEndDisplayingFooterView:view forSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    auto rs = _headerFooterCache.headerResponds();
    if (rs->heightForHeaderInSection) {
        return [_header tableView:tableView heightForHeaderInSection:section];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    auto rs = _headerFooterCache.footerResponds();
    if (rs->heightForFooterInSection) {
        return [_footer tableView:tableView heightForFooterInSection:section];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0) {
    auto rs = _headerFooterCache.headerResponds();
    if (rs->estimatedHeightForHeaderInSection) {
        return [_header tableView:tableView estimatedHeightForHeaderInSection:section];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0) {
    auto rs = _headerFooterCache.footerResponds();
    if (rs->estimatedHeightForFooterInSection) {
        return [_footer tableView:tableView estimatedHeightForFooterInSection:section];
    }
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    auto rs = _headerFooterCache.headerResponds();
    if (rs->viewForHeaderInSection) {
        return [_header tableView:tableView viewForHeaderInSection:section];
    }
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    auto rs = _headerFooterCache.footerResponds();
    if (rs->viewForFooterInSection) {
        return [_footer tableView:tableView viewForFooterInSection:section];
    }
    return nil;
}

@end

static NSIndexPath *indexPathZero;
@implementation DDTableViewItemGroupSectionComponent {
    RowCache _cache;
    TableViewResponds _myResponds;
}

+ (void)initialize {
    indexPathZero = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _myResponds.cls = self.class;
    }
    return self;
}

#pragma mark - component
- (void)setSubComponents:(NSArray<DDTableViewItemComponent *> *)subComponents {
    if (_subComponents != subComponents) {
        for (DDTableViewItemComponent *comp in _subComponents) {
            if (comp.superComponent == self) comp.superComponent = nil;
        }
        
        _subComponents = subComponents.copy;
        
        UITableView *tableView = self.rootComponent.tableView;
        for (DDTableViewItemComponent *comp in _subComponents) {
            comp.superComponent = self;
            
            if (tableView) [comp prepareCells:tableView];
        }
    }
}

- (void)prepareCells:(UITableView *)tableView {
    [super prepareCells:tableView];
    for (DDTableViewItemComponent *comp in self.subComponents) {
        [comp prepareCells:tableView];
    }
}

#pragma mark - covert
- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath fromComponent:(DDTableViewBaseComponent *)from toSuperComponent:(nonnull DDTableViewBaseComponent *)comp {
    auto rs = _cache.getComponent(from);
    if (rs == _cache.end()) {
        return nil;
    }
    else {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row + rs.index() inSection:indexPath.section];
        return [self convertIndexPath:idx toSuperComponent:comp];
    }
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toSubComponent:(DDTableViewBaseComponent *)comp {
    if (NSIndexPath *idx = [super convertIndexPath:indexPath toSubComponent:comp])
        return idx;
    
    auto rs = _cache.getRow(indexPath.row);
    if (rs == _cache.end()) {
        return nil;
    }
    else {
        if (indexPath.row == rs.index()) {
            return indexPathZero;
        }
        else {
            return nil;
        }
    }
}

#pragma mark - composite
- (void)rebuildCache {
    [super rebuildCache];
    _cache.fill(self.subComponents, self.rootComponent.tableView);
    
    _myResponds.clear();
    _myResponds.mergeCellResponds(*_cache.myResponds());
    auto headerfooterResponds = _headerFooterCache.myResponds();
    _myResponds.mergeHeaderResponds(*headerfooterResponds);
    _myResponds.mergeFooterResponds(*headerfooterResponds);
}

- (const DD::TableViewComponent::TableViewResponds *)respondsInfo {
    return &_myResponds;
}

#pragma mark - table dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cache.numberOfRows() == 0 ? 0 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cache.numberOfRows();
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getRow(indexPath.row);
    return [rs.component() tableView:tableView cellForRowAtIndexPath:indexPathZero];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->canEditRowAtIndexPath) {
        return [rs.component() tableView:tableView canEditRowAtIndexPath:indexPathZero];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->commitEditingStyle) {
        [rs.component() tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPathZero];
    }
}

#pragma mark - delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->willDisplayCell) {
        [rs.component() tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPathZero];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->didEndDisplayingCell) {
        [rs.component() tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPathZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->heightForRowAtIndexPath) {
        return [rs.component() tableView:tableView heightForRowAtIndexPath:indexPathZero];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0) {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->estimatedHeightForRowAtIndexPath) {
        return [rs.component() tableView:tableView estimatedHeightForRowAtIndexPath:indexPathZero];
    }
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->shouldHighlightRowAtIndexPath) {
        return [rs.component() tableView:tableView shouldHighlightRowAtIndexPath:indexPathZero];
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->didHighlightRowAtIndexPath) {
        [rs.component() tableView:tableView didHighlightRowAtIndexPath:indexPathZero];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->didUnhighlightRowAtIndexPath) {
        [rs.component() tableView:tableView didUnhighlightRowAtIndexPath:indexPathZero];
    }
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->willSelectRowAtIndexPath) {
        [rs.component() tableView:tableView willSelectRowAtIndexPath:indexPathZero];
    }
    return indexPath;
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->canEditRowAtIndexPath) {
        [rs.component() tableView:tableView willSelectRowAtIndexPath:indexPathZero];
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->didSelectRowAtIndexPath) {
        [rs.component() tableView:tableView didSelectRowAtIndexPath:indexPathZero];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->didDeselectRowAtIndexPath) {
        [rs.component() tableView:tableView didDeselectRowAtIndexPath:indexPathZero];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->editingStyleForRowAtIndexPath) {
        return [rs.component() tableView:tableView editingStyleForRowAtIndexPath:indexPathZero];
    }
    return UITableViewCellEditingStyleNone;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->titleForDeleteConfirmationButtonForRowAtIndexPath) {
        return [rs.component() tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPathZero];
    }
    return nil;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->editActionsForRowAtIndexPath) {
        return [rs.component() tableView:tableView editActionsForRowAtIndexPath:indexPathZero];
    }
    return nil;
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos) {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->leadingSwipeActionsConfigurationForRowAtIndexPath) {
        return [rs.component() tableView:tableView leadingSwipeActionsConfigurationForRowAtIndexPath:indexPathZero];
    }
    return nil;
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos) {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->trailingSwipeActionsConfigurationForRowAtIndexPath) {
        return [rs.component() tableView:tableView trailingSwipeActionsConfigurationForRowAtIndexPath:indexPathZero];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->shouldIndentWhileEditingRowAtIndexPath) {
        return [rs.component() tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPathZero];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath __TVOS_PROHIBITED {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->willBeginEditingRowAtIndexPath) {
        [rs.component() tableView:tableView willBeginEditingRowAtIndexPath:indexPathZero];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(nullable NSIndexPath *)indexPath __TVOS_PROHIBITED {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->didEndEditingRowAtIndexPath) {
        return [rs.component() tableView:tableView didEndEditingRowAtIndexPath:indexPathZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->indentationLevelForRowAtIndexPath) {
        return [rs.component() tableView:tableView indentationLevelForRowAtIndexPath:indexPathZero];
    }
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(5_0) {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->shouldShowMenuForRowAtIndexPath) {
        return [rs.component() tableView:tableView shouldShowMenuForRowAtIndexPath:indexPathZero];
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender NS_AVAILABLE_IOS(5_0) {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->canPerformAction) {
        return [rs.component() tableView:tableView canPerformAction:action forRowAtIndexPath:indexPathZero withSender:sender];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender NS_AVAILABLE_IOS(5_0) {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->performAction) {
        [rs.component() tableView:tableView performAction:action forRowAtIndexPath:indexPathZero withSender:sender];
    }
}

// Focus

- (BOOL)tableView:(UITableView *)tableView canFocusRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(9_0) {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->canFocusRowAtIndexPath) {
        return [rs.component() tableView:tableView canFocusRowAtIndexPath:indexPathZero];
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldSpringLoadRowAtIndexPath:(NSIndexPath *)indexPath withContext:(id<UISpringLoadedInteractionContext>)context API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos, watchos) {
    auto rs = _cache.getRow(indexPath.row);
    if (rs.responds()->shouldSpringLoadRowAtIndexPath) {
        return [rs.component() tableView:tableView shouldSpringLoadRowAtIndexPath:indexPathZero withContext:context];
    }
    return NO;
}

@end
