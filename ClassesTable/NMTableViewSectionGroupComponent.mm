//
//  NMTableViewSectionGroupComponent.m
//  NMTableViewComponent
//
//  Created by hzduanjiashun on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#include <vector>
#include <tuple>
#import "NMTableViewSectionGroupComponent.h"
#import "NMTableViewComponentCache.h"

using namespace NM::TableViewComponent;

@implementation NMTableViewSectionGroupComponent {
    SectionCache _cache;
}

#pragma mark - interface
- (NMTableViewRootComponent *)rootComponent {
    return self.superComponent.rootComponent;
}

- (UITableView *)tableView {
    return self.superComponent.tableView;
}

- (void)prepareCells {}

#pragma mark - reload
- (void)rebuildCachedIndexPaths {
    _cache.fill(self.subComponents, self.tableView);
}


- (void)reloadData {
    [self rebuildCachedIndexPaths];
}

#pragma mark - table view datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cache.numberOfSection();
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    auto rs = _cache.respondsInSection(section);
    return [std::get<1>(rs) tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.respondsInSection(indexPath.section);
    return [std::get<1>(rs) tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    auto rs = _cache.respondsInSection(section);
    if (std::get<0>(rs)->titleForHeaderInSection) {
        return [std::get<1>(rs) tableView:tableView titleForHeaderInSection:section];
    }
    return nil;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    auto rs = _cache.respondsInSection(section);
    if (std::get<0>(rs)->titleForFooterInSection) {
        return [std::get<1>(rs) tableView:tableView titleForHeaderInSection:section];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->canEditRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->commitEditingStyle) {
        [std::get<1>(rs) tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

#pragma mark - delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->willDisplayCell) {
        [std::get<1>(rs) tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.respondsInSection(section);
    if (std::get<0>(rs)->willDisplayHeaderView) {
        [std::get<1>(rs) tableView:tableView willDisplayHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.respondsInSection(section);
    if (std::get<0>(rs)->willDisplayFooterView) {
        [std::get<1>(rs) tableView:tableView willDisplayFooterView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->didEndDisplayingCell) {
        [std::get<1>(rs) tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.respondsInSection(section);
    if (std::get<0>(rs)->willDisplayCell) {
        [std::get<1>(rs) tableView:tableView didEndDisplayingHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.respondsInSection(section);
    if (std::get<0>(rs)->willDisplayCell) {
        [std::get<1>(rs) tableView:tableView didEndDisplayingFooterView:view forSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->heightForRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    auto rs = _cache.respondsInSection(section);
    if (std::get<0>(rs)->heightForHeaderInSection) {
        return [std::get<1>(rs) tableView:tableView heightForHeaderInSection:section];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    auto rs = _cache.respondsInSection(section);
    if (std::get<0>(rs)->heightForFooterInSection) {
        return [std::get<1>(rs) tableView:tableView heightForFooterInSection:section];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0) {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->estimatedHeightForRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0) {
    auto rs = _cache.respondsInSection(section);
    if (std::get<0>(rs)->estimatedHeightForHeaderInSection) {
        return [std::get<1>(rs) tableView:tableView estimatedHeightForHeaderInSection:section];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0) {
    auto rs = _cache.respondsInSection(section);
    if (std::get<0>(rs)->estimatedHeightForFooterInSection) {
        return [std::get<1>(rs) tableView:tableView estimatedHeightForFooterInSection:section];
    }
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    auto rs = _cache.respondsInSection(section);
    if (std::get<0>(rs)->viewForHeaderInSection) {
        return [std::get<1>(rs) tableView:tableView viewForHeaderInSection:section];
    }
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    auto rs = _cache.respondsInSection(section);
    if (std::get<0>(rs)->viewForFooterInSection) {
        return [std::get<1>(rs) tableView:tableView viewForFooterInSection:section];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->shouldHighlightRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->didHighlightRowAtIndexPath) {
        [std::get<1>(rs) tableView:tableView didHighlightRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->didUnhighlightRowAtIndexPath) {
        [std::get<1>(rs) tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
    }
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->willSelectRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView willSelectRowAtIndexPath:indexPath];
    }
    return indexPath;
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->canEditRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView willDeselectRowAtIndexPath:indexPath];
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->didSelectRowAtIndexPath) {
        [std::get<1>(rs) tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->didDeselectRowAtIndexPath) {
        [std::get<1>(rs) tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->editingStyleForRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    }
    return UITableViewCellEditingStyleNone;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->titleForDeleteConfirmationButtonForRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->editActionsForRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView editActionsForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos) {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->leadingSwipeActionsConfigurationForRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView leadingSwipeActionsConfigurationForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos) {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->trailingSwipeActionsConfigurationForRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView trailingSwipeActionsConfigurationForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->shouldIndentWhileEditingRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath __TVOS_PROHIBITED {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->willBeginEditingRowAtIndexPath) {
        [std::get<1>(rs) tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(nullable NSIndexPath *)indexPath __TVOS_PROHIBITED {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->didEndEditingRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView didEndEditingRowAtIndexPath:indexPath];
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->indentationLevelForRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(5_0) {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->shouldShowMenuForRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender NS_AVAILABLE_IOS(5_0) {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->canPerformAction) {
        return [std::get<1>(rs) tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender NS_AVAILABLE_IOS(5_0) {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->performAction) {
        [std::get<1>(rs) tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
}

// Focus

- (BOOL)tableView:(UITableView *)tableView canFocusRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(9_0) {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->canFocusRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView canFocusRowAtIndexPath:indexPath];
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldSpringLoadRowAtIndexPath:(NSIndexPath *)indexPath withContext:(id<UISpringLoadedInteractionContext>)context API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos, watchos) {
    auto rs = _cache.respondsInSection(indexPath.section);
    if (std::get<0>(rs)->shouldSpringLoadRowAtIndexPath) {
        return [std::get<1>(rs) tableView:tableView shouldSpringLoadRowAtIndexPath:indexPath withContext:context];
    }
    return NO;
}

@end
