//
//  DDTableViewComponentHelper.m
//  Component
//
//  Created by hzduanjiashun on 2018/11/19.
//  Copyright © 2018 Daniel. All rights reserved.
//

#import "DDTableViewComponentHelper.h"


@implementation DDTableViewHeaderFooterSectionComponent (Helper)

+ (instancetype)componentWithHeader:(DDTableViewItemComponent *)header
                             footer:(DDTableViewItemComponent *)footer {
    DDTableViewHeaderFooterSectionComponent *comp = [self new];
    comp.header = header;
    comp.footer = footer;
    return comp;
}

@end

@implementation DDTableViewItemGroupSectionComponent (Helper)

+ (instancetype)componentWithHeader:(DDTableViewItemComponent *)header
                             footer:(DDTableViewItemComponent *)footer
                      subComponents:(NSArray<DDTableViewItemComponent *> *)subComponents {
    DDTableViewItemGroupSectionComponent *comp = [self componentWithHeader:header footer:footer];
    comp.subComponents = subComponents;
    return comp;
}

+ (instancetype)componentWithSubComponents:(NSArray<DDTableViewItemComponent *> *)subComponents {
    DDTableViewItemGroupSectionComponent *comp = [self new];
    comp.subComponents = subComponents;
    return comp;
}

@end

@implementation DDTableViewSectionGroupComponent (Helper)

+ (instancetype)componentWithSubComponents:(NSArray<DDTableViewSectionComponent *> *)subComponents {
    DDTableViewSectionGroupComponent *comp = [self new];
    comp.subComponents = subComponents;
    return comp;
}

@end

@implementation DDTableViewRootComponent (Helper)

+ (instancetype)componentWithTableView:(UITableView *)tableView
                         subComponents:(NSArray<DDTableViewSectionComponent *> *)subComponents {
    DDTableViewRootComponent *comp = [[self alloc] initWithTableView:tableView];
    comp.subComponents = subComponents;
    return comp;
}

@end

@implementation DDTableViewStatusComponent (Helper)

+ (instancetype)componentWithComponents:(NSDictionary<NSString *, DDTableViewSectionComponent *> *)components {
    DDTableViewStatusComponent *comp = [self new];
    [components enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, DDTableViewSectionComponent * _Nonnull obj, BOOL * _Nonnull stop) {
        [comp setComponent:obj forState:key];
    }];
    return comp;
}

@end
