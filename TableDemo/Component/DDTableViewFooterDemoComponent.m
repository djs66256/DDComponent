//
//  DDTableViewFooterDemoComponent.m
//  Component
//
//  Created by hzduanjiashun on 2018/11/19.
//  Copyright © 2018 Daniel. All rights reserved.
//

#import "DDTableViewFooterDemoComponent.h"

@implementation DDTableViewFooterDemoComponent

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSInteger gSection = [self convertToGlobalSection:section];
    NSInteger lSection = [self convertFromGlobalSection:gSection];
    return [NSString stringWithFormat:@"Footer (%zd),(%zd)", gSection, lSection];
}

@end
