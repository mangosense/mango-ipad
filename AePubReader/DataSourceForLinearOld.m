//
//  DataSourceForLinearOld.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 29/10/13.
//
//

#import "DataSourceForLinearOld.h"
#import "OldStoreCell.h"
#import "NewBookStore.h"
@implementation DataSourceForLinearOld
-(id)initWithString:(NSString *) string{
    self=[super init];
    if (self) {
        _prefix=string;
    }
    return self;
}
-(id)initWithArray:(NSArray *)array{
    self=[super init];
    if (self) {
        _array=array;
    }
    return self;
}
- (NSInteger)collectionView:(PSTCollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return _array.count;
}

- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    OldStoreCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
   // cell.label.text = [NSString stringWithFormat:@"%@ %d",_prefix,indexPath.item];
    NewBookStore *store=[_array objectAtIndex:indexPath.row];
  //  NSLog(@"%@",store.image);
   // cell.imageView.image=store.image;
   // cell.imageView.image=[UIImage imageWithContentsOfFile:store.imageLocalLoc];
    cell.imageView.image=[UIImage imageWithContentsOfFile:store.imageLocalLoc];
    return cell;
}
-(NSInteger)numberOfSectionsInCollectionView:(PSTCollectionView *)collectionView{
    return 1;
}
@end
