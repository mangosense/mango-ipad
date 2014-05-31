//
//  AudioRecordingsListViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 11/11/13.
//
//

#import "AePubReaderAppDelegate.h"
#import "ItemsListViewController.h"
#import "AudioRecord.h"
#import "MBProgressHUD.h"

@interface ItemsListViewController ()

@end

@implementation ItemsListViewController

@synthesize itemsListArray;
@synthesize tableType;
@synthesize delegate;

int menuLanguage = 0;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;
        userDeviceID = delegate.deviceId;
        // Custom initialization
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            self.tableView.contentInset = UIEdgeInsetsMake(-37, 0, -37, 0);
            if ([self respondsToSelector:@selector(setPreferredContentSize:)]) {
                self.preferredContentSize = CGSizeMake(150, 110);
            } else {
                self.contentSizeForViewInPopover = CGSizeMake(150, 110);
            }
        }
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        cellSize = 30;
        fontSize = 14;
    }
    else{
        cellSize = 44;
        fontSize = 24;
    }
    viewName =@"Store Page";
    storeBooksType = [[NSArray alloc] initWithObjects:@"Categories", @"Age_Group", @"Languages", @"Grade", nil];
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
    return [itemsListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexpath %d", indexPath.row);
    static NSString *CellIdentifier = @"Cell";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.numberOfLines = 100;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        cell.textLabel.font = [UIFont systemFontOfSize:12];
    }
    switch (tableType) {
        case TABLE_TYPE_AUDIO_RECORDINGS: {
            AudioRecord *audioRecord = [itemsListArray objectAtIndex:indexPath.row];
            cell.textLabel.text = audioRecord.audioName;
        }
            break;
            
        case TABLE_TYPE_TEXT_TEMPLATES: {
            cell.textLabel.text = [itemsListArray objectAtIndex:indexPath.row];
        }
            break;
            
        case TABLE_TYPE_LANGUAGE: {
            cell.textLabel.text = [itemsListArray objectAtIndex:indexPath.row];
        }
            break;
            
        default: {
            cell.textLabel.text = [[itemsListArray objectAtIndex:indexPath.row] objectForKey:NAME];
        }
            break;
    }
    
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

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (tableType) {
        case TABLE_TYPE_AUDIO_RECORDINGS:
            
            break;
            
        case TABLE_TYPE_TEXT_TEMPLATES: {
            return MAX(cellSize, [[itemsListArray objectAtIndex:indexPath.row] sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(250, 100) lineBreakMode:NSLineBreakByWordWrapping].height);
        }
            break;
            
        case TABLE_TYPE_LANGUAGE: {
            return MAX(cellSize, [[itemsListArray objectAtIndex:indexPath.row] sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(250, 10000) lineBreakMode:NSLineBreakByWordWrapping].height);
        }
            break;
            
        default: {
            return MAX(cellSize, [[[itemsListArray objectAtIndex:indexPath.row] objectForKey:NAME] sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(250, 10000) lineBreakMode:NSLineBreakByWordWrapping].height);
        }
            break;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *detail;
    NSMutableDictionary *detailsDict = [NSMutableDictionary dictionary];
    
    
    switch (self.tableType) {
        case TABLE_TYPE_TEXT_TEMPLATES: {
            [delegate itemType:self.tableType tappedAtIndex:indexPath.row withDetail:nil];
            return;
        }
            break;

        case TABLE_TYPE_CATEGORIES:
        case TABLE_TYPE_AGE_GROUPS:
        case TABLE_TYPE_GRADE: {
            detail = [[itemsListArray objectAtIndex:indexPath.row] objectForKey:@"id"];
            [detailsDict setObject:detail forKey:@"id"];
            detail = [[itemsListArray objectAtIndex:indexPath.row] objectForKey:NAME];
            [detailsDict setObject:detail forKey:@"title"];
            break;
        }

        case TABLE_TYPE_LANGUAGE: {
            [detailsDict setObject:[itemsListArray objectAtIndex:indexPath.row] forKey:@"id"];
            [detailsDict setObject:[itemsListArray objectAtIndex:indexPath.row] forKey:@"title"];
        }
            break;

        default:
            break;
    }
    NSLog(@"TableType: %d", self.tableType);
    AePubReaderAppDelegate *delegate1=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_GROUP: [detailsDict valueForKey:@"title"]
                                 };
    [delegate1 trackEvent:[STORE_FILTER valueForKey:@"description"]  dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[STORE_FILTER valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [STORE_FILTER valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate1.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate1.country forKey:@"deviceCountry"];
    [userObject setObject:delegate1.language forKey:@"deviceLanguage"];
    [userObject setObject:[detailsDict valueForKey:@"title"] forKey:@"storeFilter"];
    [userObject setObject:[storeBooksType objectAtIndex: _filterTag-1] forKey:@"storeBookGroup"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    [delegate itemType:self.tableType tappedWithDetail:detailsDict];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        [self dismissViewControllerAnimated:self.view completion:nil];
    }
}

#pragma mark - Setters

- (void)setTableType:(int)tableTypeForList {
    tableType = tableTypeForList;
    [self getListData];
}

#pragma mark - Post API Delegate

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if(menuLanguage){
        itemsListArray = [[NSMutableArray alloc] init];
        NSMutableArray *tempItemArray = [NSMutableArray arrayWithArray:dataArray];
    
        //  itemsListArray = [NSMutableArray arrayWithArray:dataArray];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"count" ascending:FALSE];
        [tempItemArray sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        for(int i =0 ; i<tempItemArray.count; ++i){
        [itemsListArray addObject:[tempItemArray[i] valueForKey:@"_id"]];
        }
    }
    else{
        itemsListArray = [NSMutableArray arrayWithArray:dataArray];
    }
    [self.tableView reloadData];
}

#pragma mark - Get Data API

- (void)getListData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    menuLanguage = 0;
    MangoApiController *apiController = [MangoApiController sharedApiController];
    
    switch (tableType) {
        case TABLE_TYPE_CATEGORIES:
            [apiController getListOf:CATEGORIES ForParameters:nil withDelegate:self];
            break;
            
        case TABLE_TYPE_AGE_GROUPS:
            [apiController getListOf:AGE_GROUPS ForParameters:nil withDelegate:self];
            break;
            
        case TABLE_TYPE_LANGUAGE:
            [apiController getListOf:LANGUAGES ForParameters:nil withDelegate:self];
            menuLanguage = 1;
            break;
            
        case TABLE_TYPE_GRADE:
            [apiController getListOf:GRADES ForParameters:nil withDelegate:self];
            break;
            
        default:
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            break;
    }
}

@end
