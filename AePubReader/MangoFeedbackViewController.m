//
//  MangoFeedbackViewController.m
//  MangoReader
//
//  Created by Jagdish on 5/3/14.
//
//

#import "MangoFeedbackViewController.h"
#import "AePubReaderAppDelegate.h"
#import "ATSurveys.h"
#import <QuartzCore/QuartzCore.h>
#import "ATConnect.h"

@interface MangoFeedbackViewController ()

@end

@implementation MangoFeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.loggedInUserInfo){
        _loginButton.titleLabel.text  = @"Login";
    }
    // Do any additional setup after loading the view from its nib.
    
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyBecameAvailable:) name:ATSurveyNewSurveyAvailableNotification object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadMessageCountChanged:) name:ATMessageCenterUnreadCountChangedNotification object:nil];
	
	//[[ATConnect sharedConnection] engage:@"init" fromViewController:self];
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

- (IBAction)surveyView:(id)sender{
    
    if ([ATSurveys hasSurveyAvailableWithNoTags]) {
        [ATSurveys presentSurveyControllerWithNoTagsFromViewController:self];
    }
    
}

- (IBAction)chatDisscussView:(id)sender{
    
    [[ATConnect sharedConnection] presentMessageCenterFromViewController:self];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
