//
//  MangoApiController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 05/12/13.
//
//

#import "MangoApiController.h"
#import "AFHTTPRequestOperationManager.h"
#import "Constants.h"
#import "AFURLSessionManager.h"

@implementation MangoApiController

+ (id)sharedApiController {
    static MangoApiController *apiController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        apiController = [[self alloc] init];
    });
    return apiController;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - API Methods

- (void)validateReceiptWithData:(NSData *)rData  amount:(NSString *)amount storyId:(NSString *)storyId
                          block:(void (^)(id response, NSInteger type, NSString * error))block {
    
    NSUserDefaults * userdefaults = [NSUserDefaults standardUserDefaults];
    NSString * userId = [userdefaults objectForKey:USER_ID];
    NSString * authToken = [userdefaults objectForKey:AUTH_TOKEN];
    NSString * strMethod;
    NSDictionary *paramDict;
    
    if (userId.length>5 && authToken.length >0) {
        strMethod = ReceiptValidate_SignedIn;
        paramDict = @{@"receipt_data":rData, @"amount":amount, @"user_id":userId, @"story_id":storyId};
    }
    else {
        strMethod = ReceiptValidate_NotSignedIn;
        paramDict = @{@"receipt_data":rData, @"amount":amount, @"story_id":storyId};
    }
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [manager POST:strMethod parameters:paramDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject != nil) { block(responseObject, 1, nil);}//Successful
        else { block(nil, 0, @"Response is nil.");}//Errored
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Request:: %@", operation.request);
        NSLog(@"ResponseString:: %@", operation.responseString);
        block(nil, 0, [error localizedDescription]);//Errored
    }];
}

- (void)getListOf:(NSString *)methodName ForParameters:(NSDictionary *)paramDictionary withDelegate:(id <MangoPostApiProtocol>)delegate {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [manager GET:methodName parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Get List Response: %@", responseObject);
        if ([delegate respondsToSelector:@selector(reloadViewsWithArray:ForType:)]) {
            [delegate reloadViewsWithArray:(NSArray *)responseObject ForType:methodName];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get List Error: %@", error);
        if ([delegate respondsToSelector:@selector(reloadViewsWithArray:ForType:)]) {
            [delegate reloadViewsWithArray:[NSArray array] ForType:methodName];
        }
    }];
}

- (void)getImageAtUrl:(NSString *)urlString withDelegate:(id <MangoPostApiProtocol>)delegate {
    AFHTTPRequestOperation *imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    imageRequestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Image Response: %@", responseObject);
        if ([delegate respondsToSelector:@selector(reloadImage:forUrl:)]) {
            [delegate reloadImage:(UIImage *)responseObject forUrl:urlString];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image error: %@", error);
    }];
    [imageRequestOperation start];
}

- (void)loginWithEmail:(NSString *)email AndPassword:(NSString *)password {
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:EMAIL];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:email, password, nil] forKeys:[NSArray arrayWithObjects:EMAIL, PASSWORD, nil]];
    [manager POST:LOGIN parameters:paramsDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Login Response: %@", responseObject);
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        if ([_delegate respondsToSelector:@selector(saveUserDetails:)]) {
            [_delegate saveUserDetails:responseDict];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Login Error: %@", error);
    }];
}

- (void)downloadBookWithId:(NSString *)bookId {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSURL *URL = [NSURL URLWithString:[BASE_URL stringByAppendingFormat:DOWNLOAD_STORY, bookId, [[userDefaults objectForKey:EMAIL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [userDefaults objectForKey:AUTH_TOKEN]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        return [documentsDirectoryPath URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        if ([_delegate respondsToSelector:@selector(getBookAtPath:)]) {
            [_delegate getBookAtPath:filePath];
        }
    }];
    [downloadTask resume];
}

@end
