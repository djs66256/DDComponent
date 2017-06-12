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
#import "DDCollectionViewSectionComponent.h"
#import "DDCollectionViewSectionGroupComponent.h"

/**
 This component is for status changing.
 For example, a request should has 'Loading', 'Error', 'Empty Data', 'Normal Data'.
 And the component should show 'Loading' when request is loading.
 */
@interface DDCollectionViewStatusComponent : DDCollectionViewBaseComponent

/**
 You can change the state by this property.
 You must reloadData by yourself after currentState changed!
 */
@property (strong, nonatomic, nullable) NSString *currentState;
@property (readonly, nonatomic, nullable) DDCollectionViewBaseComponent *currentComponent;

- (DDCollectionViewBaseComponent * _Nullable)componentForState:(NSString * _Nullable)state;

/**
 <#Description#>

 @param comp Component for the state
 @param state Nil will do nothing
 */
- (void)setComponent:(DDCollectionViewBaseComponent * _Nullable)comp forState:(NSString * _Nullable)state;

@end


/**
 Like DDCollectionViewStatusComponent, but the header and footer will use statusComponent properties,
 not the subComponent's properties.
 */
@interface DDCollectionViewHeaderFooterStatusComponent : DDCollectionViewStatusComponent

@property (strong, nonatomic, nullable) __kindof DDCollectionViewSectionComponent *headerComponent;
@property (strong, nonatomic, nullable) __kindof DDCollectionViewSectionComponent *footerComponent;
@property (strong, nonatomic, nullable) __kindof DDCollectionViewSectionComponent *headerFooterComponent;

@end
