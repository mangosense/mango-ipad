//
//  MangoSubscriptionViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 10/04/14.
//
//

#import "MangoSubscriptionViewController.h"
#import "SubscriptionInfo.h"
#import "AePubReaderAppDelegate.h"


#define MONTHLY_TAG 9
#define QUARTERLY_TAG 29
#define YEARLY_TAG 99

@interface MangoSubscriptionViewController ()

@end

@implementation MangoSubscriptionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;
        userDeviceID = delegate.deviceId;
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
    // Do any additional setup after loading the view from its nib.
    [self setupInitialUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initial Setup

- (void)setupSubscriptionView:(UIView *)subscriptionView {
    [subscriptionView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [subscriptionView.layer setShadowOpacity:0.7f];
    [subscriptionView.layer setShadowRadius:5.0f];
    [subscriptionView.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
}

- (void)setupSubscriptionViewsUI {
    [self setupSubscriptionView:_monthlySubscriptionView];
    [self setupSubscriptionView:_yearlySubscriptionView];
    [self setupSubscriptionView:_quarterlySubcriptionView];
}

- (void)setupInitialUI {
    [self setupSubscriptionViewsUI];
}

#pragma mark - Action Methods

- (IBAction)backButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)subscribeButtonTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSString *productId;
    
    if (button.tag == MONTHLY_TAG) {
        productId = @"mrmonthly1";
    } else if (button.tag == QUARTERLY_TAG) {
        productId = @"mrmonthly1";
    } else if (button.tag == YEARLY_TAG) {
        productId = @"mrmonthly1";
    }
    
    [[PurchaseManager sharedManager] itemProceedToPurchase:productId storeIdentifier:productId withDelegate:self];
}

#pragma mark - PurchaseManager Delegate Methods

- (void)itemReadyToUse:(NSString *)productID ForTransaction:(NSString *)transactionId {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    SubscriptionInfo *subscriptionInfo = [[SubscriptionInfo alloc] init];
    subscriptionInfo.id = productID;
    subscriptionInfo.subscriptionType = @"mrmonthly1";
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.ejdbController insertOrUpdateObject:subscriptionInfo]) {
        appDelegate.subscriptionInfo = subscriptionInfo;
    }
}

- (void)updateBookProgress:(int)progress {
    
  
}

@end
