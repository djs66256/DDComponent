//
//  ObjcImagesComponent.m
//  Component
//
//  Created by hzduanjiashun on 2018/7/26.
//  Copyright © 2018年 Daniel. All rights reserved.
//

#import "ObjcImagesComponent.h"
#import "ObjcImageCollectionViewCell.h"

@implementation ObjcTitleModel
@end

@implementation ObjcImagesComponent

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.size = CGSizeMake(80, 80);
        self.lineSpacing = 5;
        self.itemSpacing = 5;
    }
    return self;
}

- (void)prepareCollectionView {
    [super prepareCollectionView];
    
    [self.collectionView registerClass:ObjcImageCollectionViewCell.class
            forCellWithReuseIdentifier:NSStringFromClass(ObjcImageCollectionViewCell.class)];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ObjcImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ObjcImageCollectionViewCell.class) forIndexPath:indexPath];
    
    return cell;
}

/* override this for size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = ...;
    CGFloat height = ...;
    return CGSizeMake(width, height);
}
*/

@end
