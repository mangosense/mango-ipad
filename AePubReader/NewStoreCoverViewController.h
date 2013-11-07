//
//  NewStoreCoverViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 25/10/13.
//
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "PSTCollectionView.h"
#import "DataSourceForLinear.h"
#import "StoreCell.h"
#import "DataSourceForLinearOld.h"
@interface NewStoreCoverViewController : UIViewController<UISearchBarDelegate,iCarouselDelegate,UICollectionViewDelegate>
- (IBAction)changeCategory:(id)sender;
@property (weak, nonatomic) IBOutlet iCarousel *featured;
@property (weak, nonatomic) IBOutlet UIView *newarrivals;
@property (weak, nonatomic) IBOutlet UIView *mangopacks;
@property (weak, nonatomic) IBOutlet UIView *popularBooks;
@property(retain,nonatomic) DataSourceForLinear *linear;
@property(retain,nonatomic) UICollectionViewFlowLayout *collectionViewFlowLayout;
@property(retain,nonatomic) UICollectionView *collectionView;
@property(retain,nonatomic) PSTCollectionView *pstCollectionView;
@property(retain,nonatomic) PSTCollectionViewFlowLayout *pstLayout;
@property(retain,nonatomic) DataSourceForLinearOld *dataSourceOld;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

@end
