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
#import "MBProgressHUD.h"

@interface MangoApiController ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *imageOperationManager;
@property (nonatomic, strong) NSOperationQueue *downloadOperationQueue;
@property (nonatomic, strong) NSOperationQueue *freeBookQueue;

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
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        deviceid = delegate.deviceId;
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

- (void)validateReceiptWithData:(NSData *)rData ForTransaction:(NSString *)transactionId amount:(NSString *)amount storyId:(NSString *)storyId block:(void (^)(id response, NSInteger type, NSString * error))block {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    //NSString * password = @"3c4367bb610d4e52af02de9cb63b2233";
    NSString * userId = appDelegate.loggedInUserInfo.id;
    NSString * authToken = appDelegate.loggedInUserInfo.authToken;
    NSString * strMethod;
    NSDictionary *paramDict;
   // [self checkRecipt:rData :password];
  //  [self checkRecipt:rData passItunes:password];
    
    NSString *base64TxReceiptStr = [self base64EncodedStringFromData:rData];
    
    if (userId.length>5 && authToken.length >0) {
        //strMethod = ReceiptValidate_SignedIn;
        strMethod = SubscriptionValidate;
      //  paramDict = @{@"receipt_data":base64TxReceiptStr, @"amount":amount, @"user_id":userId, @"story_id":storyId};
        paramDict = @{@"receipt_data":base64TxReceiptStr, @"amount":amount, @"user_id":userId, @"subscription_id":storyId, @"udid":deviceid, VERSION:VERSION_NO, PLATFORM :IOS, ISMOBILE :ISMOBILEVALUE};
    }
    else {
        strMethod = SubscriptionValidate;
        paramDict = @{@"receipt_data":base64TxReceiptStr, @"amount":amount, @"subscription_id":storyId, @"udid":deviceid, VERSION:VERSION_NO, PLATFORM :IOS, ISMOBILE : ISMOBILEVALUE};
    }
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [manager POST:strMethod parameters:paramDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", operation.request);
        if (responseObject != nil) { block(responseObject, 1, nil);}//Successful
        else { block(nil, 0, @"Response is nil.");}//Errored
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Request:: %@", operation.request);
        NSLog(@"ResponseString:: %@", operation.responseString);
        block(nil, 0, [error localizedDescription]);//Errored
    }];
}


- (void) validateSubscription :(NSString *)TransctionId andDeviceId:(NSString *)deviceId block:(void (^)(id response, NSInteger type, NSString * error))block {
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString * userId = appDelegate.loggedInUserInfo.id;
    
    NSString * strMethod;
    NSDictionary *paramDict;
    if(userId){
        
        paramDict = @{ @"user_id":userId, @"udid":deviceId, VERSION:VERSION_NO, PLATFORM :IOS, ISMOBILE :ISMOBILEVALUE};
    }
    else if((!userId) && (TransctionId)) {
        paramDict = @{ @"transaction_id":TransctionId, @"udid":deviceId, VERSION:VERSION_NO, PLATFORM :IOS, ISMOBILE :ISMOBILEVALUE};
    }
    else{
        paramDict = @{ @"transaction_id":@"0", @"udid":deviceId, VERSION:VERSION_NO, PLATFORM :IOS, ISMOBILE : ISMOBILEVALUE};
    }
    //[paramDict setValue:VERSION_NO forKeyPath:VERSION];
    strMethod = SubscriptionStatus;
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [manager POST:strMethod parameters:paramDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", operation.request);
        if (responseObject != nil) { block(responseObject, 1, nil);}//Successful
        else { block(nil, 0, @"Response is nil.");}//Errored
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Request:: %@", operation.request);
        NSLog(@"ResponseString:: %@", operation.responseString);
        block(nil, 0, [error localizedDescription]);//Errored
    }];
    
}


