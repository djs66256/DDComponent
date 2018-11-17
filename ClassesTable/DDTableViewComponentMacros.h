//
//  DDTableViewComponentMacros.h
//  Component
//
//  Created by daniel on 2018/11/16.
//  Copyright © 2018 Daniel. All rights reserved.
//

#ifndef DDTableViewComponentMacros_h
#define DDTableViewComponentMacros_h

#define DDNeedOverride()  [[NSException exceptionWithName:@"Need override!" \
                                                   reason:[NSString stringWithFormat:@"Component (%@) need override %s!", self, sel_getName(_cmd)] \
                                                 userInfo:nil] raise];

#if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
# define FINAL_CLASS __attribute__((objc_subclassing_restricted))
#else
# define FINAL_CLASS
#endif

#endif /* DDTableViewComponentMacros_h */
