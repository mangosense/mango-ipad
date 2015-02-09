//
//  UserBookDownloadViewController.h
//  MangoReader
//
//  Created by Harish on 1/24/15.
//
//

#import <UIKit/UIKit.h>
#import "MangoApiController.h"

@protocol BooksJsonAndDownload <NSObject>

@optional

- (IBAction)getJsonIntoArray:(NSArray *) bookArray;

- (IBAction) finishBookDownlaod;

@end

@interface UserBookDownloadViewController : UIViewController<MangoPostApiProtocol>

@property (nonatomic, strong) NSMutableArray *allBooksDetail;
@property (nonatomic, weak) id <BooksJsonAndDownload> delegate;

- (void) returnArrayElementa;

+ (NSArray *) returnAllAvailableLevels;

- (void) downloadBook :(NSString *)bookId;

@end
