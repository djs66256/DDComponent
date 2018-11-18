//
//  DDTableViewComponentProtocol.h
//  DDTableViewComponent
//
//  Created by daniel on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DDTableViewRootComponent;

@protocol DDTableViewComponentProtocol <NSObject, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak, readonly) id<DDTableViewComponentProtocol> superComponent;
@property (nonatomic, strong, readonly) DDTableViewRootComponent *rootComponent;

- (void)prepareCells:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
