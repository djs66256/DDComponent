//
//  DDTableViewStatusComponent.m
//  Component
//
//  Created by daniel on 2018/11/17.
//  Copyright © 2018 Daniel. All rights reserved.
//

#import "DDTableViewStatusComponent.h"
#import "DDTableViewCompositeComponentProtocol.h"
#import "DDTableViewComponentCache.h"
#import "DDTableViewComponentInternal.h"
#import "DDTableViewRootComponent.h"

using namespace DD::TableViewComponent;

@interface DDTableViewStatusComponent () <DDTableViewCompositeComponentProtocol>
@end

@implementation DDTableViewStatusComponent {
    NSArray<NSString *> *_headerFooterWhiteList;
    NSMutableDictionary<NSString *, DDTableViewSectionComponent *> *_components;
    const TableViewResponds *_responds;
    DDTableViewSectionComponent *_currentComponent;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _components = [NSMutableDictionary new];
    }
    return self;
}

- (void)setComponent:(DDTableViewSectionComponent *)comp forState:(NSString *)state {
    if (state == nil) return;
    DDTableViewSectionComponent *prevComp = _components[state];
    if (prevComp.superComponent == self) prevComp.superComponent = nil;
    comp.superComponent = self;
    if (UITableView *tableView = self.rootComponent.tableView) {
        [comp prepareCells:tableView];
    }
    _components[state] = comp;
}

- (DDTableViewSectionComponent *)componentForState:(NSString *)state {
    if (state == nil) return nil;
    return _components[state];
}

- (DDTableViewSectionComponent *)objectForKeyedSubscript:(NSString *)state {
    return [self componentForState:state];
}

- (void)setObject:(DDTableViewSectionComponent *)comp forKeyedSubscript:(NSString *)state {
    [self setComponent:comp forState:state];
}

- (void)prepareCells:(UITableView *)tableView {
    [super prepareCells:tableView];
    [_components enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, DDTableViewSectionComponent * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj prepareCells:tableView];
    }];
}

#pragma mark - convert
- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toSubComponent:(DDTableViewBaseComponent *)comp {
    if (self == comp) return indexPath;
    return [_currentComponent convertIndexPath:indexPath toSubComponent:comp];
}

- (NSInteger)convertSection:(NSInteger)section toSubComponent:(DDTableViewBaseComponent *)comp {
    if (self == comp) return section;
    return [_currentComponent convertSection:section toSubComponent:comp];
}

#pragma mark - composite
- (const TableViewResponds *)respondsInfo {
    return _responds;
}

- (void)rebuildCache {
    [super rebuildCache];
    
    DDTableViewSectionComponent *comp = self[self.state];
    if ([comp conformsToProtocol:@protocol(DDTableViewCompositeComponentProtocol)]) {
        id<DDTableViewCompositeComponentProtocol> composite = (id<DDTableViewCompositeComponentProtocol>)comp;
        [composite rebuildCache];
        _responds = [composite respondsInfo];
    }
    else {
        _responds = RespondsManager::getInstance().respondsForObject(comp);
    }
    
    _currentComponent = comp;
}

