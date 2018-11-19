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
#import "DDTableViewHeaderDemoComponent.h"
#import "DDTableViewFooterDemoComponent.h"

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
    
    DDTableViewItemGroupSectionComponent *section0 = [DDTableViewItemGroupSectionComponent componentWithSubComponents:
                                                   @[
                                                     [DDTableViewItemDemoComponent new],
                                                     [DDTableViewItemDemoComponent new]
                                                     ]];
    section0.header = [DDTableViewHeaderDemoComponent new];
    section0.footer = [DDTableViewFooterDemoComponent new];
    
    DDTableViewHeaderFooterSectionDemoComponent *section1 = [DDTableViewHeaderFooterSectionDemoComponent componentWithHeader:[DDTableViewHeaderDemoComponent new]
                                                                                                                      footer:[DDTableViewFooterDemoComponent new]];
    
    DDTableViewSectionGroupComponent *sectionGroup = [DDTableViewSectionGroupComponent componentWithSubComponents:
                                                      @[[DDTableViewItemGroupSectionComponent componentWithSubComponents:
                                                         @[
                                                           [DDTableViewItemDemoComponent new],
                                                           [DDTableViewItemDemoComponent new]
                                                           ]],
                                                        [DDTableViewHeaderFooterSectionDemoComponent new],
                                                        [DDTableViewHeaderFooterSectionDemoComponent new]
                                                        ]];
    
    DDTableViewSectionGroupComponent *g = [DDTableViewSectionGroupComponent componentWithSubComponents:
                                           @[
                                             section0,
                                             section1,
                                             sectionGroup
                                             ]];
    DDTableViewStatusComponent *status = [DDTableViewStatusComponent componentWithComponents:
                                          @{ @"normal": g }];
    self.rootComponent.subComponents = @[status];
    
    status.state = @"normal";
    
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
