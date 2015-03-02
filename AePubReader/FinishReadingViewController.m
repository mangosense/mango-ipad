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
#import "ReadBook.h"
#import "UserBookDownloadViewController.h"

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
    
    currentScreen = @"finishReadingPage";
    
    if([_totalTime integerValue] > 60){
        int minutes = floor([_totalTime integerValue]/60);
        int seconds = round([_totalTime integerValue] - minutes * 60);
        _timeTakenValue.text = [NSString stringWithFormat:@"Welldone! You just read the story in %d min and %d sec",minutes, seconds];
    }
    else{
        int seconds = [_totalTime integerValue];
        _timeTakenValue.text = [NSString stringWithFormat:@"Welldone! You just read the story in %d sec", seconds];
    }
    
    
    //_timeTakenValue.text = @"to be obtained";
    //Apply ratevalue
    
    rate = [self returnCorrectRateValue:[_rateValue floatValue]];
    
    _scoreValue.text = [NSString stringWithFormat:@"and scored %d points", (int)rate*100];
    
    //Rating value
    DYRateView *rateView;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        rateView = [[DYRateView alloc] initWithFrame:CGRectMake(120, 50, 190, 75)];
    }
    else{
        rateView = [[DYRateView alloc] initWithFrame:CGRectMake(170, 135, 490, 285)];
    }
    rateView.rate = rate;
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/StarSound%d.mp3",
                               [[NSBundle mainBundle] resourcePath],(int)rate];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL
                                                     error:nil];
    [_player play];
    rateView.alignment = RateViewAlignmentRight;
    [self.view addSubview:rateView];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"levelInfoMod" ofType:@"json"];
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSError *error =  nil;
    
    _allDisplayBooks = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    
    // Do any additional setup after loading the view from its nib.
}

- (float) returnCorrectRateValue :(float) value{
    
    int val;
    if(value >= 0 && value < 2){
        val = 1.0;
    }
    else if(value >= 2 && value <3){
        val = 2.0;
    }
    else if(value >= 3 && value <4){
        val = 3.0;
    }
    else if(value >= 4 && value <5){
        val = 4.0;
    }
    else val = 5.0;
    
    return val;
}

- (void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    _book= [delegate.dataModel getBookOfId:_identity];
    
    for(NSDictionary *element in _allDisplayBooks){
        if([[element valueForKey:@"id"] isEqualToString:_book.id]){
            
            _currentLevel = [element valueForKey:@"level"];
            break;
        }
    }
    
    [self saveReaderInfo:@"book"];
    
    NSDictionary *dimensions = @{
                                 
                                 PARAMETER_ACTION : @"finishReadingPage",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_EVENT_DESCRIPTION : @"finish Reading Page open",
                                 };
    [delegate trackEventAnalytic:@"finishReadingPage" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"finishReadingPage"];
}


//for banner ad

 - (GADRequest *)request{
 
 GADRequest *request = [GADRequest request];
 //request.testDevices = @[GAD_SIMULATOR_ID, @"635c376ad4fbda6e7cb2ac5bc6043b7b"];
     request.testDevices = @[ @"635c376ad4fbda6e7cb2ac5bc6043b7b" ];
 return request;
 }
 - (void) adViewDidReceiveAd:(GADBannerView *)view{
 //self.btnToDiasplayRemoveAds.hidden = NO;
 NSLog(@"receive ad");
 [UIView animateWithDuration:1.0 animations:^{
     view.frame = CGRectMake(self.view.frame.size.width/6, 0.0, self.view.frame.size.width/1.5, view.frame.size.height);
 }];
 }
 - (void) adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{
 
 //self.btnToDiasplayRemoveAds.hidden = YES;
 NSLog(@"Failed to received ad due to : %@",[error localizedFailureReason]);
 }

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}


