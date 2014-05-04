//
//  MangoDashbHelpViewController.m
//  MangoReader
//
//  Created by Jagdish on 5/3/14.
//
//

#import "MangoDashbHelpViewController.h"
#import "AePubReaderAppDelegate.h"
@interface MangoDashbHelpViewController ()

@end

@implementation MangoDashbHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Help Desk View";
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
    // Do any additional setup after loading the view from its nib.
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
