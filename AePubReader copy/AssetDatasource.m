//
//  AssetDatasource.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 25/11/13.
//
//

#import "AssetDatasource.h"

@implementation AssetDatasource
-(id)initWithArray:(NSArray *)array{
    self=[super init];
    if (self) {
        _array=array;
    }
    return self;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
 return    _array.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    AssetCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UIImage *image= [_array objectAtIndex:indexPath.row];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.image=image;
    return cell;
}
@end
