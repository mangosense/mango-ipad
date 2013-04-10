//
//  LiveViewControllerIphone.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 05/12/12.
//
//

#import "LiveViewControllerIphone.h"
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "StoreBooks.h"
#import "DetailStoreViewController.h"
#import "RecieptValidationIphone.h"
#import "DownloadViewController.h"
#import "Base64.h"
#import <QuartzCore/QuartzCore.h>
@interface LiveViewControllerIphone ()

@end

@implementation LiveViewControllerIphone

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.tabBarItem.title=@"Store";
        self.tabBarItem.image=[UIImage imageNamed:@"cart.png"];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
      NSArray *array=  [delegate.dataModel getForPage:1];

            _array=[[NSMutableArray alloc]initWithArray:array];
        _pageNumber=1;
    }
    return self;
}
-(void)requestBooksFromServer{
    [_downloadViewController refreshButton:nil];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    //http://staging.mangoreader.com/api/v1/page/:page/store_books.json
    NSString *stringUrl=[[NSString alloc]initWithFormat:@"%@page/%d/ipad_android_books.json",[defaults stringForKey:@"baseurl"],_pageNumber];
    NSLog(@"URL %@",stringUrl);
    //stringUrl=@"http://192.168.2.29:3000/api/v1/page/1/books.json";
    NSURL *url=[[NSURL alloc]initWithString:stringUrl];
  //  [stringUrl release];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   // NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
   // [connection autorelease];
    NSURLResponse *response;
    NSError *error;
    [self performSelectorOnMainThread:@selector(showActivityIndicator) withObject:nil waitUntilDone:NO];
   NSData *data= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    if (error) {
        _error=error;
    }else{
        _data=[[NSMutableData alloc]initWithData:data];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.dataModel insertStoreBooks:_data withPageNumber:1];
        NSArray *array=  [delegate.dataModel getForPage:1];
        _array=[[NSMutableArray alloc]initWithArray:array];
        [self.tableView reloadData];
    }
    [self performSelectorOnMainThread:@selector(hideActivityIndicator) withObject:nil waitUntilDone:NO];
}
-(void)showActivityIndicator{
    UIApplication *app=[UIApplication sharedApplication];
    app.networkActivityIndicatorVisible=YES;
    
}
-(void)hideActivityIndicator{
    UIApplication *app=[UIApplication sharedApplication];
    app.networkActivityIndicatorVisible=NO;
    if (_error) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[_error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{


 //   [alert release];

}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_data setLength:0];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *lengthTotal=[[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",lengthTotal);
 //   [lengthTotal release];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
   [delegate.dataModel insertStoreBooks:_data withPageNumber:1];
    NSArray *array=  [delegate.dataModel getForPage:1];

        _array=[[NSMutableArray alloc]initWithArray:array];

    [self.tableView reloadData];
    
//       _pages=_totalNumberOfBooks/20;
//    if (_totalNumberOfBooks%20!=0) {
//        _pages++;
//    }

    
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}
-(void)transactionFailed{
         [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
//    UIAlertView *alertFailed;
    NSMutableURLRequest *request;
    NSMutableDictionary *dictionary;
    NSNumber *userid;
    NSData *jsonData;
    RecieptValidationIphone *recieptValidation;
    NSString *valueJson;
    // VerificationController *verification=[[VerificationController alloc]init];
    
    UIAlertView *alertFailed;
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateFailed:
                alertFailed =[[UIAlertView alloc]initWithTitle:@"Error"message:@"Payment not performed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertFailed show];
            //    [alertFailed release];
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
                break;
            case SKPaymentTransactionStatePurchased:
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"email"]) {
                    request=[[NSMutableURLRequest alloc]init];
                    dictionary=[[NSMutableDictionary alloc]init];
                    userid=[[NSUserDefaults standardUserDefaults]objectForKey:@"id"];
                    [dictionary setValue:userid forKey:@"user_id"];
                    [dictionary setValue:[NSNumber numberWithInteger:_identity ] forKey:@"book_id"];
                    [dictionary setValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"auth_token"] forKey:@"auth_token"];
                    [dictionary setValue:_price forKey:@"amount"];
                    NSData *transactionReciept=transaction.transactionReceipt;
                    NSString *encode=[Base64 encode:transactionReciept];
                    
                    [dictionary setValue:encode forKey:@"receipt_data"];
                    jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
                    
                    valueJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
                    NSLog(@"value json request %@",valueJson);
                   // [valueJson release];
                    [request setHTTPMethod:@"POST"];
                    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:jsonData];
                    recieptValidation=[[RecieptValidationIphone alloc]initWithDetails:(DetailStoreViewController *)self.presentedViewController live:self identity:_identity withTrans:transaction];
                    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                    
                    NSString *urlString=[NSString stringWithFormat:@"%@receipt_validate",[defaults objectForKey:@"baseurl"] ];
                    //   urlString=@"http://192.168.2.29:3000/api/v1/receipt_validate";
                    NSLog(@"reciept validation %@",urlString);
                    [request setURL:[NSURL URLWithString:urlString]];
                    recieptValidation.signIn=YES;
                    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:recieptValidation];
                  //  [recieptValidation release];
                    [connection start];
                    //  [connection autorelease];
                  //  [request release];
                  //  [dictionary release];
                }else{
                    request=[[NSMutableURLRequest alloc]init];
                    dictionary=[[NSMutableDictionary alloc]init];
                    [dictionary setValue:_price forKey:@"amount"];
                    
                    NSData *transactionReciept=transaction.transactionReceipt;
                    NSString *encode=[Base64 encode:transactionReciept];
                    [dictionary setValue:encode forKey:@"receipt_data"];
                    jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
                    
                    valueJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
                    NSLog(@"value json request %@",valueJson);
                   // [valueJson release];
                    [request setHTTPMethod:@"POST"];
                    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:jsonData];
                      recieptValidation=[[RecieptValidationIphone alloc]initWithDetails:(DetailStoreViewController *)self.presentedViewController live:self identity:_identity withTrans:transaction];
                    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                    
                    NSString *urlString=[NSString stringWithFormat:@"%@receipt_validate_without_signed_in.json",[defaults objectForKey:@"baseurl"] ];
                    //   urlString=@"http://192.168.2.29:3000/api/v1/receipt_validate";
                    NSLog(@"reciept validation %@",urlString);
                    [request setURL:[NSURL URLWithString:urlString]];
                    recieptValidation.signIn=NO;
                    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:recieptValidation];
                   // [recieptValidation release];
                  //  [connection autorelease];
                  //  [request release];
                  //  [dictionary release];
                    [connection start];
                }

                //after book is purchased
               //  [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                break;
                
        }
    
    }

}
-(void)purchaseValidation:(SKPaymentTransaction *)transaction{
    
    NSMutableURLRequest *request;
    NSMutableDictionary *dictionary;
    NSNumber *userid;
    NSData *jsonData;
    RecieptValidationIphone *recieptValidation;
    NSString *valueJson;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"email"]) {
        request=[[NSMutableURLRequest alloc]init];
        dictionary=[[NSMutableDictionary alloc]init];
        userid=[[NSUserDefaults standardUserDefaults]objectForKey:@"id"];
        [dictionary setValue:userid forKey:@"user_id"];
        [dictionary setValue:[NSNumber numberWithInteger:_identity ] forKey:@"book_id"];
        [dictionary setValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"auth_token"] forKey:@"auth_token"];
        [dictionary setValue:_price forKey:@"amount"];
        NSData *transactionReciept=transaction.transactionReceipt;
        NSString *encode=[Base64 encode:transactionReciept];
        
        [dictionary setValue:encode forKey:@"receipt_data"];
        jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        
        valueJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"value json request %@",valueJson);
        // [valueJson release];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:jsonData];
        recieptValidation=[[RecieptValidationIphone alloc]initWithDetails:(DetailStoreViewController *)self.presentedViewController live:self identity:_identity withTrans:transaction];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        
        NSString *urlString=[NSString stringWithFormat:@"%@receipt_validate",[defaults objectForKey:@"baseurl"] ];
        //   urlString=@"http://192.168.2.29:3000/api/v1/receipt_validate";
        NSLog(@"reciept validation %@",urlString);
        [request setURL:[NSURL URLWithString:urlString]];
        recieptValidation.signIn=YES;
        NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:recieptValidation];
        //  [recieptValidation release];
        [connection start];
        //  [connection autorelease];
        //  [request release];
        //  [dictionary release];
    }else{
        request=[[NSMutableURLRequest alloc]init];
        dictionary=[[NSMutableDictionary alloc]init];
        [dictionary setValue:_price forKey:@"amount"];
        
        NSData *transactionReciept=transaction.transactionReceipt;
        NSString *encode=[Base64 encode:transactionReciept];
        [dictionary setValue:encode forKey:@"receipt_data"];
        jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        
        valueJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"value json request %@",valueJson);
        // [valueJson release];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:jsonData];
        recieptValidation=[[RecieptValidationIphone alloc]initWithDetails:(DetailStoreViewController *)self.presentedViewController live:self identity:_identity withTrans:transaction];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        
        NSString *urlString=[NSString stringWithFormat:@"%@receipt_validate_without_signed_in.json",[defaults objectForKey:@"baseurl"] ];
        //   urlString=@"http://192.168.2.29:3000/api/v1/receipt_validate";
        NSLog(@"reciept validation %@",urlString);
        [request setURL:[NSURL URLWithString:urlString]];
        recieptValidation.signIn=NO;
        NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:recieptValidation];
        // [recieptValidation release];
        //  [connection autorelease];
        //  [request release];
        //  [dictionary release];
        [connection start];
    }

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *rightRefresh=[[UIBarButtonItem alloc]initWithTitle:@"Refresh" style:UIBarButtonItemStyleBordered target:self action:@selector(refreshButton:)];
    rightRefresh.tintColor=[UIColor grayColor];
    self.navigationItem.rightBarButtonItem=rightRefresh;
 //   [rightRefresh release];
        self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mangoreader-logo.png"]];
    self.navigationItem.titleView=imageView;

 
}
-(void)refreshButton:(id)sender{
    [self performSelectorInBackground:@selector(requestBooksFromServer) withObject:nil];

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
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 180;
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
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
 
    }
    
    // Configure the cell...
    StoreBooks *storeBooks=[_array objectAtIndex:indexPath.row];

    cell.imageView.image=[[UIImage alloc]initWithContentsOfFile:storeBooks.localImage];

    cell.textLabel.text=storeBooks.title;

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
    StoreBooks *book=[_array objectAtIndex:indexPath.row];
    
    NSNumber *iden=book.productIdentity;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
  
    if ([delegate.dataModel checkIfIdExists:iden]) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Book purchased" message:@"You have already purchased the book" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
      //  [alertView release];
        return;
    }
      delegate.PortraitOrientation=NO;
    _identity=iden.integerValue;
    DetailStoreViewController *detailStore=[[DetailStoreViewController alloc]initWithNibName:@"DetailStoreViewController" bundle:nil with:iden.integerValue];
    detailStore.live=self;
   // detailStore.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:detailStore animated:YES completion:nil];
   // [self.navigationController pushViewController:detailStore animated:YES];
  //  [detailStore release];
    //[self.tabBarController.tabBar setHidden:YES];

    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    [self.tabBarController.tabBar setHidden:NO];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *array=  [delegate.dataModel getForPage:1];
    if (array.count==0) {
        [self refreshButton:nil];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSNumber *identity=[[NSNumber alloc]initWithInteger:_identity];
    StoreBooks *books=[delegate.dataModel getBookById:identity];
    
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    if (buttonIndex==1) {// if yes is the case
        if (_myBooks.downloadBook) {
            UIAlertView *down=[[UIAlertView alloc]initWithTitle:@"Downloading.." message:@"Cannot start downloading as previous download is not complete" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [down show];
        //    [down release];
            [delegate.dataModel insertBookWithNo:books ];
        }else{
            [delegate.dataModel insertBookWithYes:books];
            [_myBooks downloadComplete:_identity];
        }
        
    }else{// for no case
        [delegate.dataModel insertBookWithNo:books];
            UINavigationController *nav=self.tabBarController.viewControllers[1];
        DownloadViewController *download=(DownloadViewController *)nav.topViewController;
        [delegate.dataModel insertBookWithNo:books ];
        [download getPurchasedDataFromDataBase];     
    }
  //  [identity release];
}
/*-(void)dealloc{
    _array=nil;
    _data=nil;
    _price=nil;
    [super dealloc];
}*/
@end
