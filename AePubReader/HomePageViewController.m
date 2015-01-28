//
//  HomePageViewController.m
//  MangoReader
//
//  Created by Harish on 1/13/15.
//
//

#import "HomePageViewController.h"
#import "AePubReaderAppDelegate.h"
#import "PageNewBookTypeViewController.h"
#import "UserSubscriptionViewController.h"
#import "UserProgressViewController.h"
#import "UserAgeLevelViewController.h"
#import "AppInfoViewController.h"
#import "UIImageView+WebCache.h"
//store link
#import "MangoStoreViewController.h"

@interface HomePageViewController ()

@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _storiesCarousel.type = iCarouselTypeRotary;
    
    UserBookDownloadViewController *bookDownloadClass = [[UserBookDownloadViewController alloc] init];
    bookDownloadClass.delegate = self;
    [bookDownloadClass returnArrayElementa];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DismissOtherViewAndLoadAgepage) name:@"EditAgeValue" object:nil];
    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)getJsonIntoArray:(NSArray *) bookArray{
    
    _allDisplayBooks = [[NSMutableArray alloc] initWithArray:bookArray];
    [_storiesCarousel reloadData];
    
}


- (void) viewWillAppear:(BOOL)animated{
    
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/bgPlayHomePage.mp3",
                               [[NSBundle mainBundle] resourcePath]];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL
                                                     error:nil];
    _player.numberOfLoops = -1; //Infinite
    
    [_player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) viewDidDisappear:(BOOL)animated{
    
    _player = nil;
}

- (BOOL) checkIfBookAvailable :(NSString *) bookId{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    Book *bk=[appDelegate.dataModel getBookOfEJDBId:bookId];
    
    //int isDownloaded = [bk.downloaded integerValue];
    
    if(bk){
        return TRUE;
    }
    else{
        return FALSE;
    }
}



- (IBAction)readyBookToOpen:(NSString *)bookId{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    Book *bk=[appDelegate.dataModel getBookOfEJDBId:selectedBookId];
    
    //int isDownloaded = [bk.downloaded integerValue];
    
    if(bk.localPathFile){
        [self openBook:bk];
    }
    else{
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Book not available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
        [self displaySettingsView];
    }
    //}
}


