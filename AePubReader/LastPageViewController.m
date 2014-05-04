//
//  LastPageViewController.m
//  MangoReader
//
//  Created by Harish on 3/7/14.
//
//

#import "LastPageViewController.h"

#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "MBProgressHUD.h"
#import "MangoEditorViewController.h"
#import "MangoGamesListViewController.h"
#import "MangoStoreViewController.h"
#import <Parse/Parse.h>
#import "MangoSubscriptionViewController.h"
#import "CargoBay.h"

@interface LastPageViewController ()

@end

@implementation LastPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithId:(NSString *)identity
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _identity=identity;
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        _book= [delegate.dataModel getBookOfId:identity];
        NSLog(@"%@",_book.edited);
        
        userEmail = delegate.loggedInUserInfo.email;
        userDeviceID = delegate.deviceId;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    viewName = @"Book Last Page";
    if(!userEmail){
        ID = userDeviceID;
    }
    else{
        ID = userEmail;
    }
    
    _titleLabel.text= [NSString stringWithFormat:@"Thanks for Reading %@", _book.title];
    // Do any additional setup after loading the view from its nib.
    if([_book.title isEqualToString:@"My Book"] || [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"]) {
        self.recommendedBooksView.hidden = YES;
        self.mangoreaderLinkView.hidden = NO;
    }
    else {
        
        [self loadRecommendedBooks:_book.id];
    }
    
    [self showOrHideGameButton];
    
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    
    if(!validSubscription){
        
        if(appDelegate.subscriptionInfo){
            //provide access
            
            [[MangoApiController sharedApiController]validateSubscription:appDelegate.subscriptionInfo.subscriptionTransctionId andDeviceId:appDelegate.deviceId block:^(id response, NSInteger type, NSString *error){
                NSLog(@"type --- %d", type);
                if ([[response objectForKey:@"status"] integerValue] == 1){
                    
                    NSLog(@"You are already subscribed");
                }
                else{
                        
                        MangoSubscriptionViewController *subscriptionViewController;
                        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
                            
                            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
                        }
                        else{
                            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController" bundle:nil];
                        }
                        [prefs setBool:YES forKey:@"FIRSTTIMEDISPLAY"];
                        subscriptionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                        [self presentViewController:subscriptionViewController animated:YES completion:nil];
                    
                }
                
            }];
        }
        
        else{
            
            
            [[MangoApiController sharedApiController]validateSubscription:appDelegate.subscriptionInfo.subscriptionTransctionId andDeviceId:appDelegate.deviceId block:^(id response, NSInteger type, NSString *error){
                NSLog(@"type --- %d", type);
                if ([[response objectForKey:@"status"] integerValue] == 1){
                    
                    NSLog(@"You are already subscribed");
                }
                else{
                    
                        MangoSubscriptionViewController *subscriptionViewController;
                        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
                            
                            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
                        }
                        else{
                            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController" bundle:nil];
                        }
                        [prefs setBool:YES forKey:@"FIRSTTIMEDISPLAY"];
                        subscriptionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                        [self presentViewController:subscriptionViewController animated:YES completion:nil];
                }
                
            }];
        }
        
    }
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getJsonContentForBook {
    NSString *jsonLocation=_book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
    NSString *jsonContent=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    return jsonContent;
}

- (NSDictionary *)getJsonDictForBook {
    NSString *jsonContent = [self getJsonContentForBook];
    NSData *jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];

    return jsonDict;
}

- (void)showOrHideGameButton {
    NSDictionary *jsonDict = [self getJsonDictForBook];
    if ([[jsonDict objectForKey:NUMBER_OF_GAMES] intValue] == 0) {
        _games.hidden = YES;
    } else {
        _games.hidden= NO;
    }
}

