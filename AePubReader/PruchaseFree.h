//
//  PruchaseFree.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 19/11/12.
//
//

#import <Foundation/Foundation.h>
#import "PopPurchaseViewController.h"
#import "LiveViewController.h"
@interface PruchaseFree : NSObject<NSURLConnectionDataDelegate,UIAlertViewDelegate>
@property(nonatomic,retain)NSMutableData *mutableData;
@property(nonatomic,assign)PopPurchaseViewController *popPurchase;
@property(nonatomic,assign) LiveViewController *liveViewController;
@property(nonatomic,retain)NSString *downLoadLink;
@property(nonatomic,assign)NSInteger identity;
-(id)initWithPop:(PopPurchaseViewController *)popPurchase LiveController:(LiveViewController *)liveViewController fileLink:(NSInteger)downloadLink;
@end
