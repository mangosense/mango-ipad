//
//  PurchaseFreeIphone.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 10/12/12.
//
//

#import <Foundation/Foundation.h>
#import "DetailStoreViewController.h"
#import "LiveViewControllerIphone.h"
@interface PurchaseFreeIphone : NSObject<NSURLConnectionDataDelegate>
@property (nonatomic,retain)NSMutableData *mutableData;
@property(nonatomic,assign)LiveViewControllerIphone *live;
@property(nonatomic,assign)DetailStoreViewController *detail;
@property(nonatomic,assign)NSInteger identity;
-(id)initWithDetails:(DetailStoreViewController *)detail live:(LiveViewControllerIphone *)live identity:(NSInteger)indentity;
@end