- (IBAction)gameButtonTapped:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID: _book.id,
                                 
                                 };
    [delegate trackEvent:[LASTPAGE_PLAYGAMES valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[LASTPAGE_PLAYGAMES valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [LASTPAGE_PLAYGAMES valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:_book.id forKey:@"bookID"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    NSDictionary *jsonDict = [self getJsonDictForBook];
    if ([[jsonDict objectForKey:NUMBER_OF_GAMES] intValue] == 0) {
        UIAlertView *noGamesAlert = [[UIAlertView alloc] initWithTitle:@"No Games" message:@"Sorry, this story does not have any games in it." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [noGamesAlert show];
    } else {
        
        MangoGamesListViewController *gamesListViewController;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
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

- (IBAction)pushToCoverView:(id)sender{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID: _book.id,
                                 
                                 };
    [delegate trackEvent:[LASTPAGE_READ_AGAIN valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[LASTPAGE_READ_AGAIN valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [LASTPAGE_READ_AGAIN valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:_book.id forKey:@"bookID"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:4] animated:YES];
}

- (void) loadRecommendedBooks:(NSString *)story_Id_value{
    MangoApiController *apiController = [MangoApiController sharedApiController];
    
    NSString *url;
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    url = RECOMMENDED_STORIES;
    [paramDict setObject:story_Id_value forKey:@"story_id"];
    [paramDict setObject:IOS forKey:PLATFORM];
    [MBProgressHUD showHUDAddedTo:self.recommendedBooksView animated:YES];
    [apiController getListOf:url ForParameters:paramDict withDelegate:self];
}

- (void)getImageForUrl:(NSString *)urlString {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    
    [apiController getImageAtUrl:urlString withDelegate:self];
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    [MBProgressHUD hideAllHUDsForView:self.recommendedBooksView animated:YES];
    //MangoApiController *apiController = [MangoApiController sharedApiController];
    
    //[apiController getImageAtUrl:urlString withDelegate:self];
    _tempItemArray = [NSMutableArray arrayWithArray:dataArray];
    for(int i = 0; i< _tempItemArray.count; ++i){
        NSString *imageURLString = [NSString stringWithFormat:@"http://www.mangoreader.com%@",[_tempItemArray[i] objectForKey:@"cover"]];

        
        for (UIView* view in [_recommendedBooksView subviews]) {
            if([view isKindOfClass:[UILabel class]]){
                UILabel *label = (UILabel*)view;
                if(label.tag == (i+1)){
                    label.text = [_tempItemArray[i] objectForKey:@"title"];
                }
            }
            else if([view isKindOfClass:[UIButton class]]){
                
                UIButton *button = (UIButton*)view;
                if(button.tag == (i+1)){
                    button.userInteractionEnabled = YES;
                   // UIImage *pImage=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]]];
                    CALayer *btnLayer = [button layer];
                    [btnLayer setMasksToBounds:YES];
                    [btnLayer setCornerRadius:15.0f];
                    [btnLayer setBorderWidth:3.0f];
                    [btnLayer setBorderColor:[UIColor brownColor].CGColor];
                   // [button setBackgroundImage:pImage forState:UIControlStateNormal];
                    [self downloadImageWithURL:[NSURL URLWithString:imageURLString] completionBlock:^(BOOL succeeded, NSData *data) {
                        if (succeeded) {
                          //  button.imageView.image = [[UIImage alloc] initWithData:data];
                            [button setBackgroundImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                        }
                    }];
                }
            }
        }
    }
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, NSData *data))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            completionBlock(YES, data);
        } else {
            completionBlock(NO, nil);
        }
    }];
}

- (IBAction)bookTapped:(id)sender{
    if([sender tag]){
        
        [self showBookDetailsForBook:_tempItemArray[[sender tag]-1]];
    }
}

- (void)showBookDetailsForBook:(NSDictionary *)bookDict {
    
    BookDetailsViewController *bookDetailsViewController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController_iPhone" bundle:nil];
        
    }
    else{
        bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
    }
    
    bookDetailsViewController.delegate = self;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
  //  NSMutableArray *tempDropDownArray = [[NSMutableArray alloc] init];
    [bookDetailsViewController setModalPresentationStyle:UIModalPresentationPageSheet];
    [self presentViewController:bookDetailsViewController animated:YES completion:^(void) {
        bookDetailsViewController.bookTitleLabel.text = [bookDict objectForKey:@"title"];
        
        if(![[bookDict objectForKey:@"authors"] isKindOfClass:[NSNull class]] && ([[[bookDict objectForKey:@"authors"] valueForKey:@"name"] count])){
            bookDetailsViewController.bookWrittenBy.text = [NSString stringWithFormat:@"Written by: %@", [[[bookDict objectForKey:@"authors"] valueForKey:@"name"] componentsJoinedByString:@", "]];
        }
        else{
            bookDetailsViewController.bookWrittenBy.text = [NSString stringWithFormat:@""];
        }
        
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"tags"]isKindOfClass:[NSNull class]]){
            bookDetailsViewController.bookTags.text = [NSString stringWithFormat:@"Tags: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"tags"] componentsJoinedByString:@", "]];
        }
        else{
            bookDetailsViewController.bookTags.text = [NSString stringWithFormat:@"Tags: -"];
        }
        
        if(![[bookDict objectForKey:@"narrators"] isKindOfClass:[NSNull class]] && ([[[bookDict objectForKey:@"narrators"] valueForKey:@"name"] count])){
            bookDetailsViewController.bookNarrateBy.text = [NSString stringWithFormat:@"Narrated by: %@", [[[bookDict objectForKey:@"narrators"] valueForKey:@"name"] componentsJoinedByString:@", "]];
        }
        else{
            bookDetailsViewController.bookNarrateBy.text = [NSString stringWithFormat:@""];
        }
        
        if(![[bookDict objectForKey:@"illustrators"] isKindOfClass:[NSNull class]] && ([[[bookDict objectForKey:@"illustrators"] valueForKey:@"name"] count])){
            bookDetailsViewController.bookIllustratedBy.text = [NSString stringWithFormat:@"Illustrated by: %@", [[[bookDict objectForKey:@"illustrators"] valueForKey:@"name"] componentsJoinedByString:@", "]];
        }
        else{
            bookDetailsViewController.bookIllustratedBy.text = [NSString stringWithFormat:@""];
        }
        
        [bookDetailsViewController.dropDownButton setTitle:[[bookDict objectForKey:@"info"] objectForKey:@"language"] forState:UIControlStateNormal];
      //  [tempDropDownArray addObject:[[bookDict objectForKey:@"info"] objectForKey:@"language"]];
      //  [tempDropDownArray addObjectsFromArray:[[bookDict objectForKey:@"available_languages"] valueForKey:@"language"]];
       // [bookDetailsViewController.dropDownArrayData addObjectsFromArray:[[NSSet setWithArray:tempDropDownArray] allObjects]];
        // [bookDetailsViewController.dropDownArrayData addObject:@"Record new language"];
        
        //[bookDetailsViewController.dropDownView.uiTableView reloadData];
        bookDetailsViewController.bookAvailGamesNo.text = [NSString stringWithFormat:@"No. of Games: %@",[bookDict objectForKey:@"widget_count"]];
        
        bookDetailsViewController.ageLabel.text = [NSString stringWithFormat:@"Age Group: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"age_groups"] componentsJoinedByString:@", "]];
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"learning_levels"] isKindOfClass:[NSNull class]]){
            bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Levels: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"learning_levels"] componentsJoinedByString:@", "]];
        }
        else {
            bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Levels: -"];
        }
        
        bookDetailsViewController.numberOfPagesLabel.text = [NSString stringWithFormat:@"No. of pages: %d", [[bookDict objectForKey:@"page_count"] intValue]];
        if([[bookDict objectForKey:@"price"] floatValue] == 0.00){
            bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"FREE"];
       //     [bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"Read-now.png"] forState:UIControlStateNormal];
        }
        else{
            bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"$ %.2f", [[bookDict objectForKey:@"price"] floatValue]];
        //    [bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"buynow.png"] forState:UIControlStateNormal];
        }
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"categories"] isKindOfClass:[NSNull class]]){
            bookDetailsViewController.categoriesLabel.text = [[[bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "];
        }
        else{
            bookDetailsViewController.categoriesLabel.text = [NSString stringWithFormat:@"Category: -"];
        }
        [bookDetailsViewController setIdOfDisplayBook:[bookDict objectForKey:@"id"]];
        bookDetailsViewController.descriptionLabel.text = [bookDict objectForKey:@"synopsis"];
        
        NSDictionary *dimensions = @{
                                     PARAMETER_USER_ID : ID,
                                     PARAMETER_DEVICE: IOS,
                                     PARAMETER_BOOK_ID: _book.id,
                                     PARAMETER_RECOMMEND_BOOKID : [bookDict objectForKey:@"id"]
                                     
                                     };
        [delegate trackEvent:[LASTPAGE_RECOMMENDED_BOOK valueForKey:@"description"] dimensions:dimensions];
        PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
        [userObject setObject:[LASTPAGE_RECOMMENDED_BOOK valueForKey:@"value"] forKey:@"eventName"];
        [userObject setObject: [LASTPAGE_RECOMMENDED_BOOK valueForKey:@"description"] forKey:@"eventDescription"];
        [userObject setObject:viewName forKey:@"viewName"];
        [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
        [userObject setObject:delegate.country forKey:@"deviceCountry"];
        [userObject setObject:delegate.language forKey:@"deviceLanguage"];
        [userObject setObject:_book.id forKey:@"bookID"];
        [userObject setObject:[bookDict objectForKey:@"id"] forKey:@"recommendBookID"];
        if(userEmail){
            [userObject setObject:ID forKey:@"emailID"];
        }
        [userObject setObject:IOS forKey:@"device"];
        [userObject saveInBackground];
        
        bookDetailsViewController.selectedProductId = [bookDict objectForKey:@"id"];
        [bookDetailsViewController setIdOfDisplayBook:[bookDict objectForKey:@"id"]];
        bookDetailsViewController.imageUrlString = [[ASSET_BASE_URL stringByAppendingString:[bookDict objectForKey:@"cover"]] stringByReplacingOccurrencesOfString:@"cover_" withString:@"banner_"];
    }];
    bookDetailsViewController.view.superview.frame = CGRectMake(([UIScreen mainScreen].applicationFrame.size.width/2)-400, ([UIScreen mainScreen].applicationFrame.size.height/2)-270, 776, 575);
}

- (IBAction)socialSharingOrLike :(id)sender{
    //action for social sharing or like of the app
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID: _book.id,
                                 
                                 };
    [delegate trackEvent:[LASTPAGE_SHARE valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[LASTPAGE_SHARE valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [LASTPAGE_SHARE valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:_book.id forKey:@"bookID"];
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
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            [self presentViewController:activity animated:YES completion:nil];
        }
        else{
            _popOverShare=[[UIPopoverController alloc]initWithContentViewController:activity];
        
            [_popOverShare presentPopoverFromRect:button.frame inView:button.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        }
        
        return;
    }
    
}

- (IBAction)backButtonTap:(id)sender{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    if (path) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:3] animated:YES];
    }
}

- (IBAction)mangoReaderAppStoreLink:(id)sender{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                @"itms-apps://itunes.apple.com/us/app/mangoreader-interactive-kids/id568003822?mt=8&uo=4"]];
    
}

- (void)openBook:(Book *)bk {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *identity=[NSString stringWithFormat:@"%@", bk.id];
    [appDelegate.dataModel displayAllData];
    
    CoverViewControllerBetterBookType *coverController;
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType_iPhone" bundle:nil WithId:identity];
    }
    else{
        coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType" bundle:nil WithId:identity];
    }
    
    [self.navigationController pushViewController:coverController animated:YES];
}

@end
