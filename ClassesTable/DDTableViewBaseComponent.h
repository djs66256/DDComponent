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

- (NSInteger)convertSection:(NSInteger)section toSuperComponent:(DDTableViewBaseComponent *)comp;
- (NSInteger)convertSection:(NSInteger)section toSubComponent:(DDTableViewBaseComponent *)comp;

- (NSInteger)convertToGlobalSection:(NSInteger)section;
- (NSInteger)convertFromGlobalSection:(NSInteger)section;

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toSuperComponent:(DDTableViewBaseComponent *)comp;
- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toSubComponent:(DDTableViewBaseComponent *)comp;

- (NSIndexPath *)convertToGlobalIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)convertFromGlobalIndexPath:(NSIndexPath *)indexPath;

- (DDTableViewBaseComponent *)componentAtIndexPath:(NSIndexPath *)indexPath;

// Here, indexPath is all relative indexPath, not equal to tableView's indexPath.
- (__kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

- (void)selectRowAtIndexPath:(nullable NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

- (nullable __kindof UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)indexPathForCell:(UITableViewCell *)cell;

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
