//
//  BookDownloaderIphone.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 04/12/12.
//
//

#import <Foundation/Foundation.h>
#import "DownloadViewController.h"
#import "MyBooksViewControlleriPhone.h"
@interface BookDownloaderIphone : NSObject<NSURLConnectionDataDelegate>{
    BOOL somethinRemains;
}
@property(nonatomic,retain) NSMutableData *data;
@property(nonatomic,assign)MyBooksViewControlleriPhone *myBookViewController;
@property(nonatomic,retain)NSString *loc;
@property(nonatomic,retain)NSFileHandle *handle;
@property(nonatomic,assign)float value;
@property(nonatomic,retain)UIProgressView *progress;
@property(nonatomic,retain)Book *book;
@property(nonatomic,assign)long sizeLenght;
-(id)initWithViewController:(MyBooksViewControlleriPhone *)store;
@end
