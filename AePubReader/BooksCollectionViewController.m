//
//  BooksCollectionViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 06/03/14.
//
//

#import "BooksCollectionViewController.h"
#import "BooksCollectionHeaderView.h"
#import "Constants.h"
#import "AePubReaderAppDelegate.h"
#import "Book.h"
#import "MangoEditorViewController.h"
#import "MangoStoreViewController.h"
#import "CoverViewControllerBetterBookType.h"
#import "MangoAnalyticsViewController.h"
#import "MangoSubscriptionViewController.h"

@interface BooksCollectionViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *allBooksArray;
@property (nonatomic, strong) UIPopoverController *popOverController;
@property (nonatomic, strong) NSMutableDictionary *bookImageDictionary;
@property (nonatomic, assign) BOOL isDeleteMode;

@end

@implementation BooksCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;
        userDeviceID = delegate.deviceId;
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //_allBooksArray = [[NSMutableArray alloc] init];
    _settingsProbSupportView.alpha = 0.4f;
    //popoverClass = [WEPopoverController class];
    if(_fromCreateStoryView){
        
        viewName = @"Create book";
        currentPage = @"Create book";
    }
    else{
        viewName = @"Detail Category Books";
        currentPage = @"my_books_screen";
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    int validUserSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    if(!validUserSubscription){
        if(delegate.loggedInUserInfo){
            //now validate user
            [[MangoApiController sharedApiController]validateSubscription:delegate.subscriptionInfo.subscriptionTransctionId andDeviceId:delegate.deviceId block:^(id response, NSInteger type, NSString *error){
                NSLog(@"type --- %d", type);
                if ([[response objectForKey:@"status"] integerValue] == 1){
                    if([[response objectForKey:@"subscription_type"] isEqualToString:@"trial"]){
                        [prefs setBool:YES forKey:@"ISTRIALUSER"];
                    }
                    NSLog(@"You are already subscribed");
                    [prefs setBool:YES forKey:@"USERISSUBSCRIBED"];
                }
            }];
            
        }
    }
    
    _settingQuesArray = [[NSArray alloc] init];
    // Do any additional setup after loading the view from its nib.
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *pListpath = [bundle pathForResource:@"SettingsQues" ofType:@"plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:pListpath];
    _settingQuesArray = [dictionary valueForKey:@"Problems"];
    
    if(!userEmail){
        ID = userDeviceID;
    }
    else{
        ID = userEmail;
    }
    //[self getAllFreeBooks];
    if(_pushCreateStory){
        
        // push to editor version
        [self goToEditorView];
    }
    
}

/*-(void)getAllFreeBooks {
    
     MangoApiController *apiController = [MangoApiController sharedApiController];
    apiController.delegate = self;
    //[apiController getListOf:FREE_STORIES ForParameters:nil withDelegate:self];
    [apiController getFreeBookInformation:FREE_STORIES withDelegate:self];
}*/

- (void)freeBooksSetup : (NSArray *)booksInfo;{
    NSLog(@"gsadasjkda");
  //  [_allBooksArray addObjectsFromArray:booksInfo];
  //  [_booksCollectionView reloadData];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    if (_allBooksArray) {
        _allBooksArray = nil;
    }
    if (_booksCollectionView) {
        [_booksCollectionView removeFromSuperview];
    }
    //_allBooksArray = [self getAllBooks];
    
    _allBooksArray = [[NSMutableArray alloc] initWithArray:[self getAllBooks]];
    if (!_allBooksArray) {
        //_allBooksArray = [NSArray array];
        [_allBooksArray addObjectsFromArray:[self getAllBooks]];
    }
    [self setupUI];
    
    [self.view bringSubviewToFront:[_settingsProbSupportView superview]];
    [self.view bringSubviewToFront:[_settingsProbView superview]];
    [[_settingsProbSupportView superview] bringSubviewToFront:_settingsProbSupportView];
    [[_settingsProbView superview] bringSubviewToFront:_settingsProbView];
    
}

