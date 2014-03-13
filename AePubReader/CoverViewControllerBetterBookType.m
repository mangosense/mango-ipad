//
//  CoverViewControllerBetterBookType.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/13.
//
//

#import "CoverViewControllerBetterBookType.h"
#import "LanguageChoiceViewController.h"
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "PageNewBookTypeViewController.h"
#import "MangoEditorViewController.h"
#import "MangoGamesListViewController.h"
#import <Parse/Parse.h>

@interface CoverViewControllerBetterBookType ()

@end

@implementation CoverViewControllerBetterBookType

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithId:(NSString *)identity
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _identity=identity;
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
       _book= [delegate.dataModel getBookOfId:identity];
        NSLog(@"%@",_book.edited);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _titleLabel.text=_book.title;
    NSString *jsonLocation=_book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
  //  NSLog(@"json location %@",jsonLocation);
    NSString *jsonContents=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
  //  NSLog(@"json contents %@",jsonContents);
    UIImage *image=[MangoEditorViewController coverPageImageForStory:jsonContents WithFolderLocation:_book.localPathFile];

    _coverImageView.image=image;
    // Do any additional setup after loading the view from its nib.
    
    NSData *jsonData = [jsonContents dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    currentBookId = [jsonDict objectForKey:@"id"];
    [_languageLabel setTitle:[[jsonDict objectForKey:@"info"] objectForKey:@"language"] forState:UIControlStateNormal];
    
    [self showOrHideGameButton];
}
- (IBAction)multipleLanguage:(id)sender {
    UIButton *button=(UIButton *)sender;
    MangoApiController *apiController = [MangoApiController sharedApiController];
    NSString *url;
    url = LANGUAGES_FOR_BOOK;
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:currentBookId forKey:@"story_id"];
    [paramDict setObject:IOS forKey:PLATFORM];
    [apiController getListOf:url ForParameters:paramDict withDelegate:self];
    
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    
   _avilableLanguages = [NSMutableArray arrayWithArray:dataArray];
    NSMutableArray *languageArray = [[NSMutableArray alloc] init];
    
    
    LanguageChoiceViewController *choiceViewController=[[LanguageChoiceViewController alloc]initWithStyle:UITableViewStyleGrouped];
    choiceViewController.delegate=self;
    _popOverController=[[UIPopoverController alloc]initWithContentViewController:choiceViewController];
    CGSize size=_popOverController.popoverContentSize;
    size.height=size.height-300;
    _popOverController.popoverContentSize=size;
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
        
    [_popOverController presentPopoverFromRect:_languageLabel.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)optionsToReader:(id)sender {
    UIButton *button=(UIButton *)sender;
    PageNewBookTypeViewController *controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController" bundle:nil WithOption:button.tag BookId:_identity];
      
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)libraryButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) dismissPopOver{
    [_popOverController dismissPopoverAnimated:YES];
}

- (NSString *)getJsonContentForBook {
    NSString *jsonLocation=_book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
    //  NSLog(@"json location %@",jsonLocation);
    NSString *jsonContent=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    return jsonContent;
}

- (void)showOrHideGameButton {
    NSDictionary *jsonDict = [self getJsonDictForBook];
    if ([[jsonDict objectForKey:NUMBER_OF_GAMES] intValue] == 0) {
        _games.hidden = YES;
    } else {
        _games.hidden= NO;
    }
}

- (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
	CGImageRef imgRef = [image CGImage];
    CGImageRef maskRef = [maskImage CGImage];
    CGImageRef actualMask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                              CGImageGetHeight(maskRef),
                                              CGImageGetBitsPerComponent(maskRef),
                                              CGImageGetBitsPerPixel(maskRef),
                                              CGImageGetBytesPerRow(maskRef),
                                              CGImageGetDataProvider(maskRef), NULL, false);
    CGImageRef masked = CGImageCreateWithMask(imgRef, actualMask);
    return [UIImage imageWithCGImage:masked];
}

- (NSDictionary *)getJsonDictForBook {
    NSString *jsonContent = [self getJsonContentForBook];
    NSData *jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    NSLog(@"%@", jsonDict);
    return jsonDict;
}

- (IBAction)gameButtonTapped:(id)sender {
    NSDictionary *jsonDict = [self getJsonDictForBook];
    if ([[jsonDict objectForKey:NUMBER_OF_GAMES] intValue] == 0) {
        UIAlertView *noGamesAlert = [[UIAlertView alloc] initWithTitle:@"No Games" message:@"Sorry, this story does not have any games in it." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [noGamesAlert show];
    } else {
        MangoGamesListViewController *gamesListViewController = [[MangoGamesListViewController alloc] initWithNibName:@"MangoGamesListViewController" bundle:nil];
        gamesListViewController.jsonString = [self getJsonContentForBook];
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

- (IBAction)shareButton:(id)sender {
    //[PFAnalytics trackEvent:EVENT_BOOK_SHARED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
    
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



@end
