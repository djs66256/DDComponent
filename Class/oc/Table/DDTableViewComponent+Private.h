//
//  DDTableViewComponent+Private.h
//  Pods
//
//  Created by hzduanjiashun on 2017/6/12.
//
//

#ifndef DDTableViewComponent_Private_h
#define DDTableViewComponent_Private_h

#import "DDTableViewComponent.h"

@interface DDTableViewBaseComponent()

- (NSInteger)firstRowOfComponent:(id<DDTableViewComponent>)comp;
- (NSInteger)firstSectioniOfComponent:(id<DDTableViewComponent>)comp;

@end

#endif /* DDTableViewComponent_Private_h */
