//
//  AePubReaderAppDelegate.m
//  AePubReader
//
//  Created by Federico Frappi on 04/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AePubReaderAppDelegate.h"

#import "Book.h"
#import "CustomNavViewController.h"
#import "Flurry.h"
#include <sys/xattr.h>
#import "ZipArchive.h"
#import "Base64.h"
@implementation AePubReaderAppDelegate
static UIAlertView *alertViewLoading;

@synthesize window;
@synthesize managedObjectContext,managedObjectModel,persistentStoreCoordinator;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    _LandscapeOrientation=YES;
    _PortraitOrientation=YES;
   _dataModel=[[DataModelControl alloc]initWithContext:[self managedObjectContext]];
 //   NSLog(@"bundle identifier %@",[[NSBundle mainBundle]bundleIdentifier]);
    _wasFirstInPortrait=NO;
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"baseurl"]) {
        
         [userDefaults setObject:@"http://www.mangoreader.com/api/v1/" forKey:@"baseurl"];
    }
    [userDefaults setBool:NO forKey:@"changed"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSString *string=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *destPath;/*=@"780.jpg";*/
    NSString *insPath;/* = @"780.jpg";*/
    NSString *srcPath; /*= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:insPath];
    destPath=[string stringByAppendingPathComponent:destPath];*/
    //  NSLog(@"src path %@ des path %@",srcPath,temp);
    NSError *error=nil;
    NSString *recording=[string stringByAppendingPathComponent:@"recording"];
    [userDefaults setObject:recording forKey:@"recordingDirectory"];
    
    NSNumber *moonCapId;


    destPath=@"49.jpg";
    insPath=@"49.jpg";
    srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:insPath];
    destPath=[string stringByAppendingPathComponent:destPath];
    if (![fileManager fileExistsAtPath:destPath]) {
        [fileManager copyItemAtPath:srcPath toPath:destPath error:&error];
        
        if (error) {
            NSLog(@"error %@",[error description]);
        }else{
            NSURL *url=[[NSURL alloc]initFileURLWithPath:destPath];
            [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
           // [url release];
        }
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
        
        self.window.clipsToBounds =YES;
        
        //self.window.frame =  CGRectMake(20,0,self.window.frame.size.width,self.window.frame.size.height-20);
        
      //  //added on 19th Sep
    //    self.window.bounds = CGRectMake(20, 20, self.window.frame.size.width, self.window.frame.size.height);
    }

    moonCapId=@49;
    
    if(![_dataModel checkIfIdExists:moonCapId]){
        Book *book= [_dataModel getBookInstance];
        book.title=@"Moon and the Cap";
        book.desc=@"Do you like to wear a cap on a sunny day? Find out who else likes to wear a cap in this charming english book.The Moon and The Cap was originally published as part of the Read India project by Pratham Books. This book is written and narrated in multiple different languages including Hindi & English. Read this book to your kid and see their eyes light up! If you're not a kid then this book will take you back in days when life was simple and small simple gifts made us excited with joy. Tap/click on characters and objects and you will discover new things. <br/> <br/><br /><br /> <br/><strong> <br/>Age Group <br/></strong> 2 - 6 <br/><br /><br /> <br/><strong>Grade</strong> <br/>NUR <br/><br /><br /> <br/><strong>Includes:</strong> Interactive audio with highlighting, puzzle game, word game, memory game <br/>";
        book.link=@"http://www.mangoreader.com/books/49";
        book.imageUrl=@"http://www.mangoreader.com/49/cover_image/download";
        book.sourceFileUrl=@"http://www.mangoreader.com/book/49/download";
        book.localPathImageFile=destPath;
        book.id=@49;
        book.size=@7631651;
        book.date=[NSDate date];
        book.textBook=@1;
        book.downloadedDate=[NSDate date];
        book.downloaded=@NO;
        NSError *error=nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"%@",error);
        }
        
    }

    
    NSURL *url=[NSURL fileURLWithPath:destPath];
    
    id Flag=nil;
    [url getResourceValue:&Flag forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (Flag) {
        NSNumber *flag=(NSNumber *)Flag;
        NSLog(flag.boolValue ? @"Yes" : @"No");
        NSLog(@"%@",Flag);
    }

    destPath=@"445.jpg";
    destPath=[string stringByAppendingPathComponent:destPath];
    insPath = @"445.jpg";
    srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:insPath];
    // NSLog(@"src path %@ des path %@",srcPath,temp);
    if (![fileManager fileExistsAtPath:destPath]) {
        [fileManager copyItemAtPath:srcPath  toPath:destPath error:nil];
        if (error) {
            NSLog(@"error %@",[error description]);
        }else{
            NSURL *url=[[NSURL alloc]initFileURLWithPath:destPath];
            //NSURLIsExcludedFromBackupKey
            [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
           // [url release];
        }
    }
      NSNumber *vayuTheWind=@445;
    if (![_dataModel checkIfIdExists:vayuTheWind]) {
        Book *book= [_dataModel getBookInstance];
        book.title=@"Vayu the Wind";
        book.desc=@"Vayu, The Wind  written by Madhuri Pai and published by Pratham Books is intended for kids  from the ages of 3-6yrs. The book is a  great way to teach the kids about wind and its effects. Even though we can\r\nsee it, the wind plays an integral part in our lives and what better way to learn about it than this. So lets learn about the wind from a kid's perspective. And play game when hover over the game image.";
        book.link=@"http://www.mangoreader.com/books/445";
        book.imageUrl=@"http://www.mangoreader.com/445/cover_image/download";
        book.sourceFileUrl=@"http://www.mangoreader.com/book/445/download";
        book.localPathImageFile=destPath;
        book.id=@445;
        book.size=@26171226;
        book.date=[NSDate date];
        book.downloadedDate=[NSDate date];
        book.downloaded=@NO;
        book.textBook=@1;
        //book.downloaded=[NSNumber numberWithBool:NO];
        NSError *error=nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"%@",error);
        }
        
        
    }

    destPath=@"1094.jpg";
    destPath=[string stringByAppendingPathComponent:destPath];
    insPath = @"1094.jpg";
    srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:insPath];
    // NSLog(@"src path %@ des path %@",srcPath,temp);
    if (![fileManager fileExistsAtPath:destPath]) {
        [fileManager copyItemAtPath:srcPath  toPath:destPath error:nil];
        if (error) {
            NSLog(@"error %@",[error description]);
        }else{
            NSURL *url=[[NSURL alloc]initFileURLWithPath:destPath];
            //NSURLIsExcludedFromBackupKey
            [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
            // [url release];
        }
    }
    NSNumber *azzura=@1094;
    if (![_dataModel checkIfIdExists:azzura]) {
        Book *book= [_dataModel getBookInstance];
        book.title=@"Azzura";
        book.desc=@"Azzura";
        book.link=@"http://www.mangoreader.com/books/1094";
        book.imageUrl=@"http://www.mangoreader.com/1094/cover_image/download";
        book.sourceFileUrl=@"http://www.mangoreader.com/book/1094/download";
        book.localPathImageFile=destPath;
        book.id=@1094;
        book.size=@26171226;
        book.date=[NSDate date];
        book.downloadedDate=[NSDate date];
        book.downloaded=@YES;
        book.textBook=@1;
        
        //book.downloaded=[NSNumber numberWithBool:NO];
        NSError *error=nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"%@",error);
        }
        
    }else{
        Book *book= [_dataModel getBookOfId:[NSString stringWithFormat:@"%@",azzura ]];
        book.localPathImageFile=destPath;
        [_dataModel saveData:book];
    }
  
    destPath=@"1094.epub";
    destPath=[string stringByAppendingPathComponent:destPath];
    insPath = @"1094.epub";
    srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:insPath];
    // NSLog(@"src path %@ des path %@",srcPath,temp);
    if (![fileManager fileExistsAtPath:destPath]) {
        [fileManager copyItemAtPath:srcPath  toPath:destPath error:nil];
        if (error) {
            NSLog(@"error %@",[error description]);
        }else{
            NSURL *url=[[NSURL alloc]initFileURLWithPath:destPath];
            //NSURLIsExcludedFromBackupKey
            [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
            // [url release];
        }
    }
   azzura=@1331;
    destPath=@"1331.jpg";
    destPath=[string stringByAppendingPathComponent:destPath];
    insPath = @"1331.jpg";
    srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:insPath];
    // NSLog(@"src path %@ des path %@",srcPath,temp);
    if (![fileManager fileExistsAtPath:destPath]) {
        [fileManager copyItemAtPath:srcPath  toPath:destPath error:nil];
        if (error) {
            NSLog(@"error %@",[error description]);
        }else{
            NSURL *url=[[NSURL alloc]initFileURLWithPath:destPath];
            //NSURLIsExcludedFromBackupKey
            [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
            // [url release];
        }
    }

    if (![_dataModel checkIfIdExists:azzura]) {
        Book *book= [_dataModel getBookInstance];
        book.title=@"InOpen";
        book.desc=@"InOpen";
        book.link=@"http://www.mangoreader.com/books/1331";
        book.imageUrl=@"http://www.mangoreader.com/1331/cover_image/download";
        book.sourceFileUrl=@"http://www.mangoreader.com/book/1331/download";
        book.localPathImageFile=destPath;
        book.id=@1331;
        book.size=@26171226;
        book.date=[NSDate date];
        book.downloadedDate=[NSDate date];
        book.downloaded=@NO;
        book.textBook=@3;
        
        //book.downloaded=[NSNumber numberWithBool:NO];
        NSError *error=nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"%@",error);
        }
        
    }
   /* destPath=@"1331.epub";
    destPath=[string stringByAppendingPathComponent:destPath];
    insPath = @"1331.epub";
    srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:insPath];
    // NSLog(@"src path %@ des path %@",srcPath,temp);
    if (![fileManager fileExistsAtPath:destPath]) {
        [fileManager copyItemAtPath:srcPath  toPath:destPath error:nil];
        if (error) {
            NSLog(@"error %@",[error description]);
        }else{
            NSURL *url=[[NSURL alloc]initFileURLWithPath:destPath];
            //NSURLIsExcludedFromBackupKey
            [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
            // [url release];
        }
    }*/
   // [vayuTheWind release];
  
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
       _loginViewControllerIphone=[[LoginViewControllerIphone alloc]initWithNibName:@"LoginViewControllerIphone" bundle:nil];
        CustomNavViewController *nav=[[CustomNavViewController alloc]initWithRootViewController:_loginViewControllerIphone];
      
        self.window.rootViewController = nav;
        //[nav release];
        [self.window makeKeyAndVisible];
    }else{
        _loginViewController=[[LoginViewController alloc]init];
        CustomNavViewController *nav=[[CustomNavViewController alloc]initWithRootViewController:_loginViewController];
   
        self.window.rootViewController = nav;
 
        [self.window makeKeyAndVisible];
    }
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self addSkipBackupAttribute];
    [self performSelectorInBackground:@selector(unzipExisting) withObject:nil];
    // convert all directories out of backup
    _location=[self applicationDocumentsDirectory];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"bkup"]) {
        [self performSelectorInBackground:@selector(removeBackDirectory) withObject:nil];

    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"bkup"];
 [Flurry startSession:@"ZVNA994FI9SI51FN68Q9"];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge];
    [Appirater appLaunched:YES];
    return YES;
}
-(void)addSkipAttribute:(NSString *) string{
    const char* filePath = [string fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result =  setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    NSLog(@"Result %d",result);
}
void uncaughtExceptionHandler(NSException *exception) {
    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"Error %@",error);
}
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *urlString=[NSString stringWithFormat:@"%@apns_device_request",[[NSUserDefaults standardUserDefaults]objectForKey:@"baseurl"]  ];
    NSURL *url;//=[NSURL URLWithString:@"http://192.168.0.107:3000/api/v1/apns_device_request"];
    url=[NSURL URLWithString:urlString];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
   // "apns": {  "udid": " ", "devise_token": " "  }
    [dictionary setValue:@"Not Allowed" forKey:@"udid"];
    [dictionary setValue:newToken forKey:@"device_token"];
    NSMutableDictionary *apns=[[NSMutableDictionary alloc]init];
    [apns setValue:dictionary forKey:@"apns"];
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:apns options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:jsonData];
  //  NSLog(@"json token %@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse *response;
    NSError *error;
    /*NSData *responseData=*/[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error %@",error);
    }else{
    //    NSLog(@"responseData %@",[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding]);
    }
    // send device token
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
}

