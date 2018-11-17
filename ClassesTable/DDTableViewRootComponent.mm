//
//  DDTableViewRootComponent.m
//  DDTableViewComponent
//
//  Created by daniel on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#import "DDTableViewRootComponent.h"
#import "DDTableViewCompositeComponentProtocol.h"
#import "DDTableViewResponds.h"

using namespace DD::TableViewComponent;
@interface DDTableViewSectionGroupComponent (internal) <DDTableViewCompositeComponentProtocol>

@end

@implementation DDTableViewRootComponent {
    BOOL _needReload;
    ScrollResponds _scrollResponds;
}
@synthesize tableView = _tableView;

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self) {
        _tableView = tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _scrollViewDelegate = tableView.delegate;
    }
    return self;
}

- (id<DDTableViewComponentProtocol>)superComponent {
    return nil;
}

- (DDTableViewRootComponent *)rootComponent {
    return self;
}

- (void)setScrollViewDelegate:(id<UIScrollViewDelegate>)scrollViewDelegate {
    _scrollViewDelegate = scrollViewDelegate;
    _scrollResponds.fill(scrollViewDelegate);
}

- (void)reloadData {
    [self rebuildCache];
    [self.tableView reloadData];
}

- (void)beginUpdate {
    [self.tableView beginUpdates];
}

- (void)commitUpdate {
    [self.tableView endUpdates];
}

- (void)performBatchUpdate:(void (^)())block {
}

#pragma mark - scroll delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_scrollResponds.scrollViewDidScroll) {
        [_scrollViewDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_scrollResponds.scrollViewWillBeginDragging) {
        [_scrollViewDelegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0) {
    if (_scrollResponds.scrollViewWillEndDragging) {
        [_scrollViewDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_scrollResponds.scrollViewDidEndDragging) {
        [_scrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (_scrollResponds.scrollViewWillBeginDecelerating) {
        [_scrollViewDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_scrollResponds.scrollViewDidEndDecelerating) {
        [_scrollViewDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_scrollResponds.scrollViewDidEndScrollingAnimation) {
        [_scrollViewDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if (_scrollResponds.scrollViewShouldScrollToTop) {
        return [_scrollViewDelegate scrollViewShouldScrollToTop:scrollView];
    }
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (_scrollResponds.scrollViewDidScrollToTop) {
        [_scrollViewDelegate scrollViewDidScrollToTop:scrollView];
    }
}

- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView API_AVAILABLE(ios(11.0), tvos(11.0)) {
    if (_scrollResponds.scrollViewDidChangeAdjustedContentInset) {
        [_scrollViewDelegate scrollViewDidChangeAdjustedContentInset:scrollView];
    }
}

@end
