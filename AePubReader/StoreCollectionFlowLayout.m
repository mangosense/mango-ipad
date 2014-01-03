//
//  StoreCollectionFlowLayout.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 04/12/13.
//
//

#import "StoreCollectionFlowLayout.h"

@implementation StoreCollectionFlowLayout

-(id)init {
    self = [super init];
    if (self) {
        self.itemSize = CGSizeMake(150, 270);
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
//        self.sectionInset = UIEdgeInsetsMake(30, 0, 20, 0);
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray* array = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    return array;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
//    return CGSizeMake(collectionView.frame.size.width, 30);
//}

@end