- (void) viewDidAppear:(BOOL)animated{
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"my_books_screen" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:_headerLabel.text forKey:PARAMETER_BOOK_CATEGORY_VALUE];
    [dimensions setObject:@"My Books screen open" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"my_books_screen" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"my_books_screen"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get Books

- (NSArray *)booksForCategory:(NSString *)category {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *booksForSelectedCategory = [[NSMutableArray alloc] init];
    for (Book *book in [appDelegate.dataModel getAllUserBooks]) {
        
        NSString *jsonLocation = [AePubReaderAppDelegate returnBookJsonPath:book];
        
        if (jsonLocation && _categorySelected && [appDelegate.ejdbController getBookForBookId:book.id]) {
            
            NSString *jsonLocation = [AePubReaderAppDelegate returnBookJsonPath:book];

            NSFileManager *fm = [NSFileManager defaultManager];
            NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
            NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
            NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
            jsonLocation = [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
            
            if(!onlyJson.count){
                if([category isEqualToString:ALL_BOOKS_CATEGORY]){
                    [booksForSelectedCategory addObject:book];
                }
                continue;
            }
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonLocation] options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"Categories - %@, Selected Category - %@", [[jsonDict objectForKey:@"info"] objectForKey:@"categories"], [_categorySelected objectForKey:NAME]);
            if([[[jsonDict objectForKey:@"info"] objectForKey:@"categories"] containsObject:@"My Books"] && [category isEqualToString:ALL_BOOKS_CATEGORY]){
                continue;
            }
            
            if ([[[jsonDict objectForKey:@"info"] objectForKey:@"categories"] containsObject:category] || [category isEqualToString:ALL_BOOKS_CATEGORY]) {
                [booksForSelectedCategory addObject:book];
            }
        }
    }
    return booksForSelectedCategory;
}

- (NSArray *)getAllBooks {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (_toEdit) {
        return [appDelegate.dataModel getEditedBooks];
    } else {
        return [self booksForCategory:[_categorySelected objectForKey:NAME]];
    }
    return nil;
}


#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"Download Free Book"]){
        
    }
    else{
        if (buttonIndex == 1) {
        [self deleteBook:[_allBooksArray objectAtIndex:deleteBookIndex]];
        }
    }
}


#pragma mark - Setup UI

- (void)setupUI {
    CGRect viewFrame = self.view.bounds;

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        _booksCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMinX(viewFrame), 50, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame)-78) collectionViewLayout:layout];
    }
    else{
        _booksCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMinX(viewFrame), 90, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame) - 150) collectionViewLayout:layout];
    }
    _booksCollectionView.dataSource = self;
    _booksCollectionView.delegate =self;
    [_booksCollectionView registerClass:[BooksCollectionViewCell class] forCellWithReuseIdentifier:BOOK_CELL_ID];
    [_booksCollectionView registerClass:[BooksCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID];
    [_booksCollectionView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_booksCollectionView];
    
    if (_toEdit) {
        _headerLabel.text = @"My Stories";
    } else {
        _headerLabel.text = [_categorySelected objectForKey:NAME];
    }
}

#pragma mark - UICollectionView Datasource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_allBooksArray count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BooksCollectionViewCell *bookCell = [collectionView dequeueReusableCellWithReuseIdentifier:BOOK_CELL_ID forIndexPath:indexPath];
    
    bookCell.delegate = self;
    if (indexPath.row > 0) {
        //if([[_allBooksArray objectAtIndex:indexPath.row-1] count]){
        Book *book = [_allBooksArray objectAtIndex:indexPath.row - 1];
        bookCell.book = book;
        bookCell.isDeleteMode = _isDeleteMode;
       // }
    } else {
        
        bookCell.isDeleteMode = NO;
        bookCell.labelFreeBook.hidden = YES;
        if (_toEdit || [[_categorySelected objectForKey:NAME] isEqualToString:@"My Books"]) {
            bookCell.bookCoverImageView.image = [UIImage imageNamed:@"create-story-book-icon1.png"];
        } else {
            bookCell.bookCoverImageView.image = [UIImage imageNamed:@"icons_getmorebooks.png"];
        }
    }
    
    return bookCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void) goToEditorView{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        MangoEditorViewController *newBookEditorViewController = [[MangoEditorViewController alloc] initWithNibName:@"MangoEditorViewController" bundle:nil];
        newBookEditorViewController.isNewBook = YES;
        newBookEditorViewController.storyBook = nil;
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:newBookEditorViewController animated:YES];
    }
    
}

