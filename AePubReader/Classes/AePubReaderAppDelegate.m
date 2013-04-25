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

@synthesize window;
@synthesize managedObjectContext,managedObjectModel,persistentStoreCoordinator;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    _LandscapeOrientation=YES;
    _PortraitOrientation=YES;
   _dataModel=[[DataModelControl alloc]initWithContext:[self managedObjectContext]];

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
            [url setResourceValue:[NSNumber numberWithBool: YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
           // [url release];
        }
    }
    moonCapId=[[NSNumber alloc]initWithInt:49];
    
    if(![_dataModel checkIfIdExists:moonCapId]){
        Book *book= [_dataModel getBookInstance];
        book.title=@"Moon and the Cap";
        book.desc=@"Do you like to wear a cap on a sunny day? Find out who else likes to wear a cap in this charming hindi book.The Moon and The Cap was originally published as part of the Read India project by Pratham Books. This book is written and narrated in multiple different languages including Hindi & English. Read this book to your kid and see thier eyes light up! If you're not a kid then this book will take you back in days when life was simple and small simple gifts made us excited with joy.";
        book.link=@"http://www.mangoreader.com/books/49";
        book.imageUrl=@"http://www.mangoreader.com/49/cover_image/download";
        book.sourceFileUrl=@"http://www.mangoreader.com/book/49/download";
        book.localPathImageFile=destPath;
        book.id=[NSNumber numberWithInteger:49];
        book.size=[NSNumber numberWithInteger:7631651];
        book.date=[NSDate date];
        book.textBook=[NSNumber numberWithInteger:1];
        book.downloadedDate=[NSDate date];
        book.downloaded=[NSNumber numberWithBool:YES];
        NSError *error=nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"%@",error);
        }
        
    }
   // [moonCapId release];
    destPath=@"49.epub";
    insPath = @"49.epub";
    srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:insPath];
    destPath=[string stringByAppendingPathComponent:destPath];
   // [fileManager removeItemAtPath:destPath error:nil];
    if (![fileManager fileExistsAtPath:destPath]) {
        [fileManager copyItemAtPath:srcPath toPath:destPath error:&error];
        
        if (error) {
            NSLog(@"error %@",[error description]);
        }else{
            NSLog(@"%@",destPath);
            NSURL *url=[NSURL fileURLWithPath:destPath];
            error=nil;
            [url setResourceValue:[NSNumber numberWithBool: YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
            id Flag=nil;
            [url getResourceValue:&Flag forKey:NSURLIsExcludedFromBackupKey error:&error];
            if (Flag) {
                NSNumber *flag=(NSNumber *)Flag;
                NSLog(flag.boolValue ? @"Yes" : @"No");
                NSLog(@" 49.epub flag %@",Flag);
            }
            if (error) {
                  NSLog(@"error %@",[error description]);
            }

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
            [url setResourceValue:[NSNumber numberWithBool: YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
           // [url release];
        }
    }
      NSNumber *vayuTheWind=[[NSNumber alloc]initWithInt:445];
    if (![_dataModel checkIfIdExists:vayuTheWind]) {
        Book *book= [_dataModel getBookInstance];
        book.title=@"Vayu the Wind";
        book.desc=@"Vayu, The Wind  written by Madhuri Pai and published by Pratham Books is intended for kids  from the ages of 3-6yrs. The book is a  great way to teach the kids about wind and its effects. Even though we can\r\nsee it, the wind plays an integral part in our lives and what better way to learn about it than this. So lets learn about the wind from a kid's perspective. And play game when hover over the game image.";
        book.link=@"http://www.mangoreader.com/books/445";
        book.imageUrl=@"http://www.mangoreader.com/445/cover_image/download";
        book.sourceFileUrl=@"http://www.mangoreader.com/book/445/download";
        book.localPathImageFile=destPath;
        book.id=[NSNumber numberWithInteger:445];
        book.size=[NSNumber numberWithInteger:26171226];
        book.date=[NSDate date];
        book.downloadedDate=[NSDate date];
        book.downloaded=[NSNumber numberWithBool:NO];
        //book.downloaded=[NSNumber numberWithBool:NO];
        NSError *error=nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"%@",error);
        }
        
        
    }
    
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
-(void)removeBackDirectory{
      NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_location error:nil];
    BOOL isDir;
    for (NSString *fileName in dirFiles) {
        NSString *loc=[_location stringByAppendingPathComponent:fileName];
        BOOL file=[[NSFileManager defaultManager] fileExistsAtPath:loc isDirectory:&isDir];
        NSLog(@"%@",loc);
        NSError *error;
        if (!isDir&&[[NSFileManager defaultManager] fileExistsAtPath:loc]) {
            [[NSURL URLWithString:loc] setResourceValue:[NSNumber numberWithBool: YES]
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
    for (SKPaymentTransaction *transaction in transactions) {
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
                    [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchased:
                if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
                    [self purchaseValidationIpad:transaction];
                
                
                }else{// for iphone or ipod case
                    [self purchaseValidationIphone:transaction];
                }
                
                break;
            case SKPaymentTransactionStateRestored:
                number=[[NSNumber alloc]initWithInteger:transaction.payment.productIdentifier.integerValue];
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
                NSLog(@"value json request %@",valueJson);

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

}
-(void)purchaseValidationIphone:(SKPaymentTransaction *)transaction{
    NSMutableURLRequest *request;
    NSMutableDictionary *dictionary;
    NSNumber *userid;
    NSData *jsonData;
    NSString *valueJson;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"email"])
    {
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
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:jsonData];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSString *urlString=[NSString stringWithFormat:@"%@receipt_validate",[defaults objectForKey:@"baseurl"] ];
        //   urlString=@"http://192.168.2.29:3000/api/v1/receipt_validate";
        NSLog(@"reciept validation %@",urlString);
        [request setURL:[NSURL URLWithString:urlString]];
        NSURLResponse *response;
        NSError *error;
        NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }else{
            NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSString *value= [dictionary objectForKey:@"message"];
            if ([value isEqualToString:@"purchase successful!"]) {
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Purchase Successful" message:@"Do you want to download it now?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
                // [alertViewDelegate autorelease];
                alertView.tag=2000;
                [alertView show];
                //   [alertView release];
                
                
            }else{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Purchase failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            
            }
            [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
        }
        
        
    }else// no email
    {
        NSURLResponse *response;
        NSError *error;
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
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        
        NSString *urlString=[NSString stringWithFormat:@"%@receipt_validate_without_signed_in.json",[defaults objectForKey:@"baseurl"] ];
        //   urlString=@"http://192.168.2.29:3000/api/v1/receipt_validate";
        NSLog(@"reciept validation %@",urlString);
        [request setURL:[NSURL URLWithString:urlString]];
        NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }else{
            NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSNumber *value= [dictionary objectForKey:@"status"];
            if (value.integerValue==0) {
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Purchase Successful" message:@"Do you want to download it now?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
                // [alertViewDelegate autorelease];
                alertView.tag=2000;
                [alertView show];

        
            }else{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Purchase failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
                
            }
            [[SKPaymentQueue defaultQueue]finishTransaction:transaction];

        
        }
        
        
    }
}
-(void) purchaseValidationIpad:(SKPaymentTransaction *)transaction{
    NSMutableURLRequest *request;
    NSMutableDictionary *dictionary;
    NSNumber *userid;
    NSData *jsonData;
    NSString *valueJson;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"email"])
    {
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
        //  [valueJson release];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:jsonData];
        NSString *urlString=[NSString stringWithFormat:@"%@receipt_validate",[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"] ];
        [request setURL:[NSURL URLWithString:urlString]];
        NSURLResponse *response;
        NSError *error;
        NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            
        }else{
            NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSString *value= [dictionary objectForKey:@"message"];
            if ([value isEqualToString:@"purchase successful!"])
            {
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Purchase Successful" message:@"Do you want to download it now?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
                alertView.tag=1000;
                [alertView show];
                
            }else{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Purchase failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
            [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
        }
        
    }else{// not logged in
        request=[[NSMutableURLRequest alloc]init];
        dictionary=[[NSMutableDictionary alloc]init];
        // [dictionary setValue:_price forKey:@"amount"];
        
        NSData *transactionReciept=transaction.transactionReceipt;
        NSString *encode=[Base64 encode:transactionReciept];
        [dictionary setValue:encode forKey:@"receipt_data"];
        jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        
        valueJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"value json request %@",valueJson);
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:jsonData];
        NSString *urlString=[NSString stringWithFormat:@"%@receipt_validate_without_signed_in.json",[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"] ];
        [request setURL:[NSURL URLWithString:urlString]];
        NSURLResponse *response;
        NSError *error;
        NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }else{
            NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSNumber *value= [dictionary objectForKey:@"status"];
            if (value.integerValue==0)
            {
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Purchase Successful" message:@"Do you want to download it now?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
                [alertView show];
                
            }else{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Purchase failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
                
            }
            [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
            
        }
    }
    

}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
 if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
    NSNumber *identity=[[NSNumber alloc]initWithInteger:_identity];
    StoreBooks *books=[self.dataModel getBookById:identity];
    float size=[books.size floatValue];
    //  [image release];
    NSLog(@"%@",[NSNumber numberWithLongLong:size] );
    size=size/1024.0f;
    NSLog(@"%@",[NSNumber numberWithLongLong:size] );
    size=size/1024.0f;
    NSLog(@"%@",[NSNumber numberWithLongLong:size] );
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
                [_loginViewController downloadBook:bookToDownload];
            }
            
        }
        }else{/// no is the case
                [self.dataModel insertBookWithNo:books];
        
            }
            [self.loginViewController liveViewControllerDismiss];
            [self.loginViewController refreshDownloads];
    }else if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone){
        NSNumber *identity=[[NSNumber alloc]initWithInteger:_identity];
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
-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        [_loginViewController restoreFailed];
    }else{
        [_loginViewControllerIphone restoreFailed];
    }
}

-(void)applicationDidEnterBackground:(UIApplication *)application{

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
       
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    						 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
    						 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
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
   // [persistentStoreCoordinator release];
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
/*- (void)dealloc {
  //  _loginViewController=nil;

    
    [window release];
    
    [super dealloc];
}*/


@end

