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
@implementation DataSourceForLinear
-(id)initWithString:(NSString *) string{
    self=[super init];
    if (self) {
        _prefix=string;
    }
    return self;
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return 60;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    StoreCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"%@ %d",_prefix,indexPath.item];
    return cell;
}
@end
