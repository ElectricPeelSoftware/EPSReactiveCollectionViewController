//
//  EPSColorSwatchCell.h
//  EPSReactiveCollectionViewController
//
//  Created by Peter Stuart on 3/3/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EPSReactiveCollectionViewController.h"

@class EPSColorSwatch;

@interface EPSColorSwatchCell : UICollectionViewCell <EPSReactiveCollectionViewCell>

@property (nonatomic) EPSColorSwatch *object;

@end
