//
//  LanguageChoiceViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/13.
//
//

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

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    [_delegate dismissPopOver];
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
        bookDetailsViewController.imageUrlString = [ASSET_BASE_URL stringByAppendingString:[_bookDict objectForKey:@"cover"]];
    }];
    bookDetailsViewController.view.superview.frame = CGRectMake(([UIScreen mainScreen].applicationFrame.size.width/2)-400, ([UIScreen mainScreen].applicationFrame.size.height/2)-270, 800, 540);
}

#pragma mark - Get Languages

- (void)getBookDetails {
    
}

@end
