//
//  MangoDashbHelpViewController.h
//  MangoReader
//
//  Created by Jagdish on 5/3/14.
//
//

#import <UIKit/UIKit.h>

@interface MangoDashbHelpViewController : UIViewController{
    
    NSString *storyAsAppFilePath;
    int validUserSubscription;
}

@property (nonatomic, strong) IBOutlet UICollectionView *helpImagesDisplayView;
@property (nonatomic,retain) IBOutlet UIButton *loginButton;
- (IBAction)logoutUser:(id)sender;
- (IBAction)moveToBack:(id)sender;

@end
