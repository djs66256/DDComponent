//
//  DDTableViewItemComponent.h
//  DDTableViewComponent
//
//  Created by daniel on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDTableViewComponentProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDTableViewItemComponent : NSObject <DDTableViewComponentProtocol>

@property (nonatomic, weak) id<DDTableViewComponentProtocol> superComponent;

- (void)prepareCells:(UITableView *)tableView NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
