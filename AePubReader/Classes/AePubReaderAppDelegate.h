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

- (NSString *)applicationDocumentsDirectory;
@end
