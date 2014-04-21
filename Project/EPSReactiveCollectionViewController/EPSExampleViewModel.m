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

@property (nonatomic) NSSet *firstColorSwatchesSet;
@property (nonatomic) NSSet *secondColorSwatchesSet;

@end

@implementation EPSExampleViewModel

- (id)init {
    self = [super init];
    if (self == nil) return nil;
    
    NSMutableSet *firstSwatches = [NSMutableSet new];
    NSMutableSet *secondSwatches = [NSMutableSet new];
    
    for (NSInteger index = 0; index < 5; index++) {
        [firstSwatches addObject:[EPSExampleViewModel randomColorSwatch]];
        [secondSwatches addObject:[EPSExampleViewModel randomColorSwatch]];
    }
    
    _firstColorSwatchesSet = firstSwatches;
    _secondColorSwatchesSet = secondSwatches;
    
    RAC(self, firstColorSwatches) = [RACObserve(self, firstColorSwatchesSet)
        map:^NSArray *(NSSet *swatchesSet){
            return [swatchesSet sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"hue" ascending:YES] ]];
        }];
    
    RAC(self, secondColorSwatches) = [RACObserve(self, secondColorSwatchesSet)
        map:^NSArray *(NSSet *swatchesSet) {
            return [swatchesSet sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"hue" ascending:YES] ]];
        }];
    
    return self;
}

- (void)addColorSwatchToSection:(NSInteger)section {
    NSSet *set;
    if (section == 0) set = self.firstColorSwatchesSet;
    else set = self.secondColorSwatchesSet;
    
    // Make sure all swatches are unique
    EPSColorSwatch *newSwatch;
    do {
        newSwatch = [EPSExampleViewModel randomColorSwatch];
    } while ([set containsObject:newSwatch]);
    
    if (section == 0) self.firstColorSwatchesSet = [self.firstColorSwatchesSet setByAddingObject:newSwatch];
    else self.secondColorSwatchesSet = [self.secondColorSwatchesSet setByAddingObject:newSwatch];
}

- (void)removeColorSwatch:(EPSColorSwatch *)swatch fromSection:(NSInteger)section {
    if (section == 0) {
        NSMutableSet *firstColorSwatches = self.firstColorSwatchesSet.mutableCopy;
        EPSColorSwatch *firstColorSwatch = self.firstColorSwatches.firstObject;
        [firstColorSwatches removeObject:firstColorSwatch];
        self.firstColorSwatchesSet = firstColorSwatches;
    }
    else {
        NSMutableSet *secondColorSwatches = self.secondColorSwatchesSet.mutableCopy;
        EPSColorSwatch *secondColorSwatch = self.secondColorSwatches.firstObject;
        [secondColorSwatches removeObject:secondColorSwatch];
        self.secondColorSwatchesSet = secondColorSwatches;
    }
    
    return;
    
    /*
    if ([firstColorSwatches containsObject:swatch]) {
        NSInteger index = [self.firstColorSwatches indexOfObject:swatch];
        NSLog(@"delete %i %i", 0, index);
        
        [firstColorSwatches removeObject:swatch];
        self.firstColorSwatchesSet = firstColorSwatches;
    }
    
    NSMutableSet *secondColorSwatches = self.secondColorSwatchesSet.mutableCopy;
    if ([secondColorSwatches containsObject:swatch]) {
        NSInteger index = [self.secondColorSwatches indexOfObject:swatch];
        NSLog(@"delete %i %i", 1, index);

        [secondColorSwatches removeObject:swatch];
        self.secondColorSwatchesSet = secondColorSwatches;
    }
     */
}

+ (EPSColorSwatch *)randomColorSwatch {
    EPSColorSwatch *colorSwatch = [EPSColorSwatch new];
    
    double hue = (arc4random() % 100) / 100.0;
    
    UIColor *color = [UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1];
    colorSwatch.color = color;
    
    return colorSwatch;
}

@end
