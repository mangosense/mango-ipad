//
//  MangoAnalyticsViewController.m
//  MangoReader
//
//  Created by Harish on 3/5/14.
//
//

#import "MangoAnalyticsViewController.h"
#import "MangoAnalyticsSingleViewCell.h"
#import "AePubReaderAppDelegate.h"
#import <Parse/Parse.h>

@interface MangoAnalyticsViewController ()

@end

@implementation MangoAnalyticsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        _loginUserEmail = delegate.loggedInUserInfo.email;
        self.title = @"My Analytics";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.loggedInUserInfo){
        _loginButton.titleLabel.text  = @"Login";
    }
    
    _arrayCollectionData = [[NSArray alloc] init];
    
    _dropDownArrayData = [[NSMutableArray alloc] initWithObjects:@"Week", @"Month", @"Year", nil];
    _dropDownView = [[DropDownView alloc] initWithArrayData:_dropDownArrayData cellHeight:36 heightTableView:100 paddingTop:-38 paddingLeft:-5 paddingRight:-10 refView:_dropDownButton animation:BLENDIN openAnimationDuration:1 closeAnimationDuration:1];
    _dropDownView.delegate = self;
    
	[self.view addSubview:_dropDownView.view];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    
    [self.bookDataDisplayView setCollectionViewLayout:flowLayout];
    
    // Register the colleciton cell
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        flowLayout.itemSize = CGSizeMake(185.0, 177.0);
        [self.bookDataDisplayView registerNib:[UINib nibWithNibName:@"MangoAnalyticsSingleViewCell_iPhone" bundle:nil] forCellWithReuseIdentifier:@"ViewCell"];
    }
    else{
        flowLayout.itemSize = CGSizeMake(248.0, 490.0);
        [self.bookDataDisplayView registerNib:[UINib nibWithNibName:@"MangoAnalyticsSingleViewCell" bundle:nil] forCellWithReuseIdentifier:@"ViewCell"];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"LOADING PLEASE WAIT...";
    
    // Do any additional setup after loading the view from its nib.
    
    
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) viewDidAppear:(BOOL)animated{
    
    if(![self connected])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Your internet connection appears to be offline, please try later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    __block int booksRead =0, pagesRead =0, timeCompleted =0, activitiesTotal = 0;
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    PFQuery *query = [PFQuery queryWithClassName:@"Analytics"];
    if(_loginUserEmail == nil){
        [query whereKey:@"deviceIDValue" equalTo:udid];
    }
    else{
        [query whereKey:@"email_ID" equalTo:_loginUserEmail];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            //NSLog(@"all objects are %d", objects.count);
            _arrayCollectionData = [NSArray arrayWithArray:objects];
            [_bookDataDisplayView reloadData];
            
            for (int i =0; i< _arrayCollectionData.count; ++i) {
                booksRead = booksRead + [[_arrayCollectionData[i] valueForKey:@"bookCompleted"] integerValue];
                pagesRead = pagesRead + [[_arrayCollectionData[i] valueForKey:@"pagesCompleted"] integerValue];
                timeCompleted = timeCompleted + [[_arrayCollectionData[i] valueForKey:@"readingTime"] integerValue];
                activitiesTotal = activitiesTotal + [[_arrayCollectionData[i] valueForKey:@"activityCount"] integerValue];
            }
            NSLog(@"all objects are %d - %d - %d", booksRead, pagesRead, timeCompleted);
            
            if(timeCompleted >= 3600){
                NSInteger hours = floor(timeCompleted/(60*60));
                NSInteger minutes = floor((timeCompleted/60) - hours * 60);
                _labelTotalTimeSpent.text = [NSString stringWithFormat:@"%d hrs %d min", hours, minutes];
            }
            
            else if((timeCompleted <3600) && (timeCompleted > 60)){
                NSInteger minutes = floor(timeCompleted/60);
                NSInteger second = floor(timeCompleted - minutes * 60);
                _labelTotalTimeSpent.text = [NSString stringWithFormat:@"%d min %d sec", minutes, second];
            }
            else{
                int secValue = (int)timeCompleted;
                _labelTotalTimeSpent.text = [NSString stringWithFormat:@"%d sec", secValue];
            }

            
            _labelTotalPagesRead.text = [NSString stringWithFormat:@"%d", pagesRead];
            _labelStoriesCompleted.text = [NSString stringWithFormat:@"%d", booksRead];
            _labelAllActivities.text = [NSString stringWithFormat:@"%d", activitiesTotal];
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
        else{
            NSLog(@"No objects are found");
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _arrayCollectionData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MangoAnalyticsSingleViewCell *cell = (MangoAnalyticsSingleViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ViewCell" forIndexPath:indexPath];
    
//    if (cell == nil) {
//		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MangoAnalyticsSingleViewCell" owner:self options:nil];
//		for (id oneObject in nib)
//			if ([oneObject isKindOfClass:[MangoAnalyticsSingleViewCell class]])
//				cell = (MangoAnalyticsSingleViewCell *)oneObject;
//    }
    
    NSLog(@"count value is %d",_arrayCollectionData.count);
    if(!(_dropDownArrayData.count == 0)){
        
        float timeValue = [[[_arrayCollectionData objectAtIndex:indexPath.row] valueForKey:@"readingTime"] integerValue];
        
        NSString *pageslabel = [NSString stringWithFormat:@"%@ of %@",[[_arrayCollectionData objectAtIndex:indexPath.row] valueForKey:@"currentPage"], [[_arrayCollectionData objectAtIndex:indexPath.row] valueForKey:@"availablePage"]];
        cell.bookTitlelabel.text = [[_arrayCollectionData objectAtIndex:indexPath.row] valueForKey:@"bookTitle"];
        cell.gradeLabel.text = [[_arrayCollectionData objectAtIndex:indexPath.row] valueForKey:@"gradeLevel"];
        cell.currentPageLabel.text = pageslabel;
        
        NSURL *url = [NSURL URLWithString:[[_arrayCollectionData objectAtIndex:indexPath.row] valueForKey:@"bookCoverImageURL"]];
        
        CALayer *imgLayer = [cell.bookCoverImageView layer];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            [imgLayer setCornerRadius:45.0f];
            [imgLayer setBorderWidth:4.0f];
        }
        else{
            
            [imgLayer setCornerRadius:107.0f];
            [imgLayer setBorderWidth:8.0f];
            
        }
        [imgLayer setMasksToBounds:YES];
        
        [imgLayer setBorderColor:[UIColor orangeColor].CGColor];
        
        if([[[_arrayCollectionData objectAtIndex:indexPath.row] valueForKey:@"bookCoverImageURL"] hasSuffix:@"/(null)"]){
            NSLog(@"nsurl - %@", url);
            cell.bookCoverImageView.image = [UIImage imageNamed:@"loading1.png"];
        }
        
        else{
        [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, NSData *data) {
            if (succeeded) {
                    cell.bookCoverImageView.image = [[UIImage alloc] initWithData:data];
            }

        }];}
        
        
        if(timeValue >= 3600){
            NSInteger hours = floor(timeValue/(60*60));
            NSInteger minutes = floor((timeValue/60) - hours * 60);
            cell.readForLabel.text = [NSString stringWithFormat:@"%d hrs %d min", hours, minutes];
        }
        
        else if((timeValue <3600) && (timeValue > 60)){
            NSInteger minutes = floor(timeValue/60);
            NSInteger second = floor(timeValue - minutes * 60);
            cell.readForLabel.text = [NSString stringWithFormat:@"%d min %d sec", minutes, second];
        }
        else{
            int secValue = (int)timeValue;
            cell.readForLabel.text = [NSString stringWithFormat:@"%d sec", secValue];
        }
        int activityValue = [[[_arrayCollectionData objectAtIndex:indexPath.row] valueForKey:@"activityCount"] intValue] ;
        cell.Activity1Label.text = [NSString stringWithFormat:@"%d", activityValue];
    }
    
    return cell;
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, NSData *data))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            completionBlock(YES, data);
        } else {
            completionBlock(NO, nil);
        }
    }];
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
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logoutUser:(id)sender{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.loggedInUserInfo) {
        UserInfo *loggedInUserInfo = [appDelegate.ejdbController getUserInfoForId:appDelegate.loggedInUserInfo.id];
        [appDelegate.ejdbController deleteObject:loggedInUserInfo];
        
        appDelegate.loggedInUserInfo = nil;
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

-(IBAction)hide{
    
    _subview.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
