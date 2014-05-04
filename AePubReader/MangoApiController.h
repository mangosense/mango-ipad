//
//  MangoApiController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 05/12/13.
//
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@protocol MangoPostApiProtocol <NSObject>

@optional
- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type;
- (void)reloadWithObject:(NSDictionary *)responseObject ForType:(NSString *)type;
- (void)reloadImage:(UIImage *)image forUrl:(NSString *)urlString;
- (void)saveUserDetails:(NSDictionary *)userDetailsDictionary;
- (void)getBookAtPath:(NSURL *)filePath;
- (void)saveStoryId:(NSNumber *)storyId;
- (void)updateBookProgress:(int)progress;
- (void)bookDownloaded;
- (void)saveFacebookDetails:(NSDictionary *)facebookDetailsDictionary;

@end

@interface MangoApiController : NSObject{
    
    NSString *deviceid;
}

@property (nonatomic, assign) id <MangoPostApiProtocol> delegate;

+ (id)sharedApiController;

- (void)getListOf:(NSString *)methodName ForParameters:(NSDictionary *)paramDictionary withDelegate:(id <MangoPostApiProtocol>)delegate;
- (void)getObject:(NSString *)methodName ForParameters:(NSDictionary *)paramsDict WithDelegate:(id <MangoPostApiProtocol>) delegate;
- (void)getImageAtUrl:(NSString *)urlString withDelegate:(id <MangoPostApiProtocol>)delegate;
- (void)loginWithEmail:(NSString *)email AndPassword:(NSString *)password IsNew:(BOOL)isNew Name:(NSString *)name;
- (void)saveBookWithId:(NSString *)bookId AndJSON:(NSString *)bookJSON;
- (void)saveNewBookWithJSON:(NSString *)bookJSON;
- (void)downloadBookWithId:(NSString *)bookId withDelegate:(id <MangoPostApiProtocol>)delegate ForTransaction:(NSString *)transactionId;
- (void)loginWithFacebookDetails:(NSDictionary *)facebookDetailsDictionary;

#pragma mark - Validate Receipt
- (void)validateReceiptWithData:(NSData *)rData ForTransaction:(NSString *)transactionId amount:(NSString *)amount storyId:(NSString *)storyId block:(void (^)(id response, NSInteger type, NSString * error))block;
- (void) validateSubscription :(NSString *)userIdOrTransctionId andDeviceId:(NSString *)deviceId block:(void (^)(id response, NSInteger type, NSString * error))block;
@end
