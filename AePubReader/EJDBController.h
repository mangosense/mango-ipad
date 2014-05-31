//
//  EJDBController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 26/11/13.
//
//

#import <Foundation/Foundation.h>
#import "EJDBKit/EJDBKit.h"
#import "MangoBook.h"
#import "MangoPage.h"
#import "MangoLayer.h"
#import "MangoImageLayer.h"
#import "MangoTextLayer.h"
#import "MangoAudioLayer.h"
#import "UserInfo.h"
#import "SubscriptionInfo.h"

@interface EJDBController : NSObject

@property (nonatomic, strong) EJDBCollection *collection;
@property (nonatomic, strong) EJDBDatabase *db;

- (id)initWithCollectionName:(NSString *)collectionName andDatabaseName:(NSString *)databaseName;
- (BOOL)insertOrUpdateObject:(id)object;
- (void)parseBookJson:(NSData *)bookJsonData WithId:(NSNumber *)numberId AtLocation:(NSString *)filePath;

- (NSArray *)getAllUserInfoObjects;
- (NSArray *)getAllSubscriptionInfoObjects;
- (NSArray *)getAllSubscriptionObjects;
- (UserInfo *)getUserInfoForId:(NSString *)userId;
- (MangoBook *)getBookForBookId:(NSString *)bookId;
- (MangoPage *)getPageForPageId:(NSString *)pageId;
- (id)getLayerForLayerId:(NSString *)layerId;
- (void)saveBook:(MangoBook *)book AtLocation:(NSString *)filePath WithEJDBId:(NSString *)ejdbId;

- (BOOL)deleteObject:(id)object;
- (BOOL)deleteSubscriptionObject:(SubscriptionInfo *)subInfo;

@end
