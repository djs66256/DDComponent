//
//  ObjcImagesComponent.h
//  Component
//
//  Created by daniel on 2018/7/26.
//  Copyright © 2018年 Daniel. All rights reserved.
//

#import <DDComponent/DDComponent.h>

@interface ObjcTitleModel : NSObject

@property (nonatomic, strong) NSString *title;

@end

@interface ObjcImagesComponent : DDCollectionViewHeaderFooterSectionComponent

@property (nonatomic, strong) NSArray<ObjcTitleModel *> *cellModels;

@end
