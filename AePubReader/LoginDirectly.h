//
//  LoginDirectly.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 15/10/12.
//
//

#import <Foundation/Foundation.h>
#import "DownloadViewControlleriPad.h"
@interface LoginDirectly : NSObject<NSURLConnectionDataDelegate>
@property(assign,nonatomic)DownloadViewControlleriPad *storeController;
@property(retain,nonatomic)NSMutableData *mutableData;
@property(retain,nonatomic)UIAlertView *alert;
@end
