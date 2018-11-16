//
//  NMTableViewCompositeComponentProtocol.h
//  NMTableViewComponent
//
//  Created by hzduanjiashun on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMTableViewResponds.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NMTableViewCompositeComponentProtocol <NSObject>

- (void)rebuildCache;
- (NM::TableViewComponent::TableViewResponds&)respondsInfo;

@end

NS_ASSUME_NONNULL_END
