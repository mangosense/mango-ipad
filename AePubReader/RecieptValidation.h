//
//  RecieptValidation.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 17/11/12.
//
//

#import <Foundation/Foundation.h>
#import "PopPurchaseViewController.h"
#import "LiveViewController.h"

#import "LibraryViewController.h"
@interface RecieptValidation : NSObject<NSURLConnectionDataDelegate,UIAlertViewDelegate>
@property(retain,nonatomic) NSMutableData *mutableData;
@property(nonatomic,assign)PopPurchaseViewController *popPurchase;
@property(nonatomic,assign) LiveViewController *liveViewController;
@property(nonatomic,assign)NSInteger identity;
@property(nonatomic,retain)SKPaymentTransaction *transaction;
@property(assign,nonatomic)BOOL signedIn;
-(id)initWithPop:(PopPurchaseViewController *)popPurchase LiveController:(LiveViewController *)liveViewController fileLink:(NSInteger)downloadLink transaction:(SKPaymentTransaction *)trans;
@end
