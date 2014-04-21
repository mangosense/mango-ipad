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

@interface BooksCollectionViewController ()

@property (nonatomic, strong) NSArray *allBooksArray;
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
    _settingsProbSupportView.alpha = 0.4f;
    popoverClass = [WEPopoverController class];
    if(_fromCreateStoryView){
        
        viewName = @"Create book";
    }
    else{
        viewName = @"Detail Category Books";
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
    _allBooksArray = [self getAllBooks];
    if (!_allBooksArray) {
        _allBooksArray = [NSArray array];
    }
    [self setupUI];
    
    [self.view bringSubviewToFront:[_settingsProbSupportView superview]];
    [self.view bringSubviewToFront:[_settingsProbView superview]];
    [[_settingsProbSupportView superview] bringSubviewToFront:_settingsProbSupportView];
    [[_settingsProbView superview] bringSubviewToFront:_settingsProbView];
    
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
        if (book.localPathFile && _categorySelected && [appDelegate.ejdbController getBookForBookId:book.id]) {
            NSString *jsonLocation=book.localPathFile;
            NSFileManager *fm = [NSFileManager defaultManager];
            NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
            NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
            NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
            jsonLocation = [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonLocation] options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"Categories - %@, Selected Category - %@", [[jsonDict objectForKey:@"info"] objectForKey:@"categories"], [_categorySelected objectForKey:NAME]);
            
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

#pragma mark - Setup UI

- (void)setupUI {
    CGRect viewFrame = self.view.bounds;

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        _booksCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMinX(viewFrame), 45, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame)-78) collectionViewLayout:layout];
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
        Book *book = [_allBooksArray objectAtIndex:indexPath.row - 1];
        bookCell.book = book;
        bookCell.isDeleteMode = _isDeleteMode;
    } else {
        bookCell.isDeleteMode = NO;
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

#pragma mark - UICollectionView Delegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Index Path %@", [_categorySelected objectForKey:NAME]);
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    switch (indexPath.row) {
        case 0: {
            if (_toEdit || [[_categorySelected objectForKey:NAME] isEqualToString:@"My Books"]) {
                MangoEditorViewController *newBookEditorViewController = [[MangoEditorViewController alloc] initWithNibName:@"MangoEditorViewController" bundle:nil];
                NSDictionary *dimensions = @{
                                             PARAMETER_USER_ID : ID,
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
                [userObject saveInBackground];
                
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
                
                NSDictionary *dimensions = @{
                                             PARAMETER_USER_ID : ID,
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
                [userObject saveInBackground];

                
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
                    
                    NSDictionary *dimensions = @{
                                                 PARAMETER_USER_ID : ID,
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
                    [userObject saveInBackground];
                    
                    [self.navigationController pushViewController:mangoEditorViewController animated:YES];
                } else {
                    
                    CoverViewControllerBetterBookType *coverController;
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        
                        coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType_iPhone" bundle:nil WithId:book.id];
                        
                    }
                    else{
                        coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType" bundle:nil WithId:book.id];
                    }
                    
                    NSDictionary *dimensions = @{
                                                 PARAMETER_USER_ID : ID,
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
                    [userObject saveInBackground];
                    
                    [self.navigationController pushViewController:coverController animated:YES];
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
        NSLog(@"dddoonnee");
    }
    else{
        settingSol = NO;
    }
    _textQuesSolution.text = @"";
    _settingsProbView.hidden = YES;
    _settingsProbSupportView.hidden = YES;
    [self displaySettingsOrNot];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    self.popoverControlleriPhone = nil;
}

- (void)displaySettingsOrNot {
    
    if(settingSol){
        [self displaySettings];
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


-(void)displaySettings {
    
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
    
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        return UIEdgeInsetsMake(15, 60, 0, 0);
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
        return CGSizeMake(160, 125);
        
    }
    else{
            return CGSizeMake(200, 240);
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return 10.0f;
    }
    else{
        return 30.0f;
    }
}

#pragma mark - Action Methods

- (IBAction)settingsButtonTapped:(id)sender {
    
    int rNo = arc4random()%8;
    settingQuesNo = rNo;
    
    if (_popoverControlleriPhone){
        
        [self.popoverControlleriPhone dismissPopoverAnimated:YES];
        self.popoverControlleriPhone = nil;
        
        return;
    }
    
    [self qusetionForSettings];
    
  /*  UIAlertView *settingAlert = [[UIAlertView alloc] initWithTitle:@"SOLVE" message:[[_settingQuesArray objectAtIndex:rNo] valueForKey:@"ques"] delegate:self cancelButtonTitle:[[_settingQuesArray objectAtIndex:rNo] valueForKey:@"sol1"] otherButtonTitles:[[_settingQuesArray objectAtIndex:rNo] valueForKey:@"sol2"], nil];
    [settingAlert show];*/
    
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
    [_popoverControlleriPhone dismissPopoverAnimated:YES];
    self.popoverControlleriPhone = nil;
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

#pragma mark - SaveBookImage Delegate

- (void)saveBookImage:(UIImage *)image ForBook:(Book *)book {
    if (!_bookImageDictionary) {
        _bookImageDictionary = [[NSMutableDictionary alloc] init];
    }
    if (image) {
        [_bookImageDictionary setObject:image forKey:book.id];
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
    BOOL deleteSuccess = [appDelegate.ejdbController deleteObject:[appDelegate.ejdbController getBookForBookId:book.id]];
    if (deleteSuccess) {
        NSDictionary *EVENT;
        PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
        NSDictionary *dimensions = @{
                                     PARAMETER_USER_ID : ID,
                                     PARAMETER_DEVICE: IOS,
                                     PARAMETER_BOOK_ID :book.id                                     
                                     };
        if(_fromCreateStoryView){
            EVENT = CREATESTORY_DELETE_BOOK;
            [appDelegate trackEvent:[EVENT valueForKey:@"description"] dimensions:dimensions];
            [userObject setObject:viewName forKey:@"viewName"];
        }
        else{
            EVENT = DETAIL_CATEGORY_DELETE_BOOK;
            [appDelegate trackEvent:[EVENT valueForKey:@"description"] dimensions:dimensions];
            [userObject setObject:viewName forKey:@"viewName"];
        }
        [userObject setObject:[EVENT valueForKey:@"value"] forKey:@"eventName"];
        [userObject setObject: [EVENT valueForKey:@"description"] forKey:@"eventDescription"];
        [userObject setObject:appDelegate.deviceId forKey:@"deviceIDValue"];
        [userObject setObject:appDelegate.country forKey:@"deviceCountry"];
        [userObject setObject:appDelegate.language forKey:@"deviceLanguage"];
        [userObject setObject:book.id forKey:@"bookID"];
        if(userEmail){
            [userObject setObject:ID forKey:@"emailID"];
        }
        [userObject setObject:IOS forKey:@"device"];
        [userObject saveInBackground];
        
        NSLog(@"Deleted Book");
        _allBooksArray = [self getAllBooks];
        if (!_allBooksArray) {
            _allBooksArray = [NSArray array];
        }
        [_booksCollectionView reloadData];
    }
    
}

- (IBAction)backgroundTap:(id)sender {
    [_textQuesSolution resignFirstResponder];
    
}

@end
