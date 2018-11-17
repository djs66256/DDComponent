//
//  DDTableViewStatusComponent.h
//  Component
//
//  Created by daniel on 2018/11/17.
//  Copyright © 2018 Daniel. All rights reserved.
//

#import "DDTableViewSectionComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDTableViewStatusComponent : DDTableViewHeaderFooterSectionComponent

@property (nonatomic, strong) NSString *state;

- (nullable DDTableViewSectionComponent *)componentForState:(NSString *)state;
- (nullable DDTableViewSectionComponent *)objectForKeyedSubscript:(NSString *)state;
- (void)setComponent:(nullable DDTableViewSectionComponent *)comp forState:(NSString *)state;
- (void)setObject:(nullable DDTableViewSectionComponent *)comp forKeyedSubscript:(NSString *)state;

@property (nonatomic, strong) NSArray<NSString *> *headerFooterWhiteList;

@end

NS_ASSUME_NONNULL_END
