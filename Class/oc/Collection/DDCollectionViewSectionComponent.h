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

@interface DDCollectionViewSectionComponent : DDCollectionViewBaseComponent

/**
 It will fit the collection height or width when use DDComponentAutomaticDimension.
 */
@property (assign, nonatomic) CGSize headerSize;
@property (assign, nonatomic) CGSize footerSize;
@property (assign, nonatomic) CGSize size;

/**
 It will use FlowLayout's properties if DDComponentAutomaticDimension.
 */
@property (assign, nonatomic) CGFloat lineSpacing;
@property (assign, nonatomic) CGFloat itemSpacing;
@property (assign, nonatomic) UIEdgeInsets sectionInset;

@end


@interface DDCollectionViewHeaderFooterSectionComponent : DDCollectionViewSectionComponent

@property (strong, nonatomic, nullable) __kindof DDCollectionViewSectionComponent *headerComponent;
@property (strong, nonatomic, nullable) __kindof DDCollectionViewSectionComponent *footerComponent;
@property (strong, nonatomic, nullable) __kindof DDCollectionViewSectionComponent *headerFooterComponent;

@end

@interface DDCollectionViewItemGroupComponent : DDCollectionViewHeaderFooterSectionComponent

@property (strong, nonatomic, nullable) NSArray<__kindof DDCollectionViewBaseComponent *> *subComponents;

- (__kindof DDCollectionViewBaseComponent * _Nullable)componentAtItem:(NSInteger)atItem;

@end
