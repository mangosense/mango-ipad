//
//  AppInfoViewController.m
//  MangoReader
//
//  Created by Harish on 1/22/15.
//
//

#import "AppInfoViewController.h"
#import "AePubReaderAppDelegate.h"
#import "Constants.h"

@interface AppInfoViewController ()<MFMailComposeViewControllerDelegate>

@end

@implementation AppInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentScreen = @"appInfoScreen";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) backToHomePage:(id)sender{
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 
                                 PARAMETER_ACTION : @"homeButtonClick",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_EVENT_DESCRIPTION : @"back to home click",
                                 };
    [delegate trackEventAnalytic:@"homeButtonClick" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"homeButtonClick"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) viewDidAppear:(BOOL)animated{
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 
                                 PARAMETER_ACTION : @"appInfoScreen",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_EVENT_DESCRIPTION : @"back to home click",
                                 };
    [delegate trackEventAnalytic:@"appInfoScreen" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"appInfoScreen"];
}



- (IBAction)emailSupport:(id)sender
{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 
                                 PARAMETER_ACTION : @"sentEmail",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_EVENT_DESCRIPTION : @"sent Support Email",
                                 };
    [delegate trackEventAnalytic:@"sentEmail" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"sentEmail"];
    
    UIButton *button = (UIButton *)sender;
    NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
    NSString *model = [[UIDevice currentDevice] model];
    NSString *version = @"1.0";
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setToRecipients:[NSArray arrayWithObjects: button.titleLabel.text,nil]];
    [mailComposer setSubject:[NSString stringWithFormat: @"Endless Stories Support v%@",version]];
    NSString *supportText = [NSString stringWithFormat:@"Device: %@\niOS Version:%@\n\n",model,iOSVersion];
    supportText = [supportText stringByAppendingString: @""];
    [mailComposer setMessageBody:supportText isHTML:NO];
    [self presentViewController:mailComposer animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
