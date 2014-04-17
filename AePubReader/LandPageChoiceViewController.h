//
//  LandPageChoiceViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 19/11/13.
//
//

#import <UIKit/UIKit.h>
#import "StoriesViewController.h"
@interface LandPageChoiceViewController : UIViewController{
    
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;
    NSString *viewName;
}
- (IBAction)creatAStory:(id)sender;
- (IBAction)openFreeStories:(id)sender;
- (IBAction)store:(id)sender;
- (IBAction)myStories:(id)sender;

@property(retain,nonatomic)StoriesViewController *storiesViewController;
@end
