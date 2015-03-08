//
//  AePubReaderAppDelegate.m
//  AePubReader
//
//  Created by Federico Frappi on 04/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AePubReaderAppDelegate.h"
#import "MangoEditorViewController.h"
#import "MangoStoreViewController.h"

#import "Book.h"
//#import "CustomNavViewController.h"
#import "Flurry.h"
#include <sys/xattr.h>
#import "ZipArchive.h"
#import "Base64.h"
#import "MangoApiController.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "MBProgressHUD.h"
#import "MangoSubscriptionViewController.h"
#import "UserSubscriptionViewController.h"
#import "BooksFromCategoryViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ATConnect.h"
#import "MBProgressHUD.h"
//#import "Fingerprint.h"

@implementation AePubReaderAppDelegate
static UIAlertView *alertViewLoading;

//@synthesize window;
@synthesize managedObjectContext,managedObjectModel,persistentStoreCoordinator, nav;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    for (NSString* family in [UIFont familyNames])
//    {
//        NSLog(@"%@", family);
//        
//        for (NSString* name in [UIFont fontNamesForFamilyName: family])
//        {
//            NSLog(@"  %@", name);
//        }
//    }

    
    //test account mixpanel
    //[Mixpanel sharedInstanceWithToken:@"01943dcf98ca5fabd4ba382256e6c270"];
    
    //Endless Stories mixpanel account
    [Mixpanel sharedInstanceWithToken:@"e7d5897e9c2fba5e25843289886db881"];
    
//    [ATConnect sharedConnection].apiKey = @"fba67dd1698aff8d958e0c80b48cee111099d81268aeddde83f0f0c10b55b006";
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    //Cache
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:4*1024*1024 diskCapacity:20*1024*1024 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    //EJDB
    _ejdbController = [[EJDBController alloc] initWithCollectionName:@"MangoCollection" andDatabaseName:@"MangoDb.db"];
    
    _prek=NO;
    
    //Parse Endless Stories Original App -
    [Parse setApplicationId:@"l4LHVnIcefNsZbnwhgY4WFygeNUBmNxVk9s4mQNj"
                  clientKey:@"gEwfyKlPWSj8go5TIYiJ3A70m1kknFneMKxBZE56"];
    
    //Test app for testing
    //[Parse setApplicationId:@"HDYSM40wgGxveHLKrGlyc2AMjbiR3E6ORoMkX5uF"
    //                   clientKey:@"mfbRYQ4lejSlrJz3Jn7U0MRiAlkdGIXcwDsIZM3t"];
    
 
    //Flurry
    
    [Flurry setCrashReportingEnabled:YES];
    //[Flurry startSession:@"ZVNA994FI9SI51FN68Q9"];//mangoreader
    [Flurry startSession:@"XNDP89F6WKB8B7Y9BQHS"]; // endless stories
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    
//    [application registerForRemoteNotificationTypes:
//     UIRemoteNotificationTypeBadge |
//     UIRemoteNotificationTypeAlert |
//     UIRemoteNotificationTypeSound];
    
    //FingerPrintPlay
    
/*    NSMutableDictionary* fpOptions = [NSMutableDictionary dictionaryWithCapacity:1];
    [fpOptions setObject:[NSNumber numberWithBool:NO] forKey:@"bMultiplayer"];
    [fpOptions setObject:[NSNumber numberWithBool:YES] forKey:@"bLandscape"];
    [fpOptions setObject:[NSNumber numberWithBool:NO] forKey:@"bPracticeRound"];
    [fpOptions setObject:[NSNumber numberWithBool:NO] forKey:@"bSuppressPauseScreen"];
    
    // Startup the Fingerprint API.
    // fpDelegate is an object which implements the FingerprintDelegate protocol.
    [Fingerprint startup:launchOptions fpOptions:fpOptions fpDelegate:self];
    
    // Establish Account and Child
    // (Or you can also wait to call after your splash sequence)
    // Note the API Delegate onLoginComplete method will let you know when child is ready to play
    [Fingerprint login];*/
    
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    _country = @"US";//[locale displayNameForKey: NSLocaleCountryCode value: countryCode];
    NSString *countrylang = [locale objectForKey: NSLocaleLanguageCode];
    _language = @"US";//[locale displayNameForKey:NSLocaleLanguageCode value:countrylang];
    _uuidValue = [[NSUUID UUID] UUIDString];
    _udidValue = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    _deviceId = _udidValue;
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
    
