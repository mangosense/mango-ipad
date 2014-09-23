//
//  LanguageChoiceViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/13.
//
//

#import "AePubReaderAppDelegate.h"
#import "LanguageChoiceViewController.h"
#import "BookDetailsViewController.h"
#import "Constants.h"
#import "BooksCollectionViewController.h"
#import "CoverViewControllerBetterBookType.h"

@interface LanguageChoiceViewController ()

@end

@implementation LanguageChoiceViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            self.tableView.contentInset = UIEdgeInsetsMake(-37, 0, -37, 0);
            if ([self respondsToSelector:@selector(setPreferredContentSize:)]) {
                self.preferredContentSize = CGSizeMake(150, 110);
            } else {
                self.contentSizeForViewInPopover = CGSizeMake(150, 110);
            }
        }
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;
        userDeviceID = delegate.deviceId;

    }
    return self;
}

- (void)viewDidLoad
{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    userEmail = delegate.loggedInUserInfo.email;
    userDeviceID = delegate.deviceId;
    
    [super viewDidLoad];
    if(!userEmail){
        ID = userDeviceID;
    }
    else{
        ID = userEmail;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    BookDetailsViewController *bookDetailView = [[BookDetailsViewController alloc] init];
    bookDetailView.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        return 32;
    }
    else{
        return 44;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        cell.textLabel.font = [UIFont systemFontOfSize:12];
    }
    
    cell.textLabel.text=[_array objectAtIndex:indexPath.row];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[_delegate dismissPopOver];
    MangoApiController *apiController = [MangoApiController sharedApiController];
    newLanguage = [_array objectAtIndex:indexPath.row];
    NSString *url;
    url = [LIVE_STORIES_WITH_ID stringByAppendingString:[NSString stringWithFormat:@"/%@",[_bookIDArray objectAtIndex:indexPath.row]]];
   // [paramDict setObject:currentBookId forKey:@"story_id"];
    [apiController getListOf:url ForParameters:nil withDelegate:self];
    
    /*
    BookDetailsViewController *bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];

    [bookDetailsViewController setModalPresentationStyle:UIModalPresentationPageSheet];
    [self presentViewController:bookDetailsViewController animated:YES completion:^(void) {
        bookDetailsViewController.bookTitleLabel.text = [_bookDict objectForKey:@"title"];
        bookDetailsViewController.ageLabel.text = [NSString stringWithFormat:@"Age Groups: %@", [[[_bookDict objectForKey:@"info"] objectForKey:@"age_groups"] componentsJoinedByString:@", "]];
        bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Levels: %@", [[[_bookDict objectForKey:@"info"] objectForKey:@"learning_levels"] componentsJoinedByString:@", "]];
        bookDetailsViewController.numberOfPagesLabel.text = [NSString stringWithFormat:@"No. of pages: %d", [[_bookDict objectForKey:@"page_count"] intValue]];
        bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"Rs. %d", [[_bookDict objectForKey:@"price"] intValue]];
        bookDetailsViewController.categoriesLabel.text = [[[_bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "];
        bookDetailsViewController.descriptionLabel.text = [_bookDict objectForKey:@"synopsis"];
        
        bookDetailsViewController.selectedProductId = [[[_bookDict objectForKey:@"available_languages"] objectAtIndex:indexPath.row] objectForKey:@"live_story_id"];
        bookDetailsViewController.imageUrlString = [[ASSET_BASE_URL stringByAppendingString:[_bookDict objectForKey:@"cover"]] stringByReplacingOccurrencesOfString:@"cover_" withString:@"banner_"];
    }];
    bookDetailsViewController.view.superview.frame = CGRectMake(([UIScreen mainScreen].applicationFrame.size.width/2)-400, ([UIScreen mainScreen].applicationFrame.size.height/2)-270, 800, 540);
     */
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type{
    
    AePubReaderAppDelegate *delegate = (AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
//    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
//    NSDictionary *EVENT;
    
    NSString *val;
    
    if(!dataArray.count){
        val = @"No id available";
    }
    
    else{
        val = [dataArray[0] valueForKey:@"id"];
    }
    
    /*NSDictionary *dimensions = @{
                                 PARAMETER_USER_EMAIL_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_LANGUAGE : _language,
                                 PARAMETER_BOOK_ID : val,
                                 PARAMETER_BOOK_NEW_LANGUAGE_SELECT : newLanguage
                                 };*/
    
    if(_isReadPage){
        
        currentPage = @"reading";
        
    }
    else{
        currentPage = @"cover_screen";
    }
    
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"switch_language" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:_oldBookId forKey:PARAMETER_BOOK_ID];
    [dimensions setObject:_oldBookTitle forKey:PARAMETER_BOOK_TITLE];
    [dimensions setObject:val forKey:PARAMETER_NEWLANG_BOOK_ID];
    [dimensions setObject:newLanguage forKey:PARAMETER_BOOK_NEW_LANGUAGE_SELECT];
    [dimensions setObject:@"Switch to new language" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"switch_language" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    //[delegate trackMixpanelEvents:dimensions eventName:@"switch_language"];
    /*[userObject setObject:[EVENT valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [EVENT valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:val forKey:@"bookID"];
    [userObject setObject:_language forKey:@"bookLanguage"];
    [userObject setObject:newLanguage forKey:@"bookNewLanguageSelect"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];*/
    
    NSLog(@"My array is %@", dataArray);
    NSMutableArray *tempItemArray = [[NSMutableArray alloc] init];
    tempItemArray = [NSMutableArray arrayWithArray:dataArray];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    Book *bk=[appDelegate.dataModel getBookOfEJDBId:val];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    if ((path) && (!validSubscription)) {
        
        [_delegate dismissPopOver];
        
        MangoSubscriptionViewController *subscriptionViewController;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            
            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
        }
        else{
            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController" bundle:nil];
        }
        subscriptionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [self.view.window.rootViewController presentViewController:subscriptionViewController animated:YES completion:nil];
        //[self presentViewController:subscriptionViewController animated:YES completion:nil];
        [_delegate dismissPopOver];
    }
    
    else{
    
    if (bk) {
        
        [self openBook:bk];
        [self closeDetails:nil];
    
    
//        if([[NSString stringWithFormat:@"%@", [_delegate class]] isEqualToString:@"PageNewBookTypeViewController"]){
//           // [self showBookDetailsForBook:tempItemArray[0]];

//            
//        }
            [_delegate dismissPopOver];
        
    } else {
    
        [self showBookDetailsForBook:tempItemArray[0]];
    }
    }
}

- (void)showBookDetailsForBook:(NSDictionary *)bookDict {
    BookDetailsViewController *bookDetailsViewController;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *storyOfDayId = [prefs valueForKey:@"StoryOfTheDayBookId"];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController_iPhone" bundle:nil];
        [_delegate dismissPopOver];
        
    }
    else{
        bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
        [_delegate dismissPopOver];
    }
    
    if(_isReadPage){
        
        currentPage = @"reading";
        
    }
    else{
        currentPage = @"cover_screen";
    }
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    bookDetailsViewController.delegate = self;
    NSMutableArray *tempDropDownArray = [[NSMutableArray alloc] init];
    bookDetailsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    bookDetailsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.view.window.rootViewController presentViewController:bookDetailsViewController animated:YES completion:^(void) {
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
        [tempDropDownArray addObject:[[bookDict objectForKey:@"info"] objectForKey:@"language"]];
        [tempDropDownArray addObjectsFromArray:[[bookDict objectForKey:@"available_languages"] valueForKey:@"language"]];
        [bookDetailsViewController.dropDownArrayData addObjectsFromArray:[[NSSet setWithArray:tempDropDownArray] allObjects]];
        // [bookDetailsViewController.dropDownArrayData addObject:@"Record new language"];
        
        [bookDetailsViewController.dropDownView.uiTableView reloadData];
        bookDetailsViewController.bookAvailGamesNo.text = [NSString stringWithFormat:@"Games : %@",[bookDict objectForKey:@"widget_count"]];
        
        bookDetailsViewController.ageLabel.text = [NSString stringWithFormat:@"Age : %@", [bookDict objectForKey:@"combined_age_group"]];
        
        bookDetailsViewController.gradeLevel.text = [NSString stringWithFormat:@"Grade : %@", [bookDict objectForKey:@"combined_grades"]];
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"learning_levels"] isKindOfClass:[NSNull class]]){
            bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Level : %@", [bookDict objectForKey:@"combined_reading_level"]];
        }
        else {
            bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Level : -"];
        }
        
        bookDetailsViewController.numberOfPagesLabel.text = [NSString stringWithFormat:@"No. of pages: %d", [[bookDict objectForKey:@"page_count"] intValue]];
        if([[bookDict objectForKey:@"price"] floatValue] == 0.00){
            bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"FREE"];
        //    [bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"Read-now.png"] forState:UIControlStateNormal];
        }
        else{
            bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"$ %.2f", [[bookDict objectForKey:@"price"] floatValue]];
            //[bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"buynow.png"] forState:UIControlStateNormal];
        }
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"categories"] isKindOfClass:[NSNull class]]){
            bookDetailsViewController.categoriesLabel.text = [NSString stringWithFormat:@"Categories : %@",[[[bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "]];
        }
        else{
            bookDetailsViewController.categoriesLabel.text = [NSString stringWithFormat:@"Category: -"];
        }
        
        if([storyOfDayId isEqualToString:[bookDict objectForKey:@"id"]]){
            [bookDetailsViewController.buyButton setTitle: @"Read Now" forState: UIControlStateNormal];
            bookDetailsViewController.imgStoryOfDay.hidden = NO;
        }
        
        bookDetailsViewController.descriptionLabel.text = [bookDict objectForKey:@"synopsis"];
        
        bookDetailsViewController.selectedProductId = [bookDict objectForKey:@"id"];
        bookDetailsViewController.imageUrlString = [[bookDict objectForKey:@"thumb"] stringByReplacingOccurrencesOfString:@"thumb_new" withString:@"ipad_banner"];
        bookDetailsViewController.baseNavView = currentPage;
        [bookDetailsViewController setIdOfDisplayBook:[bookDict objectForKey:@"id"]];
        
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
        //[delegate trackMixpanelEvents:dimensions eventName:@"show_book"];
        
    }];
    bookDetailsViewController.view.superview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    bookDetailsViewController.view.layer.cornerRadius = 5.0;
    bookDetailsViewController.view.superview.bounds = CGRectMake(0, 0, 776, 529);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
}

- (void)openBook:(Book *)bk {
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *identity=[NSString stringWithFormat:@"%@", bk.id];
    [appDelegate.dataModel displayAllData];
    
    
    [CoverViewControllerBetterBookType setIdentityValue:identity];
    
    
    if([[NSString stringWithFormat:@"%@", [_delegate class]] isEqualToString:@"PageNewBookTypeViewController"]){
        
       // DismissBookPageView
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissBookPageView" object:self];
        if ([self isMovingFromParentViewController])
        {
            
                self.navigationController.delegate = nil;
        }
        
        
    }
    
    else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadCoverView" object:self];
    }
    
    
     
   /*  CoverViewControllerBetterBookType *coverController;
     
     if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
     
     coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType_iPhone" bundle:nil WithId:identity];
     }
     else{
     coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType" bundle:nil WithId:identity];
     }
     
    [self.navigationController popToViewController:coverController animated:YES];*/
    

 /*   AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *identity=[NSString stringWithFormat:@"%@", bk.id];
    [appDelegate.dataModel displayAllData];
    
     CoverViewControllerBetterBookType *coverController;
     
     if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
     
     coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType_iPhone" bundle:nil WithId:identity];
     }
     else{
     coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType" bundle:nil WithId:identity];
     }
     
     [self.navigationController pushViewController:coverController animated:YES];*/
}

- (IBAction)closeDetails:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void) {
        //[_delegate openBookViewWithCategory:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:[[_categoriesLabel.text componentsSeparatedByString:@", "] firstObject]] forKey:@"categories"]];
    }];
}


#pragma mark - Get Languages

- (void)getBookDetails {
    
}

@end
