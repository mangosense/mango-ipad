//
//  SubscriptionInfo.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 15/04/14.
//
//

#import <Foundation/Foundation.h>

@interface SubscriptionInfo : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *expirationDate;
@property (nonatomic, strong) NSString *type;

@end
