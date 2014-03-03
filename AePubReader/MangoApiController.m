//
//  MangoApiController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 05/12/13.
//
//

#import "AFNetworking.h"
#import "MangoApiController.h"
#import "AFHTTPRequestOperationManager.h"
#import "Constants.h"
#import "AFURLSessionManager.h"
#import "AePubReaderAppDelegate.h"

@interface MangoApiController ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *imageOperationManager;
@property (nonatomic, strong) NSOperationQueue *downloadOperationQueue;

@end

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

#pragma mark - Data Encoding Methods

- (NSString *)base64EncodedStringFromData:(NSData *)data {
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

#pragma mark - API Methods

- (void)validateReceiptWithData:(NSData *)rData  amount:(NSString *)amount storyId:(NSString *)storyId
                          block:(void (^)(id response, NSInteger type, NSString * error))block {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];

    NSString * userId = appDelegate.loggedInUserInfo.id;
    NSString * authToken = appDelegate.loggedInUserInfo.authToken;
    NSString * strMethod;
    NSDictionary *paramDict;
    
    NSString *base64TxReceiptStr = [self base64EncodedStringFromData:rData];
    
    if (userId.length>5 && authToken.length >0) {
        strMethod = ReceiptValidate_SignedIn;
        paramDict = @{@"receipt_data":base64TxReceiptStr, @"amount":amount, @"user_id":userId, @"story_id":storyId};
    }
    else {
        strMethod = ReceiptValidate_NotSignedIn;
        paramDict = @{@"receipt_data":base64TxReceiptStr, @"amount":amount, @"story_id":storyId};
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
        //NSLog(@"Image Response: %@", responseObject);
        if ([delegate respondsToSelector:@selector(reloadImage:forUrl:)]) {
            [delegate reloadImage:(UIImage *)responseObject forUrl:urlString];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image error: %@ \n Attempting to get cover image...", error);
        [self getImageAtUrl:[urlString stringByReplacingOccurrencesOfString:@"banner" withString:@"cover"] withDelegate:delegate];
    }];

    if (!_imageOperationManager) {
        _imageOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
        [_imageOperationManager.operationQueue setMaxConcurrentOperationCount:2];
    }
    [_imageOperationManager.operationQueue addOperation:imageRequestOperation];
    
    //[imageRequestOperation start];
}

- (void)loginWithEmail:(NSString *)email AndPassword:(NSString *)password IsNew:(BOOL)isNew Name:(NSString *)name {    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *methodName = isNew ? SIGN_UP:LOGIN;
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:email, password, nil] forKeys:[NSArray arrayWithObjects:EMAIL, PASSWORD, nil]];
    if (name) {
        [paramsDict setObject:name forKey:NAME];
    }
    [manager POST:methodName parameters:paramsDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Login Response: %@", responseObject);
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        if ([_delegate respondsToSelector:@selector(saveUserDetails:)]) {
            [_delegate saveUserDetails:responseDict];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Login Error: %@", error);
        if ([_delegate respondsToSelector:@selector(saveUserDetails:)]) {
            [_delegate saveUserDetails:@{}];
        }
    }];
}

- (void)loginWithFacebookDetails:(NSDictionary *)facebookDetailsDictionary {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setObject:[facebookDetailsDictionary objectForKey:EMAIL] forKey:EMAIL];
    [paramsDict setObject:[facebookDetailsDictionary objectForKey:@"id"] forKey:@"id"];
    [paramsDict setObject:[facebookDetailsDictionary objectForKey:AUTH_TOKEN] forKey:AUTH_TOKEN];
    [paramsDict setObject:[facebookDetailsDictionary objectForKey:FACEBOOK_TOKEN_EXPIRATION_DATE] forKey:FACEBOOK_TOKEN_EXPIRATION_DATE];
    [paramsDict setObject:[facebookDetailsDictionary objectForKey:USERNAME] forKey:USERNAME];
    [paramsDict setObject:[facebookDetailsDictionary objectForKey:NAME] forKey:NAME];
    
    [manager POST:FACEBOOK_LOGIN parameters:paramsDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Login Response: %@", responseObject);
        NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)responseObject];
        [responseDict setObject:[paramsDict objectForKey:USERNAME] forKey:USERNAME];
        [responseDict setObject:[paramsDict objectForKey:NAME] forKey:NAME];
        if ([_delegate respondsToSelector:@selector(saveFacebookDetails:)]) {
            [_delegate saveFacebookDetails:responseDict];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Login Error: %@", error);
    }];

}

