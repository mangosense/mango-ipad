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
- (void)saveStoryId:(NSNumber *)storyId;

@end

@interface MangoApiController : NSObject

@property (nonatomic, assign) id <MangoPostApiProtocol> delegate;

+ (id)sharedApiController;

- (void)getListOf:(NSString *)methodName ForParameters:(NSDictionary *)paramDictionary withDelegate:(id <MangoPostApiProtocol>)delegate;
- (void)getImageAtUrl:(NSString *)urlString withDelegate:(id <MangoPostApiProtocol>)delegate;
- (void)loginWithEmail:(NSString *)email AndPassword:(NSString *)password IsNew:(BOOL)isNew;
- (void)downloadBookWithId:(NSString *)bookId withDelegate:(id <MangoPostApiProtocol>)delegate;
- (void)saveBookWithId:(NSString *)bookId AndJSON:(NSString *)bookJSON;
- (void)saveNewBookWithJSON:(NSString *)bookJSON;
- (void)downloadBookWithId:(NSString *)bookId withDelegate:(id <MangoPostApiProtocol>)delegate;

#pragma mark - Validate Receipt
- (void)validateReceiptWithData:(NSData *)rData  amount:(NSString *)amount storyId:(NSString *)storyId block:(void (^)(id response, NSInteger type, NSString * error))block;

@end
