//
//  DownloadViewControlleriPhone.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 07/11/13.
//
//

#import "DownloadViewControlleriPhone.h"
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "SyncIpadConnection.h"
#import "ListOfPurchasedBooks.h"
#import "NewStoreViewControlleriPhone.h"
@interface DownloadViewControlleriPhone ()

@end

@implementation DownloadViewControlleriPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
            if (dict[@"error"]) {
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden=YES;
    // Do any additional setup after loading the view from its nib.
}
-(void)transactionFailed{
    [self hideIndicator];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)showIndicator{
    UIApplication *app=[UIApplication sharedApplication];
    app.networkActivityIndicatorVisible=YES;
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 180;
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

- (IBAction)library:(id)sender {
 /*   NewStoreViewControlleriPhone *storeNew=[[NewStoreViewControlleriPhone alloc]initWithStyle:UITableViewStylePlain];
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:0.80];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                           forView:self.navigationController.view cache:NO];
    
    [self.navigationController pushViewController:storeNew animated:YES];
    [UIView commitAnimations];*/
    [self.tabBarController setSelectedIndex:0];

}
- (IBAction)refresh:(id)sender {
      [self performSelectorInBackground:@selector(requestBooksFromServerinit) withObject:nil];
}

- (IBAction)restore:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.completedStorePopulation) {
        [self showIndicator];
      //  [[SKPaymentQueue defaultQueue]addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please wait till the information for books in the store are retrived" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

- (IBAction)signout:(id)sender {
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
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message: @"Cannot connect to iTunes store" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    
}
- (IBAction)sync:(id)sender {
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
            NSArray *array=@[bookId,amount];
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
-(void)getPurchasedDataFromDataBase{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *notDownloaded=[delegate.dataModel getDataNotDownloaded];
    //_array=nil;
    _array=[[NSMutableArray alloc]initWithArray:notDownloaded];
    [self.tableView reloadData];
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
    }
    
    // Configure the cell...
    Book *book=_array[indexPath.row];
    cell.imageView.image=[[UIImage alloc]initWithContentsOfFile:book.localPathImageFile];
    
    
    
    cell.textLabel.text=book.title;
    return cell;
}
-(void)transactionRestored{
    [self getPurchasedDataFromDataBase];
    [self hideIndicator];
    
}
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
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
                number=@(transaction.payment.productIdentifier.integerValue);
                books= [delegate.dataModel getBookById:number];
                [delegate.dataModel insertBookWithNo:books];
                //  [number release];
                
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                break;
        }
        
        
    }
    [self getPurchasedDataFromDataBase];
    [self hideIndicator];
    
    
}
@end
