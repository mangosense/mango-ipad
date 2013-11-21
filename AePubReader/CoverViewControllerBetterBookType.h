//
//  CoverViewControllerBetterBookType.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/13.
//
//

#import <UIKit/UIKit.h>

@interface CoverViewControllerBetterBookType : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIButton *games;
- (IBAction)optionsToReader:(id)sender;
- (IBAction)libraryButtonClicked:(id)sender;

@end
