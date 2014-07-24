//
//  MangoDashbHelpViewController.m
//  MangoReader
//
//  Created by Jagdish on 5/3/14.
//
//

#import "MangoDashbHelpViewController.h"
#import "AePubReaderAppDelegate.h"
#import "MangoDashHelperCell.h"
#import "Constants.h"

@interface MangoDashbHelpViewController (){
    NSArray *helpImages;
}

@end

@implementation MangoDashbHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;

        self.title = @"Help Desk";
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentPage = @"dashboard_help_screen";
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    validUserSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    storyAsAppFilePath = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    
    if (!appDelegate.loggedInUserInfo){
        _loginButton.titleLabel.text  = @"Login";
    }
    
    helpImages = [NSArray arrayWithObjects:@"dashboard.jpg", @"createstory.jpg", @"store.jpg", @"readpage.jpg", @"readbar.jpg", @"subscribe.jpg", nil];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.helpImagesDisplayView setCollectionViewLayout:flowLayout];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        flowLayout.itemSize = CGSizeMake(568.0, 219.0);
        [self.helpImagesDisplayView registerNib:[UINib nibWithNibName:@"MangoDashHelperCell_iPhone" bundle:nil] forCellWithReuseIdentifier:@"ViewCell"];
        
    }
    else{
        flowLayout.itemSize = CGSizeMake(1024.0, 615.0);
        [self.helpImagesDisplayView registerNib:[UINib nibWithNibName:@"MangoDashHelperCell" bundle:nil] forCellWithReuseIdentifier:@"ViewCell"];
        
        
    }
    
    if(validUserSubscription && storyAsAppFilePath){
        
        _loginButton.hidden = YES;
    }
    
    //[self.helpImagesDisplayView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
}

-(void) viewDidAppear:(BOOL)animated{
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"dashboard_help_screen" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:@"Dashboard help screen open" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"dashboard_help_screen" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return helpImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MangoDashHelperCell *cell = (MangoDashHelperCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ViewCell" forIndexPath:indexPath];
    
    //UIImageView *helpImageView = (UIImageView *)[cell viewWithTag:100];
    cell.helpimage.image = [UIImage imageNamed:[helpImages objectAtIndex:indexPath.row]];
    return cell;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    return UIEdgeInsetsMake(0,0,0,0);  // top, left, bottom, right
}



- (IBAction)moveToBack:(id)sender{
   
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