#pragma mark - dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_currentComponent numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_currentComponent tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_currentComponent tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_responds->titleForHeaderInSection) {
        return [_currentComponent tableView:tableView titleForHeaderInSection:section];
    }
    return nil;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (_responds->titleForFooterInSection) {
        return [_currentComponent tableView:tableView titleForHeaderInSection:section];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_responds->canEditRowAtIndexPath) {
        return [_currentComponent tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_responds->commitEditingStyle) {
        [_currentComponent tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

#pragma mark - delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_responds->willDisplayCell) {
        [_currentComponent tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    if (_responds->willDisplayHeaderView) {
        [_currentComponent tableView:tableView willDisplayHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    if (_responds->willDisplayFooterView) {
        [_currentComponent tableView:tableView willDisplayFooterView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0) {
    if (_responds->didEndDisplayingCell) {
        [_currentComponent tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    if (_responds->willDisplayCell) {
        [_currentComponent tableView:tableView didEndDisplayingHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    if (_responds->willDisplayCell) {
        [_currentComponent tableView:tableView didEndDisplayingFooterView:view forSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_responds->heightForRowAtIndexPath) {
        return [_currentComponent tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_responds->heightForHeaderInSection) {
        return [_currentComponent tableView:tableView heightForHeaderInSection:section];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (_responds->heightForFooterInSection) {
        return [_currentComponent tableView:tableView heightForFooterInSection:section];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0) {
    if (_responds->estimatedHeightForRowAtIndexPath) {
        return [_currentComponent tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0) {
    if (_responds->estimatedHeightForHeaderInSection) {
        return [_currentComponent tableView:tableView estimatedHeightForHeaderInSection:section];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0) {
    if (_responds->estimatedHeightForFooterInSection) {
        return [_currentComponent tableView:tableView estimatedHeightForFooterInSection:section];
    }
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_responds->viewForHeaderInSection) {
        return [_currentComponent tableView:tableView viewForHeaderInSection:section];
    }
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (_responds->viewForFooterInSection) {
        return [_currentComponent tableView:tableView viewForFooterInSection:section];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    if (_responds->shouldHighlightRowAtIndexPath) {
        return [_currentComponent tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    if (_responds->didHighlightRowAtIndexPath) {
        [_currentComponent tableView:tableView didHighlightRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    if (_responds->didUnhighlightRowAtIndexPath) {
        [_currentComponent tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
    }
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_responds->willSelectRowAtIndexPath) {
        return [_currentComponent tableView:tableView willSelectRowAtIndexPath:indexPath];
    }
    return indexPath;
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) {
    if (_responds->canEditRowAtIndexPath) {
        return [_currentComponent tableView:tableView willDeselectRowAtIndexPath:indexPath];
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_responds->didSelectRowAtIndexPath) {
        [_currentComponent tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) {
    if (_responds->didDeselectRowAtIndexPath) {
        [_currentComponent tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_responds->editingStyleForRowAtIndexPath) {
        return [_currentComponent tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    }
    return UITableViewCellEditingStyleNone;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED {
    if (_responds->titleForDeleteConfirmationButtonForRowAtIndexPath) {
        return [_currentComponent tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED {
    if (_responds->editActionsForRowAtIndexPath) {
        return [_currentComponent tableView:tableView editActionsForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos) {
    if (_responds->leadingSwipeActionsConfigurationForRowAtIndexPath) {
        return [_currentComponent tableView:tableView leadingSwipeActionsConfigurationForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos) {
    if (_responds->trailingSwipeActionsConfigurationForRowAtIndexPath) {
        return [_currentComponent tableView:tableView trailingSwipeActionsConfigurationForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_responds->shouldIndentWhileEditingRowAtIndexPath) {
        return [_currentComponent tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath __TVOS_PROHIBITED {
    if (_responds->willBeginEditingRowAtIndexPath) {
        [_currentComponent tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(nullable NSIndexPath *)indexPath __TVOS_PROHIBITED {
    if (_responds->didEndEditingRowAtIndexPath) {
        return [_currentComponent tableView:tableView didEndEditingRowAtIndexPath:indexPath];
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_responds->indentationLevelForRowAtIndexPath) {
        return [_currentComponent tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(5_0) {
    if (_responds->shouldShowMenuForRowAtIndexPath) {
        return [_currentComponent tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender NS_AVAILABLE_IOS(5_0) {
    if (_responds->canPerformAction) {
        return [_currentComponent tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender NS_AVAILABLE_IOS(5_0) {
    if (_responds->performAction) {
        [_currentComponent tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
}

// Focus

- (BOOL)tableView:(UITableView *)tableView canFocusRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(9_0) {
    if (_responds->canFocusRowAtIndexPath) {
        return [_currentComponent tableView:tableView canFocusRowAtIndexPath:indexPath];
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldSpringLoadRowAtIndexPath:(NSIndexPath *)indexPath withContext:(id<UISpringLoadedInteractionContext>)context API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos, watchos) {
    if (_responds->shouldSpringLoadRowAtIndexPath) {
        return [_currentComponent tableView:tableView shouldSpringLoadRowAtIndexPath:indexPath withContext:context];
    }
    return NO;
}
@end