//    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
//    NSArray *fontNames;
//    NSInteger indFamily, indFont;
//    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
//    {
//        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
//        fontNames = [[NSArray alloc] initWithArray:
//                     [UIFont fontNamesForFamilyName:
//                      [familyNames objectAtIndex:indFamily]]];
//        for (indFont=0; indFont<[fontNames count]; ++indFont)
//        {
//            NSLog(@"Font name: %@", [fontNames objectAtIndex:indFont]);
//        }
//    }

    
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
        //[self performSelectorOnMainThread:@selector(unzipExistingJsonBooks) withObject:nil waitUntilDone:NO];
        
    }
    
//    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
//        //LoginNewViewController_iPhone
//        self.loginController = [[LoginNewViewController alloc] initWithNibName:@"LoginNewViewController_iPhone" bundle:nil];
//     //  _loginViewControllerIphone=[[LoginViewControllerIphone alloc]initWithNibName:@"LoginViewControllerIphone" bundle:nil];
//        CustomNavViewController *nav=[[CustomNavViewController alloc]initWithRootViewController:_loginController];
//        
//        self.window.rootViewController = nav;
//        [self.window makeKeyAndVisible];
//    } else {
    //NSString *bookId = @"5331442a69702d656a040000";
    NSString *bookId;
    NSString *pushCreateStory;
    NSString *pushSubscribe;
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        //[currentInstallation saveEventually];
    }
    
    if (launchOptions != nil)
    {
        NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {/*
            NSLog(@"receive the notifucation");
            if([dictionary objectForKey:@"bookid"]){
                bookId = [dictionary objectForKey:@"bookid"];
                NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
                [dimensions setObject:@"book_notification" forKey:PARAMETER_ACTION];
                [dimensions setObject:bookId forKey:PARAMETER_BOOK_ID];
                [dimensions setObject:@"Book notification click" forKey:PARAMETER_EVENT_DESCRIPTION];
                [self trackEventAnalytic:@"book_notification" dimensions:dimensions];
                [self eventAnalyticsDataBrowser:dimensions];
//                [self trackMixpanelEvents:dimensions eventName:@"book_notification"];
            }
            else if([[dictionary objectForKey:@"action"] isEqualToString:@"update"]){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                            @"itms-apps://itunes.apple.com/us/app/mangoreader-interactive-kids/id568003822?mt=8&uo=4"]];
                NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
                [dimensions setObject:@"update_notification" forKey:PARAMETER_ACTION];
                [dimensions setObject:@"Update notification click" forKey:PARAMETER_EVENT_DESCRIPTION];
                [self trackEventAnalytic:@"update_notification" dimensions:dimensions];
                [self eventAnalyticsDataBrowser:dimensions];
//                [self trackMixpanelEvents:dimensions eventName:@"update_notification"];
            }
            else if([[dictionary objectForKey:@"action"] isEqualToString:@"create"]){
                pushCreateStory = [dictionary objectForKey:@"action"];
                NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
                [dimensions setObject:@"create_notification" forKey:PARAMETER_ACTION];
                [dimensions setObject:@"Create notification click" forKey:PARAMETER_EVENT_DESCRIPTION];
                [self trackEventAnalytic:@"create_notification" dimensions:dimensions];
                [self eventAnalyticsDataBrowser:dimensions];
//                [self trackMixpanelEvents:dimensions eventName:@"create_notification"];
            }
            else if([[dictionary objectForKey:@"action"] isEqualToString:@"subscribe"]){
                pushSubscribe = [dictionary objectForKey:@"action"];
                NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
                [dimensions setObject:@"subscribe_notification" forKey:PARAMETER_ACTION];
                [dimensions setObject:@"Subscribe notification click" forKey:PARAMETER_EVENT_DESCRIPTION];
                [self trackEventAnalytic:@"subscribe_notification" dimensions:dimensions];
                [self eventAnalyticsDataBrowser:dimensions];
//                [self trackMixpanelEvents:dimensions eventName:@"subscribe_notification"];
            }*/
        }
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
     NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
        //validSubscription = 1;//test storyasapp
        //CustomNavViewController *nav;
        if (uiNew) {

            if ((path)&& (!validSubscription)) {
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    _loginController=[[LoginNewViewController alloc]initWithNibName:@"LoginNewViewController_iPhone" bundle:nil];
                }
                else{
                    _loginController=[[LoginNewViewController alloc]initWithNibName:@"LoginNewViewController" bundle:nil];
                }
                _loginController.pushSubscribe = pushSubscribe;
                _loginController.pushCreateStory = pushCreateStory;
                _loginController.pushNoteBookId = bookId;
                //nav=[[CustomNavViewController alloc]initWithRootViewController:_loginController];
                nav=[[UINavigationController alloc]initWithRootViewController:_loginController];
                
            }
            
            else {
                
                 if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                     _loginController=[[LoginNewViewController alloc]initWithNibName:@"LoginNewViewController_iPhone" bundle:nil];
                 }
                 else{
                     _loginController=[[LoginNewViewController alloc]initWithNibName:@"LoginNewViewController" bundle:nil];
                 }
                _loginController.pushSubscribe = pushSubscribe;
                _loginController.pushCreateStory = pushCreateStory;
                _loginController.pushNoteBookId = bookId;
                //nav=[[CustomNavViewController alloc]initWithRootViewController:_loginController];
                nav=[[UINavigationController alloc]initWithRootViewController:_loginController];
            }
            
        } else {
            _loginViewController=[[LoginViewController alloc]init];
        //nav=[[CustomNavViewController alloc]initWithRootViewController:_loginViewController];
            nav=[[UINavigationController alloc]initWithRootViewController:_loginViewController];
        }
        
        
        self.window.rootViewController = nav;
 
        [self.window makeKeyAndVisible];
    
