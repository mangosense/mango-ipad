//
//  FacebookIphoneLogin.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 11/12/12.
//
//

#import <Foundation/Foundation.h>
#import "LoginViewControllerIphone.h"
@interface FacebookIphoneLogin : NSObject<NSURLConnectionDataDelegate>
@property(retain,nonatomic)NSMutableData *data;
@property(assign,nonatomic)LoginViewControllerIphone *loginViewController;
-(id)initWithloginViewController:(LoginViewControllerIphone *)login;
@end
