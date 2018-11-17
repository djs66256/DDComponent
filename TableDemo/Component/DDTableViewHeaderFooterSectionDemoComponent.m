//
//  DDTableViewHeaderFooterSectionDemoComponent.m
//  Component
//
//  Created by daniel on 2018/11/17.
//  Copyright © 2018 Daniel. All rights reserved.
//

#import "DDTableViewHeaderFooterSectionDemoComponent.h"
#import "DDComponentDemoTableViewCell.h"

@implementation DDTableViewHeaderFooterSectionDemoComponent

- (void)prepareCells:(UITableView *)tableView {
    [super prepareCells:tableView];
    printf("%s\n", sel_getName(_cmd));
    [tableView registerClass:[DDComponentDemoTableViewCell class]
      forCellReuseIdentifier:@"DDComponentDemoTableViewCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    printf("%s\n", sel_getName(_cmd));
    DDComponentDemoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDComponentDemoTableViewCell"];
    cell.contentView.backgroundColor = arc4random()%100 > 50 ? UIColor.redColor : UIColor.greenColor;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    printf("%s\n", sel_getName(_cmd));
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

@end
