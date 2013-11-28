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
@interface PageNewBookTypeViewController ()

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
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  //  UIView *view=[MangoEditorViewController readerPage:0 ForStory:<#(NSString *)#> WithFolderLocation:<#(NSString *)#>];
    NSString *jsonLocation=_book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson lastObject]];
    //  NSLog(@"json location %@",jsonLocation);
    _jsonContent=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    /*_audioMappingViewController = [[AudioMappingViewController alloc] initWithNibName:@"AudioMappingViewController" bundle:nil];

    _pageView=[MangoEditorViewController readerPage:1 ForStory:_jsonContent WithFolderLocation:_book.localPathFile AndAudioMappingViewController:_audioMappingViewController AndDelegate:self Option:_option];
    _pageView.frame=self.view.bounds;
    for (UIView *subview in [_pageView subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            subview.frame = self.view.bounds;
        }
    }
     [self.viewBase addSubview:_pageView];

     */
    [self loadPageWithOption:_option];
    _rightView.backgroundColor=[UIColor clearColor];
   // _pageView.backgroundColor=[UIColor grayColor];
    NSNumber *numberOfPages = [MangoEditorViewController numberOfPagesInStory:_jsonContent];
    _pageNo=numberOfPages.integerValue;
    
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
    UIButton *button=(UIButton *)sender;
    NSString *ver=[UIDevice currentDevice].systemVersion;
    if([ver floatValue]>5.1){
        NSString *textToShare=[_book.title stringByAppendingString:@" great bk from MangoReader"];
        
        
        UIImage *image=[UIImage imageWithContentsOfFile:_book.localPathImageFile];
        NSArray *activityItems=@[textToShare,image];
        
        UIActivityViewController *activity=[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
        activity.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypePostToWeibo,UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
        _popOverShare=[[UIPopoverController alloc]initWithContentViewController:activity];
        
        //  [activity release];
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

- (IBAction)editButton:(id)sender {
    
    MangoEditorViewController *mangoEditorViewController= [[MangoEditorViewController alloc] initWithNibName:@"MangoEditorViewController" bundle:nil];
    mangoEditorViewController.storyBook=_book;
    [self.navigationController pushViewController:mangoEditorViewController animated:YES];

    
}

- (IBAction)changeLanguage:(id)sender {
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
            [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_play.png"] forState:UIControlStateNormal];
            [_audioMappingViewController.player pause];
        }else{
            [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];
            [_audioMappingViewController.player play];
            [self closeButton:nil];
        }
    }else{
        [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];
        [self loadPageWithOption:0];
        [self closeButton:nil];

        
    }
    
}

- (IBAction)openGameCentre:(id)sender {
    [self showComingSoonPopover:sender];
    
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
-(void)loadPageWithOption:(NSInteger)option{
    [_audioMappingViewController.timer invalidate];
    _audioMappingViewController.timer=nil;
    [_pageView removeFromSuperview];
    _audioMappingViewController = [[AudioMappingViewController alloc] initWithNibName:@"AudioMappingViewController" bundle:nil];
    
    _pageView=[MangoEditorViewController readerPage:_pageNumber ForStory:_jsonContent WithFolderLocation:_book.localPathFile AndAudioMappingViewController:_audioMappingViewController AndDelegate:self Option:option];
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
