//
//  DDTableComponentCustomViewController.m
//  Component
//
//  Created by daniel on 2018/11/17.
//  Copyright © 2018 Daniel. All rights reserved.
//

#import "DDTableComponentCustomViewController.h"
#import "DDTableViewItemDemoComponent.h"
#import "DDTableViewComponent.h"
#import "DDTableViewHeaderFooterSectionDemoComponent.h"

@interface DDTableComponentCustomViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DDTableViewRootComponent *rootComponent;

@end

@implementation DDTableComponentCustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.tableView];
    
    self.rootComponent = [[DDTableViewRootComponent alloc] initWithTableView:self.tableView];
    
    DDTableViewItemGroupSectionComponent *items = [DDTableViewItemGroupSectionComponent new];
    items.subComponents = @[[DDTableViewItemDemoComponent new], [DDTableViewItemDemoComponent new]];
    
    DDTableViewHeaderFooterSectionDemoComponent *section = [DDTableViewHeaderFooterSectionDemoComponent new];
    
    DDTableViewSectionGroupComponent *sectionGroup = [DDTableViewSectionGroupComponent new];
    
    DDTableViewItemGroupSectionComponent *items2 = [DDTableViewItemGroupSectionComponent new];
    items2.subComponents = @[[DDTableViewItemDemoComponent new], [DDTableViewItemDemoComponent new]];
    sectionGroup.subComponents = @[items2, [DDTableViewHeaderFooterSectionDemoComponent new]];
    
    DDTableViewStatusComponent *status = [DDTableViewStatusComponent new];
    DDTableViewSectionGroupComponent *g = [DDTableViewSectionGroupComponent new];
    g.subComponents = @[items, section, sectionGroup];
    status[@"normal"] = g;
    status.state = @"normal";
    
    self.rootComponent.subComponents = @[status];
    
    [self.rootComponent reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
