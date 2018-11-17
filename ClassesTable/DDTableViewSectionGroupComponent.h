//
//  DDTableViewSectionGroupComponent.h
//  DDTableViewComponent
//
//  Created by daniel on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDTableViewSectionComponent.h"
#import "DDTableViewComponentMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDTableViewSectionGroupComponent : DDTableViewSectionComponent

@property (nonatomic, weak) DDTableViewSectionGroupComponent *superComponent;

@property (nonatomic, strong) NSArray<DDTableViewSectionComponent *> *subComponents;

@end

NS_ASSUME_NONNULL_END