-(void)removeBackDirectory{
      NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_location error:nil];
    BOOL isDir;
    for (NSString *fileName in dirFiles) {
        NSString *loc=[_location stringByAppendingPathComponent:fileName];
        BOOL file=[[NSFileManager defaultManager] fileExistsAtPath:loc isDirectory:&isDir];
        //NSLog(@"%@",loc);
        NSError *error;
        if (!isDir&&[[NSFileManager defaultManager] fileExistsAtPath:loc]) {
            [[NSURL URLWithString:loc] setResourceValue:@YES
        forKey: NSURLIsExcludedFromBackupKey error: &error];
        }else if(file){
            _location=loc;
            [self performSelectorInBackground:@selector(removeBackDirectory) withObject:nil];
        }
    
    }
}
-(void)unzipExisting{

    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self applicationDocumentsDirectory] error:nil];
    NSArray *epubFles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.epub'"]];
    
    for (NSString *string in epubFles) {
        //location
        NSString *epubLocation=[[self applicationDocumentsDirectory] stringByAppendingPathComponent:string];
        NSString *value=[string stringByDeletingPathExtension];
        
        [self unzipAndSaveFile:epubLocation with:value.integerValue];
        [self addSkipAttribute:[epubLocation stringByDeletingPathExtension]];
        [[NSFileManager defaultManager] removeItemAtPath:epubLocation error:nil];
        
    }
}
- (void)unzipAndSaveFile:(NSString *) location with:(NSInteger ) identity {
	
	ZipArchive* za = [[ZipArchive alloc] init];
	if( [za UnzipOpenFile:location] ){
 
		NSString *strPath=[NSString stringWithFormat:@"%@/%d",[self applicationDocumentsDirectory],identity];
		NSFileManager *filemanager=[[NSFileManager alloc] init];
		if ([filemanager fileExistsAtPath:strPath]) {
			
			NSError *error;
			[filemanager removeItemAtPath:strPath error:&error];
		}
        //	[filemanager release];
		filemanager=nil;
		//start unzip
		BOOL ret = [za UnzipFileTo:[NSString stringWithFormat:@"%@/",strPath] overWrite:YES];
		if( NO==ret ){
			// error handler here
			UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
														  message:@"An unknown error occured"
														 delegate:self
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
			[alert show];
            //		[alert release];
			alert=nil;
		}
		[za UnzipCloseFile];
	}
	//[za release];
    
}
- (void)addSkipBackupAttribute
{
    NSString *path=[self applicationDocumentsDirectory];
    //     NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
    //    path =[path stringByAppendingFormat:@"/%d",iden ];
    
    const char* filePath = [path fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result =  setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    NSLog(@"Result %d",result);
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    UIAlertView *alertFailed;
    StoreBooks *books;
    NSNumber *number;
    BOOL restored;
    restored=NO;
    NSDictionary *diction;
    NSData *jsonData;
    NSString *valueJson;
    NSData *data;
    NSData *transactionReciept;
    NSString *encode;
    NSString *identifier;
    for (SKPaymentTransaction *transaction in transactions) {
       identifier= transaction.payment.productIdentifier;
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        [dict setValue:identifier forKey:@"identity"];
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateFailed:
                alertFailed =[[UIAlertView alloc]initWithTitle:@"Error"message:@"Payment not performed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertFailed show];
              //  [alertFailed release];
                
                if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
                    [_loginViewController transactionFailed];
                }else{
                    [_loginViewControllerIphone transactionFailed];
                    
                }
                [dict setValue:[transaction.error debugDescription] forKey:@"error"];
                [Flurry logEvent:@"payment failed" withParameters:dict];
                    [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchased:
                //[self purchaseValidation:transaction];
                /*
                 This code will get the price again from the Apple Server. Then validate the purchase and send the price to Apple
                 */
                [self requestPrice:transaction];

                break;
            case SKPaymentTransactionStateRestored:
                number=@(transaction.payment.productIdentifier.integerValue);
                books= [_dataModel getBookById:number];
                [_dataModel insertBookWithNo:books];
               // [number release];
//                string=[[NSString alloc]initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
//                NSLog(@"string %@",string);
                data=transaction.transactionReceipt;
                transactionReciept=transaction.transactionReceipt;
                encode=[Base64 encode:transactionReciept];
                 diction=[[NSMutableDictionary alloc]init];
                [diction setValue:encode forKey:@"receipt_data"];
                jsonData=[NSJSONSerialization dataWithJSONObject:diction options:NSJSONWritingPrettyPrinted error:nil];
                
                valueJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
             //   NSLog(@"value json request %@",valueJson);
                [Flurry logEvent:@"book restored" withParameters:dict];
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                restored=YES;
                
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Purchasing");
                break;
            default:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
        }
    }//end for
    if (restored) {
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            [_loginViewController transactionRestored];

        }else{
            [_loginViewControllerIphone transactionRestored];

        }
    }
    [AePubReaderAppDelegate hideAlertView];

}
-(void)requestPrice:(SKPaymentTransaction *)transaction{
    NSString *iden=[NSString stringWithFormat:@"%d",transaction.payment.productIdentifier.integerValue ];
    NSSet *prodIds=[NSSet setWithObject:iden];
    SKProductsRequest *productRequest=[[SKProductsRequest alloc]initWithProductIdentifiers:prodIds];
    productRequest.delegate=self;
    [productRequest start];
    /*the start function will call productRequest:didReceiveResponse 
     */
    _transaction=transaction;
}
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    _product=[response.products lastObject];
    [self purchaseValidation];
}
-(void)purchaseValidation {
    NSMutableURLRequest *request;
    NSMutableDictionary *dictionary;
    NSNumber *userid;
    NSData *jsonData;
    NSString *valueJson;
    _identity=_transaction.payment.productIdentifier.integerValue;
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"email"])
    {
        request=[[NSMutableURLRequest alloc]init];
        dictionary=[[NSMutableDictionary alloc]init];
        userid=[[NSUserDefaults standardUserDefaults]objectForKey:@"id"];
        [dictionary setValue:userid forKey:@"user_id"];
        [dictionary setValue:@(_identity) forKey:@"book_id"];
        [dictionary setValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"auth_token"] forKey:@"auth_token"];
        [dictionary setValue:_product.price forKey:@"amount"];
        NSData *transactionReciept=_transaction.transactionReceipt;
        NSString *encode=[Base64 encode:transactionReciept];
        
        [dictionary setValue:encode forKey:@"receipt_data"];
        jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        
        valueJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        //NSLog(@"JSON data %@",valueJson);
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:jsonData];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSString *urlString=[NSString stringWithFormat:@"%@receipt_validate",[defaults objectForKey:@"baseurl"] ];
        //   urlString=@"http://192.168.2.29:3000/api/v1/receipt_validate";
       // NSLog(@"reciept validation %@",urlString);
        [request setURL:[NSURL URLWithString:urlString]];
        NSURLResponse *response;
        NSError *error;
        NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }else{
            NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSString *value= dictionary[@"message"];
            if ([value isEqualToString:@"purchase successful!"]) {
                StoreBooks *books=[self.dataModel getBookById:@(_identity)];
                NSString *message=[NSString stringWithFormat:@"Do you wish to download book titled %@ now?",books.title ];
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Purchase Successful" message:message delegate:self cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
                // [alertViewDelegate autorelease];
                alertView.tag=2000;
                [alertView show];
                //   [alertView release];
                
                
            }else{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Purchase failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            
            }
            [[SKPaymentQueue defaultQueue]finishTransaction:_transaction];
        }
        
        
    }else// no email
    {
        NSURLResponse *response;
        NSError *error;
        request=[[NSMutableURLRequest alloc]init];
        dictionary=[[NSMutableDictionary alloc]init];
        [dictionary setValue:_product.price forKey:@"amount"];
        NSData *transactionReciept=_transaction.transactionReceipt;
        NSString *encode=[Base64 encode:transactionReciept];
        [dictionary setValue:encode forKey:@"receipt_data"];
        jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        
        valueJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
     //   NSLog(@"value json request %@",valueJson);
        // [valueJson release];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:jsonData];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        
        NSString *urlString=[NSString stringWithFormat:@"%@receipt_validate_without_signed_in.json",[defaults objectForKey:@"baseurl"] ];
        //   urlString=@"http://192.168.2.29:3000/api/v1/receipt_validate";
        //NSLog(@"reciept validation %@",urlString);
        [request setURL:[NSURL URLWithString:urlString]];
        NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }else{
            NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSNumber *value= dictionary[@"status"];
            if (value.integerValue==0) {
                StoreBooks *books=[self.dataModel getBookById:@(_identity)];
                NSString *message=[NSString stringWithFormat:@"Do you wish to download book titled %@ now?",books.title ];

                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Purchase Successful" message:message delegate:self cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
                // [alertViewDelegate autorelease];
                alertView.tag=2000;
                [alertView show];

        
            }else{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Purchase failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
                
            }
            [[SKPaymentQueue defaultQueue]finishTransaction:_transaction];

        
        }
        
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
 if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
    NSNumber *identity=@(_identity);
    StoreBooks *books=[self.dataModel getBookById:identity];
    float size=[books.size floatValue];
    //  [image release];
