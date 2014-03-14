//
//  PageNewBookTypeViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/13.
//
//

#import "PageNewBookTypeViewController.h"
#import "AePubReaderAppDelegate.h"
#import "LanguageChoiceViewController.h"
#import "CustomMappingView.h"
#import "MangoGamesListViewController.h"
#import <Parse/Parse.h>

#define FORK_TAG 9

@interface PageNewBookTypeViewController ()

@property (nonatomic, assign) NSInteger gamePageNumber;
@property (nonatomic, strong) NSMutableDictionary *gameDataDict;
@property (nonatomic, assign) BOOL showButtons;

@end

@implementation PageNewBookTypeViewController
@synthesize menuPopoverController;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithOption:(NSInteger)option BookId:(NSString *)bookID
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _option=option;
        _bookId=bookID;
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        _book= [delegate.dataModel getBookOfId:bookID];
        _pageNumber=1;
        NSLog(@"%@",_book.edited);
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    NSString *jsonLocation=_book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];

    _jsonContent=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    
    [self loadPageWithOption:_option];
    
    _rightView.backgroundColor=[UIColor clearColor];

    NSNumber *numberOfPages = [MangoEditorViewController numberOfPagesInStory:_jsonContent];
    _pageNo=numberOfPages.integerValue;
    
    _showButtons = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapGesture.delegate = (id <UIGestureRecognizerDelegate>)self;
    [self.view addGestureRecognizer:tapGesture];
    
}

- (void)hideAllButtons:(BOOL)hide {
    _showOptionButton.hidden = hide;
    _backButton.hidden = hide;
    _previousPageButton.hidden = hide;
    _nextPageButton.hidden = hide;
    if (hide) {
        _rightView.hidden=YES;
    }
}