#pragma mark - UICollectionView Delegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   // NSLog(@"Index Path %@", [_categorySelected objectForKey:NAME]);
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    switch (indexPath.row) {
        case 0: {
            if (_toEdit || [[_categorySelected objectForKey:NAME] isEqualToString:@"My Books"]) {
                MangoEditorViewController *newBookEditorViewController = [[MangoEditorViewController alloc] initWithNibName:@"MangoEditorViewController" bundle:nil];
                /*NSDictionary *dimensions = @{
                                             PARAMETER_USER_EMAIL_ID : ID,
                                             PARAMETER_DEVICE: IOS,
                                             
                                             };
                [delegate trackEvent:[CREATESTORY_NEWBOOK valueForKey:@"description" ] dimensions:dimensions];
                PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
                [userObject setObject:[CREATESTORY_NEWBOOK valueForKey:@"value"] forKey:@"eventName"];
                [userObject setObject: [CREATESTORY_NEWBOOK valueForKey:@"description"] forKey:@"eventDescription"];
                [userObject setObject:viewName forKey:@"viewName"];
                [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
                [userObject setObject:delegate.country forKey:@"deviceCountry"];
                [userObject setObject:delegate.language forKey:@"deviceLanguage"];
                if(userEmail){
                    [userObject setObject:ID forKey:@"emailID"];
                }
                [userObject setObject:IOS forKey:@"device"];
                [userObject saveInBackground];*/
                
                newBookEditorViewController.isNewBook = YES;
                newBookEditorViewController.storyBook = nil;
                [self.navigationController.navigationBar setHidden:YES];
                [self.navigationController pushViewController:newBookEditorViewController animated:YES];
            } else {
                
                MangoStoreViewController *controller;
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    controller=[[MangoStoreViewController alloc]initWithNibName:@"MangoStoreViewController_iPhone" bundle:nil];
                    
                }
                else{
                    controller=[[MangoStoreViewController alloc]initWithNibName:@"MangoStoreViewController" bundle:nil];
                }
                
                /*NSDictionary *dimensions = @{
                                             PARAMETER_USER_EMAIL_ID : ID,
                                             PARAMETER_DEVICE: IOS,
                                             PARAMETER_BOOK_CATEGORY_VALUE:[_categorySelected valueForKey:@"name"]
                                             
                                             };
                [delegate trackEvent:[DETAIL_CATEGORY_GET_MORE_BOOKS valueForKey:@"description"] dimensions:dimensions];
                PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
                [userObject setObject:[DETAIL_CATEGORY_GET_MORE_BOOKS valueForKey:@"value"] forKey:@"eventName"];
                [userObject setObject: [DETAIL_CATEGORY_GET_MORE_BOOKS valueForKey:@"description"] forKey:@"eventDescription"];
                [userObject setObject:viewName forKey:@"viewName"];
                [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
                [userObject setObject:delegate.country forKey:@"deviceCountry"];
                [userObject setObject:delegate.language forKey:@"deviceLanguage"];
                [userObject setObject:[_categorySelected valueForKey:@"name"] forKey:@"categorySelect"];
                if(userEmail){
                    [userObject setObject:ID forKey:@"emailID"];
                }
                [userObject setObject:IOS forKey:@"device"];
                [userObject saveInBackground];*/
                
                NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
                [dimensions setObject:@"get_more_book_click" forKey:PARAMETER_ACTION];
                [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
                [dimensions setObject:_headerLabel.text forKey:PARAMETER_BOOK_CATEGORY_VALUE];
                [dimensions setObject:@"Get more book click" forKey:PARAMETER_EVENT_DESCRIPTION];
                if(userEmail){
                    [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
                }
                [delegate trackEventAnalytic:@"get_more_book_click" dimensions:dimensions];
                [delegate eventAnalyticsDataBrowser:dimensions];
                [delegate trackMixpanelEvents:dimensions eventName:@"get_more_book_click"];
                
                if([[_categorySelected valueForKey:@"name"] isEqualToString:@"All Books"]) {
                    [controller setCategoryFlagValue:0];
                }
                else{
                    [controller setCategoryFlagValue:1];
                }
                
                [controller setCategoryDictValue:[[NSDictionary alloc] initWithObjectsAndKeys:[_categorySelected objectForKey:NAME], @"title", nil, @"id", nil]];
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
            break;
            
        default: {
            Book *book = [_allBooksArray objectAtIndex:indexPath.row - 1];
            if (_isDeleteMode) {
                NSString *alertMessage = [NSString stringWithFormat:@"Are you sure you want to delete the book - %@", [book valueForKeyPath:@"title"]];
                
                UIAlertView *deleteBookAlert = [[UIAlertView alloc] initWithTitle:@"Delete Book" message:alertMessage delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                [deleteBookAlert show];
                deleteBookIndex = indexPath.row -1;
                //[self deleteBook:book];
            } else {
                if (_toEdit) {
                    MangoEditorViewController *mangoEditorViewController = [[MangoEditorViewController alloc] initWithNibName:@"MangoEditorViewController" bundle:nil];
                    mangoEditorViewController.isNewBook = NO;
                    mangoEditorViewController.storyBook = book;
                    [self.navigationController.navigationBar setHidden:YES];
                    
                    /*NSDictionary *dimensions = @{
                                                 PARAMETER_USER_EMAIL_ID : ID,
                                                 PARAMETER_DEVICE: IOS,
                                                 PARAMETER_BOOK_ID : book.id
                                                 
                                                 };
                    [delegate trackEvent:[CREATESTORY_SELECT_BOOK valueForKey:@"description" ]  dimensions:dimensions];
                    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
                    [userObject setObject:[CREATESTORY_SELECT_BOOK valueForKey:@"value"] forKey:@"eventName"];
                    [userObject setObject: [CREATESTORY_SELECT_BOOK valueForKey:@"description"] forKey:@"eventDescription"];
                    [userObject setObject:viewName forKey:@"viewName"];
                    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
                    [userObject setObject:delegate.country forKey:@"deviceCountry"];
                    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
                    [userObject setObject:book.id forKey:@"bookID"];
                    if(userEmail){
                        [userObject setObject:ID forKey:@"emailID"];
                    }
                    [userObject setObject:IOS forKey:@"device"];
                    [userObject saveInBackground];*/
                    
                    [self.navigationController pushViewController:mangoEditorViewController animated:YES];
                } else {
                    
                    /*NSDictionary *dimensions = @{
                                                 PARAMETER_USER_EMAIL_ID : ID,
                                                 PARAMETER_DEVICE: IOS,
                                                 PARAMETER_BOOK_ID : book.id
                                                 
                                                 };
                    [delegate trackEvent:[DETAIL_CATEGORY_BOOK_SELECT valueForKey:@"description"] dimensions:dimensions];
                    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
                    [userObject setObject:[DETAIL_CATEGORY_BOOK_SELECT valueForKey:@"value"] forKey:@"eventName"];
                    [userObject setObject: [DETAIL_CATEGORY_BOOK_SELECT valueForKey:@"description"] forKey:@"eventDescription"];
                    [userObject setObject:viewName forKey:@"viewName"];
                    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
                    [userObject setObject:delegate.country forKey:@"deviceCountry"];
                    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
                    [userObject setObject:[_categorySelected valueForKey:@"name"] forKey:@"categorySelect"];
                    [userObject setObject:book.id forKey:@"bookID"];
                    if(userEmail){
                        [userObject setObject:ID forKey:@"emailID"];
                    }
                    [userObject setObject:IOS forKey:@"device"];
                    [userObject saveInBackground];*/
                    CoverViewControllerBetterBookType *coverController;
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    int val =[book.downloaded integerValue];
                    int isFreeBook = [book.isFree integerValue];
                    NSString *sodtBookId = [prefs valueForKey:@"StoryOfTheDayBookId"];
                    
                    if(val == 2){
                       /* NSString *message = [NSString stringWithFormat:@"Th book %@ is free, are you sure you want to download it now?", book.title];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Free Book" message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                        [alert show];*/
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        [prefs setBool:YES forKey:@"ISAPPLECHECK"];
                        [self getLiveStoryByID:book.id];
                        
                    }
                    else if([book.id isEqualToString:sodtBookId] || (isFreeBook) || (book.parentBookId) || ([book.title isEqualToString:@"My Book"])){
                        
                        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                            
                            coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType_iPhone" bundle:nil WithId:book.id];
                            
                        }
                        else{
                            coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType" bundle:nil WithId:book.id];
                        }
                        
                        [self.navigationController pushViewController:coverController animated:YES];
                        
                    }
                    else{
                        int validSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
                        int isUserEmailSubscribed = [[prefs valueForKey:@"USERISSUBSCRIBED"] integerValue];
                        AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
                        if(validSubscription || (isUserEmailSubscribed && appDelegate.loggedInUserInfo)){
                            
                            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                                
                                coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType_iPhone" bundle:nil WithId:book.id];
                                
                            }
                            else{
                                coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType" bundle:nil WithId:book.id];
                            }
                            
                            [self.navigationController pushViewController:coverController animated:YES];
                            
                        }
                        
                        else{
                        //check if user is subscribed else goto subscription screen
                            MangoSubscriptionViewController *showsubscriptionScreen;
                            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                            
                                showsubscriptionScreen=[[MangoSubscriptionViewController alloc]initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
                            
                            }
                            else{
                                showsubscriptionScreen=[[MangoSubscriptionViewController alloc]initWithNibName:@"MangoSubscriptionViewController" bundle:nil];
                            }
                        
                            [self presentViewController:showsubscriptionScreen animated:YES completion:nil];
                        }
                    }
                }
            }
        }
            break;
    }
}


- (void) qusetionForSettings{
    _settingsProbSupportView.hidden = NO;
    _settingsProbView.hidden = NO;
    NSArray *operation = [[NSArray alloc] initWithObjects:@"X", @"+", nil];
    int val1 =  arc4random()%10;
    int val2 =  arc4random()%10;
    int rand = arc4random()%2;
    _labelProblem.text = [NSString stringWithFormat:@"What is %d %@ %d = ?",val1, [operation objectAtIndex:rand],val2 ];
    quesSolution = [self calculate:val1 :val2 :[operation objectAtIndex:rand]];
}

- (int) calculate: (int) value1 :(int)value2 : (NSString *)op{
    
    if([op isEqualToString:@"X"]){
        return (value1 * value2);
    }
    
    else return (value1 + value2);
}

- (IBAction)doneProblem:(id)sender{
    [_textQuesSolution resignFirstResponder];
    if([_textQuesSolution.text intValue]  == quesSolution){
        
        settingSol = YES;
        
    }
    else{
        settingSol = NO;
    }
    _textQuesSolution.text = @"";
    _settingsProbView.hidden = YES;
    _settingsProbSupportView.hidden = YES;
    [self displaySettingsOrNot];
}

/*- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    self.popoverControlleriPhone = nil;
}*/

- (void)displaySettingsOrNot {
    
    if(settingSol){
        //[self displaySettings];
        settingSol = NO;
    }
    
}

- (IBAction)closeSettingProblemView:(id)sender{
    [_textQuesSolution resignFirstResponder];
    _textQuesSolution.text = @"";
    _settingsProbView.hidden = YES;
    _settingsProbSupportView.hidden = YES;
}

/*- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if([alertView.title isEqualToString:@"Delete Book"]){
        Book *book = [_allBooksArray objectAtIndex:deleteBookIndex];
        if(buttonIndex == 1){
            NSLog(@"delete");
            [self deleteBook:book];
        }
        else{
            [_deleteButton setImage:[UIImage imageNamed:@"doneTrash.png"] forState:UIControlStateNormal];
        }
    }
    else if([alertView.title isEqualToString:@"SOLVE"]){
        
        if((settingQuesNo % 2) == buttonIndex){
            NSLog(@"CORRECT");
            PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
            NSDictionary *EVENT;
            NSDictionary *dimensions = @{
                                         PARAMETER_USER_ID : ID,
                                         PARAMETER_DEVICE: IOS,
                                         PARAMETER_SETTINGS_QUES_SOL:[NSString stringWithFormat:@"%d", (BOOL)YES],
                                         
                                         };
            if(_fromCreateStoryView){
                EVENT = CREATESTORY_SETTING_QUES;
                [delegate trackEvent:[EVENT valueForKey:@"description"] dimensions:dimensions];
                [userObject setObject:viewName forKey:@"viewName"];
            }
            else{
                EVENT = DETAIL_CATEGORY_SETTING_QUES;
                [delegate trackEvent:[EVENT valueForKey:@"description"] dimensions:dimensions];
                [userObject setObject:viewName forKey:@"viewName"];
            }
            [userObject setObject:[EVENT valueForKey:@"value"] forKey:@"eventName"];
            [userObject setObject: [EVENT valueForKey:@"description"] forKey:@"eventDescription"];
            [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
            [userObject setObject:delegate.country forKey:@"deviceCountry"];
            [userObject setObject:delegate.language forKey:@"deviceLanguage"];
            [userObject setObject:[NSNumber numberWithBool:YES] forKey:@"boolValue"];
            if(userEmail){
                [userObject setObject:ID forKey:@"emailID"];
            }
            [userObject setObject:IOS forKey:@"device"];
            [userObject saveInBackground];
            
            NSDictionary *dimensions1 = @{
                                          PARAMETER_USER_ID : ID,
                                         PARAMETER_DEVICE: IOS,
                                         
                                         };
            if(_fromCreateStoryView){
                EVENT = CREATESTORY_SETTINGS;
                [delegate trackEvent:[EVENT valueForKey:@"description"] dimensions:dimensions1];
                [userObject setObject:viewName forKey:@"viewName"];
            }
            else{
                EVENT = DETAIL_CATEGORY_SETTINGS;
                [delegate trackEvent:[EVENT valueForKey:@"description"] dimensions:dimensions1];
                [userObject setObject:viewName forKey:@"viewName"];
            }
            [userObject setObject:[EVENT valueForKey:@"value"] forKey:@"eventName"];
            [userObject setObject: [EVENT valueForKey:@"description"] forKey:@"eventDescription"];
            [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
            [userObject setObject:delegate.country forKey:@"deviceCountry"];
            [userObject setObject:delegate.language forKey:@"deviceLanguage"];
            if(userEmail){
                [userObject setObject:ID forKey:@"emailID"];
            }
            [userObject setObject:IOS forKey:@"device"];
            [userObject saveInBackground];
            settingSol = YES;
            
        }
        else{
            NSLog(@"WRONG");
            PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
            NSDictionary *EVENT;
            NSDictionary *dimensions = @{
                                         PARAMETER_USER_ID : ID,
                                         PARAMETER_DEVICE: IOS,
                                         PARAMETER_SETTINGS_QUES_SOL:[NSString stringWithFormat:@"%d", (BOOL)YES],
                                         
                                         };
            if(_fromCreateStoryView){
                EVENT = CREATESTORY_SETTING_QUES;
                [delegate trackEvent:[EVENT valueForKey:@"description"] dimensions:dimensions];
                [userObject setObject:viewName forKey:@"viewName"];
            }
            else{
                EVENT = DETAIL_CATEGORY_SETTING_QUES;
                [delegate trackEvent:[EVENT valueForKey:@"description"] dimensions:dimensions];
                [userObject setObject:viewName forKey:@"viewName"];
            }
            [userObject setObject:[EVENT valueForKey:@"value"] forKey:@"eventName"];
            [userObject setObject: [EVENT valueForKey:@"description"] forKey:@"eventDescription"];
            [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
            [userObject setObject:delegate.country forKey:@"deviceCountry"];
            [userObject setObject:delegate.language forKey:@"deviceLanguage"];
            [userObject setObject:[NSNumber numberWithBool:NO] forKey:@"boolValue"];
            if(userEmail){
                [userObject setObject:ID forKey:@"emailID"];
            }
            [userObject setObject:IOS forKey:@"device"];
            [userObject saveInBackground];
        }
        
    }
    
}*/


/*- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(settingSol){
        [self displaySettings];
        settingSol = NO;
    }
    
}*/


/*-(void)displaySettings {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        if (!_popoverControlleriPhone) {
            
            SettingOptionViewController *settingsViewController=[[SettingOptionViewController alloc]initWithStyle:UITableViewCellStyleDefault];
            [settingsViewController.view setFrame:CGRectMake(0, 0, 50, 150)];
            settingsViewController.dismissDelegate = self;
            settingsViewController.controller = self.navigationController;
            settingsViewController.analyticsDelegate = self;
            self.popoverControlleriPhone = [[popoverClass alloc] initWithContentViewController:settingsViewController];
            self.popoverControlleriPhone.delegate = self;
            [self.popoverControlleriPhone setPopoverContentSize:CGSizeMake(200, 132)];
            self.popoverControlleriPhone.passthroughViews = nil;
            
            [self.popoverControlleriPhone presentPopoverFromRect:_settingButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            
        } else {
            [self.popoverControlleriPhone dismissPopoverAnimated:YES];
            self.popoverControlleriPhone = nil;
        }
        
    }
    
    else{
        
        SettingOptionViewController *settingsViewController=[[SettingOptionViewController alloc]initWithStyle:UITableViewCellStyleDefault];
        settingsViewController.dismissDelegate = self;
        settingsViewController.controller = self.navigationController;
        _popOverController=[[UIPopoverController alloc]initWithContentViewController:settingsViewController];
        [_popOverController setPopoverContentSize:CGSizeMake(300, 132)];
        [_popOverController presentPopoverFromRect:_settingButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}*/


#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        return UIEdgeInsetsMake(5, 30, 10, 20);
    }
    else{
        return UIEdgeInsetsMake(40, 30, 0, 0);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return CGSizeMake(120, 105);
        
    }
    else{
            return CGSizeMake(200, 240);
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return 20.0f;
    }
    else{
        return 30.0f;
    }
}

