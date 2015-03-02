//
//  AppInfoViewController.h
//  MangoReader
//
//  Created by Harish on 1/22/15.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface AppInfoViewController : UIViewController{
    
    NSString *currentScreen;
}

- (IBAction) backToHomePage:(id)sender;


- (IBAction)emailSupport:(id)sender;

@end