- (IBAction) startReadingNewbook:(id)sender{
    
    if(![self connected])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please internet connection appears offline, please try later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    //Admob start
    self.bannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0, 0.0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
    self.bannerView_.adUnitID = @"ca-app-pub-2797581562576419/4174354482";
    //self.bannerView_.delegate = self;
    //[self.bannerView_ setRootViewController:self];
    self.bannerView_.rootViewController = self;
    //[self.bannerView_ loadRequest:[GADRequest request]];
    [self.bookDownloadView addSubview:self.bannerView_];
    [self.bannerView_ loadRequest:[self request]];
    //
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int nextBookIndex;
    
    NSArray *availableBooks = [UserBookDownloadViewController returnSpecificLevelBooks:_allDisplayBooks getLevel:_currentLevel];
    
    for(int i = 0; i < availableBooks.count; ++i){
        if([[[availableBooks objectAtIndex:i] valueForKey:@"id"] isEqualToString:_book.id]){
            
            nextBookIndex = i+1;
            break;
        }
    }
    
    NSDictionary *nextBookInfo = [availableBooks objectAtIndex:nextBookIndex];
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 
                                 PARAMETER_ACTION : @"nextBookClick",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_LEVEL_VALUE : [nextBookInfo valueForKey:@"level"],
                                 PARAMETER_BOOK_ID : [nextBookInfo valueForKey:@"id"],
                                 PARAMETER_EVENT_DESCRIPTION : @"read next level book click",
                                 };
    [delegate trackEventAnalytic:@"nextBookClick" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"nextBookClick"];
    
    //check subscribed or not
    int validUserSubscription = [prefs boolForKey:@"USERSUBSCRIBED"];
    int hasfreeTrial= [prefs boolForKey:@"HASFREETRIALACCESS"];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    if(validUserSubscription || hasfreeTrial){
        
        //if([[nextBookInfo valueForKey:@"level"] isEqualToString:_currentLevel]){
            
            //allow to download the book
            [self readyBookToOpen:[nextBookInfo valueForKey:@"id"]];
//        }
//        else{
//            
//            NSArray *readBooks =[appDelegate.dataModel getAllUserReadBooks:_currentLevel];
//            
//            if(availableBooks.count == readBooks.count){
//                
//                [self readyBookToOpen:[nextBookInfo valueForKey:@"id"]];
//                [prefs setValue:[nextBookInfo valueForKey:@"level"] forKey:@"CURRENTUSERLEVEL"];
//            }
//            else{
//                
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry not accessible" message:@"Please complete all books of current level" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//                [alert show];
//            }
//        }
        
    }
    else{
        //if in same level and in range
        if([[nextBookInfo valueForKey:@"level"] isEqualToString:_currentLevel]){
            
            //check if lie in range value of free books
            //if yes then allow user to download books
            BOOL flag = 0;
            int countLevelBooks = [availableBooks count];
            if(countLevelBooks >5){// download from 1 to 5
                countLevelBooks = 5;
            }
            for (int i = 1; i < countLevelBooks; ++i) {
                
                if([[[availableBooks objectAtIndex:i] valueForKey:@"id"] isEqualToString:[nextBookInfo valueForKey:@"id"]]){
                    
                    [self readyBookToOpen:[nextBookInfo valueForKey:@"id"]];
                    flag = 1;
                    break;
                }
            }
            if(!flag){
             
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry not accessible" message:@"Please subscribe to access it" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }
            
        }
        else{
            // display alert for to subscribe
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry not accessible" message:@"Please subscribe to access it" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
}

- (IBAction)readyBookToOpen:(NSString *)bookId{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    Book *bk=[appDelegate.dataModel getBookOfEJDBId:bookId];
    //if subscribed user user then dowload irrespectively
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int currentIndexVal = [[prefs valueForKey:@"BOOKINDEX"]integerValue];
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
    
    /*else{
        
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
    }*/
}

/*- (BOOL) checkIfBookAcessible :(int) value{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int positionIndex = [[prefs valueForKey:@"USERBOOKINDEX"] integerValue];
    
    if((value >= positionIndex) && (value < (positionIndex+5))){
        
        return TRUE;
    }
    else{
        
        return FALSE;
    }
}*/

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

//core data to store information
- (void) saveReaderInfo :(NSString *) bookId{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    ReadBook *userReadBook = [appDelegate.dataModel getReadBookInstance];
    if (![appDelegate.dataModel checkIfReadIdExists:_book.id] ){
        userReadBook.date = [NSDate date];
        userReadBook.isRead = @YES;
        userReadBook.id = _book.id;
        userReadBook.starRate = [NSNumber numberWithInt:(int)rate];
        userReadBook.bookPoints = [NSNumber numberWithInt:(int)rate*100];
        userReadBook.bookTitle =  _book.title;
        userReadBook.levelValue = _currentLevel;
    
        NSError *error=nil;
        if (![appDelegate.managedObjectContext save:&error]) {
            NSLog(@"%@",error);
        }
    }
    else if([appDelegate.dataModel checkIfReadIdExists:_book.id]){
        NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"ReadBook"];
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"bookId == %@",_book.id];
        fetchRequest.predicate=predicate;
        ReadBook *newReadBook = [[appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
        [newReadBook setValue:[NSNumber numberWithInt:[_rateValue integerValue]*100] forKey:@"bookPoints"];
        [newReadBook setValue:[NSNumber numberWithInt:[_rateValue integerValue]] forKey:@"starRate"];
        
        NSError *error=nil;
        if (![appDelegate.managedObjectContext save:&error]) {
            NSLog(@"%@",error);
        }
        
    }
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
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 
                                 PARAMETER_ACTION : @"homeButtonClick",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_EVENT_DESCRIPTION : @"back to home click",
                                 };
    [delegate trackEventAnalytic:@"homeButtonClick" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"homeButtonClick"];
    
        for(UIViewController *controller in self.navigationController.viewControllers){
    
            if([controller isKindOfClass:[HomePageViewController class]]){
    
                [self.navigationController popToViewController:controller animated:YES];
                break;
            }
        }
}



@end
