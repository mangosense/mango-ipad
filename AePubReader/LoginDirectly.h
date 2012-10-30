//
//  LoginDirectly.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 15/10/12.
//
//

#import <Foundation/Foundation.h>
#import "StoreViewController.h"
@interface LoginDirectly : NSObject<NSURLConnectionDataDelegate>
@property(assign,nonatomic)StoreViewController *storeController;
@property(retain,nonatomic)NSMutableData *mutableData;
@property(retain,nonatomic)UIAlertView *alert;
@end