-(void) checkRecipt : (NSData *)reciptdata passItunes :(NSString *) passstr{
    
    NSData *receipt; // Sent to the server by the device
    
    receipt = reciptdata;
    
    // Create the JSON object that describes the request
    NSError *error;
    NSDictionary *requestContents = @{
                                      @"receipt-data": [receipt base64EncodedStringWithOptions:0],
                                      @"password" : passstr
                                      };
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                          options:0
                                                            error:&error];
    
    if (!requestData) { /* ... Handle error ... */ }
    
    // Create a POST request with the receipt data.
    NSURL *storeURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];
    
    // Make a connection to the iTunes Store on a background queue.
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   /* ... Handle error ... */
                               } else {
                                   NSError *error;
                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   if (!jsonResponse) { /* ... Handle error ...*/ }
                                   /* ... Send a response back to the device ... */
                               }
                           }];
    
}
- (void)getObject:(NSString *)methodName ForParameters:(NSDictionary *)paramsDict WithDelegate:(id <MangoPostApiProtocol>) delegate {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSMutableDictionary *newParamDict = [[NSMutableDictionary alloc] init];
    [newParamDict setDictionary:paramsDict];
    [newParamDict setObject:VERSION_NO forKey:VERSION];
    [newParamDict setObject:IOS forKey:PLATFORM];
    [newParamDict setObject:ISMOBILEVALUE forKey:ISMOBILE];
    [manager GET:methodName parameters:newParamDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([delegate respondsToSelector:@selector(reloadWithObject:ForType:)]) {
            NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)responseObject];
            SKPaymentTransaction *transaction = [paramsDict objectForKey:@"transaction"];
            if ([methodName isEqualToString:[NSString stringWithFormat:OLD_STORY_INFO, transaction.originalTransaction.payment.productIdentifier]]) {
                [responseDict setObject:transaction forKey:@"transaction"];
            }
            [delegate reloadWithObject:responseDict ForType:methodName];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get Object Error: %@", error);
        
        if(!_alert.visible){
            _alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong please try later!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [_alert show];
        }
        
        if ([delegate respondsToSelector:@selector(reloadWithObject:ForType:)]) {
            [delegate reloadWithObject:nil ForType:methodName];
        }
    }];

}

- (void)getListOf:(NSString *)methodName ForParameters:(NSDictionary *)paramDictionary withDelegate:(id <MangoPostApiProtocol>)delegate {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSMutableDictionary *newParamDict = [[NSMutableDictionary alloc] init];
    [newParamDict setDictionary:paramDictionary];
    [newParamDict setObject:VERSION_NO forKey:VERSION];
    [newParamDict setObject:IOS forKey:PLATFORM];
    [newParamDict setObject:ISMOBILEVALUE forKey:ISMOBILE];
    [manager GET:methodName parameters:newParamDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Get List Response: %@", responseObject);
        NSArray *responseArray;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            responseArray = [NSArray arrayWithObject:(NSDictionary *)responseObject];
        } else {
            responseArray = (NSArray *)responseObject;
        }
        if ([delegate respondsToSelector:@selector(reloadViewsWithArray:ForType:)]) {
            [delegate reloadViewsWithArray:responseArray ForType:methodName];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get List Error: %@", error);
        if(!_alert.visible){
            _alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong please try later!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [_alert show];
        }
        
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
        //NSLog(@"Image error: %@ \n Attempting to get cover image...", error);
        //[self getImageAtUrl:[urlString stringByReplacingOccurrencesOfString:@"banner" withString:@"cover"] withDelegate:delegate];
    }];

    if (!_imageOperationManager) {
        _imageOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
        [_imageOperationManager.operationQueue setMaxConcurrentOperationCount:1];
    }
    [_imageOperationManager.operationQueue addOperation:imageRequestOperation];
    
    //[imageRequestOperation start];
}

- (void)loginWithEmail:(NSString *)email AndPassword:(NSString *)password IsNew:(BOOL)isNew Name:(NSString *)name {
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *methodName = isNew ? SIGN_UP:LOGIN;
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:email, password, nil] forKeys:[NSArray arrayWithObjects:EMAIL, PASSWORD, nil]];
    if (name) {
        [paramsDict setObject:name forKey:NAME];
        //[paramsDict setObject:IOS forKey:PLATFORM];//send platform = ios new
    }
    NSString *subscriptionTransctionId = appDelegate.subscriptionInfo.subscriptionTransctionId;
    if(subscriptionTransctionId){
        [paramsDict setObject:subscriptionTransctionId forKey:@"transaction_id"];
    }
    
    [paramsDict setObject:VERSION_NO forKey:VERSION];
    [paramsDict setObject:IOS forKey:PLATFORM];
    [paramsDict setObject:ISMOBILEVALUE forKey:ISMOBILE];
    [paramsDict setObject:appDelegate.country forKey:@"country"];
    
    [manager POST:methodName parameters:paramsDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        NSLog(@"Login Response: %@", responseObject);
        
        if(![responseObject valueForKey:@"auth_token"]){
            /*UIAlertView *responseError = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[responseObject valueForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [responseError show];*/
            [_delegate saveUserDetails:responseDict];
        }
        
        else if ([_delegate respondsToSelector:@selector(saveUserDetails:)]) {
            [_delegate saveUserDetails:responseDict];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Login Error: %@", error);
        
            if ([_delegate respondsToSelector:@selector(saveUserDetails:)]) {
                [_delegate saveUserDetails:nil];
            }
    }];
}


