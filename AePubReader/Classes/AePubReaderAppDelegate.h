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


@class EPubViewController;
@class LoginViewController;
@interface AePubReaderAppDelegate : NSObject <UIApplicationDelegate> {
    
   
        
   
}

@property (nonatomic, retain)  UIWindow *window;
//@property(nonatomic,retain) NSString *baseURL;
//@property(nonatomic,retain)NSString *authToken;
@property (nonatomic, retain) LoginViewController *loginViewController;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) DataModelControl *dataModel;
@property(nonatomic,assign)BOOL LandscapeOrientation;
@property(nonatomic,assign)BOOL PortraitOrientation;
@property(nonatomic,assign)BOOL wasFirstInPortrait;
@property(assign,nonatomic)UIAlertView *alertView;

@property(assign,nonatomic)BOOL popPurchase;
@property(assign,nonatomic)BOOL dismissAlertViewFlag;
@property(assign,nonatomic)UIAlertView *dismissAlertView;
- (NSString *)applicationDocumentsDirectory;
- (void)unzipAndSaveFile:(NSString *) location with:(NSInteger ) identity;
@end
