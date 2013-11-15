//
//  DataSourceForLinear.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 28/10/13.
//
//

#import "DataSourceForLinear.h"
#import "PSTCollectionView.h"
#import "StoreCell.h"
#import "NewBookStore.h"
@implementation DataSourceForLinear
-(id)initWithString:(NSString *) string{
    self=[super init];
    if (self) {
        _prefix=string;
    }
    return self;
}
-(id)initWithArray:(NSArray *) array{
    self=[super init];
    if (self) {
        _array=array;
    }
    return self;
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return _array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    StoreCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    NewBookStore *store=[_array objectAtIndex:indexPath.row];
    
    cell.tag=store.bookId;
   // cell.imageView.image=[UIImage imageWithContentsOfFile:store.imageLocalLoc];
    cell.imageView.image=[UIImage imageWithContentsOfFile:store.imageLocalLoc];
    NSLog(@"%@",cell.imageView);
    NSLog(@"%@",store.imageLocalLoc);
    cell.backgroundColor=[UIColor greenColor];

  //  cell.label.text = [NSString stringWithFormat:@"%@ %d",_prefix,indexPath.item];
    return cell;
}
@end
