//
//  GameWhileDownloadViewController.m
//  MangoReader
//
//  Created by Harish on 1/25/15.
//
//

#import "GameWhileDownloadViewController.h"
#import "AgeDetailsViewController.h"
#import "AePubReaderAppDelegate.h"
#import "LevelViewController.h"
#import "Constants.h"
#import "MangoEditorViewController.h"

@interface GameWhileDownloadViewController ()
@property (nonatomic, strong) NSMutableDictionary *dataDict;
@end

@implementation GameWhileDownloadViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    bookDownload = [[UserBookDownloadViewController alloc] init];
    bookDownload.delegate = self;
    [bookDownload returnArrayElementa];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.labelText = @"Please wait!!";
    
    [self.webView bringSubviewToFront:_hud];
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    _book= [delegate.dataModel getBookOfId:@"5405663a69702d047a020000"];
    
    NSString *jsonLocation = [AePubReaderAppDelegate returnBookJsonPath:_book];
    
    NSDictionary *jsonDict = [self getJsonDictForBook];
    
    NSMutableArray *gameNames = [[NSMutableArray alloc] init];
    for (NSDictionary *pageDict in [jsonDict objectForKey:PAGES]) {
        if ([[pageDict objectForKey:TYPE] isEqualToString:GAME]) {
            [gameNames addObject:[pageDict objectForKey:NAME]];
        }
    }
        
    NSString *gameName = [gameNames objectAtIndex:1];
    
    NSString *jsonString = [self getJsonContentForBook];
    
    NSData *jsonData1 = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict1 = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData1 options:NSJSONReadingAllowFragments error:nil]];
    
    NSMutableArray *readerPagesArray1 = [[NSMutableArray alloc] initWithArray:[jsonDict1 objectForKey:PAGES]];
    NSMutableArray *gamesDataArray = [[NSMutableArray alloc] init];
    for (NSDictionary *readerPageDict in readerPagesArray1){
        if(([[readerPageDict objectForKey:PAGE_NAME] length] >3) && !([[readerPageDict objectForKey:PAGE_NAME] isEqualToString:@"Cover"])){
            NSLog(@"not match - %@", [readerPageDict objectForKey:PAGE_NAME]);
            [gamesDataArray addObject:readerPageDict];
        }
    }
    
    
    NSString *folderLocation = jsonLocation;
    
    NSMutableDictionary *gameViewDict = [MangoEditorViewController readerGamePagePro:gameName ForStory:gamesDataArray WithFolderLocation:folderLocation AndOption:99];
    
    _dataDict = [[NSMutableDictionary alloc] initWithDictionary:[gameViewDict objectForKey:@"data"]];
    [_dataDict setObject:[NSNumber numberWithBool:YES] forKey:@"from_mobile"];
    
//    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    
    _webView = [gameViewDict objectForKey:@"gameView"];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.frame = self.view.frame;
    [_webView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth];
    [[_webView scrollView] setBounces:NO];
    [self.view addSubview:_webView];
    
     [self.view bringSubviewToFront:_waitViewLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventListenerDidReceiveNotification:) name:@"BookProgressValue" object:nil];
    // Do any additional setup after loading the view from its nib.
}


- (NSDictionary *)getJsonDictForBook {
    NSString *jsonContent = [self getJsonContentForBook];
    NSData *jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    
    return jsonDict;
}

- (NSString *)getJsonContentForBook {
    
    NSString *jsonLocation = [AePubReaderAppDelegate returnBookJsonPath:_book];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
    NSString *jsonContent=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    return jsonContent;
}


#pragma mark - UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_dataDict options:NSJSONReadingMutableContainers error:nil];
    
    NSString *paramString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Param: %@", paramString);
    
    NSString *resultString = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"MangoGame.init(%@)", paramString]];
    NSLog(@"%@", resultString);
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    //test to execute javascript menthod to execute method after delay
    //[self performSelector:@selector(hideAlert:) withObject:alert afterDelay:1.5];
    //[self performSelector:@selector(testRestartGame) withObject:nil afterDelay:35.0];
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}


- (void)eventListenerDidReceiveNotification:(NSNotification *)notif
{
    
    //NSLog(@"Successfully received the notification!");
    
    NSDictionary *userInfo = notif.userInfo;
    
    NSString *newIDValue = [userInfo valueForKey:@"bookIdVal"];
    int newProgress = [[userInfo valueForKey:@"progressVal"] integerValue];
    if([firstBookId isEqualToString:newIDValue]){
        [self updateBookProgress:newProgress withBookId:newIDValue];
    }
}

- (void)updateBookProgress:(int)bookProgress withBookId:(NSString *)bookid {
    
    if(bookProgress == 99){
        
        //get index of bookid and set that in index value
    }
    
}


- (IBAction)getJsonIntoArray:(NSArray *) bookArray{
    
    //find level say level "L"
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int index;
    int finalIndex;
    
    _booksArray = bookArray;
    for(NSDictionary *bookdata in bookArray){
        
        NSString *level =[LevelViewController getLevelFromAge:_ageVal];
        if([[bookdata valueForKey:@"level"] isEqualToString:level]){
            
            //call to download two books of level L
            index = [bookArray indexOfObject:bookdata];
            
            
            [prefs setInteger:index forKey:@"USERBOOKINDEX"];
            
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:[NSDate date]];
            NSDateComponents *monComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:[NSDate date]];
            int currentDay = [components day];
            int currentMonth = [monComponents month];
            NSString *dateWithIndex = [NSString stringWithFormat:@"%d_%d_%d",currentDay, currentMonth, index+5];
            [prefs setInteger:dateWithIndex forKey:@"DATEDDMM_INDEX"];

            firstBookId = [bookdata valueForKey:@"id"];
            finalIndex = index+5;
            break;
            //for (int i = [bookArray indexOfObject:bookdata]; i < = i)
            //[bookDownload downloadBook:[bookdata valueForKey:@"id"]];
        }
    }
    
    for (int i = index; i < finalIndex; ++i) {
        NSLog(@"inddex %d", i);
        
        [bookDownload downloadBook:[[bookArray objectAtIndex:i] valueForKey:@"id"]];
    }
    
}

- (IBAction) finishBookDownlaod{
    
    
    [self closeGameView:nil];
}


- (IBAction)closeGameView:(id)sender{
    
    [self dismissViewControllerAnimated:NO completion:^(void) {
        
    }];
}

- (void) viewWillDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseGamesWhileDownload" object:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
