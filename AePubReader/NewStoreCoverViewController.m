//
//  NewStoreCoverViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 25/10/13.
//
//

#import "NewStoreCoverViewController.h"
#import "FeaturedStoreDelegate.h"
@interface NewStoreCoverViewController ()

@end

@implementation NewStoreCoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title=@"Store";
        self.tabBarItem.image=[UIImage imageNamed:@"cart.png"];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _featured.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    FeaturedStoreDelegate *featuredDatasource=[[FeaturedStoreDelegate alloc]initPrefixString:@"featured"];
    _featured.dataSource=featuredDatasource;
    _featured.type=iCarouselTypeCoverFlow;
    _collectionViewFlowLayout= [[UICollectionViewFlowLayout alloc] init];
	
	[_collectionViewFlowLayout setItemSize:CGSizeMake(245, 250)];
	//[collectionViewFlowLayout setHeaderReferenceSize:CGSizeMake(500, 30)];
	//[collectionViewFlowLayout setFooterReferenceSize:CGSizeMake(500, 50)];
	[_collectionViewFlowLayout setMinimumInteritemSpacing:10];
	[_collectionViewFlowLayout setMinimumLineSpacing:10];
	[_collectionViewFlowLayout setSectionInset:UIEdgeInsetsMake(10, 0, 20, 0)];
    
    _collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGRect frame=_newarrivals.frame;
    frame.origin.x=0;
    frame.origin.y=0;
   _collectionView=[[UICollectionView alloc]initWithFrame:frame collectionViewLayout:_collectionViewFlowLayout];
    _linear=[[DataSourceForLinear alloc]initWithString:@"NR "];
    [_collectionView registerClass:[StoreCell class] forCellWithReuseIdentifier:@"MY_CELL"];

    _collectionView.dataSource=_linear;
    _collectionView.delegate=self;
    [self.newarrivals addSubview:_collectionView];

    self.navigationController.navigationBarHidden=YES;
   CGSize size= _scrollview.contentSize;
    size.height=660;
    [_scrollview setContentSize:size];
    // Do any additional setup after loading the view from its nib.
}
-(void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeCategory:(id)sender {
}
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    
}
- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return YES;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        default:
        {
            return value;
        }
    }

    return value;
}

/*- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    const CGFloat centerItemZoom = 1.5;
    const CGFloat centerItemSpacing = 1.23;
    
    CGFloat spacing = [self carousel:carousel valueForOption:iCarouselOptionSpacing withDefault:1.0f];
    CGFloat absClampedOffset = MIN(1.0, fabs(offset));
    CGFloat clampedOffset = MIN(1.0, MAX(-1.0, offset));
    CGFloat scaleFactor = 1.0 + absClampedOffset * (1.0/centerItemZoom - 1.0);
    offset = (scaleFactor * offset + scaleFactor * (centerItemSpacing - 1.0) * clampedOffset) * carousel.itemWidth * spacing;
    
    if (carousel.vertical)
    {
        transform = CATransform3DTranslate(transform, 0.0f, offset, -absClampedOffset);
    }
    else
    {
        transform = CATransform3DTranslate(transform, offset, 0.0f, -absClampedOffset);
    }
    
    transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1.0f);
     return transform;
}
*/
@end
