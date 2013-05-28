//
//  DownloadViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 03/12/12.
//
//

#import "DownloadViewController.h"
#import "Book.h"
#import "ListOfPurchasedBooks.h"
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "DetailViewController.h"
#import "SyncIpadConnection.h"
#import <QuartzCore/QuartzCore.h>
#import "Flurry.h"
@interface DownloadViewController ()

@end

@implementation DownloadViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.tabBarItem.title=@"Downloads";
        self.tabBarItem.image=[UIImage imageNamed:@"purchased.png"];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate*)[UIApplication sharedApplication].delegate;
        NSArray *array=[delegate.dataModel getDataNotDownloaded];
        if (array.count==0) {
           [self requestBooksFromServerinit];  
        }
        else{
            _array=[[NSMutableArray alloc]initWithArray:array];
        }



    }
    return self;
}
-(void)requestBooksFromServer{
    
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {//yes
        [self.parentViewController.navigationController popToRootViewControllerAnimated:YES];
        
    }else{
        
        [self.tabBarController setSelectedIndex:0];
    }
}
-(void)refreshButton:(id)sender{
    [self performSelectorInBackground:@selector(requestBooksFromServerinit) withObject:nil];
   
}
-(void)requestBooksFromServerinit{
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"email"]) {
        [self getPurchasedDataFromDataBase];
        return;
    }    
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    NSString *temp;
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    temp=[userDefaults stringForKey:@"email"];
    [dictionary setValue:temp forKey:@"email"];
    temp=[userDefaults stringForKey:@"auth_token"];
    [dictionary setValue:temp forKey:@"auth_token"];
  //  NSLog(@"auth_token %@",temp);
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *connectionString=[userDefaults objectForKey:@"baseurl"];
    connectionString=[connectionString stringByAppendingFormat:@"book_purchase"];
    connectionString=[connectionString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
 //   NSLog(@"Connection String %@",connectionString);
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:connectionString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    //  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    ListOfPurchasedBooks *books=[[ListOfPurchasedBooks alloc]initWithViewController:self];
    books.shouldBuild=YES;
    _connection=[[NSURLConnection alloc]initWithRequest:request delegate:books];
    NSURLResponse *response;
    NSError *error;
    [self performSelectorOnMainThread:@selector(showIndicator) withObject:nil waitUntilDone:NO];
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        _error=error;
    }else{
        id dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
      //  NSLog(@"dict %@",[dict class]);
        
        if ([[dict class] isSubclassOfClass:[NSDictionary class]]) {
            if ([dict objectForKey:@"error"]) {
                  [self performSelectorOnMainThread:@selector(sessionExpired) withObject:nil waitUntilDone:NO];
            }
          
        }else{
        NSMutableData *dataToInsert=[[NSMutableData alloc]initWithData:data];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate.dataModel insertIfNew:dataToInsert];
        }

    }
    [self performSelectorOnMainThread:@selector(hideIndicator) withObject:nil waitUntilDone:NO];
    _purchase=YES;

    
}
-(void)sessionExpired{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Session expired" message:@"The session is expired. Please signout and sign in again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}
-(void)showIndicator{
    UIApplication *app=[UIApplication sharedApplication];
    app.networkActivityIndicatorVisible=YES;
}
-(void)hideIndicator{
    UIApplication *app=[UIApplication sharedApplication];
    app.networkActivityIndicatorVisible=NO;
    if (_error) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[_error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    }
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate*)[UIApplication sharedApplication].delegate;
    NSArray *array=[delegate.dataModel getDataNotDownloaded];
    _array=[[NSMutableArray alloc]initWithArray:array];
    [self.tableView reloadData];
}
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
  //  [_alert dismissWithClickedButtonIndex:0 animated:YES];
    
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message: @"Cannot connect to iTunes store" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
  //  [alertView release];
  //  _alert=nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"email"]) {
           self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:self action:@selector(signOut:)]; 
    }else{
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Sign Out" style:UIBarButtonItemStyleBordered target:self action:@selector(signOut:)];
    }
    self.navigationItem.rightBarButtonItem.tintColor=[UIColor grayColor];
    UIBarButtonItem *refresh=[[UIBarButtonItem alloc]initWithTitle:@"Refresh" style:UIBarButtonItemStyleBordered target:self action:@selector(refreshButton:)];
    UIBarButtonItem *restore=[[UIBarButtonItem alloc]initWithTitle:@"Restore" style:UIBarButtonItemStyleBordered target:self action:@selector(restore:)];
    restore.tintColor=[UIColor grayColor];
    UIBarButtonItem *syncing=[[UIBarButtonItem alloc]initWithTitle:@"Sync" style:UIBarButtonItemStyleBordered target:self action:@selector(sync:)];
    syncing.tintColor=[UIColor grayColor];
    NSArray *array=[NSArray arrayWithObjects:refresh,restore,syncing, nil];
  //  [restore release];
  //  [syncing release];
    self.navigationItem.leftBarButtonItems=array;
 
    
    self.navigationItem.leftBarButtonItem.tintColor=[UIColor grayColor];
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mangoreader-logo.png"]];
    self.navigationItem.titleView=imageView;
 //   [imageView release];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)restore:(id)sender{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.completedStorePopulation) {
        [self showIndicator];
        [[SKPaymentQueue defaultQueue]addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please wait till the information for books in the store are retrived" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}
-(void)sync:(id)sender{
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"email"]) {
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Login" message:@"Do you wish to sign in or sign up to sync your books" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                [alertView show];
              //  [alertView release];
    }else{
        //send the webservice
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc]init];
        NSString *url=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
        url =[url stringByAppendingString:@"apple_register_users_books.json"];
        [request setURL:[NSURL URLWithString:url ]];
        SyncIpadConnection *syncIpad=[[SyncIpadConnection alloc]init];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        NSArray *stor=[[NSArray alloc]initWithArray:[delegate.dataModel getStoreBooksPurchased]];
        NSMutableDictionary *diction=[[NSMutableDictionary alloc]init];
        NSMutableArray *arryMutable=[[NSMutableArray alloc]init];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *number=[defaults objectForKey:@"id"];
        [diction setValue:number forKey:@"user_id"];
        NSString *auth_token=[defaults objectForKey:@"auth_token"];
        [diction setValue:auth_token forKey:@"auth_token"];
        
        for (StoreBooks *books in stor) {
            NSNumber *bookId=books.productIdentity;
            NSNumber *amount=books.amount;
            NSArray *array=[[NSArray alloc ]initWithObjects:bookId,amount, nil];
            [arryMutable addObject:array];
         //   [array release];
            
        }
        [diction setValue:arryMutable forKey:@"books"];
        NSData *json=[NSJSONSerialization dataWithJSONObject:diction options:NSJSONWritingPrettyPrinted error:nil];
      //  NSString *string=[[NSString alloc]initWithData:json encoding:NSUTF8StringEncoding];
     //   NSLog(@"%@",string);
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:json];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:syncIpad];
        [connection start];
     /*   [syncIpad release];
        [request release];
        [connection autorelease];
        [arryMutable release];
        [diction release];
        [string release];
        [stor release];*/
    }
    
}
-(void)transactionFailed{
    [self hideIndicator];
}
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    //    UIAlertView *alertFailed;
    StoreBooks *books;
    NSNumber *number;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
      for (SKPaymentTransaction *transaction in transactions) {
          switch (transaction.transactionState) {
              case SKPaymentTransactionStateFailed:
                  
                  break;
              case SKPaymentTransactionStatePurchased:
                  
                  break;
              case SKPaymentTransactionStateRestored:
                  number=[[NSNumber alloc]initWithInteger:transaction.payment.productIdentifier.integerValue];
                 books= [delegate.dataModel getBookById:number];
                  [delegate.dataModel insertBookWithNo:books];
                //  [number release];
              
                  [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                  break;
          }
 

    }
  //  [[SKPaymentQueue defaultQueue]removeTransactionObserver:self];
    [self getPurchasedDataFromDataBase];
    [self hideIndicator];
  //  [_alert dismissWithClickedButtonIndex:0 animated:YES];
   // request from server
    //reload data
    
}
-(void)transactionRestored{
    [self getPurchasedDataFromDataBase];
    [self hideIndicator];
    
}
- (void)signOut:(id)sender {
    NSString *signout=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
    signout =[signout stringByAppendingPathComponent:@"users/sign_out"];
    signout =[signout stringByAppendingFormat:@"?user[email]=%@&auth_token=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"],[[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"]];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:signout]];
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];

    [connection start];
    [self.parentViewController.navigationController popToRootViewControllerAnimated:YES];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"email"];
   
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
-(void)getPurchasedDataFromDataBase{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *notDownloaded=[delegate.dataModel getDataNotDownloaded];
    //_array=nil;
    _array=[[NSMutableArray alloc]initWithArray:notDownloaded];
    [self.tableView reloadData];
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 180;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
     [self.tabBarController.tabBar setHidden:NO];
      self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    if (_myBook.deleted) {
        [self getPurchasedDataFromDataBase];
        _myBook.deleted=NO;
    }
    [Flurry logEvent:@"Download entered iphone "];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];

    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [Flurry logEvent:@"Download exited iphone "];

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    NSString *ver= [UIDevice currentDevice].systemVersion;
    if ([ver floatValue]>=6.0) {
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    else{
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }   
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
      //  [cell autorelease];
    }
    
    // Configure the cell...
    Book *book=[_array objectAtIndex:indexPath.row];
    cell.imageView.image=[[UIImage alloc]initWithContentsOfFile:book.localPathImageFile];
    
    

    cell.textLabel.text=book.title;
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
   Book *book= [_array objectAtIndex:indexPath.row];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.PortraitOrientation=NO;
    DetailViewController *detail=[[DetailViewController alloc]initWithNibName:@"DetailViewController" bundle:nil];
    detail.booksMy=_myBook;
    detail.identity=[book.id integerValue];
    [self.tabBarController.tabBar setHidden:YES];
    [self presentModalViewController:detail animated:YES];
 }
-(uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}
@end