#pragma mark - Action Methods

- (IBAction)settingsButtonTapped:(id)sender {
    
//    int rNo = arc4random()%8;
//    settingQuesNo = rNo;
    
    /*if (_popoverControlleriPhone){
        
        [self.popoverControlleriPhone dismissPopoverAnimated:YES];
        self.popoverControlleriPhone = nil;
        
        return;
    }*/
    
    [self qusetionForSettings];
}



- (IBAction)homeButtonTapped:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *contoller=(UIViewController *)delegate.controller;
    [self.navigationController popToViewController:contoller animated:YES];
}

- (IBAction)libraryButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)trashButtonTapped:(id)sender {
    _isDeleteMode = !_isDeleteMode;
    UIButton *trashButton = (UIButton *)sender;
    if (_isDeleteMode) {
        [trashButton setImage:[UIImage imageNamed:@"doneTrash.png"] forState:UIControlStateNormal];
    } else {
        [trashButton setImage:[UIImage imageNamed:@"MangoTrash.png"] forState:UIControlStateNormal];
    }
    [_booksCollectionView reloadData];
}

#pragma mark - Settings Delegate Methods

-(void)dismissPopOver{
    [_popOverController dismissPopoverAnimated:YES];
    //[_popoverControlleriPhone dismissPopoverAnimated:YES];
    //self.popoverControlleriPhone = nil;
}

