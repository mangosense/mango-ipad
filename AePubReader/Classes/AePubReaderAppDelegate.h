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
#import "LoginNewViewController.h"
#import "EJDBController.h"
#import "UserInfo.h"
#import "BookDetailsViewController.h"
#import "CoverViewControllerBetterBookType.h"
#import "LandPageChoiceViewController.h"
#import "SubscriptionInfo.h"
#import "Appirater.h"

@class EPubViewController;
@class LoginViewController;
@class LandPageChoiceViewController;
@interface AePubReaderAppDelegate : NSObject <UIApplicationDelegate,UIAlertViewDelegate, MangoPostApiProtocol> {
    
   
        
   
}
@property (assign,nonatomic) BOOL prek;

@property (assign,nonatomic) BOOL addControlEvents;
@property (assign,nonatomic) BOOL completedStorePopulation;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) LoginViewController *loginViewController;
@property (nonatomic,strong) LoginViewControllerIphone *loginViewControllerIphone;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) DataModelControl *dataModel;
@property (nonatomic,assign) BOOL LandscapeOrientation;
@property (nonatomic,assign) BOOL PortraitOrientation;
@property (nonatomic,assign) BOOL wasFirstInPortrait;
@property (nonatomic,strong) NSString *location;
@property (assign,nonatomic) UIAlertView *alertView;
@property (assign,nonatomic) NSInteger identity;
@property (assign,nonatomic) BOOL popPurchase;
@property (assign,nonatomic) BOOL dismissAlertViewFlag;
@property (assign,nonatomic) BOOL downloadBook;
@property (assign,nonatomic) NSInteger options;
@property (assign,nonatomic) UIAlertView *dismissAlertView;
@property (strong,nonatomic) SKProduct *product;
@property (strong,nonatomic) SKPaymentTransaction *transaction;
@property (strong,nonatomic) LoginNewViewController *loginController;
@property (strong,nonatomic) LandPageChoiceViewController *landpageController;

@property (nonatomic, strong) UserInfo *loggedInUserInfo;
@property (nonatomic, strong) SubscriptionInfo *subscriptionInfo;
@property (nonatomic, assign) BOOL arePurchasesDownloading;

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
-(void)unzipExistingJsonBooks;
+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
+ (UIColor *) colorFromHexString:(NSString *)hexString;
+ (UIColor *)colorFromRgbString:(NSString *)rgbString;
- (void)showBookDetailsForBook:(NSDictionary *)bookDict WithDelegate:(id<BookViewProtocol>)delegate AndPresentingViewcontroller:(UIViewController *)presentingViewController;
- (void)trackEvent:(NSString *)event dimensions:(NSDictionary *)dimensions;

@property(assign,nonatomic) LandPageChoiceViewController *controller;
@property(retain,nonatomic) UIViewController *pageViewController;

@property (nonatomic, strong) EJDBController *ejdbController;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *mangoStoryId;
@property (nonatomic, strong) CoverViewControllerBetterBookType *coverController;
@property (nonatomic, strong) NSString *deviceId;

@property (nonatomic, strong) UIImageView *splashView;

@property (strong, nonatomic) UINavigationController *nav;

@end
