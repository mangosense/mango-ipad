//
//  DataSourceForLinearOld.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 29/10/13.
//
//

#import "DataSourceForLinearOld.h"
#import "OldStoreCell.h"
@implementation DataSourceForLinearOld
-(id)initWithString:(NSString *) string{
    self=[super init];
    if (self) {
        _prefix=string;
    }
    return self;
}
- (NSInteger)collectionView:(PSTCollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return 60;
}

- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    OldStoreCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"%@ %d",_prefix,indexPath.item];
    return cell;
}
@end
