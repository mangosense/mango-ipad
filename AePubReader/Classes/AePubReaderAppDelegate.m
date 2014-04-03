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

#import <Parse/Parse.h>
#import "Constants.h"
#import "MBProgressHUD.h"

#import "BooksFromCategoryViewController.h"

#import <FacebookSDK/FacebookSDK.h>

@implementation AePubReaderAppDelegate
static UIAlertView *alertViewLoading;

//@synthesize window;
@synthesize managedObjectContext,managedObjectModel,persistentStoreCoordinator;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    //Cache
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:4*1024*1024 diskCapacity:20*1024*1024 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    //EJDB
    _ejdbController = [[EJDBController alloc] initWithCollectionName:@"MangoCollection" andDatabaseName:@"MangoDb.db"];
    
    _prek=NO;
    //Parse
//    [Parse setApplicationId:@"ZDhxNVZSUCqv4oEVzNgGPplnlSiqe23yxY6G954b"
//                  clientKey:@"y3QnS0AIVnzabRKv6mQreR8yK6oqDUeYOlamoIR1"];
    
   //My test account id and key
    [Parse setApplicationId:@"ZDhxNVZSUCqv4oEVzNgGPplnlSiqe23yxY6G954b"
                       clientKey:@"y3QnS0AIVnzabRKv6mQreR8yK6oqDUeYOlamoIR1"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    NSString *string=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:[BASE_URL stringByAppendingString:LOGIN]]];
    for (NSHTTPCookie *cookie in cookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    _LandscapeOrientation=YES;
    _PortraitOrientation=NO;
   _dataModel=[[DataModelControl alloc]initWithContext:[self managedObjectContext]];

    _wasFirstInPortrait=NO;
    
    BOOL uiNew=YES;
    
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];

    [userDefaults setBool:NO forKey:@"changed"];
    if (!uiNew)
    {
        [userDefaults setBool:YES forKey:@"didadd"];

        NSString *recording=[string stringByAppendingPathComponent:@"recording"];
        [userDefaults setObject:recording forKey:@"recordingDirectory"];
        
        [self performSelectorInBackground:@selector(unzipExisting) withObject:nil];

    }
    else {
        [userDefaults setBool:YES forKey:@"didaddWithNewUI"];
        [self performSelectorInBackground:@selector(unzipExistingJsonBooks) withObject:nil];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
       _loginViewControllerIphone=[[LoginViewControllerIphone alloc]initWithNibName:@"LoginViewControllerIphone" bundle:nil];
        CustomNavViewController *nav=[[CustomNavViewController alloc]initWithRootViewController:_loginViewControllerIphone];
        
        self.window.rootViewController = nav;
        [self.window makeKeyAndVisible];
    } else {
        CustomNavViewController *nav;
        if (uiNew) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];

            if (path) {
                _coverController = [[CoverViewControllerBetterBookType alloc] initWithNibName:@"CoverViewControllerBetterBookType" bundle:nil WithId:nil];
                nav = [[CustomNavViewController alloc]initWithRootViewController:_coverController];
            } else {
                _loginController=[[LoginNewViewController alloc]initWithNibName:@"LoginNewViewController" bundle:nil];
                nav=[[CustomNavViewController alloc]initWithRootViewController:_loginController];
            }
            
        } else {
        _loginViewController=[[LoginViewController alloc]init];
        nav=[[CustomNavViewController alloc]initWithRootViewController:_loginViewController];
        }
        
        
        self.window.rootViewController = nav;
 
        [self.window makeKeyAndVisible];
    }
        
    [self addSkipBackupAttribute];
    
    // convert all directories out of backup
    _location=[self applicationDocumentsDirectory];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"bkup"]) {
        [self performSelectorInBackground:@selector(removeBackDirectory) withObject:nil];

    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"bkup"];
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    // Load the FBProfilePictureView
    // You can find more information about why you need to add this line of code in our troubleshooting guide
    // https://developers.facebook.com/docs/ios/troubleshooting#objc
    [FBProfilePictureView class];
    
    return YES;
}

// In order to process the response you get from interacting with the Facebook login process,
// you need to override application:openURL:sourceApplication:annotation:
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
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

