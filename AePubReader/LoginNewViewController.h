//
//  LoginNewViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 20/11/13.
//
//

#import <UIKit/UIKit.h>
#import "MangoApiController.h"
#import "SignUpViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LoginNewViewController : UIViewController <MangoPostApiProtocol, PostSignupDelegate, FBLoginViewDelegate, UIScrollViewDelegate>{
    
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;
    NSString *viewName;
    
    UIScrollView* scrollView;
	UIPageControl* pageControl;
	
	BOOL pageControlBeingUsed;
    
}
- (IBAction)signIn:(id)sender;
- (IBAction)goToNext:(id)sender;
- (IBAction)signUp:(id)sender;

@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) NSString *udid;

@property (nonatomic, retain) IBOutlet UIView *imageHelpView;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;
@property (nonatomic, retain) IBOutlet UIButton *helpButton;

- (IBAction)changePage;
- (IBAction)skipHelpPageView:(id)sender;
- (IBAction)showHelpPageView:(id)sender;

@end
