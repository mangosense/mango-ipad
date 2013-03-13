//
//  FacebookLogin.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 11/12/12.
//
//

#import <Foundation/Foundation.h>
#import "LoginViewController.h"
@interface FacebookLogin : NSObject<NSURLConnectionDataDelegate>
@property(retain,nonatomic)NSMutableData *data;
@property(assign,nonatomic)LoginViewController *loginViewController;
-(id)initWithloginViewController:(LoginViewController *)login;

@end
