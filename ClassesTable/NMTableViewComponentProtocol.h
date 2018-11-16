//
//  NMTableViewComponentProtocol.h
//  NMTableViewComponent
//
//  Created by hzduanjiashun on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NMTableViewRootComponent;

@protocol NMTableViewComponentProtocol <NSObject, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) id<NMTableViewComponentProtocol> superComponent;
@property (nonatomic, strong, readonly) NMTableViewRootComponent *rootComponent;

- (void)prepareCells;

@end

NS_ASSUME_NONNULL_END
