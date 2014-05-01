//
//  MangoDashboardTabViewController.m
//  MangoReader
//
//  Created by Harish on 4/27/14.
//
//

#import "MangoDashboardTabViewController.h"

@interface MangoDashboardTabViewController ()

@end

@implementation MangoDashboardTabViewController
@synthesize rootController, viewCtr1, viewCtr2, viewCtr3;

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
    self.navigationController.navigationBarHidden = NO;
   // CGRect screenArea = [[UIScreen mainScreen] applicationFrame];
    
//    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(loadHomeView)];
//    self.navigationItem.rightBarButtonItem = homeButton;
//    
//    rootController.view.frame = CGRectMake(0,0,screenArea.size.width,screenArea.size.height);
    
//    CGRect frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 300);
//    UIView *v = [[UIView alloc] initWithFrame:frame];
//    [v setBackgroundColor:[UIColor greenColor]];
//    [v setAlpha:0.5];
//    [[self tabBar] addSubview:v];
    
    [[UITabBar appearance] setBackgroundColor:[UIColor orangeColor]];
    
    [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor], UITextAttributeTextColor,
                                               nil] forState:UIControlStateNormal];
    
    viewCtr1 = [[MangoDashbSubscibeViewController alloc] initWithNibName:@"MangoDashbSubscibeViewController" bundle:nil];
    [viewCtr1 setTitle:@"My Subscription"];
   // viewCtr1.tabBarItem.image =  [UIImage imageNamed:@"Logout.png"];
   // viewCtr1.tabBarItem.title = @"My Subscription";
    //viewCtr1.tabBarItem.i
    
    viewCtr2 = [[MangoDashbProfileViewController alloc] initWithNibName:@"MangoDashbProfileViewController" bundle:nil];
    [viewCtr2 setTitle:@"My Profile View"];
   // viewCtr2.tabBarItem.image =  [UIImage imageNamed:@"feedbackbutton.png"];
    
    viewCtr3 = [[MangoAnalyticsViewController alloc] initWithNibName:@"MangoAnalyticsViewController" bundle:nil];
    [viewCtr3 setTitle:@"My Analytics View"];
   // viewCtr3.tabBarItem.image =  [UIImage imageNamed:@"feedbackbutton.png"];
    
    rootController = [[UITabBarController alloc] init];
    rootController.viewControllers = [NSArray arrayWithObjects:viewCtr1, viewCtr2,viewCtr3, nil];
    rootController.delegate=self;
    [self.view addSubview:rootController.view];
    
    self.navigationController.navigationBar.hidden = NO;
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
