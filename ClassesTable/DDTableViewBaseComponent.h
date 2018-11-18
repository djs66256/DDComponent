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

@property (nonatomic, weak) __kindof DDTableViewBaseComponent *superComponent;

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toSuperComponent:(DDTableViewBaseComponent *)comp;
- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toSubComponent:(DDTableViewBaseComponent *)comp;

- (NSIndexPath *)convertToGlobalIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)convertFromGlobalIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
