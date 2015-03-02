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
#import "DYRateView.h"
#import "MangoApiController.h"
#import "GADBannerView.h"
#import "GADRequest.h"

@interface FinishReadingViewController : UIViewController<MangoPostApiProtocol,GADBannerViewDelegate>{
    
    float rate;
    NSString *currentScreen;
}

@property(strong,nonatomic) NSString *identity;
@property(strong,nonatomic) Book *book;

@property (strong, nonatomic) NSString *totalTime;
@property (strong, nonatomic) NSString *rateValue;
@property (strong, nonatomic) IBOutlet UILabel *scoreValue;
@property (strong, nonatomic) IBOutlet UILabel *timeTakenValue;

@property (strong , nonatomic) IBOutlet UIView *bookDownloadView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *bookDownloadingActivity;
@property (nonatomic, strong) GADBannerView *bannerView_;

@property (nonatomic, retain) IBOutlet DYRateView *myPicsRate;

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) NSArray *allDisplayBooks;

@property (nonatomic, strong) NSString *currentLevel;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withId :(NSString*)identity;

- (IBAction) dismissToHomePage:(id)sender;

- (IBAction) startReadingNewbook:(id)sender;

- (GADRequest *)request;

@end
