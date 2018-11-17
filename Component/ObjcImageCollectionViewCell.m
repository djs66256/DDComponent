//
//  ObjcImageCollectionViewCell.m
//  Component
//
//  Created by daniel on 2018/7/26.
//  Copyright © 2018年 Daniel. All rights reserved.
//

#import "ObjcImageCollectionViewCell.h"

@implementation ObjcImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_imageView];
    }
    return self;
}

@end
