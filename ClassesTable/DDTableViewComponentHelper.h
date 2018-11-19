//
//  DDTableViewComponentHelper.h
//  Component
//
//  Created by hzduanjiashun on 2018/11/19.
//  Copyright © 2018 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDTableViewSectionComponent.h"
#import "DDTableViewSectionGroupComponent.h"
#import "DDTableViewRootComponent.h"
#import "DDTableViewStatusComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDTableViewHeaderFooterSectionComponent (Helper)

+ (instancetype)componentWithHeader:(DDTableViewItemComponent *)header
                             footer:(DDTableViewItemComponent *)footer;

@end

@interface DDTableViewItemGroupSectionComponent (Helper)

+ (instancetype)componentWithHeader:(DDTableViewItemComponent *)header
                             footer:(DDTableViewItemComponent *)footer
                      subComponents:(NSArray<DDTableViewItemComponent *> *)subComponents;

+ (instancetype)componentWithSubComponents:(NSArray<DDTableViewItemComponent *> *)subComponents;

@end

@interface DDTableViewSectionGroupComponent (Helper)

+ (instancetype)componentWithSubComponents:(NSArray<DDTableViewSectionComponent *> *)subComponents;

@end

@interface DDTableViewRootComponent (Helper)

+ (instancetype)componentWithTableView:(UITableView *)tableView
                         subComponents:(NSArray<DDTableViewSectionComponent *> *)subComponents;

@end

@interface DDTableViewStatusComponent (Helper)

+ (instancetype)componentWithComponents:(NSDictionary<NSString *, DDTableViewSectionComponent *> *)components;

@end

NS_ASSUME_NONNULL_END
