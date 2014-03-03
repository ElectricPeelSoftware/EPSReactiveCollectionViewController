//
//  EPSExampleViewModel.h
//  EPSReactiveCollectionViewController
//
//  Created by Peter Stuart on 3/3/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EPSColorSwatch;

@interface EPSExampleViewModel : NSObject

@property (nonatomic) NSArray *sortedColorSwatches;

- (void)addColorSwatch;
- (void)removeColorSwatch:(EPSColorSwatch *)swatch;

@end
