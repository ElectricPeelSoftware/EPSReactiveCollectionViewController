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

@property (nonatomic) NSArray *firstColorSwatches;
@property (nonatomic) NSArray *secondColorSwatches;

- (void)addColorSwatchToSection:(NSInteger)section;
- (void)removeColorSwatch:(EPSColorSwatch *)swatch fromSection:(NSInteger)section;

@end