- (void)didTap:(UITapGestureRecognizer *)gesture {
    _showButtons = !_showButtons;
    [self hideAllButtons:!_showButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ShowOptions:(id)sender {
    _rightView.hidden=NO;

    UIButton *button=(UIButton *)sender;
    button.hidden=YES;
}

- (IBAction)BackButton:(id)sender {
    //AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    [self.navigationController popViewControllerAnimated:YES];
    //[self.navigationController popToViewController:delegate.pageViewController animated:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [_audioMappingViewController.timer invalidate];
    [_audioMappingViewController.player stop];
}
- (IBAction)closeButton:(id)sender {
    _rightView.hidden=YES;
    _showOptionButton.hidden=NO;
}

- (IBAction)shareButton:(id)sender {
    [PFAnalytics trackEvent:EVENT_BOOK_SHARED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
    
    UIButton *button=(UIButton *)sender;
    NSString *ver=[UIDevice currentDevice].systemVersion;
    if([ver floatValue]>5.1){
        
        AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        MangoBook *book=[appDelegate.ejdbController.collection fetchObjectWithOID:_book.id];
        NSString *textToShare=[_book.title stringByAppendingFormat:@"\n\nI found this cool book - %@ - on MangoReader!\n\n Read it here - %@ !", _book.title, [NSString stringWithFormat:@"www.mangoreader.com/live_stories/%@", book.id]];
        
        UIImage *image=[UIImage imageWithContentsOfFile:_book.localPathImageFile];
        NSMutableArray *activityItems= [[NSMutableArray alloc] init];
        if (textToShare) {
            [activityItems addObject:textToShare];
        }
        if (image) {
            [activityItems addObject:image];
        }
        
        UIActivityViewController *activity=[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
        activity.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypePostToWeibo,UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
        _popOverShare=[[UIPopoverController alloc]initWithContentViewController:activity];
        
        [_popOverShare presentPopoverFromRect:button.frame inView:button.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        
        return;
    }
    
    /// for IOS 5 code below;
   /* MFMailComposeViewController *mail;
    
    mail=[[MFMailComposeViewController alloc]init];
    [mail setSubject:@"Found this awesome interactive book on MangoReader"];
    mail.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    [mail setMailComposeDelegate:self];
    NSString *body=[NSString stringWithFormat:@"Hi,\n%@",buttonShadow.stringLink];
    body =[body stringByAppendingString:@"\nI found this cool book on mangoreader - we bring books to life.The book is interactive with the characters moving on touch and movement, which makes it fun and engaging.The audio and text highlight syncing will make it easier for kids to learn and understand pronunciation.Not only this, I can play cool games in the book, draw and make puzzles and share my scores.\nDownload the MangoReader app from the appstore and try these awesome books."];
    [mail setMessageBody:body isHTML:NO];
    [self presentModalViewController:mail animated:YES];*/

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case FORK_TAG: {
            switch (buttonIndex) {
                case 0: {
                    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
                }
                    break;
                    
                case 1: {
                    [PFAnalytics trackEvent:EVENT_BOOK_FORKED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
                    MangoEditorViewController *mangoEditorViewController= [[MangoEditorViewController alloc] initWithNibName:@"MangoEditorViewController" bundle:nil];
                    mangoEditorViewController.storyBook=_book;
                    [self.navigationController pushViewController:mangoEditorViewController animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)editButton:(id)sender {
    UIAlertView *editAlertView = [[UIAlertView alloc] initWithTitle:@"Create your own version" message:@"This will create a new version of this book which you can edit. The old version will be saved too. Do you want to continue?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    editAlertView.tag = FORK_TAG;
    [editAlertView show];
}

- (IBAction)changeLanguage:(id)sender {
    [PFAnalytics trackEvent:EVENT_TRANSLATE_INITIATED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    NSString *url;
    url = LANGUAGES_FOR_BOOK;
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:_bookId forKey:@"story_id"];
    [paramDict setObject:IOS forKey:PLATFORM];
    [apiController getListOf:url ForParameters:paramDict withDelegate:self];
    
    

}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    
    _avilableLanguages = [NSMutableArray arrayWithArray:dataArray];
    NSMutableArray *languageArray = [[NSMutableArray alloc] init];
    
    LanguageChoiceViewController *choiceViewController=[[LanguageChoiceViewController alloc]initWithStyle:UITableViewStyleGrouped];
    choiceViewController.delegate=self;
    _pop=[[UIPopoverController alloc]initWithContentViewController:choiceViewController];
    CGSize size=_pop.popoverContentSize;
    size.height=size.height-300;
    _pop.popoverContentSize=size;
    
    choiceViewController.bookIDArray = [[NSMutableArray alloc] init];
    for(int i=0; i< [_avilableLanguages count]; ++i){
        [languageArray addObject:[_avilableLanguages[i] objectForKey:@"language"]];
        NSLog(@"Print %@", [_avilableLanguages[i] objectForKey:@"language"]);
        [choiceViewController.bookIDArray addObject:[_avilableLanguages[i] objectForKey:@"live_story_id"]];
    }
    
    NSString *jsonLocation=_book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
    //  NSLog(@"json location %@",jsonLocation);
    NSString *jsonContent=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    
    NSData *jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    choiceViewController.array = [jsonDict objectForKey:@"available_languages"];
    choiceViewController.array = [[NSArray alloc] initWithArray:languageArray];
    choiceViewController.bookDict = jsonDict;
    
    if(choiceViewController.array.count>0){
        
        [_pop presentPopoverFromRect:_languageAvailButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
  //  [_pop presentPopoverFromRect:button.frame inView:self.rightView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}


- (IBAction)previousButton:(id)sender {
    if (_pageNumber==1) {
        //[self BackButton:nil];
        [self.navigationController popViewControllerAnimated:YES];

    }else{
         _pageNumber--;
             [self loadPageWithOption:_option];

    }
}

- (IBAction)nextButton:(id)sender {
    _pageNumber++;
    if (_pageNumber<(_pageNo)) {
        [self loadPageWithOption:_option];
        
        /// default is icons_play.png
        if (_option==0) {
            [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];
        }else{
            [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_play.png"] forState:UIControlStateNormal];
        }
      
        
    } else {
        _pageNumber = _pageNo - 1;
        LastPageViewController *lastPage = [[LastPageViewController alloc] initWithNibName:@"LastPageViewController" bundle:nil WithId:[_book valueForKey:@"id"]];
        [self.navigationController pushViewController:lastPage animated:YES];
    }
   
}

- (IBAction)playOrPauseButton:(id)sender {
    if (_audioMappingViewController.player) {
        if ([_audioMappingViewController.player isPlaying]) {
            [PFAnalytics trackEvent:EVENT_AUDIO_PAUSED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
            
            [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_play.png"] forState:UIControlStateNormal];
            [_audioMappingViewController.player pause];
        }else{
            [PFAnalytics trackEvent:EVENT_AUDIO_PLAYED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];

            [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];
            [_audioMappingViewController.player play];
            [self closeButton:nil];
            _showButtons = NO;
            [self hideAllButtons:!_showButtons];
        }
    } else {
        [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];
        [self loadPageWithOption:0];
        [self closeButton:nil];
        _showButtons = NO;
        [self hideAllButtons:!_showButtons];
    }
}

- (IBAction)openGameCentre:(id)sender {
    [PFAnalytics trackEvent:EVENT_GAME_CENTER_OPENED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
    
    NSData *jsonData = [_jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    NSLog(@"%@", jsonDict);
    if ([[jsonDict objectForKey:NUMBER_OF_GAMES] intValue] == 0) {
        UIAlertView *noGamesAlert = [[UIAlertView alloc] initWithTitle:@"No Games" message:@"Sorry, this story does not have any games in it." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [noGamesAlert show];
    } else {
        MangoGamesListViewController *gamesListViewController = [[MangoGamesListViewController alloc] initWithNibName:@"MangoGamesListViewController" bundle:nil];
        gamesListViewController.jsonString = _jsonContent;
        gamesListViewController.folderLocation = _book.localPathFile;
        
        NSMutableArray *gameNames = [[NSMutableArray alloc] init];
        for (NSDictionary *pageDict in [jsonDict objectForKey:PAGES]) {
            if ([[pageDict objectForKey:TYPE] isEqualToString:GAME]) {
                [gameNames addObject:[pageDict objectForKey:NAME]];
            }
        }
        gamesListViewController.gameNames = gameNames;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:gamesListViewController];
        [navController.navigationBar setHidden:YES];
        
        [self.navigationController presentViewController:navController animated:YES completion:^{
            
        }];
    }
}
- (void)showComingSoonPopover:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    UILabel *comingSoonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
    comingSoonLabel.text = @"Coming Soon...";
    comingSoonLabel.textAlignment = NSTextAlignmentCenter;
    comingSoonLabel.font = [UIFont boldSystemFontOfSize:24];
    comingSoonLabel.textColor = COLOR_GREY;
    
    UIViewController *comingSoonController = [[UIViewController alloc] init];
    [comingSoonController.view addSubview:comingSoonLabel];
    
    menuPopoverController = [[UIPopoverController alloc] initWithContentViewController:comingSoonController];
    [menuPopoverController setPopoverContentSize:CGSizeMake(250, 250) animated:YES];
    [menuPopoverController setPopoverLayoutMargins:UIEdgeInsetsMake(0, 0, 100, 100)];
    [menuPopoverController presentPopoverFromRect:button.frame inView:button.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}
-(void)dismissPopOver{
    [_pop dismissPopoverAnimated:YES];
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [_audioMappingViewController.timer invalidate];
    _audioMappingViewController.timer=nil;
    _audioMappingViewController.player=nil;

    if (_option==0) {
     /* Read By readToMe */
        [self nextButton:nil];
    }else{
    }
    [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_play.png"] forState:UIControlStateNormal];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_gameDataDict options:NSJSONReadingAllowFragments error:nil];
    NSString *paramString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Param: %@", paramString);
    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"MangoGame.init(%@)", paramString]];
}

-(void)loadPageWithOption:(NSInteger)option{
    [_audioMappingViewController.timer invalidate];
    _audioMappingViewController.timer=nil;
    [_pageView removeFromSuperview];
    _audioMappingViewController = [[AudioMappingViewController alloc] initWithNibName:@"AudioMappingViewController" bundle:nil];
    NSLog(_book.edited ? @"Yes" : @"No");
    if (_book.edited.boolValue) {

        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        MangoBook *book=[delegate.ejdbController.collection fetchObjectWithOID:_book.id];
        _pageView=[MangoEditorViewController readerPage:_pageNumber ForEditedStory:book WithFolderLocation:_book.localPathFile WithAudioMappingViewController:_audioMappingViewController andDelegate:self Option:option];
    } else {
        NSData *jsonData = [_jsonContent dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
        int numberOfGames = [[jsonDict objectForKey:NUMBER_OF_GAMES] intValue];
        NSArray *pagesArray = [jsonDict objectForKey:PAGES];

        if (_pageNumber < [pagesArray count] - numberOfGames) {
            _pageView=[MangoEditorViewController readerPage:_pageNumber ForStory:_jsonContent WithFolderLocation:_book.localPathFile AndAudioMappingViewController:_audioMappingViewController AndDelegate:self Option:option];
        } else {
            
          /*  NSMutableArray *gameNamesArray = [[NSMutableArray alloc] init];
            for (NSDictionary *pageDict in pagesArray) {
                if ([[pageDict objectForKey:TYPE] isEqualToString:GAME]) {
                    [gameNamesArray addObject:[pageDict objectForKey:NAME]];
                }
            }
            
            if ([gameNamesArray count] > 0) {
                NSMutableDictionary * gameViewDict = [MangoEditorViewController readerGamePage:[gameNamesArray objectAtIndex:_pageNumber - ([pagesArray count] - numberOfGames)] ForStory:_jsonContent WithFolderLocation:_book.localPathFile AndOption:option];
                _gameDataDict = [[NSMutableDictionary alloc] initWithDictionary:[gameViewDict objectForKey:@"data"]];
                [_gameDataDict setObject:[NSNumber numberWithBool:YES] forKey:@"from_mobile"];
                UIWebView *gameView = [gameViewDict objectForKey:@"gameView"];
                gameView.delegate = self;
                
                [_pageView addSubview:gameView];
            }*/
        }
    }
    _pageView.frame=self.view.bounds;
    /*for (UIView *subview in [_pageView subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            subview.frame = self.view.bounds;
        }
    }*/
    [self.viewBase addSubview:_pageView];
    if (option==0) {
        [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];

    }else{
        [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_play.png"] forState:UIControlStateNormal];

    }
}

@end
