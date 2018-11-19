//
//  DDTableViewHeaderFooterSectionDemoComponent.h
//  Component
//
//  Created by daniel on 2018/11/17.
//  Copyright © 2018 Daniel. All rights reserved.
//

#import "DDTableViewComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDTableViewHeaderFooterSectionDemoComponent : DDTableViewHeaderFooterSectionComponent

@property (nonatomic, strong) NSArray<NSArray<NSString *> *> *demoData;

+ (instancetype)componentWithData:(NSArray<NSArray<NSString *> *> *)demoData;

@end

NS_ASSUME_NONNULL_END
