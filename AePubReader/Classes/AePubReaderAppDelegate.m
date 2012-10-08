//
//  AePubReaderAppDelegate.m
//  AePubReader
//
//  Created by Federico Frappi on 04/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AePubReaderAppDelegate.h"


#import "EPubViewController.h"
#import "LoginViewController.h"
//#import <Social/Social.h>
#import <Socialize/Socialize.h>
@implementation AePubReaderAppDelegate

@synthesize window;
@synthesize managedObjectContext,managedObjectModel,persistentStoreCoordinator;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch.
    _loginViewController=[[LoginViewController alloc]init];
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:_loginViewController];
    [_loginViewController release];
    self.window.rootViewController = nav;
    [nav release];
    [self.window makeKeyAndVisible];
//    [Socialize storeConsumerKey:@"aedcb46f-9e28-4729-907f-83d7734a4b22"];
//    [Socialize storeConsumerSecret:@"781b76d1-e0eb-42e2-bdd5-5bcb3be95f48"];
//    [SZTwitterUtils consumerKey:""];
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"baseurl"]) {
         [userDefaults setObject:@"http://www.mangoreader.com/api/v1/" forKey:@"baseurl"];
    }
   
    _dataModel=[[DataModelControl alloc]initWithContext:[self managedObjectContext]];
   
    return YES;
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
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"MangoReader.sqlite"]];
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil URL:storeUrl options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
- (void)dealloc {
    [window release];
    
    [super dealloc];
}


@end

