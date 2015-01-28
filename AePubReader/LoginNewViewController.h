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
#import "EJDBController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LoginNewViewController : UIViewController <MangoPostApiProtocol, UINavigationControllerDelegate, PostSignupDelegate, FBLoginViewDelegate, UIScrollViewDelegate>{
    
    NSString *userEmail;
    NSString *currentPage;
    
    UIScrollView* scrollView;
	UIPageControl* pageControl;
	UINavigationController *navController;
	BOOL pageControlBeingUsed;
    
}
- (IBAction)signIn:(id)sender;
- (IBAction)goToNext:(id)sender;
- (IBAction)signUp:(id)sender;

@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UIView *imageHelpView;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;
@property (nonatomic, retain) IBOutlet UIButton *helpButton;
@property (nonatomic, assign) NSString *pushNoteBookId;
@property (nonatomic, assign) NSString *pushCreateStory;
@property (nonatomic, assign) NSString *pushSubscribe;

- (IBAction)changePage;
- (IBAction)skipHelpPageView:(id)sender;
- (IBAction)showHelpPageView:(id)sender;

///////New App
- (IBAction) moveToAgeGrouoSelection:(id)sender;

@end
