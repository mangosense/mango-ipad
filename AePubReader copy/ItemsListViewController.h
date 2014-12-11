//
//  AudioRecordingsListViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 11/11/13.
//
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "MangoApiController.h"

@protocol ItemsDelegate

@optional
- (void)itemType:(int)itemType tappedWithDetail:(NSDictionary *)detail;
- (void)itemType:(int)itemType tappedAtIndex:(int)index withDetail:(NSString *)detail;


@end

@interface ItemsListViewController : UITableViewController <MangoPostApiProtocol> {
    NSMutableArray *itemsListArray;
    int tableType;
    NSArray *storeBooksType;
    NSString *userEmail;
   // NSString *userDeviceID;
    NSString *ID;
    NSString *viewName;
    NSString *currentPage;
    int cellSize;
    int fontSize;
}

@property (nonatomic, strong) NSMutableArray *itemsListArray;
@property (nonatomic, assign) int tableType;
@property (nonatomic, assign) int filterTag;
@property (nonatomic, assign) id <ItemsDelegate> delegate;

@end
