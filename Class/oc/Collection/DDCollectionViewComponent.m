// MIT License
//
// Copyright (c) 2016 Daniel (djs66256@163.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "DDCollectionViewComponent.h"
#import "DDCollectionViewComponent+Private.h"
#import "DDCollectionViewComponent+Cache.h"
#import "DDCollectionViewSectionGroupComponent.h"

const CGFloat DDComponentAutomaticDimension = CGFLOAT_MAX;

@implementation DDCollectionViewBaseComponent
@synthesize collectionView=_collectionView;
@synthesize dataSourceCacheEnable=_dataSourceCacheEnable;
//@synthesize sizeCacheEnable=_sizeCacheEnable;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataSourceCacheEnable = YES;
//        _sizeCacheEnable = YES;
    }
    return self;
}

- (DDCollectionViewRootComponent *)rootComponent {
    return self.superComponent.rootComponent;
}

- (void)setSuperComponent:(DDCollectionViewBaseComponent *)superComponent {
    _superComponent = superComponent;
    self.collectionView = _superComponent.collectionView;
}

- (UICollectionView *)collectionView {
    return _collectionView ?: self.superComponent.collectionView;
}

- (NSInteger)firstItemOfSubComponent:(id<DDCollectionViewComponent>)subComp {
    return 0;
}

- (NSInteger)firstSectionOfSubComponent:(id<DDCollectionViewComponent>)subComp {
    return 0;
}

- (void)prepareCollectionView {}

- (void)clearDataSourceCache {}
- (void)clearSizeCache {}

//- (void)willMoveToComponent:(DDCollectionViewBaseComponent *)component {}
//- (void)didMoveToComponent {}
//- (void)willMoveToRootComponent:(DDCollectionViewBaseComponent *)component {}
//- (void)didMoveToRootComponent {}

- (NSInteger)item {
    return [self.superComponent firstItemOfSubComponent:self];
}

- (NSInteger)section {
    return [self.superComponent firstSectionOfSubComponent:self];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(false, @"MUST override!");
    return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSAssert(false, @"MUST override!");
    return nil;
}

@end
