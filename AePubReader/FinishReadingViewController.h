//
//  FinishReadingViewController.h
//  MangoReader
//
//  Created by Harish on 1/15/15.
//
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "Constants.h"

@interface FinishReadingViewController : UIViewController

@property(strong,nonatomic) NSString *identity;
@property(strong,nonatomic) Book *book;

@property(strong, nonatomic) NSString *totalWords;
@property(strong, nonatomic) NSString *totalTime;
@property (strong, nonatomic) IBOutlet UILabel *timeTakenValue;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withId :(NSString*)identity;
- (IBAction)gameButtonTapped:(id)sender;
- (IBAction)dismissToHomePage:(id)sender;

@end
