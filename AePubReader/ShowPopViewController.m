//
//  ShowPopViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 09/05/13.
//
//

#import "ShowPopViewController.h"

@interface ShowPopViewController ()

@end

@implementation ShowPopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withString:(NSString *)desc
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _desc=[[NSString alloc]initWithString:desc];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _descrption.text=_desc;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDescrption:nil];
    [super viewDidUnload];
}
@end