- (void)openBook:(Book *)bk {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *identity=[NSString stringWithFormat:@"%@", bk.id];
    [appDelegate.dataModel displayAllData];
    
    PageNewBookTypeViewController *controller;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController_iPhone" bundle:nil WithOption:nil BookId:selectedBookId];
        
    }
    else{
        controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController" bundle:nil WithOption:nil BookId:selectedBookId];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - iCarousel Delegates

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
//    if (_featuredStoriesArray) {
//        return [_featuredStoriesArray count];
//    }
    return _allDisplayBooks.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    iCarouselImageView *storyImageView = (iCarouselImageView *)[view viewWithTag:iCarousel_VIEW_TAG];
    
    NSDictionary *bookInfo = [_allDisplayBooks objectAtIndex:index];
    
    NSString *image = [NSString stringWithFormat:@"https://mangoassets.s3.amazonaws.com/uploads/stories/%@/%@",[bookInfo valueForKey:@"id"],[bookInfo valueForKey:@"images"]];
    
    NSString *ImageURL = [image stringByReplacingOccurrencesOfString:@"thumb" withString:@"cover"];
    
    BOOL isAvailable = [self checkIfBookAvailable:[bookInfo valueForKey:@"id"]];
    
    [storyImageView setContentMode:UIViewContentModeScaleAspectFill];
    [storyImageView setClipsToBounds:YES];
    UIImageView *lockImg;
    
    if (!storyImageView) {
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            storyImageView = [[iCarouselImageView alloc] initWithFrame:CGRectMake(0, 0, 173, 134)];
        }
        else{
            storyImageView = [[iCarouselImageView alloc] initWithFrame:CGRectMake(0, 0, 302, 246)];
        }
        
        storyImageView.delegate = self;
        
        
        
    }
    
    
        //lockImg = nil;
        
        [storyImageView setImageWithURL:[NSURL URLWithString:ImageURL]
                       placeholderImage:[UIImage imageNamed:@"page.png"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              }];
        
        
        NSLog(@"is avil %d", isAvailable);
        if(!isAvailable){
            lockImg =[[UIImageView alloc] initWithFrame:CGRectMake(40,120,150,120)];
            lockImg.image=[UIImage imageNamed:@"lockBook.png"];
            
        }
        else{
            
            //lockImg.image=[UIImage imageNamed:@"tmangot.png"];
            lockImg.image = nil;
        }
        
    
    [storyImageView addSubview:lockImg];
    
    return storyImageView;
    
    /*if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 302.0f, 246.0f)];
//        ((UIImageView *)view).image = [UIImage imageNamed:@"page.png"];
//        view.contentMode = UIViewContentModeCenter;
//        label = [[UILabel alloc] initWithFrame:view.bounds];
//        label.backgroundColor = [UIColor clearColor];
//        label.textAlignment = UITextAlignmentCenter;
//        label.font = [label.font fontWithSize:50];
//        label.tag = 1;
//        [view addSubview:label];
        
        NSString *image = [NSString stringWithFormat:@"https://mangoassets.s3.amazonaws.com/uploads/stories/%@/%@",[bookInfo valueForKey:@"id"],[bookInfo valueForKey:@"images"]];
        
        NSString *ImageURL = [image stringByReplacingOccurrencesOfString:@"thumb" withString:@"cover"];
        
        BOOL *isAvailable = [self checkIfBookAvailable:[bookInfo valueForKey:@"id"]];
        UIImageView *lockImg =[[UIImageView alloc] initWithFrame:CGRectMake(40,120,150,120)];
        
        if(!isAvailable){
            
            lockImg.image=[UIImage imageNamed:@"lockBook.png"];
            [view addSubview:lockImg];
        }
        else if(isAvailable){
            
            lockImg.image=[UIImage imageNamed:@"tmangot.png"];
            [storyImageView addSubview:lockImg];
        }
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = [items[index] stringValue];
    
    return view;*/

}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    //NSNumber *item = (self.items)[index];
    //get selected book id value
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //[prefs setBool:YES forKey:@"FIRSTTIMEDISPLAY"];
    [prefs setValue:[NSString stringWithFormat:@"%d",index] forKey:@"BOOKINDEX"];
    selectedBookId = [[_allDisplayBooks objectAtIndex:index] valueForKey:@"id"];
    [self readyBookToOpen:selectedBookId];
    
}


- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    
        NSLog(@"heyyyy current element level is %@",[[_allDisplayBooks objectAtIndex:self.storiesCarousel.currentItemIndex] valueForKey:@"level"]);
    NSString *levelValue = [[_allDisplayBooks objectAtIndex:(self.storiesCarousel.currentItemIndex)] valueForKey:@"level"];
    //NSString *levelString = _levelsLabel.text;
    NSMutableAttributedString *levelString = [[NSMutableAttributedString alloc] initWithString:_levelsLabel.text];
    NSRange levelRangeValue = [_levelsLabel.text rangeOfString:levelValue];
    [levelString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:levelRangeValue];
    [levelString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:25.0f] range:levelRangeValue];
    
    //[levelString addAttribute:NSBackgroundColorAttributeName value:[UIColor lightGrayColor] range:levelRangeValue];
    [_levelsLabel setAttributedText:levelString];
}

