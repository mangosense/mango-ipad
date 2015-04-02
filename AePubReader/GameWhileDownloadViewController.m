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
    
//    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    _hud.labelText = @"Please wait!!";
    
    [self.webView bringSubviewToFront:_hud];
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    _book= [delegate.dataModel getBookOfId:@"5405663a69702d047a020000"];
    
    NSString *jsonLocation = [AePubReaderAppDelegate returnBookJsonPath:_book];
    
    //NSDictionary *jsonDict = [self getJsonDictForBook];
    
   /* NSMutableArray *gameNames = [[NSMutableArray alloc] init];
    for (NSDictionary *pageDict in [jsonDict objectForKey:PAGES]) {
        if ([[pageDict objectForKey:TYPE] isEqualToString:GAME]) {
            [gameNames addObject:[pageDict objectForKey:NAME]];
        }
    }*/
        
    //NSString *gameName = [gameNames objectAtIndex:1];
    
/*    NSString *jsonString = [self getJsonContentForBook];
    
    NSData *jsonData1 = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict1 = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData1 options:NSJSONReadingAllowFragments error:nil]];
    
    NSMutableArray *readerPagesArray1 = [[NSMutableArray alloc] initWithArray:[jsonDict1 objectForKey:PAGES]];
    NSMutableArray *gamesDataArray = [[NSMutableArray alloc] init];
    for (NSDictionary *readerPageDict in readerPagesArray1){
        if(([[readerPageDict objectForKey:PAGE_NAME] length] >3) && !([[readerPageDict objectForKey:PAGE_NAME] isEqualToString:@"Cover"])){
            NSLog(@"not match - %@", [readerPageDict objectForKey:PAGE_NAME]);
            [gamesDataArray addObject:readerPageDict];
        }
    }*/
    
    
    NSString *folderLocation = jsonLocation;
    
    //NSMutableDictionary *gameViewDict = [MangoEditorViewController readerGamePagePro:gameName ForStory:gamesDataArray WithFolderLocation:folderLocation AndOption:99];
    
   // _dataDict = [[NSMutableDictionary alloc] initWithDictionary:[gameViewDict objectForKey:@"data"]];
   // [_dataDict setObject:[NSNumber numberWithBool:YES] forKey:@"from_mobile"];
    
//    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    
    //_webView = [gameViewDict objectForKey:@"gameView"];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.frame = self.view.frame;
    [_webView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth];
    [[_webView scrollView] setBounces:NO];
   // [self.view addSubview:_webView];
    
     [self.view bringSubviewToFront:_waitViewLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventListenerDidReceiveNotification:) name:@"BookProgressValue" object:nil];
    // Do any additional setup after loading the view from its nib.
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        width = 88.0;
        height = 107.0;
    }
    else{
        width = 217.0;
        height = 295.0;
    }
    [self addAnimationToView];
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
    
//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
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
    NSString *level =[LevelViewController getLevelFromAge:_ageVal];
    
    for(NSDictionary *bookdata in bookArray){
        
        
        if([[bookdata valueForKey:@"level"] isEqualToString:level]){
            
            //call to download books of level
            index = [bookArray indexOfObject:bookdata];
            
            [prefs setInteger:index forKey:@"USERBOOKINDEX"];
            
            [prefs setInteger:[NSNumber numberWithInt:index+5] forKey:@"DAILYFREEBOOK_INDEX"];

            firstBookId = [bookdata valueForKey:@"id"];
            finalIndex = index+5;
            break;
        }
    }
    
   
    //if book already downloaded
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    Book *bk=[appDelegate.dataModel getBookOfEJDBId:[[bookArray objectAtIndex:index] valueForKey:@"id"]];
    if(bk.localPathFile){
        
        [self performSelector:@selector(finishBookDownlaod) withObject:self afterDelay:5.0];
        
        //[self finishBookDownlaod];
    }
    else{//else not available
        [bookDownload downloadBook:[[bookArray objectAtIndex:index] valueForKey:@"id"]];
        [prefs setBool:TRUE forKey:@"FREEFIRSTTIMEDOWNLOAD"];
    }
  
    
}

- (void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/animationaudio.mp3",
                               [[NSBundle mainBundle] resourcePath]];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL
                                                     error:nil];
    _player.numberOfLoops = -1; //Infinite
    
    [_player play];
}

-(void) viewDidDisappear:(BOOL)animated{
    
    _player = nil;
}

- (void) addAnimationToView{
    
    UIImageView *animationView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0,width,height)];
    UIImageView *animationView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0,width,height)];
    UIImageView *animationView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0,width,height)];
    UIImageView *animationView4 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0,width,height)];
    UIImageView *animationView5 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0,width,height)];
    
    NSMutableArray* imageArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    [imageArray addObject:[UIImage imageNamed: @"load1.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load2.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load3.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load6.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load5.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load4.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load7.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load10.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load8.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load9.png"]];
    
    
    animationView1.animationImages = [NSArray arrayWithArray:imageArray];
    [animationView1 setAnimationDuration:1.9];
    animationView1.animationRepeatCount = 0;
    
    animationView2.animationImages = [NSArray arrayWithArray:imageArray];
    [animationView2 setAnimationDuration:0.6];
    animationView2.animationRepeatCount = 0;
    
    animationView3.animationImages = [NSArray arrayWithArray:imageArray];
    [animationView3 setAnimationDuration:0.55];
    animationView3.animationRepeatCount = 0;
    
    animationView4.animationImages = [NSArray arrayWithArray:imageArray];
    [animationView4 setAnimationDuration:0.4];
    animationView4.animationRepeatCount = 0;
    
    animationView5.animationImages = [NSArray arrayWithArray:imageArray];
    [animationView5 setAnimationDuration:0.63];
    animationView5.animationRepeatCount = 0;
    
    [_animationButton addSubview: animationView1];
    
//    [btnType2 addSubview: animationView2];
//    
//    [btnType3 addSubview: animationView3];
//    
//    [btnType4 addSubview: animationView4];
//    
//    [btnType5 addSubview: animationView5];
    
    [animationView1 startAnimating];
    [animationView2 startAnimating];
    [animationView3 startAnimating];
    [animationView4 startAnimating];
    [animationView5 startAnimating];
    //[self addButterfly2];
}


- (IBAction) finishBookDownlaod{
    
    
    [self closeGameView:nil];
}


- (IBAction)closeGameView:(id)sender{
    
    [self dismissViewControllerAnimated:NO completion:^(void) {
        
    }];
}

- (void) viewWillDisappear:(BOOL)animated{
    
    //[super viewWillDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseGamesWhileDownload" object:nil];
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
