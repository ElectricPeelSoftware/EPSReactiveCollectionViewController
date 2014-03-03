# EPSReactiveCollectionViewController

`EPSReactiveCollectionViewController` is a subclass of `UICollectionViewController` that automatically populates a collection view, and animates the insertion and deletion of items by observing changes to an array of model objects. It uses [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa), and is designed to be used with the [MVVM](http://en.wikipedia.org/wiki/Model_View_ViewModel) pattern.

[EPSReactiveTableViewController](https://github.com/ElectricPeelSoftware/EPSReactiveTableViewController) provides similar functionality for table view controllers.

## Usage

Subclass `EPSReactiveCollectionViewController`, and write an `init` method which calls `initWithCollectionViewLayout:bindingToKeyPath:onObject:` on `super` to set up the binding. The value at the key path must always be an `NSArray` containing objects that implement `-isEqual:` and `-hash`. No object should appear in the array more than once. In the `init` method, register a cell class for use with the class of object that will be contained in the observed array. (The cell class must conform to `<EPSReactiveCollectionViewCell>`.)

```objective-c
- (id)init {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(60, 60);
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    EPSExampleViewModel *viewModel = [EPSExampleViewModel new];
    
    self = [super initWithCollectionViewLayout:layout bindingToKeyPath:@"sortedObjects" onObject:viewModel];
    [self registerCellClass:[EPSColorSwatchCell class] forObjectsWithClass:[EPSColorSwatch class]];
    ...
    return self;
}
```

If you want to know when a cell is tapped on, subscribe to the `didSelectItemSignal` property.

```objective-c
[self.didSelectItemSignal subscribeNext:^(RACTuple *tuple) {
    RACTupleUnpack(id object, NSIndexPath *indexPath, UICollectionView *collectionView) = tuple;
    // Do something with `object`
}];
```

You don’t need to write any `<UICollectionViewDataSource>` methods.

For a more complete example of how to use `EPSReactiveCollectionViewController`, see the [example project](https://github.com/ElectricPeelSoftware/EPSReactiveCollectionViewController/tree/master/Project).

To run the example project; clone the repo, and run `pod install` from the Project directory first.

## Requirements

EPSReactiveCollectionViewController requires [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) 2.2 or higher.

## Installation

EPSReactiveCollectionViewController is available through [CocoaPods](http://cocoapods.org), to install it simply add the following line to your Podfile:

```ruby
pod "EPSReactiveCollectionViewController"
```

Alternatively, include `EPSReactiveCollectionViewController.h` and `EPSReactiveCollectionViewController.m` in your project, and install [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) 2.2 by following their [installation instructions](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/README.md#importing-reactivecocoa).

## License

EPSReactiveCollectionViewController is available under the MIT license. See the [LICENSE](https://github.com/ElectricPeelSoftware/EPSReactiveCollectionViewController/blob/master/LICENSE) file for more info.

