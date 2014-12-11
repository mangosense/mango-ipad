//
//  RecieptValidationIphone.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 10/12/12.
//
//

#import <Foundation/Foundation.h>
#import "DetailStoreViewController.h"
#import "LiveViewControllerIphone.h"
#import <StoreKit/StoreKit.h>
@interface RecieptValidationIphone : NSObject<NSURLConnectionDataDelegate>
@property(nonatomic,retain)NSMutableData *dataMutable;
@property(nonatomic,assign)LiveViewControllerIphone *live;
@property(nonatomic,assign)DetailStoreViewController *detail;
@property(nonatomic,retain) SKPaymentTransaction *transaction;
@property(nonatomic,assign)BOOL signIn;
-(id)initWithDetails:(DetailStoreViewController *)detail live:(LiveViewControllerIphone *)live identity:(NSInteger)indentity withTrans:(SKPaymentTransaction *)trans;
@end
