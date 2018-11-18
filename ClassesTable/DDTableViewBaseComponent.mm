//
//  DDTableViewBaseComponent.m
//  Component
//
//  Created by Daniel on 2018/11/18.
//  Copyright © 2018 Daniel. All rights reserved.
//

#import "DDTableViewBaseComponent.h"
#import "DDTableViewRootComponent.h"
#import "DDTableViewComponentInternal.h"

@implementation DDTableViewBaseComponent

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

#pragma mark - method

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toSuperComponent:(DDTableViewBaseComponent *)comp {
    if (self == comp) {
        return indexPath;
    }
    else {
        return [self.superComponent convertIndexPath:indexPath fromComponent:self toSuperComponent:comp];
    }
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath fromComponent:(DDTableViewBaseComponent *)from toSuperComponent:(DDTableViewBaseComponent *)comp {
    return [self convertIndexPath:indexPath toSuperComponent:comp];
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toSubComponent:(DDTableViewBaseComponent *)comp {
    if (self == comp) {
        return indexPath;
    }
    else {
        return nil;
    }
}

- (NSIndexPath *)convertToGlobalIndexPath:(NSIndexPath *)indexPath {
    return [self convertIndexPath:indexPath toSuperComponent:self.rootComponent];
}

- (NSIndexPath *)convertFromGlobalIndexPath:(NSIndexPath *)indexPath {
    return [self.rootComponent convertIndexPath:indexPath toSubComponent:self];
}

@end
