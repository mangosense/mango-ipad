//
//  MangoFeedbackViewController.m
//  MangoReader
//
//  Created by Jagdish on 5/3/14.
//
//

#import "MangoFeedbackViewController.h"
#import "AePubReaderAppDelegate.h"
//#import "ATSurveys.h"
#import <QuartzCore/QuartzCore.h>
#import "ATConnect.h"
#import "Constants.h"

@interface MangoFeedbackViewController ()

@end

@implementation MangoFeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;
        self.title = @"Feedback & Support";
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
    currentPage = @"dashboard_feedback_screen";
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    validUserSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    storyAsAppFilePath = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    
    if (!appDelegate.loggedInUserInfo){
        _loginButton.titleLabel.text  = @"Login";
    }
    // Do any additional setup after loading the view from its nib.
    
    if(validUserSubscription && storyAsAppFilePath){
        
        _loginButton.hidden = YES;
    }
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyBecameAvailable:) name:ATSurveyNewSurveyAvailableNotification object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadMessageCountChanged:) name:ATMessageCenterUnreadCountChangedNotification object:nil];
	
	//[[ATConnect sharedConnection] engage:@"init" fromViewController:self];
}

- (void) viewDidAppear:(BOOL)animated{
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"dashboard_feedback_screen" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:@"Dashboard feedback screen open" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"dashboard_feedback_screen" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
//    [delegate trackMixpanelEvents:dimensions eventName:@"dashboard_feedback_screen"];
    
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

//- (IBAction)surveyView:(id)sender{
//    
//    if ([ATSurveys hasSurveyAvailableWithNoTags]) {
//        [ATSurveys presentSurveyControllerWithNoTagsFromViewController:self];
//    }
//    
//}

//- (IBAction)chatDisscussView:(id)sender{
//    
//    [[ATConnect sharedConnection] presentMessageCenterFromViewController:self];
//}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
