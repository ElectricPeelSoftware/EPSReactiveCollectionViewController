//
//  EPSExampleViewController.m
//  EPSReactiveCollectionViewController
//
//  Created by Peter Stuart on 3/3/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import "EPSExampleViewController.h"

#import <ReactiveCocoa/RACEXTKeyPathCoding.h>
#import <ReactiveCocoa/RACEXTScope.h>

#import "EPSExampleViewModel.h"
#import "EPSColorSwatch.h"
#import "EPSColorSwatchCell.h"

@interface EPSExampleViewController ()

@property (nonatomic) EPSExampleViewModel *viewModel;

@end

@implementation EPSExampleViewController

- (id)init {
    // Setup the layout to use
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(60, 60);
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self = [super initWithCollectionViewLayout:layout];
    if (self == nil) return self;

    _viewModel = [EPSExampleViewModel new];
    
    [self addBindingToKeyPath:@"firstColorSwatches" onObject:_viewModel];
    [self addBindingToKeyPath:@"secondColorSwatches" onObject:_viewModel];
    
    [self registerCellClass:[EPSColorSwatchCell class] forObjectsWithClass:[EPSColorSwatch class]];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSwatch:)];
    
    @weakify(self);
    
    // Delete the color swatch when it's tapped
    [self.didSelectItemSignal
        subscribeNext:^(RACTuple *tuple) {
            RACTupleUnpack(EPSColorSwatch *swatch, NSIndexPath *indexPath) = tuple;
            
            @strongify(self);
            
            [self.viewModel removeColorSwatch:swatch fromSection:indexPath.section];
        }];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)addSwatch:(id)sender {
    NSInteger section = arc4random() % 2;
    [self.viewModel addColorSwatchToSection:section];
}

@end
