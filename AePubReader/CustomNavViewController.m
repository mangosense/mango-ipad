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


-(id)initWithRootViewController:(UIViewController *)rootViewController{
    self=[super initWithRootViewController:rootViewController];
    if (self) {
        _delegateApp=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        self.delegate = self;
        self.stack = [[NSMutableArray alloc] init] ;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
-(NSUInteger)supportedInterfaceOrientations{
    //NSLog(@"Navigation Supported");
  
    
    if (!_delegateApp.PortraitOrientation) {
    
        return UIInterfaceOrientationMaskLandscape;
    }else if(!_delegateApp.LandscapeOrientation)
    {
        return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
    }
    
    return [self.topViewController supportedInterfaceOrientations]; 
}
- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    @synchronized(self.stack) {
        if (self.transitioning) {
            void (^codeBlock)(void) = [^{
                [super popViewControllerAnimated:animated];
            } copy];
            [self.stack addObject:codeBlock];
           // [codeBlock release];
            
            // We cannot show what viewcontroller is currently animated now
            return nil;
        } else {
            return [super popViewControllerAnimated:animated];
        }
    }
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
  //  NSLog(@"Navigation Supported ios 5");
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
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    @synchronized(self.stack) {
        if (self.transitioning) {
            // Copy block so its no longer on the (real software) stack
            void (^codeBlock)(void) = [^{
                [super setViewControllers:viewControllers animated:animated];
            } copy];
            
            // Add to the stack list and then release
            [self.stack addObject:codeBlock];
          //  [codeBlock release];
        } else {
            [super setViewControllers:viewControllers animated:animated];
        }
    }
}

- (void) pushCodeBlock:(void (^)())codeBlock{
    @synchronized(self.stack) {
        [self.stack addObject:[codeBlock copy] ];
        
        if (!self.transitioning)
            [self runNextBlock];
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    @synchronized(self.stack) {
        if (self.transitioning) {
            void (^codeBlock)(void) = [^{
                [super pushViewController:viewController animated:animated];
            } copy];
            [self.stack addObject:codeBlock];
       //     [codeBlock release];
        } else {
            [super pushViewController:viewController animated:animated];
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    @synchronized(self.stack) {
        self.transitioning = true;
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    @synchronized(self.stack) {
        self.transitioning = false;
        
        [self runNextBlock];
    }
}

- (void) runNextBlock {
    if (self.stack.count == 0)
        return;
    
    void (^codeBlock)(void) = [self.stack objectAtIndex:0];
    
    // Execute block, then remove it from the stack (which will dealloc)
    codeBlock();
    
    [self.stack removeObjectAtIndex:0];
}
-(BOOL)shouldAutorotate{

    return [self.topViewController shouldAutorotate];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
      [self.stack removeAllObjects];
}
@end
