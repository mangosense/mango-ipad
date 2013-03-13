//
//  CustomNavViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 07/01/13.
//
//

#import "CustomNavViewController.h"
#import "AePubReaderAppDelegate.h"
#import "EpubReaderViewController.h"

@interface CustomNavViewController ()

@end

@implementation CustomNavViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _delegateApp=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
-(NSUInteger)supportedInterfaceOrientations{
    NSLog(@"Navigation Supported");
  
    
    if (!_delegateApp.PortraitOrientation) {
    
        return UIInterfaceOrientationMaskLandscape;
    }else if(!_delegateApp.LandscapeOrientation)
    {
        return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
    }
    
    return [self.topViewController supportedInterfaceOrientations]; 
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    NSLog(@"Navigation Supported ios 5");
    if (!_delegateApp.PortraitOrientation) {
//        if (_delegateApp.alertView) {
//            [_delegateApp.alertView dismissWithClickedButtonIndex:0 animated:YES];
//            _delegateApp.alertView=nil;
//        }
          return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
        
    }else if(!_delegateApp.LandscapeOrientation)
    {
//        if (_delegateApp.alertView) {
//            [_delegateApp.alertView dismissWithClickedButtonIndex:0 animated:YES];
//            _delegateApp.alertView=nil;
//        }
      return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    }
    return [self.topViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}
//-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    if (!_delegateApp.PortraitOrientation) {
//        return UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
//    }else if(!_delegateApp.LandscapeOrientation)
//    {
//        return UIInterfaceOrientationPortrait;
//    }
//  return  [self.topViewController preferredInterfaceOrientationForPresentation];
//
//  
//}
-(BOOL)shouldAutorotate{

    return [self.topViewController shouldAutorotate];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
