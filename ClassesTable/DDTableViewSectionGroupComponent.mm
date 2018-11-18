//
//  DDTableViewSectionGroupComponent.m
//  DDTableViewComponent
//
//  Created by daniel on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#include <vector>
#include <tuple>
#import "DDTableViewSectionGroupComponent.h"
#import "DDTableViewComponentCache.h"
#import "DDTableViewCompositeComponentProtocol.h"
#import "DDTableViewRootComponent.h"
#import "DDTableViewComponentInternal.h"

using namespace DD::TableViewComponent;

@implementation DDTableViewSectionGroupComponent {
    SectionCache _cache;
}

#pragma mark - convert
- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath fromComponent:(nonnull DDTableViewBaseComponent *)from toSuperComponent:(nonnull DDTableViewBaseComponent *)comp {
    auto rs = _cache.getComponent(from);
    if (rs == _cache.end()) {
        return nil;
    }
    else {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + rs.range().location];
        return [self convertIndexPath:idx toSuperComponent:comp];
    }
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toSubComponent:(DDTableViewBaseComponent *)comp {
    if (self == comp) return indexPath;
    
    auto rs = _cache.getSection(indexPath.section);
    if (rs == _cache.end()) {
        return nil;
    }
    else {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() convertIndexPath:idx toSubComponent:comp];
    }
}

- (NSInteger)convertSection:(NSInteger)section fromComponent:(DDTableViewBaseComponent *)from toSuperComponent:(DDTableViewBaseComponent *)comp {
    if (self == comp) return section;
    
    auto rs = _cache.getComponent(from);
    if (rs == _cache.end()) {
        return NSNotFound;
    }
    else {
        return [self convertSection:section + rs.range().location toSuperComponent:comp];
    }
}

- (NSInteger)convertSection:(NSInteger)section toSubComponent:(DDTableViewBaseComponent *)comp {
    if (self == comp) return section;
    
    auto rs = _cache.getSection(section);
    if (rs == _cache.end()) {
        return NSNotFound;
    }
    else {
        return [rs.component() convertSection:section - rs.range().location
                               toSubComponent:comp];
    }
}

#pragma mark - interface

- (void)setSubComponents:(NSArray<DDTableViewSectionComponent *> *)subComponents {
    if (_subComponents != subComponents) {
        for (DDTableViewSectionComponent *comp in _subComponents) {
            if (comp.superComponent == self) comp.superComponent = nil;
        }
        
        _subComponents = subComponents.copy;
        
        UITableView *tableView = self.rootComponent.tableView;
        for (DDTableViewSectionComponent * comp in subComponents) {
            comp.superComponent = self;
            if (tableView) [self prepareCells:tableView];
        }
    }
}

- (void)prepareCells:(UITableView *)tableView {
    for (DDTableViewSectionComponent *comp in self.subComponents) {
        [comp prepareCells:tableView];
    }
}

#pragma mark - composite component
- (void)rebuildCache {
    for (DDTableViewSectionComponent *comp in self.subComponents) {
        if ([comp conformsToProtocol:@protocol(DDTableViewCompositeComponentProtocol)]) {
            [(id<DDTableViewCompositeComponentProtocol>)comp rebuildCache];
        }
    }
    _cache.fill(self.subComponents, self.rootComponent.tableView);
}

- (const DD::TableViewComponent::TableViewResponds *)respondsInfo {
    return _cache.myResponds();
}

#pragma mark - table view datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cache.numberOfSection();
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    auto rs = _cache.getSection(section);
    return [rs.component() tableView:tableView numberOfRowsInSection:section - rs.range().location];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getSection(indexPath.section);
    NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
    return [rs.component() tableView:tableView cellForRowAtIndexPath:idx];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    auto rs = _cache.getSection(section);
    if (rs.responds()->titleForHeaderInSection) {
        return [rs.component() tableView:tableView titleForHeaderInSection:section - rs.range().location];
    }
    return nil;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    auto rs = _cache.getSection(section);
    if (rs.responds()->titleForFooterInSection) {
        return [rs.component() tableView:tableView titleForHeaderInSection:section - rs.range().location];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->canEditRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() tableView:tableView canEditRowAtIndexPath:idx];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->commitEditingStyle) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        [rs.component() tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:idx];
    }
}

