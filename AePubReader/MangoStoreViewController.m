//
//  MangoStoreViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 03/12/13.
//
//

#import "MangoStoreViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "StoreCollectionFlowLayout.h"
#import "StoreCollectionHeaderView.h"
#import "StoreBookCell.h"

#define SEGMENT_WIDTH 600
#define SEGMENT_HEIGHT 60
#define FILTER_BUTTON_WIDTH 130
#define CATEGORY_TAG 1
#define AGE_TAG 2
#define LANGUAGE_TAG 3
#define GRADE_TAG 4

#define STORE_BOOK_CELL_ID @"StoreBookCell"
#define HEADER_ID @"headerId"

@interface MangoStoreViewController ()

@property (nonatomic, strong) UIPopoverController *filterPopoverController;
@property (nonatomic, strong) UICollectionView *booksCollectionView;

@end

@implementation MangoStoreViewController

@synthesize filterPopoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupInitialUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods

- (IBAction)goBackToStoryPage:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)filterSelected:(id)sender {
    ItemsListViewController *textTemplatesListViewController = [[ItemsListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [textTemplatesListViewController.view setFrame:CGRectMake(0, 0, 250, 250)];
    textTemplatesListViewController.tableType = TABLE_TYPE_TEXT_TEMPLATES;
    textTemplatesListViewController.delegate = self;
    
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case CATEGORY_TAG: {
            textTemplatesListViewController.itemsListArray = [NSMutableArray arrayWithObjects:@"Bedtime Stories", @"Poems & Rhymes", @"Good Habits & Values", @"Holidays & Celebrations", @"Classics", @"Traditional Tales", nil];
        }
            break;
            
        case AGE_TAG: {
            textTemplatesListViewController.itemsListArray = [NSMutableArray arrayWithObjects:@"0-2 Years", @"2-4 Years", @"4-6 Years", @"6-8 Years", @"8-10 Years", @"10-12 Years", nil];
        }
            break;
            
        case LANGUAGE_TAG: {
            textTemplatesListViewController.itemsListArray = [NSMutableArray arrayWithObjects:@"English", @"Spanish", @"French", @"German", @"Tamil", @"Hindi", nil];
        }
            break;
            
        case GRADE_TAG: {
            textTemplatesListViewController.itemsListArray = [NSMutableArray arrayWithObjects:@"Pre K", @"Kindergarten", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", nil];
        }
            break;
            
        default:
            break;
    }
    
    filterPopoverController = [[UIPopoverController alloc] initWithContentViewController:textTemplatesListViewController];
    [filterPopoverController setPopoverContentSize:CGSizeMake(250, 250)];
    filterPopoverController.delegate = self;
    [filterPopoverController.contentViewController.view setBackgroundColor:COLOR_LIGHT_GREY];
    [filterPopoverController presentPopoverFromRect:button.frame inView:self.view.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark - UI Setup Methods

- (void)setupInitialUI {
    _storiesCarousel.delegate = self;
    _storiesCarousel.dataSource = self;
    _storiesCarousel.type = iCarouselTypeCoverFlow;
    [_storiesCarousel reloadData];
    
    StoreCollectionFlowLayout *layout = [[StoreCollectionFlowLayout alloc] init];
    _booksCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(_storiesCarousel.frame.origin.x, _storiesCarousel.frame.origin.y + _storiesCarousel.frame.size.height + 5, _storiesCarousel.frame.size.width, self.view.frame.size.height - (_storiesCarousel.frame.origin.y + _storiesCarousel.frame.size.height + 5) - 10) collectionViewLayout:layout];
    _booksCollectionView.dataSource = self;
    _booksCollectionView.delegate =self;
    [_booksCollectionView registerClass:[StoreBookCell class] forCellWithReuseIdentifier:STORE_BOOK_CELL_ID];
    [_booksCollectionView registerClass:[StoreCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID];
    [_booksCollectionView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_booksCollectionView];
    [_booksCollectionView reloadData];
}

#pragma mark - Items Delegate

- (void)itemType:(int)itemType tappedAtIndex:(int)index {
    [filterPopoverController dismissPopoverAnimated:YES];
    switch (itemType) {
        case TABLE_TYPE_TEXT_TEMPLATES:
            break;
            
        default:
            break;
    }
}

#pragma mark - iCarousel Delegates

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return 5;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    UIImageView *storyImageView = [[UIImageView alloc] init];
    [storyImageView setFrame:CGRectMake(0, 0, 400, 250)];
    [storyImageView setImage:[UIImage imageNamed:@"video image copy.png"]];
    [[storyImageView layer] setCornerRadius:12];
    [storyImageView setClipsToBounds:YES];
    return storyImageView;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    //customize carousel display
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
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return 6;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StoreBookCell *cell = [cv dequeueReusableCellWithReuseIdentifier:STORE_BOOK_CELL_ID forIndexPath:indexPath];
    [cell.bookImageView setImage:[UIImage imageNamed:@"49.jpg"]];
    cell.bookTitleLabel.text = @"The Moon And The Cap";
    [cell.bookTitleLabel setFrame:CGRectMake(2, cell.bookTitleLabel.frame.origin.y, cell.bookTitleLabel.frame.size.width, [cell.bookTitleLabel.text sizeWithFont:cell.bookTitleLabel.font constrainedToSize:CGSizeMake(cell.bookTitleLabel.frame.size.width, 50)].height)];
    [cell setNeedsLayout];
    
    cell.bookAgeGroupLabel.text = [NSString stringWithFormat:@"For Age %d-%d Yrs", 2*indexPath.section, 2*indexPath.section + 2];
    cell.bookPriceLabel.text = @"Rs. 99";
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    StoreCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID forIndexPath:indexPath];
    headerView.titleLabel.textColor = COLOR_DARK_RED;
    headerView.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    headerView.titleLabel.text = [NSString stringWithFormat:@"For Age %d-%d Years", 2*indexPath.section, 2*indexPath.section + 2];
    
    return headerView;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 0, 20, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 20);
}

@end
