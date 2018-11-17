//
//  DDTableViewItemComponent.m
//  DDTableViewComponent
//
//  Created by daniel on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#import "DDTableViewItemComponent.h"
#import "DDTableViewRootComponent.h"
#import "DDTableViewComponentMacros.h"

@implementation DDTableViewItemComponent

- (UITableView *)tableView {
    return self.rootComponent.tableView;
}

- (DDTableViewRootComponent *)rootComponent {
    return self.superComponent.rootComponent;
}

- (void)prepareCells:(UITableView *)tableView {}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDNeedOverride()
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDNeedOverride();
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDNeedOverride();
    return nil;
}

@end