#pragma mark - delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->willDisplayCell) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        [rs.component() tableView:tableView willDisplayCell:cell forRowAtIndexPath:idx];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.getSection(section);
    if (rs.responds()->willDisplayHeaderView) {
        [rs.component() tableView:tableView willDisplayHeaderView:view forSection:section - rs.range().location];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.getSection(section);
    if (rs.responds()->willDisplayFooterView) {
        [rs.component() tableView:tableView willDisplayFooterView:view forSection:section - rs.range().location];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->didEndDisplayingCell) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        [rs.component() tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:idx];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.getSection(section);
    if (rs.responds()->willDisplayCell) {
        [rs.component() tableView:tableView didEndDisplayingHeaderView:view forSection:section - rs.range().location];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.getSection(section);
    if (rs.responds()->willDisplayCell) {
        [rs.component() tableView:tableView didEndDisplayingFooterView:view forSection:section - rs.range().location];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->heightForRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() tableView:tableView heightForRowAtIndexPath:idx];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    auto rs = _cache.getSection(section);
    if (rs.responds()->heightForHeaderInSection) {
        return [rs.component() tableView:tableView heightForHeaderInSection:section - rs.range().location];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    auto rs = _cache.getSection(section);
    if (rs.responds()->heightForFooterInSection) {
        return [rs.component() tableView:tableView heightForFooterInSection:section - rs.range().location];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0) {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->estimatedHeightForRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() tableView:tableView estimatedHeightForRowAtIndexPath:idx];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0) {
    auto rs = _cache.getSection(section);
    if (rs.responds()->estimatedHeightForHeaderInSection) {
        return [rs.component() tableView:tableView estimatedHeightForHeaderInSection:section - rs.range().location];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0) {
    auto rs = _cache.getSection(section);
    if (rs.responds()->estimatedHeightForFooterInSection) {
        return [rs.component() tableView:tableView estimatedHeightForFooterInSection:section - rs.range().location];
    }
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    auto rs = _cache.getSection(section);
    if (rs.responds()->viewForHeaderInSection) {
        return [rs.component() tableView:tableView viewForHeaderInSection:section - rs.range().location];
    }
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    auto rs = _cache.getSection(section);
    if (rs.responds()->viewForFooterInSection) {
        return [rs.component() tableView:tableView viewForFooterInSection:section - rs.range().location];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->shouldHighlightRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() tableView:tableView shouldHighlightRowAtIndexPath:idx];
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->didHighlightRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        [rs.component() tableView:tableView didHighlightRowAtIndexPath:idx];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->didUnhighlightRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        [rs.component() tableView:tableView didUnhighlightRowAtIndexPath:idx];
    }
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->willSelectRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        NSIndexPath *ret = [rs.component() tableView:tableView willSelectRowAtIndexPath:idx];
        NSIndexPath *fix = [NSIndexPath indexPathForRow:ret.row inSection:ret.section + rs.range().location];
        return fix;
    }
    return indexPath;
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->canEditRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        NSIndexPath *ret = [rs.component() tableView:tableView willDeselectRowAtIndexPath:idx];
        NSIndexPath *fix = [NSIndexPath indexPathForRow:ret.row inSection:ret.section + rs.range().location];
        return fix;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->didSelectRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        [rs.component() tableView:tableView didSelectRowAtIndexPath:idx];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->didDeselectRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        [rs.component() tableView:tableView didDeselectRowAtIndexPath:idx];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->editingStyleForRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() tableView:tableView editingStyleForRowAtIndexPath:idx];
    }
    return UITableViewCellEditingStyleNone;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->titleForDeleteConfirmationButtonForRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:idx];
    }
    return nil;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->editActionsForRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() tableView:tableView editActionsForRowAtIndexPath:idx];
    }
    return nil;
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos) {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->leadingSwipeActionsConfigurationForRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() tableView:tableView leadingSwipeActionsConfigurationForRowAtIndexPath:idx];
    }
    return nil;
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos) {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->trailingSwipeActionsConfigurationForRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() tableView:tableView trailingSwipeActionsConfigurationForRowAtIndexPath:idx];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->shouldIndentWhileEditingRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() tableView:tableView shouldIndentWhileEditingRowAtIndexPath:idx];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath __TVOS_PROHIBITED {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->willBeginEditingRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        [rs.component() tableView:tableView willBeginEditingRowAtIndexPath:idx];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(nullable NSIndexPath *)indexPath __TVOS_PROHIBITED {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->didEndEditingRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() tableView:tableView didEndEditingRowAtIndexPath:idx];
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->indentationLevelForRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() tableView:tableView indentationLevelForRowAtIndexPath:idx];
    }
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(5_0) {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->shouldShowMenuForRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() tableView:tableView shouldShowMenuForRowAtIndexPath:idx];
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender NS_AVAILABLE_IOS(5_0) {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->canPerformAction) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() tableView:tableView canPerformAction:action forRowAtIndexPath:idx withSender:sender];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender NS_AVAILABLE_IOS(5_0) {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->performAction) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        [rs.component() tableView:tableView performAction:action forRowAtIndexPath:idx withSender:sender];
    }
}

// Focus

- (BOOL)tableView:(UITableView *)tableView canFocusRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(9_0) {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->canFocusRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() tableView:tableView canFocusRowAtIndexPath:idx];
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldSpringLoadRowAtIndexPath:(NSIndexPath *)indexPath withContext:(id<UISpringLoadedInteractionContext>)context API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos, watchos) {
    auto rs = _cache.getSection(indexPath.section);
    if (rs.responds()->shouldSpringLoadRowAtIndexPath) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - rs.range().location];
        return [rs.component() tableView:tableView shouldSpringLoadRowAtIndexPath:idx withContext:context];
    }
    return NO;
}

@end