- (void)linkSubscriptionWithEmail:(NSString *)email {
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *subscriptionTransctionId = appDelegate.subscriptionInfo.subscriptionTransctionId;
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setObject:email forKey:EMAIL];
    [paramsDict setObject:IOS forKey:PLATFORM];//set platform = ios
    [paramsDict setObject:VERSION_NO forKey:VERSION];
    [paramsDict setObject:ISMOBILEVALUE forKey:ISMOBILE];
    [paramsDict setObject:subscriptionTransctionId forKey:@"transaction_id"];
    
    [manager POST:LINKSUBSCRIPTIONWITHEMAIL parameters:paramsDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Login Response: %@", responseObject);
        NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)responseObject];
        if ([_delegate respondsToSelector:@selector(getEmailLinkLoginDetails:)]) {
            [_delegate getEmailLinkLoginDetails:responseDict];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Login Error: %@", error);
        [_delegate saveUserDetails:nil];
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
    [paramsDict setObject:IOS forKey:PLATFORM];//set platform = ios
    [paramsDict setObject:ISMOBILEVALUE forKey:ISMOBILE];
    [paramsDict setObject:VERSION_NO forKey:VERSION];
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

- (void)downloadBookWithId:(NSString *)bookId withDelegate:(id <MangoPostApiProtocol>)delegate ForTransaction:(NSString *)transactionId {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!_downloadOperationQueue) {
        _downloadOperationQueue = [[NSOperationQueue alloc] init];
        [_downloadOperationQueue setMaxConcurrentOperationCount:1];
    }
    [_downloadOperationQueue addOperationWithBlock:^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSURL *URL;
        if (appDelegate.loggedInUserInfo) {
            
            NSString *userEmail = @"jagdish@mangosense.com";
            NSString *authToken = @"Mxje8kL6DxmNxxSzTzR9";
            //URL = [NSURL URLWithString:[BASE_URL stringByAppendingFormat:DOWNLOAD_STORY_LOGGED_IN, bookId, [appDelegate.loggedInUserInfo.email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], appDelegate.loggedInUserInfo.authToken, IOS, ISMOBILEVALUE]];
            URL = [NSURL URLWithString:[BASE_URL stringByAppendingFormat:DOWNLOAD_STORY_LOGGED_IN, bookId, [userEmail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], authToken, IOS, ISMOBILEVALUE]];
        } else {
            NSString *subscriptionMode = @"subscription";
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            int validSubscription = [[prefs valueForKey:@"ISAPPLECHECK"]integerValue];
            
            if(validSubscription){
                
                NSString *authtokenTest = @"0";
                NSString *userIdTest = @"0";
                
                URL = [NSURL URLWithString:[BASE_URL stringByAppendingFormat:DOWNLOAD_STORY_LOGGED_IN, bookId, [userIdTest stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], authtokenTest, IOS, ISMOBILEVALUE]];
                
            }
            else if(!transactionId){
               // URL = [NSURL URLWithString:[BASE_URL stringByAppendingFormat:DOWNLOAD_STORY_STORYOFTHEDAY, bookId,subscriptionMode, IOS, ISMOBILEVALUE]];
                
                NSString *userEmail = @"jagdish@mangosense.com";
                NSString *authToken = @"Mxje8kL6DxmNxxSzTzR9";
                
                URL = [NSURL URLWithString:[BASE_URL stringByAppendingFormat:DOWNLOAD_STORY_LOGGED_IN, bookId, [userEmail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], authToken, IOS, ISMOBILEVALUE]];
            }
            else{
                URL = [NSURL URLWithString:[BASE_URL stringByAppendingFormat:DOWNLOAD_STORY_LOGGED_OUT, bookId, transactionId,subscriptionMode, IOS, ISMOBILEVALUE]];
            }
            //URL = [NSURL URLWithString:[BASE_URL stringByAppendingFormat:DOWNLOAD_STORY_LOGGED_IN, bookId, [appDelegate.loggedInUserInfo.email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], appDelegate.loggedInUserInfo.authToken]];
        }
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setBool:NO forKey:@"ISAPPLECHECK"];

        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSProgress *downloadProgress;
        __block BOOL isDataPresent;
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&downloadProgress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            if (isDataPresent) {
                NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
                return [documentsDirectoryPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", bookId]];
            }
            return nil;
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if (isDataPresent) {
                NSLog(@"File downloaded to: %@", filePath);
                
                AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate unzipExistingJsonBooks];
                
                if(filePath){
                    
                    if ([delegate respondsToSelector:@selector(bookDownloaded)]) {
                        [delegate bookDownloaded];
                    }
                }
                
                else{
                    
                    if ([delegate respondsToSelector:@selector(bookDownloadAborted)]) {
                        [delegate bookDownloadAborted];
                    }
                }
            }
        }];
        [downloadTask resume];
        
        if ([delegate respondsToSelector:@selector(updateBookProgress:)]) {
            [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {

                if (totalBytesExpectedToWrite > 512*1000) {
                    isDataPresent = YES;
                }
                if (isDataPresent) {
                    if ([delegate respondsToSelector:@selector(updateBookProgress:)]) {
                        [delegate updateBookProgress:[[NSNumber numberWithDouble:totalBytesWritten*100/totalBytesExpectedToWrite] intValue]];
                        int value = [[NSNumber numberWithDouble:totalBytesWritten*100/totalBytesExpectedToWrite] intValue];
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:value], @"progressVal", bookId, @"bookIdVal", nil];
                        //[dict setObject:[NSNumber numberWithFloat:value] forKey:bookId];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"BookProgress" object:nil userInfo:dict];
                    }
                }
            }];
        }
    }];
}

