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

#import "DDCollectionViewItemComponent.h"
#import "DDCollectionViewSectionGroupComponent.h"

@implementation DDCollectionViewItemComponent

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = self.size;
    BOOL autoWidth = size.width == DDComponentAutomaticDimension;
    BOOL autoHeight = size.height == DDComponentAutomaticDimension;
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (autoWidth || autoHeight) {
        inset = [self.rootComponent collectionView:collectionView
                                            layout:collectionViewLayout
                            insetForSectionAtIndex:indexPath.section];
    }
    if (autoWidth) {
        size.width = MAX(collectionView.frame.size.width - inset.left - inset.right, 0);
    }
    if (autoHeight) {
        size.height = MAX(collectionView.frame.size.height - inset.top - inset.bottom, 0);
    }
    return size;
}

@end
