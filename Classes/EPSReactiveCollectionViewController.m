//
//  EPSReactiveCollectionViewController.m
//  EPSReactiveCollectionViewController
//
//  Created by Peter Stuart on 3/3/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import "EPSReactiveCollectionViewController.h"

#import <ReactiveCocoa/RACEXTScope.h>

@interface EPSReactiveCollectionViewController ()

@property (readwrite, nonatomic) RACSignal *didSelectItemSignal;

@property (nonatomic) NSArray *objects;
@property (nonatomic) NSDictionary *identifiersForClasses;

@end

@implementation EPSReactiveCollectionViewController

#pragma mark - Public Methods

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout bindingToKeyPath:(NSString *)keyPath onObject:(id)object {
    self = [super initWithCollectionViewLayout:layout];
    if (self == nil) return nil;
    
    _animateChanges = YES;
    _identifiersForClasses = @{};
    
    RAC(self, objects) = [[object
        rac_valuesForKeyPath:keyPath observer:self]
        deliverOn:[RACScheduler mainThreadScheduler]];
    
    RACSignal *didSelectMethodSignal = [self rac_signalForSelector:@selector(collectionView:didSelectItemAtIndexPath:)];
    RACSignal *objectsWhenSelected = [RACObserve(self, objects) sample:didSelectMethodSignal];
    
    self.didSelectItemSignal = [[didSelectMethodSignal
        zipWith:objectsWhenSelected]
        map:^RACTuple *(RACTuple *tuple) {
            RACTupleUnpack(RACTuple *arguments, NSArray *objects) = tuple;
            RACTupleUnpack(UICollectionView *collectionView, NSIndexPath *indexPath) = arguments;
            id object = [EPSReactiveCollectionViewController objectForIndexPath:indexPath inArray:objects];
            return RACTuplePack(object, indexPath, collectionView);
        }];

    return self;
}

- (void)registerCellClass:(Class)cellClass forObjectsWithClass:(Class)objectClass {
    NSString *identifier = [EPSReactiveCollectionViewController identifierFromCellClass:cellClass objectClass:objectClass];
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
    
    NSMutableDictionary *dictionary = [self.identifiersForClasses mutableCopy];
    dictionary[NSStringFromClass(objectClass)] = identifier;
    self.identifiersForClasses = dictionary;
}

- (NSIndexPath *)indexPathForObject:(id)object {
    return [NSIndexPath indexPathForRow:[self.objects indexOfObject:object] inSection:0];
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath {
    return [EPSReactiveCollectionViewController objectForIndexPath:indexPath inArray:self.objects];
}

+ (id)objectForIndexPath:(NSIndexPath *)indexPath inArray:(NSArray *)array {
    return array[indexPath.row];
}

#pragma mark - Private Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    
    RACSignal *changeSignal = [[self rac_valuesAndChangesForKeyPath:@keypath(self.objects) options:NSKeyValueObservingOptionOld observer:nil]
        map:^RACTuple *(RACTuple *tuple) {
            RACTupleUnpack(NSArray *newObjects, NSDictionary *changeDictionary) = tuple;
            id oldObjects = changeDictionary[NSKeyValueChangeOldKey];

            NSArray *oldObjectsArray;
            if (oldObjects == [NSNull null]) oldObjectsArray = @[];
            else oldObjectsArray = oldObjects;

            NSArray *itemsToRemove;

            itemsToRemove = [[[oldObjectsArray.rac_sequence
                filter:^BOOL(id object) {
                    return [newObjects containsObject:object] == NO;
                }]
                map:^NSIndexPath *(id object) {
                    return [NSIndexPath indexPathForRow:[oldObjects indexOfObject:object] inSection:0];
                }]
                array];

            NSArray *itemsToInsert = [[[newObjects.rac_sequence
                filter:^BOOL(id object) {
                    return ([oldObjectsArray containsObject:object] == NO);
                }]
                map:^NSIndexPath *(id object) {
                    return [NSIndexPath indexPathForRow:[newObjects indexOfObject:object] inSection:0];
                }]
                array];

            return RACTuplePack(itemsToRemove, itemsToInsert);
        }];
    
    [[changeSignal
        // Take only the first value so that we can reload the table view
        take:1]
        subscribeNext:^(id x) {
            @strongify(self);

            [self.collectionView reloadData];
        }];
    
    [[changeSignal
        // Skip the first value since those changes shouldn't be animated
        skip:1]
        subscribeNext:^(RACTuple *tuple) {
            RACTupleUnpack(NSArray *rowsToRemove, NSArray *rowsToInsert) = tuple;

            @strongify(self);

            BOOL onlyOrderChanged = (rowsToRemove.count == 0) && (rowsToInsert.count == 0);

            if (self.animateChanges == YES && onlyOrderChanged == NO) {
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView deleteItemsAtIndexPaths:rowsToRemove];
                    [self.collectionView insertItemsAtIndexPaths:rowsToInsert];
                } completion:NULL];
            }
            else {
                [self.collectionView reloadData];
            }
        }];
}

+ (NSString *)identifierFromCellClass:(Class)cellClass objectClass:(Class)objectClass {
    return [NSString stringWithFormat:@"EPSReactiveCollectionViewController-%@-%@", NSStringFromClass(cellClass), NSStringFromClass(objectClass)];
}

- (NSString *)identifierForObject:(id)object {
    return self.identifiersForClasses[NSStringFromClass([object class])];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectForIndexPath:indexPath];
    NSString *identifier = [self identifierForObject:object];
    
    if (identifier == nil) {
        return [self collectionView:collectionView cellForObject:object atIndexPath:indexPath];
    }
    
    UICollectionViewCell <EPSReactiveCollectionViewCell> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if ([[cell class] conformsToProtocol:@protocol(EPSReactiveCollectionViewCell)] == NO) {
        NSLog(@"EPSReactiveCollectionViewController Error: %@ does not conform to the <EPSReactiveCollectionViewCell> protocol.", NSStringFromClass([cell class]));
    }
    
    cell.object = object;
    
    return cell;
}

#pragma mark - For Subclasses

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"EPSReactiveCollectionViewController Error: -collectionView:cellForObject:atIndexPath: must be overridden by a subclass.");
    return nil;
}

@end