- (void)saveBookWithId:(NSString *)bookId AndJSON:(NSString *)bookJSON {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:appDelegate.loggedInUserInfo.authToken, appDelegate.loggedInUserInfo.email, bookJSON,VERSION, PLATFORM, ISMOBILE, nil] forKeys:[NSArray arrayWithObjects:AUTH_TOKEN, EMAIL, BOOK_JSON, VERSION_NO, IOS, ISMOBILEVALUE, nil]];
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

- (void) getSubscriptionProductsInformation :(NSString *)methodName withDelegate:(id <MangoPostApiProtocol>)delegate{
    
    NSMutableDictionary *newParamDict = [[NSMutableDictionary alloc] init];
    [newParamDict setObject:VERSION_NO forKey:VERSION];
    [newParamDict setObject:IOS forKey:PLATFORM];
    [newParamDict setObject:ISMOBILEVALUE forKey:ISMOBILE];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [manager GET:methodName parameters:newParamDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Get List Response: %@", responseObject);
        NSArray *responseArray;
        if(([responseObject isKindOfClass:[NSArray class]]) && ([responseObject count] > 0)){
            
            [_delegate subscriptionSetup:responseObject];
        }
        else {
            if(!_alert.visible){
                _alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong please try later!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [_alert show];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get List Error: %@", error);
        
        if(!_alert.visible){
            _alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong please try later!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [_alert show];
        }
        
        if ([delegate respondsToSelector:@selector(reloadViewsWithArray:ForType:)]) {
            [delegate reloadViewsWithArray:[NSArray array] ForType:methodName];
        }
    }];
    
}

- (void) getFreeBookInformation :(NSString *)methodName withDelegate:(id <MangoPostApiProtocol>)delegate{
        
        NSMutableDictionary *newParamDict = [[NSMutableDictionary alloc] init];
        [newParamDict setObject:VERSION_NO forKey:VERSION];
        [newParamDict setObject:IOS forKey:PLATFORM];
        [newParamDict setObject:ISMOBILEVALUE forKey:ISMOBILE];
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [manager GET:methodName parameters:newParamDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Get List Response: %@", responseObject);
            //NSArray *responseArray;
            if(([responseObject isKindOfClass:[NSArray class]]) && ([responseObject count] > 0)){
                
                [_delegate freeBooksSetup:responseObject];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Some thing went wrong please try later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Get List Error: %@", error);
            
            if(!_alert.visible){
                _alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong please try later!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [_alert show];
            }
        }];
    
}


- (void)saveNewBookWithJSON:(NSString *)bookJSON {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[BASE_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    //Remove after Testing. TEMPORARY
    
    bookJSON = @"{\"title\": \"NewTestBookKedar\",\"language\": \"English\",\"pages\": [{\"id\": \"Cover\",\"name\": \"Cover\",\"layers\": []},{\"id\": 1,\"json\": {\"id\": 1,\"name\": 1,\"type\": \"page\",\"layers\": []}}]}";
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:appDelegate.loggedInUserInfo.authToken, appDelegate.loggedInUserInfo.email, bookJSON,VERSION, PLATFORM, ISMOBILE, nil] forKeys:[NSArray arrayWithObjects:AUTH_TOKEN, EMAIL, BOOK_JSON, VERSION_NO, IOS, ISMOBILEVALUE, nil]];

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
