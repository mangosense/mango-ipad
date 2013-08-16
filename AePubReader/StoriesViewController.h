//
//  StoriesViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 16/08/13.
//
//

#import <UIKit/UIKit.h>

@interface StoriesViewController : UIViewController {
    
}

@property (nonatomic, strong) IBOutlet UIButton *englishLanguageButton;
@property (nonatomic, strong) IBOutlet UIButton *tamilLanguageButton;
- (IBAction)languageButtonTapped:(id)sender;

@end
