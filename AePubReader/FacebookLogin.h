//
//  FacebookLogin.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 11/12/12.
//
//

#import <Foundation/Foundation.h>
#import "LoginNewViewController.h"

@interface FacebookLogin : NSObject<NSURLConnectionDataDelegate>

@property(retain,nonatomic) NSMutableData *data;
@property(assign,nonatomic) LoginNewViewController *loginViewController;

-(id)initWithloginViewController:(LoginNewViewController *)login;

@end
