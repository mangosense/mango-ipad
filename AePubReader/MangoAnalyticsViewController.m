//
//  MangoAnalyticsViewController.m
//  MangoReader
//
//  Created by Harish on 3/5/14.
//
//

#import "MangoAnalyticsViewController.h"

@interface MangoAnalyticsViewController ()

@end

@implementation MangoAnalyticsViewController

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

    [_storiesReadCarousel setType:iCarouselTypeLinear];
    _storiesReadCarousel.centerItemWhenSelected = YES;
    
    _testArray = [[NSArray alloc] initWithObjects:@"pagepng", @"pagepng" ,@"pagepng" ,@"pagepng" ,@"pagepng" ,@"pagepng" ,@"pagepng" @"pagepng", @"pagepng", @"pagepng", nil];
    
    _dropDownArrayData = [[NSMutableArray alloc] initWithObjects:@"Last Week", @"Last Month", @"Last Year", nil];
    _dropDownView = [[DropDownView alloc] initWithArrayData:_dropDownArrayData cellHeight:35 heightTableView:100 paddingTop:-30 paddingLeft:-5 paddingRight:-10 refView:_dropDownButton animation:BLENDIN openAnimationDuration:1 closeAnimationDuration:1];
    _dropDownView.delegate = self;
    
	[self.view addSubview:_dropDownView.view];
    
    [_storiesReadCarousel reloadData];
    [_storiesReadCarousel scrollToOffset:1.5 duration:0.1];
    
    // Do any additional setup after loading the view from its nib.
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    
    return [_testArray count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    MangoAnalyticsSingleBookView *analyticsSingleView = [[MangoAnalyticsSingleBookView alloc] init];
   // analyticsSingleView.backgroundColor = [UIColor lightGrayColor];
    UIImageView *bookImage =[[UIImageView alloc] initWithFrame:CGRectMake(8,20,213,213)];
    bookImage.image=[UIImage imageNamed:@"test_delete_book.png"];
    [analyticsSingleView addSubview:bookImage];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(16, 266, 98, 21)];
    label1.backgroundColor=[UIColor clearColor];
    label1.textColor=[UIColor blackColor];
    label1.userInteractionEnabled=NO;
    label1.text= @"Grade level:";
    [analyticsSingleView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(16, 301, 98, 21)];
    label2.backgroundColor=[UIColor clearColor];
    label2.textColor=[UIColor blackColor];
    label2.userInteractionEnabled=NO;
    label2.text= @"Read for:";
    [analyticsSingleView addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(16, 333, 110, 21)];
    label3.backgroundColor=[UIColor clearColor];
    label3.textColor=[UIColor blackColor];
    label3.userInteractionEnabled=NO;
    label3.text= @"Current page:";
    [analyticsSingleView addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(16, 367, 98, 21)];
    label4.backgroundColor=[UIColor clearColor];
    label4.textColor=[UIColor blackColor];
    label4.userInteractionEnabled=NO;
    label4.text= @"Activity 1:";
    [analyticsSingleView addSubview:label4];
    
    UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(16, 418, 98, 21)];
    label5.backgroundColor=[UIColor clearColor];
    label5.textColor=[UIColor blackColor];
    label5.userInteractionEnabled=NO;
    label5.text= @"Activity 2:";
    [analyticsSingleView addSubview:label5];
    
    UILabel *lblGradeLevel = [[UILabel alloc] initWithFrame:CGRectMake(114, 265, 115, 22)];
    lblGradeLevel.backgroundColor=[UIColor clearColor];
    lblGradeLevel.textColor = [UIColor orangeColor];
    lblGradeLevel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(19.0)];
    lblGradeLevel.userInteractionEnabled=NO;
    lblGradeLevel.text= @"Grade";
    [analyticsSingleView addSubview:lblGradeLevel];
    
    UILabel *lblReadFor = [[UILabel alloc] initWithFrame:CGRectMake(106, 300, 115, 22)];
    lblReadFor.backgroundColor=[UIColor clearColor];
    lblReadFor.textColor=[UIColor orangeColor];
    lblReadFor.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(19.0)];
    lblReadFor.userInteractionEnabled=NO;
    lblReadFor.text= @"Read";
    [analyticsSingleView addSubview:lblReadFor];
    
    UILabel *lblCurrentPage = [[UILabel alloc] initWithFrame:CGRectMake(123, 332, 115, 22)];
    lblCurrentPage.backgroundColor=[UIColor clearColor];
    lblCurrentPage.textColor=[UIColor orangeColor];
    lblCurrentPage.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(19.0)];
    lblCurrentPage.userInteractionEnabled=NO;
    lblCurrentPage.text= @"Current";
    [analyticsSingleView addSubview:lblCurrentPage];
    
    UILabel *lblActivity1 = [[UILabel alloc] initWithFrame:CGRectMake(112, 366, 115, 22)];
    lblActivity1.backgroundColor=[UIColor clearColor];
    lblActivity1.textColor=[UIColor orangeColor];
    lblActivity1.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(19.0)];
    lblActivity1.userInteractionEnabled=NO;
    lblActivity1.text= @"Activity";
    [analyticsSingleView addSubview:lblActivity1];
    
    UILabel *lblActivity2 = [[UILabel alloc] initWithFrame:CGRectMake(112, 417, 115, 22)];
    lblActivity2.backgroundColor=[UIColor clearColor];
    lblActivity2.textColor=[UIColor orangeColor];
    lblActivity2.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(19.0)];
    lblActivity2.userInteractionEnabled=NO;
    lblActivity2.text= @"Activity";
    [analyticsSingleView addSubview:lblActivity2];
    
    UIView *seperateView = [[UIView alloc] initWithFrame:CGRectMake(239, 231, 2, 227)];
    seperateView.backgroundColor = [UIColor lightGrayColor];
    [analyticsSingleView addSubview:seperateView];
    
    [analyticsSingleView setFrame:CGRectMake(0, 0, 241, 490)];
    [[analyticsSingleView layer] setCornerRadius:12];
    [analyticsSingleView setClipsToBounds:YES];
    return analyticsSingleView;
    
}



- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return NO;
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


-(IBAction)dropDownActionButtonClick{
    
    if(_dropDownArrayData.count>1){
        _dropDownButton.userInteractionEnabled = YES;
        [self.dropDownView openAnimation];
    }
    else{
        _dropDownButton.userInteractionEnabled = NO;
    }
}

-(void)dropDownCellSelected:(NSInteger)returnIndex{
	
    [_dropDownButton setTitle:[_dropDownArrayData objectAtIndex:returnIndex] forState:UIControlStateNormal];
    NSLog(@"Drop down button category selected");
	//handle book language response here ...
}

-(IBAction)backView:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
