//
//  CustomTabViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 07/01/13.
//
//

#import <UIKit/UIKit.h>
#import "AePubReaderAppDelegate.h"
@interface CustomTabViewController : UITabBarController
@property(assign,nonatomic) AePubReaderAppDelegate *delegateApp;
@end
