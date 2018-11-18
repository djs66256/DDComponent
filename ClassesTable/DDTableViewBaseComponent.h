//
//  DDTableViewBaseComponent.h
//  Component
//
//  Created by Daniel on 2018/11/18.
//  Copyright © 2018 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDTableViewComponentProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDTableViewBaseComponent : NSObject <DDTableViewComponentProtocol>

@property (nonatomic, weak) id<DDTableViewComponentProtocol> superComponent;

@end

NS_ASSUME_NONNULL_END