//    NSLog(@"%ll",size );
//    size=size/1024.0f;
//    NSLog(@"%f",size );
//    size=size/1024.0f;
//    NSLog(@"%f",size);
    if (buttonIndex==1) {// yes is case
        if (size>[self getFreeDiskspace]) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"There is no sufficient space in your device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            [self.dataModel insertBookWithNo:books];
            [self.loginViewController refreshDownloads];

        }else{// if there is sufficient space
            if (!_addControlEvents) {
                UIAlertView *down=[[UIAlertView alloc]initWithTitle:@"Downloading.." message:@"Cannot start downloading as previous download is not complete" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
                [down show];
                [self.dataModel insertBookWithNo:books];
                [self.loginViewController refreshDownloads];

            }//end if add controlevents
            else{
                [self.dataModel insertBookWithYes:books];
                [self.loginViewController liveViewControllerDismiss];
                NSString *valu=[[NSString alloc]initWithFormat:@"%d.epub",_identity ];
                Book *bookToDownload=[self.dataModel getBookOfId:valu];
                if (![_loginViewController downloadBook:bookToDownload]) {
                    bookToDownload.downloaded=@NO;
                    [self.dataModel saveData:bookToDownload];
                }
                
            }
            
        }
        }else{/// no is the case
                [self.dataModel insertBookWithNo:books];
        
            }
            [self.loginViewController liveViewControllerDismiss];
            [self.loginViewController refreshDownloads];
    }else if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone){
        NSNumber *identity=@(_identity);
        StoreBooks *books=[self.dataModel getBookById:identity];
        float size=[books.size floatValue];
        //  [image release];
        NSLog(@"%@",[NSNumber numberWithLongLong:size] );
        size=size/1024.0f;
        NSLog(@"%@",[NSNumber numberWithLongLong:size] );
        size=size/1024.0f;
        NSLog(@"%@",[NSNumber numberWithLongLong:size] );

        if (buttonIndex==1) {
            if (size>[self getFreeDiskspace]) {
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"There is no sufficient space in your device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
                [self.dataModel insertBookWithNo:books];
                [self.loginViewControllerIphone downloadViewControllerRefreshUI];
                
            }else // if there is space
                {
                    if (_downloadBook) {
                        UIAlertView *down=[[UIAlertView alloc]initWithTitle:@"Downloading.." message:@"Cannot start downloading as previous download is not complete" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
                        [down show];
                        [_dataModel insertBookWithNo:books ];
                        [self.loginViewControllerIphone downloadViewControllerRefreshUI];

                    }else{
                        [_dataModel insertBookWithYes:books];
                        [self.loginViewControllerIphone downloadComplete:_identity];
                    }
                }// end else of if there is freespace
        }        
        else
        {
            [_dataModel insertBookWithNo:books];
            [self.loginViewControllerIphone downloadViewControllerRefreshUI];
        }
                
    }
[self.loginViewControllerIphone dismissStoreViewController];
}
-(uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = dictionary[NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = dictionary[NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}
-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        [_loginViewController restoreFailed];
    }else{
        [_loginViewControllerIphone restoreFailed];
    }
}

