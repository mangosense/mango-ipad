//
//  CustomNavViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 07/01/13.
//
//

#import <UIKit/UIKit.h>
#import "AePubReaderAppDelegate.h"
@interface CustomNavViewController : UINavigationController<UINavigationControllerDelegate>
@property(nonatomic,assign)AePubReaderAppDelegate *delegateApp;
@property(nonatomic,assign)UIAlertView *alert;

@end
