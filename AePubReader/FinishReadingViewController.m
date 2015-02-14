//
//  FinishReadingViewController.m
//  MangoReader
//
//  Created by Harish on 1/15/15.
//
//

#import "FinishReadingViewController.h"
#import "AePubReaderAppDelegate.h"
#import "MangoGamesListViewController.h"
#import "HomePageViewController.h"
#import "PageNewBookTypeViewController.h"

@interface FinishReadingViewController ()

@end

@implementation FinishReadingViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withId :(NSString*)identity{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        _identity=identity;
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        _book= [delegate.dataModel getBookOfId:identity];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*if([_totalTime integerValue] > 60){
        int minutes = floor([_totalTime integerValue]/60);
        int seconds = round([_totalTime integerValue] - minutes * 60);
        _timeTakenValue.text = [NSString stringWithFormat:@"Welldone! you have completed the book in %d min and %d sec",minutes, seconds];
    }
    else{
        int seconds = [_totalTime integerValue];
        _timeTakenValue.text = [NSString stringWithFormat:@"Welldone! you have completed the book in %d sec", seconds];
    }*/
    
    self.bannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0, 0.0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
    self.bannerView_.adUnitID = @"ca-app-pub-2797581562576419/9752375688";
    self.bannerView_.delegate = self;
    [self.bannerView_ setRootViewController:self];
    [self.bookDownloadView addSubview:self.bannerView_];
    [self.bannerView_ loadRequest:[self request]];
    
    _timeTakenValue.text = @"to be obtained";
    
    // Do any additional setup after loading the view from its nib.
}


//for banner ad

 - (GADRequest *)request{
 
 GADRequest *request = [GADRequest request];
 request.testDevices = @[GAD_SIMULATOR_ID, @"cb070a3553b00abe94caf7932cf48233"];
 return request;
 }
 - (void) adViewDidReceiveAd:(GADBannerView *)view{
 //self.btnToDiasplayRemoveAds.hidden = NO;
 NSLog(@"receive ad");
 [UIView animateWithDuration:1.0 animations:^{
 view.frame = CGRectMake(self.view.frame.size.width, 0.0, self.view.frame.size.width, view.frame.size.height+50);
 }];
 }
 - (void) adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{
 
 //self.btnToDiasplayRemoveAds.hidden = YES;
 NSLog(@"Failed to received ad due to : %@",[error localizedFailureReason]);
 }


- (IBAction) startReadingNewbook:(id)sender{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"levelInfoMod" ofType:@"json"];
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSError *error =  nil;
    NSArray* allDisplayBooks = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int indexVal = [[prefs valueForKey:@"BOOKINDEX"]integerValue];
    if(indexVal+1 >= allDisplayBooks.count){
        indexVal = 0;
    }
    else{
        indexVal++;
        
    }
    [self readyBookToOpen:[[allDisplayBooks objectAtIndex:indexVal] valueForKey:@"id"]];
}

- (IBAction)readyBookToOpen:(NSString *)bookId{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    Book *bk=[appDelegate.dataModel getBookOfEJDBId:bookId];
    //if subscribed user user then dowload irrespectively
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validUserSubscription = [[prefs valueForKey:@"USERSUBSCRIBED"] integerValue];
    int currentIndexVal = [[prefs valueForKey:@"BOOKINDEX"]integerValue];
    if(validUserSubscription){
        [prefs setValue:[NSString stringWithFormat:@"%d", currentIndexVal+1] forKey:@"BOOKINDEX"];
        if(bk.localPathFile){
            [self openBook:bk];
        }
        else{
            //download the book
            _bookDownloadView.hidden = NO;
            [_bookDownloadingActivity startAnimating];
            MangoApiController *apiController = [MangoApiController sharedApiController];
            [apiController downloadBookWithId:bookId withDelegate:self ForTransaction:nil];
        }
    }
    else{
        
        BOOL val = [self checkIfBookAcessible:currentIndexVal];
        int freeIndexVal = [[prefs valueForKey:@"DAILYFREEBOOK_INDEX"]integerValue];
        if(val || (freeIndexVal == currentIndexVal)){
            [prefs setValue:[NSString stringWithFormat:@"%d", currentIndexVal+1] forKey:@"BOOKINDEX"];
            //lies in free books
            if(bk.localPathFile){
                [self openBook:bk];
            }
            else{
                //download the book
                _bookDownloadView.hidden = NO;
                [_bookDownloadingActivity startAnimating];
                MangoApiController *apiController = [MangoApiController sharedApiController];
                [apiController downloadBookWithId:bookId withDelegate:self ForTransaction:nil];
            }
        }
        else{
            //do nothing
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry not accessible" message:@"Please subscribe to access it" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

- (BOOL) checkIfBookAcessible :(int) value{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int positionIndex = [[prefs valueForKey:@"USERBOOKINDEX"] integerValue];
    
    if((value >= positionIndex) && (value < (positionIndex+5))){
        
        return TRUE;
    }
    else{
        
        return FALSE;
    }
}

- (void)bookDownloaded:(NSString *)bookId{
    _bookDownloadView.hidden = YES;
    [_bookDownloadingActivity stopAnimating];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    Book *bk=[appDelegate.dataModel getBookOfEJDBId:bookId];
    [self openBook:bk];
}
- (void) bookDownloadAborted:(NSString *)bookId{
    
    _bookDownloadView.hidden = YES;
    [_bookDownloadingActivity stopAnimating];
}


- (void)openBook:(Book *)bk {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *identity=[NSString stringWithFormat:@"%@", bk.id];
    [appDelegate.dataModel displayAllData];
    
    PageNewBookTypeViewController *controller;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController_iPhone" bundle:nil WithOption:nil BookId:bk.id];
        
    }
    else{
        controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController" bundle:nil WithOption:nil BookId:bk.id];
    }
    
    [self.navigationController pushViewController:controller animated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    _bannerView_.delegate = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)dismissToHomePage:(id)sender{
    
        for(UIViewController *controller in self.navigationController.viewControllers){
    
            if([controller isKindOfClass:[HomePageViewController class]]){
    
                [self.navigationController popToViewController:controller animated:YES];
                break;
            }
        }
}



@end