/*- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    self.popoverControlleriPhone = nil;
}*/

- (void) showAnalyticsView{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        MangoAnalyticsViewController *analyticsViewController = [[MangoAnalyticsViewController alloc] initWithNibName:@"MangoAnalyticsViewController_iPhone" bundle:nil];
        analyticsViewController.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
        [self presentViewController:analyticsViewController animated:YES completion:nil];
    }
}

- (void) showSubscriptionView{
    
    MangoSubscriptionViewController *subscriptionViewController;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
        subscriptionViewController.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
        [self presentViewController:subscriptionViewController animated:YES completion:nil];
    }
}


#pragma mark - SaveBookImage Delegate

- (void)saveBookImage:(UIImage *)image ForBook:(Book *)book {
    if (!_bookImageDictionary) {
        _bookImageDictionary = [[NSMutableDictionary alloc] init];
    }
    if (image) {
        if(!book.id){
            [_bookImageDictionary setObject:image forKey:book.bookId];
        }
        else{
            [_bookImageDictionary setObject:image forKey:book.id];
        }
    }
}

- (UIImage *)getImageForBook:(Book *)book {
    if (_bookImageDictionary) {
        return [_bookImageDictionary objectForKey:book.id];
    }
    return nil;
}

#pragma mark - Delete Book

