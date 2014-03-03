//
//  EPSExampleViewModel.m
//  EPSReactiveCollectionViewController
//
//  Created by Peter Stuart on 3/3/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import "EPSExampleViewModel.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "EPSColorSwatch.h"

@interface EPSExampleViewModel ()

@property (nonatomic) NSSet *colorSwatches;

@end

@implementation EPSExampleViewModel

- (id)init {
    self = [super init];
    if (self == nil) return nil;
    
    NSMutableSet *swatches = [NSMutableSet new];
    for (NSInteger index = 0; index < 5; index++) {
        [swatches addObject:[EPSExampleViewModel randomColorSwatch]];
    }
    
    _colorSwatches = swatches;
    
    RAC(self, sortedColorSwatches) = [RACObserve(self, colorSwatches)
        map:^NSArray *(NSSet *swatches){
            return [swatches sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"hue" ascending:YES] ]];
        }];
    
    return self;
}

- (void)addColorSwatch {
    // Make sure all swatches are unique
    EPSColorSwatch *newSwatch;
    do {
        newSwatch = [EPSExampleViewModel randomColorSwatch];
    } while ([self.colorSwatches containsObject:newSwatch]);
    
    self.colorSwatches = [self.colorSwatches setByAddingObject:newSwatch];
}

- (void)removeColorSwatch:(EPSColorSwatch *)swatch {
    NSMutableSet *colorSwatches = self.colorSwatches.mutableCopy;
    [colorSwatches removeObject:swatch];
    self.colorSwatches = colorSwatches;
}

+ (EPSColorSwatch *)randomColorSwatch {
    EPSColorSwatch *colorSwatch = [EPSColorSwatch new];
    
    double hue = (arc4random() % 100) / 100.0;
    
    UIColor *color = [UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1];
    colorSwatch.color = color;
    
    return colorSwatch;
}

@end
