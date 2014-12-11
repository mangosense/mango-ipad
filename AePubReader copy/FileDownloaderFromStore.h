//
//  FileDownloaderFromStore.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/12.
//
//

#import <Foundation/Foundation.h>
#import "PruchaseFree.h"
#import "LiveViewController.h"
#import "PopPurchaseViewController.h"
@interface FileDownloaderFromStore : NSObject<NSURLConnectionDataDelegate>{
    BOOL somethinRemains;
}
@property(nonatomic,retain)NSMutableData *mutableData;
@property(nonatomic,retain)NSString *loc;
@property(nonatomic,retain)NSFileHandle *handle;
@property(nonatomic,assign)float value;
@property(nonatomic,retain)UIProgressView *progress;
@property(nonatomic,assign) LiveViewController *liveController;
@property(nonatomic,assign)PopPurchaseViewController *popPurchaseController;
@property(nonatomic,assign)long sizeLenght;
-(id)initWithLiveViewController:(LiveViewController *)liveViewController andWith:(PopPurchaseViewController *)PopPurchaseViewController;
@end
