//
//  PurchaseManager.h
//  MangoReader
//
//  Created by Avinash Nehra on 1/31/14.
//
//

#import <Foundation/Foundation.h>

@protocol PurchaseManagerProtocol <NSObject>

- (void)itemReadyToUse:(NSString *)productID;

@end

@interface PurchaseManager : NSObject

+ (id)sharedManager;
- (void)itemProceedToPurchase :(NSString *)productId storeIdentifier:(NSString *)productIdentifier withDelegate:(id<PurchaseManagerProtocol>)delegate;

@end
