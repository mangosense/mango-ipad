//
//  NewStoreControlleriPhone.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 07/11/13.
//
//

#import "NewStoreControlleriPhone.h"
#import "CategoryViewController.h"
#import "AFTableViewCell.h"
@interface NewStoreControlleriPhone ()

@end

@implementation NewStoreControlleriPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backToLibrary:(id)sender {
    self.tabBarController.tabBar.hidden=YES;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.75];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:YES];
    [UIView commitAnimations];
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)category:(id)sender {
    CategoryViewController *viewController=[[CategoryViewController alloc]initWithStyle:UITableViewStylePlain];
    viewController.delegate=self;
    [self presentViewController:viewController animated:YES completion:nil];
}
-(void)chosenCategory:(NSString *)category{
    
    self.titleLabel.text=category;
    
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
@end
