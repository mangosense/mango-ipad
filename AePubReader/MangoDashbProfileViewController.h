//
//  MangoDashbProfileViewController.h
//  MangoReader
//
//  Created by Harish on 4/27/14.
//
//

#import <UIKit/UIKit.h>

@interface MangoDashbProfileViewController : UIViewController

@property (nonatomic,retain) IBOutlet UIButton *loginButton;
- (IBAction)logoutUser:(id)sender;
- (IBAction)moveToBack:(id)sender;

@end
