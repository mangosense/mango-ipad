//
//  MangoApiController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 05/12/13.
//
//

#import <Foundation/Foundation.h>

@protocol MangoPostApiProtocol <NSObject>

@optional
- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type;
- (void)reloadImage:(UIImage *)image forUrl:(NSString *)urlString;
- (void)saveUserDetails:(NSDictionary *)userDetailsDictionary;
- (void)getBookAtPath:(NSURL *)filePath;

@end

@interface MangoApiController : NSObject

@property (nonatomic, assign) id <MangoPostApiProtocol> delegate;

+ (id)sharedApiController;

- (void)getListOf:(NSString *)methodName ForParameters:(NSDictionary *)paramDictionary withDelegate:(id <MangoPostApiProtocol>)delegate;
- (void)getImageAtUrl:(NSString *)urlString;
- (void)loginWithEmail:(NSString *)email AndPassword:(NSString *)password;
- (void)downloadBookWithId:(NSString *)bookId;

#pragma mark - Validate Receipt
- (void)validateReceiptWithData:(NSData *)rData  amount:(NSString *)amount storyId:(NSString *)storyId
                          block:(void (^)(id response, NSInteger type, NSString * error))block ;

@end
