//
//  DDTableViewBaseComponent.m
//  Component
//
//  Created by Daniel on 2018/11/18.
//  Copyright © 2018 Daniel. All rights reserved.
//

#import "DDTableViewBaseComponent.h"
#import "DDTableViewRootComponent.h"

@implementation DDTableViewBaseComponent

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
