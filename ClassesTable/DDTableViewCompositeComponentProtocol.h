//
//  DDTableViewCompositeComponentProtocol.h
//  DDTableViewComponent
//
//  Created by daniel on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDTableViewResponds.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DDTableViewCompositeComponentProtocol <NSObject>

- (void)rebuildCache;
- (const DD::TableViewComponent::TableViewResponds *)respondsInfo;

@end

NS_ASSUME_NONNULL_END
