//
//  SyncIpadConnection.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 20/12/12.
//
//

#import <Foundation/Foundation.h>
#import "DownloadViewControlleriPad.h"
#import "DownloadViewController.h"
@interface SyncIpadConnection : NSObject<NSURLConnectionDataDelegate>

@property(nonatomic,retain)NSMutableData *data;
@property(nonatomic,assign)DownloadViewControlleriPad *store;
-(id)init;
@property(nonatomic,assign)DownloadViewController *download;
@end
