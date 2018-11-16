//
//  NMTableViewRootComponent.h
//  NMTableViewComponent
//
//  Created by hzduanjiashun on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#import "NMTableViewSectionComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface NMTableViewRootComponent : NMTableViewSectionComponent

@property (nonatomic, strong) UITableView *tableView;

- (instancetype)initWithTableView:(UITableView *)tableView;

- (void)setNeedReload;
- (void)reloadData;
- (void)reloadDifferences;

@end

NS_ASSUME_NONNULL_END
