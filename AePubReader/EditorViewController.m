//
//  EditorViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 08/08/13.
//
//

#import "EditorViewController.h"
#import <QuartzCore/QuartzCore.h>

#define MAIN_TEXTVIEW_TAG 100

@interface EditorViewController ()

@end

@implementation EditorViewController

@synthesize backgroundImageView;
@synthesize mainTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title=@"Editor";
        self.tabBarItem.image=[UIImage imageNamed:@"library.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.    
    backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:backgroundImageView];
    
    mainTextView = [[MovableTextView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + 20, self.view.frame.origin.y + 20, self.view.frame.size.width/3, self.view.frame.size.height/4)];
    mainTextView.tag = MAIN_TEXTVIEW_TAG;
    mainTextView.textColor = [UIColor blackColor];
    mainTextView.font = [UIFont systemFontOfSize:17];
    mainTextView.text = @"This is a sample text for this storybook page.";
    [self.view addSubview:mainTextView];
    
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo1.png"]];
    self.navigationItem.titleView=imageView;
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
