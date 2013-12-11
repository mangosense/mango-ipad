//
//  MangoApiController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 05/12/13.
//
//

#import <Foundation/Foundation.h>

@protocol MangoPostApiProtocol

@optional
- (void)reloadViewsWithArray:(NSArray *)dataArray;
- (void)reloadImage:(UIImage *)image forUrl:(NSString *)urlString;

@end

@interface MangoApiController : NSObject

@property (nonatomic, assign) id <MangoPostApiProtocol> delegate;
+ (id)sharedApiController;
- (void)getListOf:(NSString *)methodName ForParameters:(NSDictionary *)paramDictionary;
- (void)getImageAtUrl:(NSString *)urlString;

@end
