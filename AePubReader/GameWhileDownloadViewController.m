//
//  GameWhileDownloadViewController.m
//  MangoReader
//
//  Created by Harish on 1/25/15.
//
//

#import "GameWhileDownloadViewController.h"
#import "AgeDetailsViewController.h"
#import "LevelViewController.h"
#import "Constants.h"

@interface GameWhileDownloadViewController ()
@property (nonatomic, strong) NSMutableDictionary *dataDict;
@end

@implementation GameWhileDownloadViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    bookDownload = [[UserBookDownloadViewController alloc] init];
    bookDownload.delegate = self;
    [bookDownload returnArrayElementa];
    
    //NSMutableArray *booksArray = [[NSMutableArray alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mango" ofType:@"json"];
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    //NSError *error =  nil;
    
    NSData *jsonData = [myJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    
    
    //booksArray = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    
    NSMutableArray *gameNames = [[NSMutableArray alloc] init];
    for (NSDictionary *pageDict in [jsonDict objectForKey:PAGES]) {
        if ([[pageDict objectForKey:TYPE] isEqualToString:GAME]) {
            [gameNames addObject:[pageDict objectForKey:NAME]];
        }
    }
    NSLog(@"Games names %@", gameNames);
    
    NSMutableArray *readerPagesArray1 = [[NSMutableArray alloc] initWithArray:[jsonDict objectForKey:PAGES]];
    NSMutableArray *gamesDataArray = [[NSMutableArray alloc] init];
    for (NSDictionary *readerPageDict in readerPagesArray1){
        if(([[readerPageDict objectForKey:PAGE_NAME] length] >3) && !([[readerPageDict objectForKey:PAGE_NAME] isEqualToString:@"Cover"])){
            NSLog(@"not match - %@", [readerPageDict objectForKey:PAGE_NAME]);
            [gamesDataArray addObject:readerPageDict];
        }
    }
    
    
    NSArray *readerPagesArray = gamesDataArray;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    //for (NSDictionary *readerPageDict in readerPagesArray) {
    NSDictionary *readerPageDict = readerPagesArray[1];
    if ([[readerPageDict objectForKey:PAGE_NAME] isEqualToString:@"wordsearch"]) {
        //NSLog(@"game name - %@", gameName);
        UIWebView *gameWebView;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            gameWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 568, 320)];
        }
        else{
            gameWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        }
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
        //NSLog(@"%@", filePath);
        [gameWebView loadRequest:[[NSURLRequest alloc ] initWithURL:[NSURL URLWithString:filePath]]];
        
        [dict setObject:gameWebView forKey:@"gameView"];
        [dict setObject:[[readerPageDict objectForKey:LAYERS] lastObject] forKey:@"data"];
        
    }
    
    _dataDict = [[NSMutableDictionary alloc] initWithDictionary:[dict objectForKey:@"data"]];
    [_dataDict setObject:[NSNumber numberWithBool:YES] forKey:@"from_mobile"];
    
    _webView = [dict objectForKey:@"gameView"];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.frame = self.view.frame;
    [_webView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth];
    [[_webView scrollView] setBounces:NO];
    
    [self.view addSubview:_webView];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventListenerDidReceiveNotification:) name:@"BookProgressValue" object:nil];
    // Do any additional setup after loading the view from its nib.
}


#pragma mark - UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_dataDict options:NSJSONReadingMutableContainers error:nil];
    
    NSString *paramString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Param: %@", paramString);
    
    NSString *resultString = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"MangoGame.init(%@)", paramString]];
    NSLog(@"%@", resultString);
    
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
        [self updateBookProgress:newProgress];
    }
}

- (void)updateBookProgress:(int)bookProgress {
    
    
}


- (IBAction)getJsonIntoArray:(NSArray *) bookArray{
    
    //find level say level "L"
    int index;
    int finalIndex;
    _booksArray = bookArray;
    for(NSDictionary *bookdata in bookArray){
        
        NSString *level =[LevelViewController getLevelFromAge:_ageVal];
        if([[bookdata valueForKey:@"level"] isEqualToString:level]){
            
            //call to download two books of level L
            index = [bookArray indexOfObject:bookdata];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseGamesWhileDownload" object:self];
        return;
    }];
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