- (void)deleteBook:(Book *)book {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *book_id = book.id;
    BOOL deleteSuccess = [appDelegate.ejdbController deleteObject:[appDelegate.ejdbController getBookForBookId:book.id]];
    if (deleteSuccess) {
        NSDictionary *EVENT;
        /*PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
        NSDictionary *dimensions = @{
                                     PARAMETER_USER_EMAIL_ID : ID,
                                     PARAMETER_DEVICE: IOS,
                                     PARAMETER_BOOK_ID :book_id
                                     };*/
        if(_fromCreateStoryView){
//            EVENT = CREATESTORY_DELETE_BOOK;
//            [appDelegate trackEvent:[EVENT valueForKey:@"description"] dimensions:dimensions];
//            [userObject setObject:viewName forKey:@"viewName"];
        }
        else{
//            EVENT = DETAIL_CATEGORY_DELETE_BOOK;
//            [appDelegate trackEvent:[EVENT valueForKey:@"description"] dimensions:dimensions];
//            [userObject setObject:viewName forKey:@"viewName"];
            
            NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
            [dimensions setObject:@"delete_click" forKey:PARAMETER_ACTION];
            [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
            [dimensions setObject:@"Delete book click" forKey:PARAMETER_EVENT_DESCRIPTION];
            [dimensions setObject:@"True" forKey:PARAMETER_PASS];
            if(userEmail){
                [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
            }
            [appDelegate trackEventAnalytic:@"delete_click" dimensions:dimensions];
            [appDelegate eventAnalyticsDataBrowser:dimensions];
            [appDelegate trackMixpanelEvents:dimensions eventName:@"delete_click"];

        }
        /*[userObject setObject:[EVENT valueForKey:@"value"] forKey:@"eventName"];
        [userObject setObject: [EVENT valueForKey:@"description"] forKey:@"eventDescription"];
        [userObject setObject:appDelegate.deviceId forKey:@"deviceIDValue"];
        [userObject setObject:appDelegate.country forKey:@"deviceCountry"];
        [userObject setObject:appDelegate.language forKey:@"deviceLanguage"];
        [userObject setObject:book_id forKey:@"bookID"];
        if(userEmail){
            [userObject setObject:ID forKey:@"emailID"];
        }
        [userObject setObject:IOS forKey:@"device"];
        [userObject saveInBackground];*/
        
        NSLog(@"Deleted Book");
        //_allBooksArray = [self getAllBooks];
        [_allBooksArray removeAllObjects];
        [_allBooksArray addObjectsFromArray:[self getAllBooks]];
        if (!_allBooksArray) {
            //_allBooksArray = [NSArray array];
            [_allBooksArray addObjectsFromArray:[self getAllBooks]];
        }
        [_booksCollectionView reloadData];
    }
    
}

- (IBAction)backgroundTap:(id)sender {
    [_textQuesSolution resignFirstResponder];
}

- (void) getLiveStoryByID :(NSString *)bookID{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    MangoApiController *apiController = [MangoApiController sharedApiController];
    NSString *url;
    url = [LIVE_STORIES_WITH_ID stringByAppendingString:[NSString stringWithFormat:@"/%@",bookID]];
    
    [apiController getListOf:url ForParameters:nil withDelegate:self];
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    NSDictionary *passDictionaryValue;
    
    if(dataArray.count){
        passDictionaryValue = dataArray [0];
    }
    else {
        passDictionaryValue = nil;
    }
    
    [self showBookDetailsForBook:passDictionaryValue];
}

#pragma bookdetail popup

- (void)showBookDetailsForBook:(NSDictionary *)bookDict {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *storyOfDayId = [prefs valueForKey:@"StoryOfTheDayBookId"];
    if(!bookDict){
        
        return;
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    BookDetailsViewController *bookDetailsViewController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController_iPhone" bundle:nil];
        
    }
    else{
        bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
    }
    bookDetailsViewController.fromMyStories = 1;
    bookDetailsViewController.delegate = self;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    //  NSMutableArray *tempDropDownArray = [[NSMutableArray alloc] init];
    bookDetailsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    bookDetailsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:bookDetailsViewController animated:YES completion:^(void) {
        bookDetailsViewController.bookTitleLabel.text = [bookDict objectForKey:@"title"];
        
        if(![[bookDict objectForKey:@"authors"] isKindOfClass:[NSNull class]] && ([[[bookDict objectForKey:@"authors"] valueForKey:@"name"] count])){
            bookDetailsViewController.bookWrittenBy.text = [NSString stringWithFormat:@"-by : %@", [[[bookDict objectForKey:@"authors"] valueForKey:@"name"] componentsJoinedByString:@", "]];
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
        bookDetailsViewController.bookAvailGamesNo.text = [NSString stringWithFormat:@"Games: %@",[bookDict objectForKey:@"widget_count"]];
        
        bookDetailsViewController.ageLabel.text = [NSString stringWithFormat:@"Age : %@", [bookDict objectForKey:@"combined_age_group"]];
        [bookDetailsViewController setIdOfDisplayBook:[bookDict objectForKey:@"id"]];
        
        bookDetailsViewController.gradeLevel.text = [NSString stringWithFormat:@"Grade : %@", [bookDict objectForKey:@"combined_grades"]];
        
        if(![[bookDict objectForKey:@"combined_reading_level"] isKindOfClass:[NSNull class]]){
            bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Level : %@", [bookDict objectForKey:@"combined_reading_level"]];
        }
        else {
            bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Levels: -"];
        }
        
        bookDetailsViewController.numberOfPagesLabel.text = [NSString stringWithFormat:@"Pages: %d", [[bookDict objectForKey:@"page_count"] intValue]];
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
            bookDetailsViewController.singleCategoryLabel.text = [NSString stringWithFormat:@"Category : %@",[[[bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "]];
        }
        else{
            bookDetailsViewController.categoriesLabel.text = [NSString stringWithFormat:@"Category: -"];
        }
        int availableLanguagesCount = [[bookDict valueForKey:@"available_languages"] count];
        if(availableLanguagesCount){
            bookDetailsViewController.labelAvaillanguageCount.text = [NSString stringWithFormat:@"Available in %d languages :", availableLanguagesCount+1];
        }
        else{
            bookDetailsViewController.labelAvaillanguageCount.text = [NSString stringWithFormat:@"Available in %d language :", availableLanguagesCount+1];
            bookDetailsViewController.dropDownButton.userInteractionEnabled = NO;
        }
        [bookDetailsViewController setIdOfDisplayBook:[bookDict objectForKey:@"id"]];
        bookDetailsViewController.descriptionLabel.text = [bookDict objectForKey:@"synopsis"];
        
        NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
        [dimensions setObject:@"show_book" forKey:PARAMETER_ACTION];
        [dimensions setObject:@"show_book" forKey:PARAMETER_CURRENT_PAGE];
        [dimensions setObject:@"Show book details" forKey:PARAMETER_EVENT_DESCRIPTION];
        [dimensions setObject:[bookDict objectForKey:@"id"] forKey:PARAMETER_BOOK_ID];
        [dimensions setObject:[bookDict objectForKey:@"title"] forKey:PARAMETER_BOOK_TITLE];
        [dimensions setObject:currentPage forKey:PARAMETER_BOOKDETAIL_SOURCE];
        if(userEmail){
            [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
        }
        [delegate trackEventAnalytic:@"show_book" dimensions:dimensions];
        [delegate eventAnalyticsDataBrowser:dimensions];
        [delegate trackMixpanelEvents:dimensions eventName:@"show_book"];
        
        if([storyOfDayId isEqualToString:[bookDict objectForKey:@"id"]]){
            [bookDetailsViewController.buyButton setTitle: @"Read Now" forState: UIControlStateNormal];
            bookDetailsViewController.imgStoryOfDay.hidden = NO;
        }
        
        bookDetailsViewController.baseNavView = currentPage;
        bookDetailsViewController.selectedProductId = [bookDict objectForKey:@"id"];
        [bookDetailsViewController setIdOfDisplayBook:[bookDict objectForKey:@"id"]];
        bookDetailsViewController.imageUrlString = [[bookDict objectForKey:@"thumb"] stringByReplacingOccurrencesOfString:@"thumb_new" withString:@"ipad_banner"];
    }];
    bookDetailsViewController.view.superview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    bookDetailsViewController.view.layer.cornerRadius = 2.5f;
    bookDetailsViewController.view.superview.bounds = CGRectMake(0, 0, 776, 529);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

}

@end
