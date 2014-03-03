//
//  EPSColorSwatchCell.m
//  EPSReactiveCollectionViewController
//
//  Created by Peter Stuart on 3/3/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import "EPSColorSwatchCell.h"

#import "EPSColorSwatch.h"

@interface EPSColorSwatchCell ()

@end

@implementation EPSColorSwatchCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        RAC(self, backgroundColor) = [RACObserve(self, object)
            map:^UIColor *(EPSColorSwatch *swatch) {
                return swatch.color;
            }];
    }
    
    return self;
}

@end
