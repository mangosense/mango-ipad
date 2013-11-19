//
//  AePubReaderAppDelegate.h
//  AePubReader
//
//  Created by Federico Frappi on 04/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModelControl.h"
#import <CoreData/CoreData.h>
#import <StoreKit/StoreKit.h>
#import "LoginViewControllerIphone.h"
#import "LoginViewController.h"
#import "Appirater.h"
@class EPubViewController;
@class LoginViewController;
@interface AePubReaderAppDelegate : NSObject <UIApplicationDelegate,SKPaymentTransactionObserver,UIAlertViewDelegate,SKProductsRequestDelegate> {
    
   
        
   
}
@property(assign,nonatomic) BOOL prek;

@property(assign,nonatomic)BOOL addControlEvents;
@property(assign,nonatomic)BOOL completedStorePopulation;
@property (nonatomic, retain)  UIWindow *window;
//@property(nonatomic,retain) NSString *baseURL;
//@property(nonatomic,retain)NSString *authToken;
@property (nonatomic, retain) LoginViewController *loginViewController;
@property(nonatomic,strong)LoginViewControllerIphone *loginViewControllerIphone;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) DataModelControl *dataModel;
@property(nonatomic,assign)BOOL LandscapeOrientation;
@property(nonatomic,assign)BOOL PortraitOrientation;
@property(nonatomic,assign)BOOL wasFirstInPortrait;
@property(nonatomic,strong)NSString *location;
@property(assign,nonatomic)UIAlertView *alertView;
//@property(strong,nonatomic)NSDecimalNumber *price;
@property(assign,nonatomic)NSInteger identity;
@property(assign,nonatomic)BOOL popPurchase;
@property(assign,nonatomic)BOOL dismissAlertViewFlag;
@property(assign,nonatomic)BOOL downloadBook;
@property(assign,nonatomic)NSInteger options;
@property(assign,nonatomic)UIAlertView *dismissAlertView;
@property(strong,nonatomic)SKProduct *product;
@property(strong,nonatomic)SKPaymentTransaction *transaction;
-(void)removeBackDirectory;
- (NSString *)applicationDocumentsDirectory;
- (void)unzipAndSaveFile:(NSString *) location with:(NSInteger ) identity;
-(void)insertInStore;
+(void)adjustForIOS7:(UIView *) view;
+(void)showAlertView;
+(UIAlertView *) getAlertView;
+(void)hideAlertView;
+(void)showAlertViewiPad;
+(void)hideTabBar:(UITabBarController *)tabbarcontroller;
@end
