//
//  DDTableViewItemComponent.h
//  DDTableViewComponent
//
//  Created by daniel on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDTableViewBaseComponent.h"

NS_ASSUME_NONNULL_BEGIN
@class DDTableViewSectionComponent;
@interface DDTableViewItemComponent : DDTableViewBaseComponent

@property (nonatomic, weak) DDTableViewSectionComponent *superComponent;

@end

NS_ASSUME_NONNULL_END
