//
//  SubscriptionInfo.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 15/04/14.
//
//

#import <Foundation/Foundation.h>
#import "EJDBKit/BSONArchiving.h"

@interface SubscriptionInfo : NSObject<BSONArchiving,NSCopying>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *subscriptionProductId;
@property (nonatomic, strong) NSString *subscriptionTransctionId;
@property (nonatomic, strong) NSData *subscriptionReceiptData;
@property (nonatomic, strong) NSString *subscriptionAmount;

@end
