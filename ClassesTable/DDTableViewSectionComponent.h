//
//  DDTableViewSectionComponent.h
//  DDTableViewComponent
//
//  Created by daniel on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDTableViewBaseComponent.h"
#import "DDTableViewItemComponent.h"
#import "DDTableViewComponentMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDTableViewSectionComponent : DDTableViewBaseComponent

@property (nonatomic, weak) DDTableViewSectionComponent *superComponent;

@end

@interface DDTableViewHeaderFooterSectionComponent : DDTableViewSectionComponent

@property (nonatomic, strong) DDTableViewItemComponent *header;
@property (nonatomic, strong) DDTableViewItemComponent *footer;

- (void)prepareCells:(UITableView *)tableView NS_REQUIRES_SUPER;

@end

FINAL_CLASS
@interface DDTableViewItemGroupSectionComponent : DDTableViewHeaderFooterSectionComponent

@property (nonatomic, strong) NSArray<DDTableViewItemComponent *> *subComponents;

- (void)prepareCells:(UITableView *)tableView NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
