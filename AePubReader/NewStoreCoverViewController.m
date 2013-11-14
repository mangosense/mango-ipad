//
//  NewStoreCoverViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 25/10/13.
//
//

#import "NewStoreCoverViewController.h"
#import "FeaturedStoreDelegate.h"
#import "DataSourceForLinearOld.h"
#import "OldStoreCell.h"
#import "DetailViewControllerStore.h"
#import "NewBookStore.h"
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
        NSString *sampleJsonLoc=[[NSBundle mainBundle]pathForResource:@"storesamplejson" ofType:@"txt"];
        _sampleStoreJson=[[NSData alloc]initWithContentsOfFile:sampleJsonLoc];
        _featuredArray=[[NSMutableArray alloc]init];
        _arrivalsNewArray=[[NSMutableArray alloc]init];
    }
    return self;
}
- (IBAction)showCollectionView:(id)sender {
    DetailViewControllerStore *controller=[[DetailViewControllerStore alloc]initWithNibName:@"DetailViewControllerStore" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self performSelectorInBackground:@selector(DownloadInBackground) withObject:nil];
}
-(void)DownloadInBackground{
    NSDictionary *diction=[NSJSONSerialization JSONObjectWithData:_sampleStoreJson options:NSJSONReadingAllowFragments error:nil];
    
    NSArray *bookArray=diction[@"books"];
    
    for (NSDictionary *dict in bookArray) {
        NSDictionary *d=dict[@"book"];
        NewBookStore *bookStore=[[NewBookStore alloc]init];
        bookStore.bookTitle=d[@"title"];
        bookStore.bookDesc=d[@"description"];
        bookStore.bookSize=d[@"source_file_size"];
        bookStore.category=d[@"categories"];
        bookStore.subcategory=d[@"sub_category"];
        bookStore.section=d[@"section"];
        bookStore.imageUrl=d[@"cover_image_url"];
        if ([bookStore.section isEqualToString:@"featured"]) {
            [_featuredArray addObject:bookStore];
            
        }
        if ([bookStore.section isEqualToString:@"newarrivals"]) {
            [_arrivalsNewArray addObject:bookStore];
        }
    }
    NSArray* cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachePath = [cachePathArray lastObject];
    int i=0;
    NSLog(@"%@",cachePath);
    for (NewBookStore *book in _featuredArray) {
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:book.imageUrl]];
        NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        //book.image=[UIImage imageWithData:data];
        NSString *imagePath=[cachePath stringByAppendingFormat:@"/featured%d.jpg",i];
        [data writeToFile:imagePath atomically:YES];
        book.imageLocalLoc=imagePath;
        i++;

    }
    i=0;
    for(NewBookStore *book in _arrivalsNewArray){
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:book.imageUrl]];
        NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        i++;
        NSString *imagePath=[cachePath stringByAppendingFormat:@"/newarrival%d.jpg",i];
        [data writeToFile:imagePath atomically:YES];
        book.imageLocalLoc=imagePath;
        //book.image=[UIImage imageWithData:data];
    }
    [self performSelectorOnMainThread:@selector(UIChange) withObject:nil waitUntilDone:NO];
    
}
-(void)UIChange{
    
    _featured.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    FeaturedStoreDelegate *featuredDatasource=[[FeaturedStoreDelegate alloc]initWithArray:_featuredArray];
    _featured.dataSource=featuredDatasource;
    _featured.type=iCarouselTypeCoverFlow;
    CGRect frame=_newarrivals.frame;
    frame.origin.x=0;
    frame.origin.y=0;
    frame.size.height=400;
    if ([UIDevice currentDevice].systemVersion.integerValue>5) {
        _collectionViewFlowLayout= [[UICollectionViewFlowLayout alloc] init];
        
        [_collectionViewFlowLayout setItemSize:CGSizeMake(250, 320)];
        //[collectionViewFlowLayout setHeaderReferenceSize:CGSizeMake(500, 30)];
        //[collectionViewFlowLayout setFooterReferenceSize:CGSizeMake(500, 50)];
        [_collectionViewFlowLayout setMinimumInteritemSpacing:10];
        [_collectionViewFlowLayout setMinimumLineSpacing:10];
        [_collectionViewFlowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        _collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView=[[UICollectionView alloc]initWithFrame:frame collectionViewLayout:_collectionViewFlowLayout];
        _linear=[[DataSourceForLinear alloc]initWithArray:_featuredArray];
        [_collectionView registerClass:[StoreCell class] forCellWithReuseIdentifier:@"MY_CELL"];
        _collectionView.backgroundColor=[UIColor whiteColor];
        _collectionView.dataSource=_linear;
        _collectionView.delegate=self;
    
        [self.newarrivals addSubview:_collectionView];
        
    }
    else{
        _dataSourceOld=[[DataSourceForLinearOld alloc]initWithArray:_arrivalsNewArray];
        _pstLayout=[[PSTCollectionViewFlowLayout alloc]init];
        
        [_pstLayout setItemSize:CGSizeMake(245, 320)];
        [_pstLayout setMinimumInteritemSpacing:10];
        [_pstLayout setMinimumLineSpacing:10];
        [_pstLayout setSectionInset:UIEdgeInsetsMake(10, 0, 20, 0)];
        [_pstLayout setMinimumInteritemSpacing:10];
        _pstLayout.scrollDirection=PSTCollectionViewScrollDirectionHorizontal;
        CGRect frame=_newarrivals.frame;
        frame.origin.x=0;
        frame.origin.y=0;
        
        _pstCollectionView=[[PSTCollectionView alloc]initWithFrame:frame collectionViewLayout:_pstLayout];
        [_pstCollectionView registerClass:[OldStoreCell class] forCellWithReuseIdentifier:@"MY_CELL"];
        
        //  _pstCollectionView.contentSize= CGSizeMake(_pstCollectionView.contentSize.width,100);
        _pstCollectionView.dataSource=_dataSourceOld;
        _pstCollectionView.backgroundColor=[UIColor yellowColor];
        self.newarrivals.backgroundColor=[UIColor redColor];
        [self.newarrivals addSubview:_pstCollectionView];
    }
    self.navigationController.navigationBarHidden=YES;
    CGSize size= _scrollview.contentSize;
    size.height=660;
    [_scrollview setContentSize:size];
}
- (IBAction)libraryView:(id)sender {
  //  [self dismissViewControllerAnimated:YES completion:nil];
  //  [self.navigationController popViewControllerAnimated:YES];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.75];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:YES];
    [UIView commitAnimations];
    [self.navigationController popViewControllerAnimated:NO];
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
 //   _pstCollectionView.contentSize= CGSizeMake(_pstCollectionView.contentSize.width,100);
    [_segmentedControl setSelectedSegmentIndex:2];
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
- (IBAction)switchTabs:(id)sender {
    UISegmentedControl *control=(UISegmentedControl *)sender;
    [self.tabBarController setSelectedIndex:control.selectedSegmentIndex];

}
- (IBAction)switchTabButtonClick:(id)sender {
    UIButton *button=(UIButton *)sender;
    [self.tabBarController setSelectedIndex:button.tag];
}
@end
