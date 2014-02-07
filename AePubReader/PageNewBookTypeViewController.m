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
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson lastObject]];

    _jsonContent=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    
    [self loadPageWithOption:_option];
    
    _rightView.backgroundColor=[UIColor clearColor];

    NSNumber *numberOfPages = [MangoEditorViewController numberOfPagesInStory:_jsonContent];
    _pageNo=numberOfPages.integerValue;
    _gamePageNumber = 0;
    
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
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self.navigationController popToViewController:delegate.pageViewController animated:YES];
    
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
        NSString *textToShare=[_book.title stringByAppendingString:@" great bk from MangoReader"];
        
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
    
    UIButton *button=(UIButton *)sender;
    LanguageChoiceViewController *choiceViewController=[[LanguageChoiceViewController alloc]initWithStyle:UITableViewStyleGrouped];
    choiceViewController.delegate=self;
    _pop=[[UIPopoverController alloc]initWithContentViewController:choiceViewController];
    CGSize size=_pop.popoverContentSize;
    size.height=size.height-300;
    _pop.popoverContentSize=size;
    
    [_pop presentPopoverFromRect:button.frame inView:self.rightView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];

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
        }
    } else {
        [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];
        [self loadPageWithOption:0];
        [self closeButton:nil];

        
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
        _pageView=[MangoEditorViewController readerPage:_pageNumber ForStory:_jsonContent WithFolderLocation:_book.localPathFile AndAudioMappingViewController:_audioMappingViewController AndDelegate:self Option:option];
        if (!_pageView) {
            _pageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            NSArray *gameNamesArray = [NSArray arrayWithObjects:@"wordsearch", @"memory", @"jigsaw", nil];
            NSMutableDictionary * gameViewDict = [MangoEditorViewController readerGamePage:[gameNamesArray objectAtIndex:_gamePageNumber] ForStory:_jsonContent WithFolderLocation:_book.localPathFile AndOption:option];
            _gameDataDict = [[NSMutableDictionary alloc] initWithDictionary:[gameViewDict objectForKey:@"data"]];
            [_gameDataDict setObject:[NSNumber numberWithBool:YES] forKey:@"from_mobile"];
            UIWebView *gameView = [gameViewDict objectForKey:@"gameView"];
            gameView.delegate = self;
            
            [_pageView addSubview:gameView];
            _gamePageNumber++;
            _gamePageNumber = _gamePageNumber%3;
        }
                
    }
    _pageView.frame=self.view.bounds;
    for (UIView *subview in [_pageView subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            subview.frame = self.view.bounds;
        }
    }
    [self.viewBase addSubview:_pageView];
    if (option==0) {
        [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];

    }else{
        [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_play.png"] forState:UIControlStateNormal];

    }
}

@end
