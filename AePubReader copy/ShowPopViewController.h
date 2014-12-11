//
//  ShowPopViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 09/05/13.
//
//

#import <UIKit/UIKit.h>

@interface ShowPopViewController : UIViewController
@property(strong,nonatomic)NSString *desc;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withString:(NSString *)desc;

@end
