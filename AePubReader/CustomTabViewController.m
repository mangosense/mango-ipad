//
//  CustomTabViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 07/01/13.
//
//

#import "CustomTabViewController.h"

@interface CustomTabViewController ()

@end

@implementation CustomTabViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _delegateApp=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        
    }
    return self;
}
-(NSUInteger)supportedInterfaceOrientations{
  //  NSLog(@"Tab Supported");
    if (!_delegateApp.PortraitOrientation) {
        
        return UIInterfaceOrientationMaskLandscape;
    }else if(!_delegateApp.LandscapeOrientation)
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return [self.selectedViewController supportedInterfaceOrientations];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (!_delegateApp.PortraitOrientation) {
        return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    }else if(!_delegateApp.LandscapeOrientation)
    {
        return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    }
    return [self.selectedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    if (!_delegateApp.PortraitOrientation) {
        return UIInterfaceOrientationLandscapeLeft;
    }else if(!_delegateApp.LandscapeOrientation)
    {
        return UIInterfaceOrientationPortrait;
    }
    return  [self.selectedViewController preferredInterfaceOrientationForPresentation];
    
    
}
-(BOOL)shouldAutorotate{
    
    return [self.selectedViewController shouldAutorotate];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