- (void)downloadBookWithId:(NSString *)bookId withDelegate:(id <MangoPostApiProtocol>)delegate {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    /*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:bookId];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *op = [manager GET:[BASE_URL stringByAppendingFormat:DOWNLOAD_STORY, bookId, [[userDefaults objectForKey:EMAIL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [userDefaults objectForKey:AUTH_TOKEN]]
                                   parameters:nil
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          NSLog(@"successful download to %@", path);
                                          if ([delegate respondsToSelector:@selector(getBookAtPath:)]) {
                                              [delegate getBookAtPath:[NSURL URLWithString:path]];
                                          }
                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error: %@", error);
                                      }];
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];*/
    
    //////--------
    
    if (!_downloadOperationQueue) {
        _downloadOperationQueue = [[NSOperationQueue alloc] init];
        [_downloadOperationQueue setMaxConcurrentOperationCount:1];
    }
    [_downloadOperationQueue addOperationWithBlock:^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSURL *URL = [NSURL URLWithString:[BASE_URL stringByAppendingFormat:DOWNLOAD_STORY, bookId, [appDelegate.loggedInUserInfo.email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], appDelegate.loggedInUserInfo.authToken]];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSProgress *downloadProgress;
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&downloadProgress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
            return [documentsDirectoryPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", bookId]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSLog(@"File downloaded to: %@", filePath);
            
            AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate unzipExistingJsonBooks];
            
            if ([delegate respondsToSelector:@selector(bookDownloaded)]) {
                [delegate bookDownloaded];
            }
        }];
        [downloadTask resume];
        
        [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            NSLog(@"Progress… %lld", totalBytesWritten*100/totalBytesExpectedToWrite);
            if ([delegate respondsToSelector:@selector(updateBookProgress:)]) {
                [delegate updateBookProgress:[[NSNumber numberWithDouble:totalBytesWritten*100/totalBytesExpectedToWrite] intValue]];
            }
        }];
    }];
}

- (void)saveBookWithId:(NSString *)bookId AndJSON:(NSString *)bookJSON {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:appDelegate.loggedInUserInfo.authToken, appDelegate.loggedInUserInfo.email, bookJSON, nil] forKeys:[NSArray arrayWithObjects:AUTH_TOKEN, EMAIL, BOOK_JSON, nil]];
    NSString *methodName = [NSString stringWithFormat:SAVE_STORY, bookId];
    [manager POST:methodName parameters:paramsDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Save Story Response: %@", responseObject);
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        if ([_delegate respondsToSelector:@selector(saveStoryId:)]) {
            [_delegate saveStoryId:[responseDict objectForKey:@"id"]];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Save Story Error: %@", error);
    }];
}

- (void)saveNewBookWithJSON:(NSString *)bookJSON {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    //Remove after Testing. TEMPORARY
    
    bookJSON = @"{\"title\": \"NewTestBookKedar\",\"language\": \"English\",\"pages\": [{\"id\": \"Cover\",\"name\": \"Cover\",\"layers\": []},{\"id\": 1,\"json\": {\"id\": 1,\"name\": 1,\"type\": \"page\",\"layers\": []}}]}";
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:appDelegate.loggedInUserInfo.authToken, appDelegate.loggedInUserInfo.email, bookJSON, nil] forKeys:[NSArray arrayWithObjects:AUTH_TOKEN, EMAIL, BOOK_JSON, nil]];

    [manager POST:NEW_STORY parameters:paramsDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Save Story Response: %@", responseObject);
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        if ([_delegate respondsToSelector:@selector(saveStoryId:)]) {
            [_delegate saveStoryId:[responseDict objectForKey:@"id"]];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Save Story Error: %@", error);
    }];
}

@end
