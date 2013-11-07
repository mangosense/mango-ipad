//
//  NewStoreViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 05/11/13.
//
//

#import "NewStoreViewControlleriPhone.h"
#import "DataSourceForLinear.h"
#import "AFTableViewCell.h"
#import "CategoryViewController.h"
@interface NewStoreViewControlleriPhone ()
@end

@implementation NewStoreViewControlleriPhone

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.tabBarItem.title=@"Store";
        self.tabBarItem.image=[UIImage imageNamed:@"cart.png"];
        _linear=[[DataSourceForLinear alloc]initWithString:@"No"];
        _oldLinear=[[DataSourceForLinearOld alloc]initWithString:@"OLD"];
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
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Category" style:UIBarButtonItemStyleBordered target:self action:@selector(showCategoryChoice)];
    self.tabBarController.tabBar.hidden=YES;
}
-(void)libraryView:(id) sender{
    self.tabBarController.tabBar.hidden=NO;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.75];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:YES];
    [UIView commitAnimations];
    [self.navigationController popViewControllerAnimated:NO];

}
-(void)showCategoryChoice{
    CategoryViewController *viewController=[[CategoryViewController alloc]initWithStyle:UITableViewStylePlain];
    viewController.delegate=self;
    [self presentViewController:viewController animated:YES completion:nil];
}
/*-(void)loadView{
    const NSInteger numberOfTableViewRows = 20;
    const NSInteger numberOfCollectionViewCells = 15;
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:numberOfTableViewRows];
    
    for (NSInteger tableViewRow = 0; tableViewRow < numberOfTableViewRows; tableViewRow++)
    {
        NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:numberOfCollectionViewCells];
        
        for (NSInteger collectionViewItem = 0; collectionViewItem < numberOfCollectionViewCells; collectionViewItem++)
        {
            
            CGFloat red = arc4random() % 255;
            CGFloat green = arc4random() % 255;
            CGFloat blue = arc4random() % 255;
            UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0f];
            
            [colorArray addObject:color];
        }
        
        [mutableArray addObject:colorArray];
    }
    
    self.colorArray = [NSArray arrayWithArray:mutableArray];
    
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];

}*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)chosenCategory:(NSString *)category{
    
    self.navigationController.title=category;
    self.label.text=category;
    
}
#pragma mark - Table view data source
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    view.autoresizingMask= UIViewAutoresizingFlexibleWidth;
    //   view.backgroundColor=[UIColor blueColor];
    view.backgroundColor=[UIColor grayColor];
    UIButton *anotherButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    [anotherButton setTitle:@"Library" forState:UIControlStateNormal];
    [anotherButton addTarget:self action:@selector(libraryView:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:anotherButton];
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-150, 5, 150, 100)];
    [button setTitle:@"Category" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showCategoryChoice) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    _label=[[UILabel alloc]initWithFrame:CGRectMake(300, 0, 300, 100)];
    [view addSubview:_label];
    _label.text=@"All";
    switch (section) {
        case 0:
            NSLog(@"Section 0");
            break;
            
        default:
            break;
    }
    return view;
}
-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 100;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}
-(float)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    AFTableViewCell *cell = (AFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[AFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
       return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(AFTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([UIDevice currentDevice].systemVersion.integerValue<7) {
        [cell setCollectionViewOldDataSourceDelegate:_oldLinear Delegate:nil index:indexPath.row];
    }else{
    [cell setCollectionViewDataSourceDelegate:_linear Delegate:nil index:indexPath.row];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
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

@end