-(void)applicationDidEnterBackground:(UIApplication *)application{
    [Flurry logEvent:@"Application went to background thus downloads and connection request will close"];

}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
   NSString *loc=  [[NSUserDefaults standardUserDefaults]valueForKey:@"locDirectory"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:loc]) {
        [[NSFileManager defaultManager] removeItemAtPath:loc error:nil];
    }
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Books" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];;
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"MangoReader.sqlite"]];
    NSError *error = nil;
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
    						 NSInferMappingModelAutomaticallyOption: @YES};
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    NSString *ver=[UIDevice currentDevice].systemVersion;
    if (ver.integerValue<6) {
        if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                     configuration:nil URL:storeUrl options:options error:&error]) {
            /*Error for store creation should be handled in here*/
            NSLog(@"%@",error);
            
        }
 
    }else{
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:NSMigratePersistentStoresAutomaticallyOption URL:storeUrl options:options error:&error]) {
        /*Error for store creation should be handled in here*/
        NSLog(@"%@",error);

    }
    }
    return persistentStoreCoordinator;
}
- (NSPersistentStoreCoordinator *)resetPersistentStore {
    NSError *error = nil;
    
    if ([persistentStoreCoordinator persistentStores] == nil)
        return [self persistentStoreCoordinator];
    
    [managedObjectContext reset];
    [managedObjectContext lock];
    
    // FIXME: dirty. If there are many stores...
    NSPersistentStore *store = [[persistentStoreCoordinator persistentStores] lastObject];
    
    if (![persistentStoreCoordinator removePersistentStore:store error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // Delete file
    if ([[NSFileManager defaultManager] fileExistsAtPath:store.URL.path]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    // Delete the reference to non-existing store
    persistentStoreCoordinator = nil;
    
    NSPersistentStoreCoordinator *r = [self persistentStoreCoordinator];
    [managedObjectContext unlock];
    
    return r;
}
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
-(void)insertInStore{
    [_loginViewController insertInStore];
}
+(void)adjustForIOS7:(UIView *)view{
    if(    [UIDevice currentDevice].systemVersion.integerValue>=7){
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect frame=view.frame;
    frame.origin.y=20;
        frame.size.height=screenBounds.size.height-20;
        view.frame=frame;
    }
    
}
+(void)showAlertView{
   alertViewLoading= [[UIAlertView alloc]init];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
    [indicator startAnimating];
    [alertViewLoading addSubview:indicator];
    // [indicator release];
    [alertViewLoading setTitle:@"Loading...."];
    
    
    
    [alertViewLoading show];

}
+(void)showAlertViewiPad{
    alertViewLoading =[[UIAlertView alloc]init];
    
    
    UIImage *image=[UIImage imageNamed:@"loading.png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, -160, 391, 320)];
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    
    imageView.image=image;
    [alertViewLoading addSubview:imageView];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, 25, 66.0f, 66.0f)];
    indicator.color=[UIColor blackColor];
    [indicator startAnimating];
    [alertViewLoading addSubview:indicator];
    [alertViewLoading show];
}
+(UIAlertView *) getAlertView{
    return alertViewLoading;
}
+(void)hideAlertView{
    if(alertViewLoading){
        [alertViewLoading dismissWithClickedButtonIndex:0 animated:YES];}
    alertViewLoading =nil;
    
}
@end