- (void)iCarouselSaveImage:(UIImage *)image ForUrl:(NSString *)imageUrl {
    if (!image){return;}
    //[_localImagesDictionary setObject:image forKey:imageUrl];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    //customize carousel display
    switch (option) {
        case iCarouselOptionWrap: {
            //normally you would hard-code this to YES or NO
            return YES;
        }
            
        case iCarouselOptionSpacing: {
            //add a bit of spacing between the item views
            if([[UIDevice currentDevice] userInterfaceIdiom]== UIUserInterfaceIdiomPhone){
                return value *1.7f;
            }
            else{
                return value * 1.0f;
            }
        }
            
        case iCarouselOptionFadeMax: {
            if (carousel.type == iCarouselTypeCustom) {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value*0.5f;
        }
            
        case iCarouselOptionVisibleItems: {
            return 5;
        }
            
        default: {
            return value;
        }
    }
}

- (IBAction)SelectLevelValue:(id)sender{
    
    //check sender value
    //match json value with sender value and highlight sender background
    //only selectable sender rem. with clear
    [sender setBackgroundColor:[UIColor lightGrayColor]];
}

- (IBAction) displayUserSettings:(id)sender{
    
    [self displaySettingsView];
}

- (void)displaySettingsView {
    int settingSol =1;
    if(settingSol){
        // [self displaySettings];
        settingSol = NO;
        
        UITabBarController *tabBarController = [[UITabBarController alloc] init];
        tabBarController.delegate = self;
        
        UserAgeLevelViewController *viewCtr0;
        UserSubscriptionViewController *viewCtr1;
        UserProgressViewController *viewCtr2;
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            
            viewCtr0 = [[UserAgeLevelViewController alloc] initWithNibName:@"UserAgeLevelViewController_iPhone" bundle:nil];
            
            viewCtr1 = [[UserSubscriptionViewController alloc] initWithNibName:@"UserSubscriptionViewController_iPhone" bundle:nil];
            
            viewCtr2 = [[UserProgressViewController alloc] initWithNibName:@"UserProgressViewController_iPhone" bundle:nil];
        }
        
        else{
            
            viewCtr0 = [[UserAgeLevelViewController alloc] initWithNibName:@"UserAgeLevelViewController" bundle:nil];
            
            viewCtr1 = [[UserSubscriptionViewController alloc] initWithNibName:@"UserSubscriptionViewController" bundle:nil];
            
            viewCtr2 = [[UserProgressViewController alloc] initWithNibName:@"UserProgressViewController" bundle:nil];
        }
        
        viewCtr0.tabBarItem.image = [UIImage imageNamed:@"profile.png"];
        
        viewCtr1.tabBarItem.image = [UIImage imageNamed:@"feedback.png"];
        
        viewCtr2.tabBarItem.image = [UIImage imageNamed:@"analytics.png"];
        
        viewCtr0.navigationController.navigationBarHidden = YES;
        
        viewCtr1.navigationController.navigationBarHidden=YES;
        
        viewCtr2.navigationController.navigationBarHidden=YES;
        
        tabBarController.viewControllers= [NSArray arrayWithObjects: viewCtr1, viewCtr0, viewCtr2,  nil];
        
        [self.navigationController pushViewController:tabBarController animated:YES];
    }
}

- (IBAction) presentAppInfoPage:(id)sender{
    
    AppInfoViewController *displayAppInfo;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        displayAppInfo = [[AppInfoViewController alloc] initWithNibName:@"AppInfoViewController_iPhone" bundle:nil];
        
    }
    else{
        displayAppInfo = [[AppInfoViewController alloc] initWithNibName:@"AppInfoViewController" bundle:nil];
    }
    [self presentViewController:displayAppInfo animated:YES completion:nil];
}

- (void) DismissOtherViewAndLoadAgepage{
    
    [self.navigationController popViewControllerAnimated:NO];
}


///Just for testing purpose

- (IBAction)storeView:(id)sender{
    
    MangoStoreViewController *storeViewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        storeViewController = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController_iPhone" bundle:nil];
    }
    else{
        storeViewController = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController" bundle:nil];
    }
    
   
    
    [self.navigationController pushViewController:storeViewController animated:YES];
}

@end
