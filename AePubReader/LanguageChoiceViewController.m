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

@interface LanguageChoiceViewController ()

@end

@implementation LanguageChoiceViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;
        userDeviceID = delegate.deviceId;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!userEmail){
        ID = userDeviceID;
    }
    else{
        ID = userEmail;
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    NSDictionary *EVENT;
    
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_LANGUAGE : _language,
                                 PARAMETER_BOOK_ID : [dataArray[0] valueForKey:@"id"],
                                 PARAMETER_BOOK_NEW_LANGUAGE_SELECT : newLanguage
                                 };
    
    if(_isReadPage){
        
        EVENT = READBOOK_CHANGE_LANGUAGE;
        [PFAnalytics trackEvent:[EVENT valueForKey:@"description"] dimensions:dimensions];
        [userObject setObject:@"Book Read View" forKey:@"viewName"];
        
    }
    else{
        
        EVENT = BOOKCOVER_NEW_LANGUAGE;
        [delegate trackEvent:[EVENT valueForKey:@"description"] dimensions:dimensions];
        [userObject setObject:@"Book cover view" forKey:@"viewName"];
    }
    
    [userObject setObject:[EVENT valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [EVENT valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:[dataArray[0] valueForKey:@"id"] forKey:@"bookID"];
    [userObject setObject:_language forKey:@"bookLanguage"];
    [userObject setObject:newLanguage forKey:@"bookNewLanguageSelect"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    NSLog(@"My array is %@", dataArray);
    NSMutableArray *tempItemArray = [[NSMutableArray alloc] init];
    tempItemArray = [NSMutableArray arrayWithArray:dataArray];
    [self showBookDetailsForBook:tempItemArray[0]];
}

- (void)showBookDetailsForBook:(NSDictionary *)bookDict {
    BookDetailsViewController *bookDetailsViewController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController_iPhone" bundle:nil];
        [_delegate dismissPopOver];
        
    }
    else{
        bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
        [_delegate dismissPopOver];
    }
    
    bookDetailsViewController.delegate = self;
    NSMutableArray *tempDropDownArray = [[NSMutableArray alloc] init];
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
        [tempDropDownArray addObject:[[bookDict objectForKey:@"info"] objectForKey:@"language"]];
        [tempDropDownArray addObjectsFromArray:[[bookDict objectForKey:@"available_languages"] valueForKey:@"language"]];
        [bookDetailsViewController.dropDownArrayData addObjectsFromArray:[[NSSet setWithArray:tempDropDownArray] allObjects]];
        // [bookDetailsViewController.dropDownArrayData addObject:@"Record new language"];
        
        [bookDetailsViewController.dropDownView.uiTableView reloadData];
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
            [bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"Read-now.png"] forState:UIControlStateNormal];
        }
        else{
            bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"$ %.2f", [[bookDict objectForKey:@"price"] floatValue]];
            [bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"buynow.png"] forState:UIControlStateNormal];
        }
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"categories"] isKindOfClass:[NSNull class]]){
            bookDetailsViewController.categoriesLabel.text = [[[bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "];
        }
        else{
            bookDetailsViewController.categoriesLabel.text = [NSString stringWithFormat:@"Category: -"];
        }
        
        bookDetailsViewController.descriptionLabel.text = [bookDict objectForKey:@"synopsis"];
        
        bookDetailsViewController.selectedProductId = [bookDict objectForKey:@"id"];
        bookDetailsViewController.imageUrlString = [[ASSET_BASE_URL stringByAppendingString:[bookDict objectForKey:@"cover"]] stringByReplacingOccurrencesOfString:@"cover_" withString:@"banner_"];
        
        [bookDetailsViewController setIdOfDisplayBook:[bookDict objectForKey:@"id"]];
    }];
    bookDetailsViewController.view.superview.frame = CGRectMake(([UIScreen mainScreen].applicationFrame.size.width/2)-400, ([UIScreen mainScreen].applicationFrame.size.height/2)-270, 776, 575);
    
}

#pragma mark - Get Languages

- (void)getBookDetails {
    
}

@end