-(void)unzipExistingJsonBooks{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];

    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self applicationDocumentsDirectory] error:nil];
    NSArray *epubFles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.zip'"]];
    if (path) {
        epubFles = [NSArray arrayWithObject:@"MangoStory"];
    }
    
    for (NSString *string in epubFles) {
        //location
        NSString *epubLocation=[[self applicationDocumentsDirectory] stringByAppendingPathComponent:string];
        if (path) {
            epubLocation = path;
        }
        NSString *value=[string stringByDeletingPathExtension];
        
        NSLog(@"EpubLocation: %@, Value: %@", epubLocation, value);
            // unzip the file
        [self unzipAndSaveFile:epubLocation withString:value];
        // provide do not backup attribute to folder itself
        [self addSkipAttribute:[epubLocation stringByDeletingPathExtension]];
        // delete the zip since it is unzipped
        [self SendToEJDB:[epubLocation stringByDeletingPathExtension] WithId:nil];

        [[NSFileManager defaultManager] removeItemAtPath:epubLocation error:nil];
    }
}

-(void)SendToEJDB:(NSString *)locationDirectory WithId:(NSNumber *)numberId {
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:locationDirectory error:nil];
    NSArray *epubFles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"]];
    
    NSString *actualJsonLocation=[locationDirectory stringByAppendingPathComponent:[epubFles firstObject]];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:actualJsonLocation];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    if (path) {
        dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/MangoStory",[self applicationDocumentsDirectory]] error:nil];
        epubFles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"]];
        NSString *actualJsonLocation = [[NSString stringWithFormat:@"%@/MangoStory",[self applicationDocumentsDirectory]] stringByAppendingPathComponent:[epubFles firstObject]];
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:actualJsonLocation];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
        _mangoStoryId = [jsonDict objectForKey:@"id"];

        [_ejdbController parseBookJson:jsonData WithId:numberId AtLocation:[NSString stringWithFormat:@"%@/MangoStory",[self applicationDocumentsDirectory]]];

        _coverController.identity = _mangoStoryId;
    } else {
        [_ejdbController parseBookJson:jsonData WithId:numberId AtLocation:locationDirectory];
    }
}

-(void)unzipAndSaveFile:(NSString *)location withString:(NSString *)folderName{
    ZipArchive* za = [[ZipArchive alloc] init];
   // NSString *strPath=[NSString stringWithFormat:@"%@/%@",[self applicationDocumentsDirectory],folderName];
    NSLog(@"zip %@",location);
    
    if( [za UnzipOpenFile:location] ){
        
		NSFileManager *filemanager=[[NSFileManager alloc] init];
        NSString *destination;
        destination = [NSString stringWithFormat:@"%@/%@",[self applicationDocumentsDirectory], folderName];
        
        NSLog(@"Unzip Destination: %@", destination);
        
		BOOL ret = [za UnzipFileTo:destination overWrite:YES];
		if( NO==ret ){
			// error handler here
			UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
														  message:@"An unknown error occured"
														 delegate:self
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
			[alert show];
		}else{
            
        }
        [filemanager removeItemAtPath:location error:nil];
		[za UnzipCloseFile];
	}

}
- (void)unzipAndSaveFile:(NSString *) location with:(NSInteger ) identity {
	NSLog(@"location %@",location);
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
    _arePurchasesDownloading = NO;
}

#pragma mark - Image Manipulation

+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
	CGImageRef imgRef = [image CGImage];
    CGImageRef maskRef = [maskImage CGImage];
    CGImageRef actualMask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                              CGImageGetHeight(maskRef),
                                              CGImageGetBitsPerComponent(maskRef),
                                              CGImageGetBitsPerPixel(maskRef),
                                              CGImageGetBytesPerRow(maskRef),
                                              CGImageGetDataProvider(maskRef), NULL, false);
    CGImageRef masked = CGImageCreateWithMask(imgRef, actualMask);
    return [UIImage imageWithCGImage:masked];
}

#pragma mark - After Download

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
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
+(void)hideTabBar:(UITabBarController *)tabbarcontroller
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    float fHeight = screenRect.size.height;
    if(  UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
    {
        fHeight = screenRect.size.width;
    }
    
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
            view.backgroundColor = [UIColor blackColor];
        }
    }
}

+ (UIColor *)colorFromRgbString:(NSString *)rgbString {
    NSScanner *scanner = [NSScanner scannerWithString:rgbString];
    NSString *junk, *red, *green, *blue;
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&junk];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet punctuationCharacterSet] intoString:&red];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&junk];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet punctuationCharacterSet] intoString:&blue];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&junk];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet punctuationCharacterSet] intoString:&green];
    
    UIColor *backgroundColor = [UIColor colorWithRed:red.intValue/255.0 green:green.intValue/255.0 blue:blue.intValue/255.0 alpha:1.0];
    return backgroundColor;
}

+ (UIColor *) colorFromHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
@end

