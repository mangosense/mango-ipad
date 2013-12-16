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

- (void)getListOf:(NSString *)methodName ForParameters:(NSDictionary *)paramDictionary {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    [manager GET:methodName parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Get List Response: %@", responseObject);
        [_delegate reloadViewsWithArray:(NSArray *)responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get List Error: %@", [error localizedDescription]);
    }];
}

- (void)getImageAtUrl:(NSString *)urlString {
    AFHTTPRequestOperation *imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    imageRequestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Image Response: %@", responseObject);
        [_delegate reloadImage:(UIImage *)responseObject forUrl:urlString];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image error: %@", [error localizedDescription]);
    }];
    [imageRequestOperation start];
}

- (void)loginWithEmail:(NSString *)email AndPassword:(NSString *)password {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:email, password, nil] forKeys:[NSArray arrayWithObjects:@"username", @"pass", nil]];
    [manager POST:LOGIN parameters:paramsDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Login Response: %@", responseObject);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Login Error: %@", error);
    }];
}

@end
