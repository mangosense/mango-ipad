//
//  FileDownloader.h
//  AePubReader
//
//  Created by Nikhil Dhavale on 27/09/12.
//
//

#import <Foundation/Foundation.h>
#import "LibraryViewController.h"
#import "Book.h"
@interface FileDownloader : NSObject<NSURLConnectionDelegate>{
    BOOL somethinRemains;
}
@property(assign,nonatomic)LibraryViewController *libViewController;
-(id)initWithViewController:(LibraryViewController *)store;
@property(nonatomic,retain) NSMutableData *data;
@property(nonatomic,retain)NSString *loc;
@property(nonatomic,retain)NSFileHandle *handle;
@property(nonatomic,retain)UIProgressView *progress;
@property(nonatomic,retain)Book *book;
@property(nonatomic,assign)float value;

@property(nonatomic,assign)long sizeLenght;
-(void)defunct:(id)sender;
@end
