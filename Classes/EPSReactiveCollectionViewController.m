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

@property (nonatomic) NSArray *sectionSignals;
@property (nonatomic) NSArray *objectsInSections;
@property (nonatomic) NSDictionary *identifiersForClasses;

@end

@implementation EPSReactiveCollectionViewController

#pragma mark - Public Methods

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self == nil) return nil;
    
    _animateChanges = YES;
    _identifiersForClasses = @{};
    _sectionSignals = @[];
    
    RACSignal *didSelectMethodSignal = [self rac_signalForSelector:@selector(collectionView:didSelectItemAtIndexPath:)];
    RACSignal *objectsWhenSelected = [RACObserve(self, objectsInSections) sample:didSelectMethodSignal];
    
    self.didSelectItemSignal = [[didSelectMethodSignal
        zipWith:objectsWhenSelected]
        map:^RACTuple *(RACTuple *tuple) {
            RACTupleUnpack(RACTuple *arguments, NSArray *objects) = tuple;
            RACTupleUnpack(UICollectionView *collectionView, NSIndexPath *indexPath) = arguments;
            id object = [EPSReactiveCollectionViewController objectForIndexPath:indexPath inArray:objects];
            return RACTuplePack(object, indexPath, collectionView);
        }];
    
    RAC(self, objectsInSections) = [[[[RACObserve(self, sectionSignals)
        map:^RACSignal *(NSArray *signals) {
            return [RACSignal combineLatest:signals];
        }]
        switchToLatest]
        map:^NSArray *(RACTuple *tuple) {
            return tuple.rac_sequence.array;
        }]
        distinctUntilChanged];
    
    return self;
}

- (void)addBindingToKeyPath:(NSString *)keyPath onObject:(id)object {
    RACSignal *signal = [[object rac_valuesForKeyPath:keyPath observer:self] deliverOn:[RACScheduler mainThreadScheduler]];
    self.sectionSignals = [self.sectionSignals arrayByAddingObject:signal];
}

- (void)registerCellClass:(Class)cellClass forObjectsWithClass:(Class)objectClass {
    NSString *identifier = [EPSReactiveCollectionViewController identifierFromCellClass:cellClass objectClass:objectClass];
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
    
    NSMutableDictionary *dictionary = [self.identifiersForClasses mutableCopy];
    dictionary[NSStringFromClass(objectClass)] = identifier;
    self.identifiersForClasses = dictionary;
}

- (NSIndexPath *)indexPathForObject:(id)object {
    return [EPSReactiveCollectionViewController indexPathForObject:object inSectionsArray:self.objectsInSections];
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath {
    return [EPSReactiveCollectionViewController objectForIndexPath:indexPath inArray:self.objectsInSections];
}

+ (id)objectForIndexPath:(NSIndexPath *)indexPath inArray:(NSArray *)array {
    return array[indexPath.section][indexPath.row];
}

+ (NSIndexPath *)indexPathForObject:(id)object inSectionsArray:(NSArray *)array {
    for (NSArray *sectionContents in array) {
        for (id anObject in sectionContents) {
            if ([anObject isEqual:object]) {
                NSInteger section = [array indexOfObject:sectionContents];
                NSInteger item = [sectionContents indexOfObject:anObject];
                
                return [NSIndexPath indexPathForItem:item inSection:section];
            }
        }
    }
    
    return nil;
}

#pragma mark - Private Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    
    RACSignal *changeSignal = [[self rac_valuesAndChangesForKeyPath:@keypath(self.objectsInSections) options:NSKeyValueObservingOptionOld observer:nil]
        map:^RACTuple *(RACTuple *tuple) {
            RACTupleUnpack(NSArray *newObjects, NSDictionary *changeDictionary) = tuple;
            id oldObjects = changeDictionary[NSKeyValueChangeOldKey];

            NSArray *oldObjectsArray;
            if (oldObjects == [NSNull null]) oldObjectsArray = @[];
            else oldObjectsArray = oldObjects;

            NSArray *itemsToRemove;

            itemsToRemove = [oldObjectsArray.rac_sequence
                foldLeftWithStart:@[] reduce:^id(NSArray *accumulator, NSArray *sectionArray) {
                    NSArray *newPaths = [[[sectionArray.rac_sequence
                        filter:^BOOL(id object) {
                            return [EPSReactiveCollectionViewController indexPathForObject:object inSectionsArray:newObjects] == NO;
                        }]
                        map:^NSIndexPath *(id object) {
                            return [EPSReactiveCollectionViewController indexPathForObject:object inSectionsArray:oldObjectsArray];
                        }]
                        array];
                    return [accumulator arrayByAddingObjectsFromArray:newPaths];
                }];

            NSArray *itemsToInsert = [newObjects.rac_sequence
                foldLeftWithStart:@[] reduce:^id(NSArray *accumulator, NSArray *sectionArray) {
                    NSArray *newPaths = [[[sectionArray.rac_sequence
                        filter:^BOOL(id object) {
                            return [EPSReactiveCollectionViewController indexPathForObject:object inSectionsArray:oldObjectsArray] == NO;
                        }]
                        map:^NSIndexPath *(id object) {
                            return [EPSReactiveCollectionViewController indexPathForObject:object inSectionsArray:newObjects];
                        }]
                        array];
                    
                    return [accumulator arrayByAddingObjectsFromArray:newPaths];
                }];

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
    return self.objectsInSections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.objectsInSections[section] count];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - For Subclasses

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"EPSReactiveCollectionViewController Error: -collectionView:cellForObject:atIndexPath: must be overridden by a subclass.");
    return nil;
}

@end