//    }
        
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
    
    [Appirater appLaunched:YES];
    
    //int isFreeBooksApiCall = [[prefs valueForKey:@"ISFREEBOOKAPICALL"] integerValue];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    mixpanel.showNotificationOnActive = NO;
    [mixpanel registerSuperPropertiesOnce:@{PARAMETER_DEVICE_COUNTRY : _country,
                                            PARAMETER_DEVICE_LANGUAGE :_language,
                                            PLATFORM : IOS,
                                            PARAMETER_UUID : _uuidValue,
                                            PARAMETER_DEVICE_UDID : _uuidValue}];

    
//    if (!path){
//        if(!isFreeBooksApiCall){
//            //[self getAllFreeBooks];
//        }
//    }
    if(path && !validSubscription){
        //sleep(8.0);
    }
    return YES;
}

- (void)handleBackgroundNotification:(NSDictionary *)notification
{
    //NSDictionary *aps = (NSDictionary *)[notification objectForKey:@"aps"];
//    NSMutableString *alert = [NSMutableString stringWithString:@""];
//    if ([aps objectForKey:@"alert"])
//    {
//        [alert appendString:(NSString *)[aps objectForKey:@"alert"]];
//    }
//    if ([notification objectForKey:@"job_id"])
//    {
//        // do something with job id
//        int jobID = [[notification objectForKey:@"job_id"] intValue];
//    }
   // NSString *str = [NSString stringWithFormat:@"%@",aps];
   // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:str delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
   // [alert show];
    
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
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validUserSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    NSMutableArray *epubFles = [[NSMutableArray alloc] init];

    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self applicationDocumentsDirectory] error:nil];
    if([dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.zip'"]].count){
    [epubFles addObjectsFromArray:[dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.zip'"]]];
    }
        if (path && !validUserSubscription )  {
        //epubFles = [NSArray arrayWithObject:@"MangoStory"];
        [epubFles addObject:@"MangoStory"];
    }
    
    
    [epubFles removeObject:@" "];
    for (NSString *string in epubFles) {
        //location
        NSString *epubLocation=[[self applicationDocumentsDirectory] stringByAppendingPathComponent:string];
        if ([string isEqualToString:@"MangoStory"]) {
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

//Analytics

- (void)trackEvent:(NSString *)event dimensions:(NSDictionary *)dimensions {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    
    NSMutableDictionary *dimensionDict = [NSMutableDictionary dictionaryWithDictionary:dimensions];
    [dimensionDict setObject:_country forKey:PARAMETER_DEVICE_COUNTRY];
    [dimensionDict setObject:_language forKey:PARAMETER_DEVICE_LANGUAGE];
    if(path){
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        [dimensionDict setObject:bundleIdentifier forKey:PARAMETER_APP_NAME];
    }
    
    [PFAnalytics trackEvent:event dimensions:dimensionDict];
}

//New Analytics
- (void)trackEventAnalytic:(NSString *)event dimensions:(NSDictionary *)dimensions {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    
    NSMutableDictionary *dimensionDict = [NSMutableDictionary dictionaryWithDictionary:dimensions];
    [dimensionDict setObject:_country forKey:PARAMETER_DEVICE_COUNTRY];
    [dimensionDict setObject:_language forKey:PARAMETER_DEVICE_LANGUAGE];
    [dimensionDict setObject:IOS forKey:PLATFORM];
    [dimensionDict setObject:_uuidValue forKey:PARAMETER_UUID];
    [dimensionDict setObject:_udidValue forKey:PARAMETER_DEVICE_UDID];
    if(path){
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        [dimensionDict setObject:bundleIdentifier forKey:PARAMETER_APP_NAME];
    }
    
    [PFAnalytics trackEvent:event dimensions:dimensionDict];
}

- (void)eventAnalyticsDataBrowser :(NSDictionary *)dimensions{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    PFObject *userObject = [PFObject objectWithClassName:@"UserHistory"];
    [userObject setObject:_country forKey:PARAMETER_DEVICE_COUNTRY];
    [userObject setObject:_language forKey:PARAMETER_DEVICE_LANGUAGE];
    [userObject setObject:IOS forKey:PLATFORM];
    [userObject setObject:_uuidValue forKey:PARAMETER_UUID];
    [userObject setObject:_udidValue forKey:PARAMETER_DEVICE_UDID];
    [userObject setValuesForKeysWithDictionary:dimensions];
    if(path){
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        [userObject setObject:bundleIdentifier forKey:PARAMETER_APP_NAME];
    }
    [userObject saveInBackground];
}

- (void) trackMixpanelEvents : (NSDictionary *)properties eventName : (NSString *)event{
    
    Mixpanel *mixpanelTrack = [Mixpanel sharedInstance];
     [mixpanelTrack track:event properties:properties];
        if([properties valueForKey:PARAMETER_USER_EMAIL_ID] != nil){
            NSString *userIdValue = [properties valueForKey:PARAMETER_USER_EMAIL_ID];
            [mixpanelTrack identify:userIdValue];
            [mixpanelTrack.people set:properties];
        }
}

- (void)userHistoryAnalyticsDataBrowser :(NSDictionary *)dimensions{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    PFObject *userObject = [PFObject objectWithClassName:@"BookHistory"];
    [userObject setObject:_country forKey:PARAMETER_DEVICE_COUNTRY];
    [userObject setObject:_language forKey:PARAMETER_DEVICE_LANGUAGE];
    [userObject setObject:IOS forKey:PLATFORM];
    [userObject setObject:_uuidValue forKey:PARAMETER_UUID];
    [userObject setObject:_udidValue forKey:PARAMETER_DEVICE_UDID];
    [userObject setValuesForKeysWithDictionary:dimensions];
    if(path){
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        [userObject setObject:bundleIdentifier forKey:PARAMETER_APP_NAME];
    }
    [userObject saveInBackground];
}


-(void)getAllFreeBooks {
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    apiController.delegate = self;
    //[apiController getListOf:FREE_STORIES ForParameters:nil withDelegate:self];
    
    if(![self connected])
    {
        [MBProgressHUD hideAllHUDsForView:self.loginController.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please internet connection appears offline, please try later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else{
        [apiController getFreeBookInformation:FREE_STORIES withDelegate:self];
    }
}

- (void)freeBooksSetup : (NSArray *)booksInfo;{
    NSLog(@"gsadasjkda");
    for(int i =0; i< booksInfo.count; ++i){
        NSString *dirPath = [NSString stringWithFormat:@"%@/%@",[self applicationDocumentsDirectory], [[booksInfo objectAtIndex:i] objectForKey:@"id"]];
        NSError* error;
        NSLog(@"path:%@",dirPath);
        NSNumber *number = [NSNumber numberWithInt:1];
        NSData *data = [NSJSONSerialization dataWithJSONObject:[booksInfo objectAtIndex:i] options:NSJSONReadingMutableLeaves error:&error];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [_ejdbController parseBookJson:data   WithId:number AtLocation:dirPath];
        });
        
    }
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

-(void)SendToEJDB:(NSString *)locationDirectory WithId:(NSNumber *)numberId {
    
    NSString *value = [[locationDirectory componentsSeparatedByString:@"/"] lastObject];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validUserSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:locationDirectory error:nil];
    NSArray *epubFles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"]];
    
    NSString *actualJsonLocation=[locationDirectory stringByAppendingPathComponent:[epubFles firstObject]];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:actualJsonLocation];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    if ([value isEqualToString:@"MangoStory"]) {
        dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/MangoStory",[self applicationDocumentsDirectory]] error:nil];
        epubFles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"]];
        NSString *actualJsonLocation = [[NSString stringWithFormat:@"%@/MangoStory",[self applicationDocumentsDirectory]] stringByAppendingPathComponent:[epubFles firstObject]];
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:actualJsonLocation];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
        _mangoStoryId = [jsonDict objectForKey:@"id"];
        
        //int isStoryAsApp = [[prefs valueForKey:@"STORYASAPPCALL"] integerValue];
        
        
        //if(!isStoryAsApp){
        //    [_ejdbController parseBookJson:jsonData WithId:numberId AtLocation:[NSString stringWithFormat:@"%@/MangoStory",[self applicationDocumentsDirectory]]];
        //}
        
        [_ejdbController parseBookJson:jsonData WithId:numberId AtLocation:[NSString stringWithFormat:@"%@/MangoStory",[self applicationDocumentsDirectory]]];
        
        /*Book *book = [Book alloc];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        book= [delegate.dataModel getBookOfId:_mangoStoryId];
        NSString *jsonLocation=book.localPathFile;
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
        NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
        NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
        jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
        NSString *jsonContents=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
        
        UIImage *image=[MangoEditorViewController coverPageImageForStory:jsonContents WithFolderLocation:book.localPathFile];
        _coverController.coverImageView.image = image;*/
        _coverController.identity = _mangoStoryId;
        //_loginController.identity = _mangoStoryId;
        
    } else {
        [_ejdbController parseBookJson:jsonData WithId:numberId AtLocation:locationDirectory];
        
    }
}

+(NSString *) returnBookJsonPath:(Book *)book{
    
    //NSString *rPath = [[NSBundle mainBundle] resourcePath];
    //NSString *appPath = [rPath stringByReplacingOccurrencesOfString:@"MangoReader.app" withString:@""];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *lastElement = [[book.localPathFile componentsSeparatedByString:@"/"] lastObject];
    NSString *mangoStoryBookPathVal = [[book.localPathImageFile componentsSeparatedByString:@"/"] lastObject];
    
    NSString *jsonLocation;
    if([mangoStoryBookPathVal isEqualToString:@"MangoStory"]){
        jsonLocation = [NSString stringWithFormat:@"%@/%@",documentsDirectory,mangoStoryBookPathVal];
    }
    
    else if(book.parentBookId){
        jsonLocation = [NSString stringWithFormat:@"%@/%@",documentsDirectory,book.bookId];
    }
    
    else if([lastElement isEqualToString:@"MangoStory"]){
        
        jsonLocation = [NSString stringWithFormat:@"%@/%@",documentsDirectory, lastElement];
    }
    
    else{
        if(!book.id){
            jsonLocation = [NSString stringWithFormat:@"%@/%@",documentsDirectory,book.bookId];
        }
        else{
            jsonLocation = [NSString stringWithFormat:@"%@/%@",documentsDirectory,book.id];
        }
    }
    return jsonLocation;
}

//Merge two images for book
+ (UIImage*)mergeImage:(UIImage*)first withImage:(UIImage*)second
{
    // get size of the first image
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    
    // get size of the second image
    CGImageRef secondImageRef = second.CGImage;
   // CGFloat secondWidth = CGImageGetWidth(secondImageRef);
   // CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    CGFloat secondWidth = 120.f;
    CGFloat secondHeight = 120.f;
    
    // build merged size
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    
    // capture image context ref
    UIGraphicsBeginImageContext(mergedSize);
    
    //Draw images onto the context
    [first drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [second drawInRect:CGRectMake(0, 0, secondWidth, secondHeight)];
    
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
}


//save with folder name
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
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;

    //check for date value "dd-mm-yyyy" and then call and downlaod book download book and set counter
    //value and call method if active internet connection
    //"DATEDDMM_INDEX"
    NSDate *userDateAndIndex = [prefs valueForKey:@"EXPIRETRIALDATE"];
    if(!userDateAndIndex){
        
        NSDate *today = [NSDate date];
        NSDate *expireDate = [today dateByAddingTimeInterval:60*60*24*7];
        [prefs setObject:expireDate forKey:@"EXPIRETRIALDATE"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congrats" message:@"You have got a 7 days free unlimited access of Endless Stories!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
    NSArray *userSubscriptionObjects = [delegate.ejdbController getAllSubscriptionObjects];
    if ([userSubscriptionObjects count] > 0) {
        delegate.subscriptionInfo = [userSubscriptionObjects lastObject];
    }
    
    if(delegate.subscriptionInfo){
        
        NSDate *myDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName: @"PST"]];
        NSString *myCurrentDateString = [dateFormatter stringFromDate:myDate];
        NSDate *myCurrentDate = [dateFormatter dateFromString:myCurrentDateString];
        NSDate *expDate = [dateFormatter dateFromString:delegate.subscriptionInfo.subscriptionExpireDate];
        NSComparisonResult result;
        
        result = [myCurrentDate compare:expDate]; // comparing two dates
        
        if(result==NSOrderedAscending)
            NSLog(@"Product has validity");
        /*else*/if(1){
            NSLog(@"Product is expired then send the request to the server");
            
            NSString *productId = delegate.subscriptionInfo.subscriptionProductId;
            NSString *transctionId = delegate.subscriptionInfo.subscriptionTransctionId;
            NSString *amount = delegate.subscriptionInfo.subscriptionAmount;
            NSData *recieptData = delegate.subscriptionInfo.subscriptionReceiptData;
            
            /*[[MangoApiController sharedApiController] validateReceiptWithData:recieptData ForTransaction:transctionId amount:amount storyId:productId block:^(id response, NSInteger type, NSString *error) {
                // [delegate itemReadyToUse:productId ForTransaction:transactionId];
                if ([[response objectForKey:@"status"] integerValue] == 1) {
                    NSLog(@"SuccessResponse:%@" , response);
                    [prefs setBool:YES forKey:@"ISSUBSCRIPTIONVALID"];
                    
                    //  MangoSubscriptionViewController *mangoSunscription = [[MangoSubscriptionViewController alloc] init];
                    // [mangoSunscription itemReadyToUse:productId ForTransaction:transctionId withReciptData:recieptData andAmount:amount];
                }
                else {
                    NSLog(@"ReceiptError:%@", error);
                    //[prefs setBool:NO forKey:@"ISSUBSCRIPTIONVALID"];
                }
            }];*/
            NSString *sharedSecret = @"3c4367bb610d4e52af02de9cb63b2233";
            
            //[[MangoApiController sharedApiController] checkRecipt:recieptData passItunes:sharedSecret];
            [[MangoApiController sharedApiController] checkRecipt:recieptData passItunes:sharedSecret block:^(id response, NSInteger type, NSString *error) {
                
                NSLog(@"response object is %@", response);
                if([response objectForKey:@"ststus"] == 0){
                    
                    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:[response objectForKey:@"latest_receipt"] options:0];
                    //NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
                    UserSubscriptionViewController *userSunscription = [[UserSubscriptionViewController alloc] init];
                    [userSunscription itemReadyToUse:productId ForTransaction:transctionId withReciptData:decodedData Amount:amount andExpireDate:@"6/6/2020"];
                    
                    
                }
                else{
                    
                }
            }];
            
        }
        [prefs synchronize];
    }
    
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
    CGImageRelease(actualMask);
    UIImage *img = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
    return img;
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
    if (ver.integerValue==7) {
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

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
    
    NSString *token = [[newDeviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    _deviceTokenValue = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    //NSLog(@"content---%@", token);
    
//    Mixpanel *mixpanel = [Mixpanel sharedInstance];
//    [mixpanel.people addPushDeviceToken:newDeviceToken];
    
}

-(void)applicationWillEnterForeground:(UIApplication *)application{
    [Appirater appEnteredForeground:YES];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //[PFPush handlePush:userInfo];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    if (application.applicationState == UIApplicationStateActive ){
        
        if (userInfo != nil)
        {
            NSLog(@"open active notifucation");
            NSString *message = [[userInfo objectForKey:@"aps"]
                                 objectForKey:@"alert"];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@""
                                  message:message
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
        else{
            NSString *message = [[userInfo objectForKey:@"aps"]
                                 objectForKey:@"alert"];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@""
                                  message:message
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    else{
        if (userInfo != nil)
        {
            NSLog(@"background notifucation");
            if([userInfo objectForKey:@"bookid"]){
                NSString *bookId = [userInfo objectForKey:@"bookid"];
            
                MangoApiController *apiController = [MangoApiController sharedApiController];
                NSString *url;
                url = [LIVE_STORIES_WITH_ID stringByAppendingString:[NSString stringWithFormat:@"/%@",bookId]];
            
                [apiController getListOf:url ForParameters:nil withDelegate:self];
            }
            else if([userInfo objectForKey:@"update"]){
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                            @"itms-apps://itunes.apple.com/us/app/mangoreader-interactive-kids/id568003822?mt=8&uo=4"]];
            }
        }
        else{
            NSString *message = [[userInfo objectForKey:@"aps"]
                                 objectForKey:@"alert"];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@""
                                  message:message
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    
    NSDictionary *passDictionaryData;
    if(dataArray.count){
        passDictionaryData = dataArray[0];
    }
    else{
        passDictionaryData = nil;
    }
    //[self showBookDetailsForBook:passDictionaryData];
}

@end

