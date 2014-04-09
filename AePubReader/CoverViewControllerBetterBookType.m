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
        if (identity) {
            _identity=identity;
            AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
            _book= [delegate.dataModel getBookOfId:identity];
            NSLog(@"%@",_book.edited);
            
            userEmail = delegate.loggedInUserInfo.email;
            userDeviceID = delegate.deviceId;
        }
    }
    return self;
}

- (void)setIdentity:(NSString *)identity {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    if (path) {
        _identity = identity;
        AePubReaderAppDelegate *delegate = (AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        _book = [delegate.dataModel getBookOfId:identity];
        NSLog(@"%@",_book.edited);
        
        userEmail = delegate.loggedInUserInfo.email;
        userDeviceID = delegate.deviceId;
        
        [self initialSetup];
        
        [_backButton setHidden:YES];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)initialSetup {
    viewName = @"Book cover view";

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
    
    if(!userEmail){
        ID = userDeviceID;
    }
    else{
        ID = userEmail;
    }

    _coverImageView.image=image;
    // Do any additional setup after loading the view from its nib.
    
    NSData *jsonData = [jsonContents dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    currentBookId = [jsonDict objectForKey:@"id"];
    
    currentBookGradeLevel = [[[jsonDict objectForKey:@"info"] objectForKey:@"grades"] componentsJoinedByString:@", "];
    
    currentBookImageURL = [[NSString stringWithFormat:@"http://www.mangoreader.com/live_stories/%@/%@",[jsonDict objectForKey:@"id"], [jsonDict objectForKey:@"story_image"]] stringByReplacingOccurrencesOfString:@"res/" withString:@"res/cover_"];
    
    [_languageLabel setTitle:[[jsonDict objectForKey:@"info"] objectForKey:@"language"] forState:UIControlStateNormal];
    if (_languageLabel.titleLabel.text == nil) {
        [_languageLabel setTitle:@"English" forState:UIControlStateNormal];
    }
    
    
    [self showOrHideGameButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=YES;
    if (_identity) {
        [self initialSetup];
    }
}
- (IBAction)multipleLanguage:(id)sender {
    //UIButton *button=(UIButton *)sender;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_LANGUAGE : _languageLabel.titleLabel.text,
                                 PARAMETER_BOOK_ID : [_book valueForKey:@"bookId"]
                                 
                                 };
    [delegate trackEvent:[BOOKCOVER_AVAILABLE_LANGUAGE valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[BOOKCOVER_AVAILABLE_LANGUAGE valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [BOOKCOVER_AVAILABLE_LANGUAGE valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:_languageLabel.titleLabel.text forKey:@"bookLanguage"];
    [userObject setObject:[_book valueForKey:@"bookId"] forKey:@"bookID"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];

    if (![[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"]) {
        MangoApiController *apiController = [MangoApiController sharedApiController];
        NSString *url;
        url = LANGUAGES_FOR_BOOK;
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
        [paramDict setObject:currentBookId forKey:@"story_id"];
        [paramDict setObject:IOS forKey:PLATFORM];
        [apiController getListOf:url ForParameters:paramDict withDelegate:self];
    }
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
    choiceViewController.language = _languageLabel.titleLabel.text;
    if(choiceViewController.array.count>0){
        
    [_popOverController presentPopoverFromRect:_languageLabel.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)bookCoverSelection:(id)sender {
    UIButton *button=(UIButton *)sender;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    PageNewBookTypeViewController *controller;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController_iPhone" bundle:nil WithOption:button.tag BookId:_identity];
        
    }
    else{
        controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController" bundle:nil WithOption:button.tag BookId:_identity];
    }
    
    controller.bookGradeLevel = currentBookGradeLevel;
    //add full image url
    controller.bookImageURL = currentBookImageURL;
    
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID : _identity
                                 
                                 };
    [delegate trackEvent:[BOOKCOVER_SELECTION valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[BOOKCOVER_SELECTION valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [BOOKCOVER_SELECTION valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:_identity forKey:@"bookID"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    [self.navigationController pushViewController:controller animated:YES];
}


- (IBAction)optionsToReader:(id)sender {
    UIButton *button=(UIButton *)sender;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    PageNewBookTypeViewController *controller;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController_iPhone" bundle:nil WithOption:button.tag BookId:_identity];
        
    }
    else{
        controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController" bundle:nil WithOption:button.tag BookId:_identity];
    }

    controller.bookGradeLevel = currentBookGradeLevel;
    //add full image url
    controller.bookImageURL = currentBookImageURL;
    
    if([sender tag] == 1){
        NSLog(@"Read by myself");
        
        NSDictionary *dimensions = @{
                                     PARAMETER_USER_ID : ID,
                                     PARAMETER_DEVICE: IOS,
                                     PARAMETER_BOOK_ID : _identity
                                     
                                     };
        [delegate trackEvent:[BOOKCOVER_READ_BY_MYSELF valueForKey:@"description"] dimensions:dimensions];
        PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
        [userObject setObject:[BOOKCOVER_READ_BY_MYSELF valueForKey:@"value"] forKey:@"eventName"];
        [userObject setObject: [BOOKCOVER_READ_BY_MYSELF valueForKey:@"description"] forKey:@"eventDescription"];
        [userObject setObject:viewName forKey:@"viewName"];
        [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
        [userObject setObject:delegate.country forKey:@"deviceCountry"];
        [userObject setObject:delegate.language forKey:@"deviceLanguage"];
        [userObject setObject:_identity forKey:@"bookID"];
        if(userEmail){
            [userObject setObject:ID forKey:@"emailID"];
        }
        [userObject setObject:IOS forKey:@"device"];
        [userObject saveInBackground];
        
    }
    else{
        NSLog(@"Read to me");
        
        NSDictionary *dimensions = @{
                                     PARAMETER_USER_ID : ID,
                                     PARAMETER_DEVICE: IOS,
                                     PARAMETER_BOOK_ID : _identity
                                     
                                     };
        [delegate trackEvent:[BOOKCOVER_READ_TO_ME valueForKey:@"description"] dimensions:dimensions];
        PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
        [userObject setObject:[BOOKCOVER_READ_TO_ME valueForKey:@"value"] forKey:@"eventName"];
        [userObject setObject: [BOOKCOVER_READ_TO_ME valueForKey:@"description"] forKey:@"eventDescription"];
        [userObject setObject:viewName forKey:@"viewName"];
        [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
        [userObject setObject:delegate.country forKey:@"deviceCountry"];
        [userObject setObject:delegate.language forKey:@"deviceLanguage"];
        [userObject setObject:_identity forKey:@"bookID"];
        if(userEmail){
            [userObject setObject:ID forKey:@"emailID"];
        }
        [userObject setObject:IOS forKey:@"device"];
        [userObject saveInBackground];
        
    }
    
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
    jsonLocation = [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
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

    return jsonDict;
}

- (IBAction)gameButtonTapped:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *jsonDict = [self getJsonDictForBook];
    
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID : [jsonDict objectForKey:@"story_id"]
                                 
                                 };
    [delegate trackEvent:[BOOKCOVER_PLAY_GAMES valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[BOOKCOVER_PLAY_GAMES valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [BOOKCOVER_PLAY_GAMES valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:[jsonDict objectForKey:@"story_id"] forKey:@"bookID"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    if ([[jsonDict objectForKey:NUMBER_OF_GAMES] intValue] == 0) {
        UIAlertView *noGamesAlert = [[UIAlertView alloc] initWithTitle:@"No Games" message:@"Sorry, this story does not have any games in it." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [noGamesAlert show];
    } else {
        
        MangoGamesListViewController *gamesListViewController;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            gamesListViewController = [[MangoGamesListViewController alloc] initWithNibName:@"MangoGamesListViewController_iPhone" bundle:nil];
        }
        else{
            gamesListViewController = [[MangoGamesListViewController alloc] initWithNibName:@"MangoGamesListViewController" bundle:nil];
        }
        
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
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID : [_book valueForKey:@"bookId"]
                                 
                                 };
    [delegate trackEvent:[BOOKCOVER_SHARE valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[BOOKCOVER_SHARE valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [BOOKCOVER_SHARE valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:[_book valueForKey:@"bookId"] forKey:@"bookID"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    UIButton *button=(UIButton *)sender;
    NSString *ver=[UIDevice currentDevice].systemVersion;
    if([ver floatValue]>5.1){
        
        AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        MangoBook *book=[appDelegate.ejdbController.collection fetchObjectWithOID:_book.id];
        NSString *textToShare=[_book.title stringByAppendingFormat:@"\n\nI found this cool book - %@ - on MangoReader!\n\nApp Link- https://itunes.apple.com/in/app/mangoreader-interactive-kids/id568003822?mt=8\n\n Read it here - %@ !", _book.title, [NSString stringWithFormat:@"www.mangoreader.com/live_stories/%@", book.id]];
        
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
