//
//  NMTableViewSectionGroupComponent.h
//  NMTableViewComponent
//
//  Created by hzduanjiashun on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMTableViewSectionComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface NMTableViewSectionGroupComponent : NMTableViewSectionComponent

@property (nonatomic, strong) NMTableViewSectionGroupComponent *superComponent;
@property (nonatomic, strong) NSArray<NMTableViewSectionComponent *> *subComponents;

- (void)prepareCells NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
