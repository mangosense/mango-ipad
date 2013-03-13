//
//  BookDownloaderIphone.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 04/12/12.
//
//

#import <Foundation/Foundation.h>
#import "DownloadViewController.h"
#import "MyBooksViewController.h"
@interface BookDownloaderIphone : NSObject<NSURLConnectionDataDelegate>{
    BOOL somethinRemains;
}
@property(nonatomic,retain) NSMutableData *data;
@property(nonatomic,assign)MyBooksViewController *myBookViewController;
@property(nonatomic,retain)NSString *loc;
@property(nonatomic,retain)NSFileHandle *handle;
@property(nonatomic,assign)float value;
@property(nonatomic,retain)UIProgressView *progress;
@property(nonatomic,retain)Book *book;
@property(nonatomic,assign)long sizeLenght;
-(id)initWithViewController:(MyBooksViewController *)store;
@end
