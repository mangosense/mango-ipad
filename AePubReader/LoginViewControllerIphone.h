//
//  LoginViewControllerIphone.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 03/12/12.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
@interface LoginViewControllerIphone : UIViewController<NSURLConnectionDataDelegate,UITextFieldDelegate,UIAlertViewDelegate>
@property (retain, nonatomic) IBOutlet UITextField *email;
@property (retain, nonatomic) IBOutlet UITextField *password;
- (IBAction)signUp:(id)sender;
- (IBAction)signIn:(id)sender;
@property(retain,nonatomic)NSMutableData *dataMutable;
@property (retain, nonatomic) IBOutlet UIButton *faceBookId;
- (IBAction)faceBookLogin:(id)sender;
@property(retain,nonatomic)UIAlertView *alertView;
- (IBAction)dismissKeyboard:(id)sender;
@property(assign,nonatomic)BOOL fromSignUp;
@property (retain, nonatomic) IBOutlet UIImageView *orImage;
- (IBAction)skipLogin:(id)sender;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (retain, nonatomic) IBOutlet UIButton *signIn;
@property (retain, nonatomic) IBOutlet UIButton *signUp;
-(void)goToNext;
@property(retain,nonatomic)NSError *error;
-(void)transactionRestored;
-(void)transactionFailed;
-(void)purchaseValidation:(SKPaymentTransaction *)transaction;
-(void)restoreFailed;
@end
