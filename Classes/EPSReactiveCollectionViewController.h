//
//  EPSReactiveCollectionViewController.h
//  EPSReactiveCollectionViewController
//
//  Created by Peter Stuart on 3/3/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ReactiveCocoa/ReactiveCocoa.h>

@protocol EPSReactiveCollectionViewCell;

#pragma mark - EPSReactiveCollectionViewController

@interface EPSReactiveCollectionViewController : UICollectionViewController

/**
 If set to YES, insertions and deletions will be animated. Otherwise, the table view will be reloaded when any changes are observed.
 
 @note Set to \c YES by default.
 */
@property (nonatomic) BOOL animateChanges;

/**
 A signal which sends a \c RACTuple with the object corresponding to the selected item, the index path of the selected item, and the collection view, whenever an item is selected.
 
 @code
[self.didSelectRowSignal subscribeNext:^(RACTuple *tuple) {
    RACTupleUnpack(id object, NSIndexPath *indexPath, UICollectionView *collectionView) = tuple;
    // Do something with `object`.
}
 @endcode
 */
@property (readonly, nonatomic) RACSignal *didSelectItemSignal;

/**
 @param object An object in the observed array.
 */
- (NSIndexPath *)indexPathForObject:(id)object;

/**
 @returns The object corresponding to \c indexPath.
 */
- (id)objectForIndexPath:(NSIndexPath *)indexPath;

/**
 Registers a cell class for use for items that correspond to objects which are members of the given object class.
 @param cellClass A \c UICollectionViewCell subclass. \c cellClass must conform to \c <EPSReactiveCollectionViewCell>.
 @param objectClass A class of model object that’s contained in the observed array.
 */
- (void)registerCellClass:(Class)cellClass forObjectsWithClass:(Class)objectClass;

/**
 @param layout The collection view layout to use.
 @param keyPath The key path to observe on \c object. The value at the key path must always be an \c NSArray containing objects that implement \c -isEqual: and \c -hash. No object should appear in the array more than once.
 @param object The object whose key path will be observed.
 */
- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout bindingToKeyPath:(NSString *)keyPath onObject:(id)object;

/**
 Override this method instead of \c -collectionView:cellForItemAtIndexPath:.
 @note Overriding this method is only necessary if you haven’t registered a cell class to use.
 @see -registerCellClass:forObjectsWithClass:
 @param object An object from the observed array.
 @param indexPath The index path corresponding to \c object.
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - <EPSReactiveCollectionViewCell>

/**
 Cell classes registered for use in \c registerCellClass:forObjectsWithClass: must conform to this protocol.
 */
@protocol EPSReactiveCollectionViewCell <NSObject>

/**
 This property will be set in \c -collectionView:cellForRowAtIndexPath: with the cell’s corresponding object from the observed array.
 */
@property (nonatomic) id object;

@end