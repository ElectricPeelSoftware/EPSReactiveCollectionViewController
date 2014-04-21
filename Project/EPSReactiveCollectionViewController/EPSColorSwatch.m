//
//  EPSColorSwatch.m
//  EPSReactiveCollectionViewController
//
//  Created by Peter Stuart on 3/3/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import "EPSColorSwatch.h"

@implementation EPSColorSwatch

- (double)hue {
    CGFloat hue;
    
    [self.color getHue:&hue saturation:nil brightness:nil alpha:nil];
    
    return hue;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[EPSColorSwatch class]] == NO) return NO;
    
    EPSColorSwatch *swatch = object;
    return [self.color isEqual:swatch.color];
}

- (NSUInteger)hash {
    return self.color.hash;
}

@end
