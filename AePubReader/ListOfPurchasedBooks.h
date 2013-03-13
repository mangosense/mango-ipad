//
//  ListOfPurchasedBooks.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 04/12/12.
//
//

#import <Foundation/Foundation.h>
#import "DownloadViewController.h"
@interface ListOfPurchasedBooks : NSObject<NSURLConnectionDataDelegate>
-(id)initWithViewController:(DownloadViewController *)store;
@property(assign,nonatomic)DownloadViewController *store;
@property(retain,nonatomic)NSMutableData *dataMutable;
@property(assign,nonatomic)BOOL shouldBuild;
@end
