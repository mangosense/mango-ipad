//
//  AudioRecordingsListViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 11/11/13.
//
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@protocol ItemsDelegate

- (void)itemType:(int)itemType tappedAtIndex:(int)index;

@end

@interface ItemsListViewController : UITableViewController {
    NSMutableArray *itemsListArray;
    int tableType;
}

@property (nonatomic, strong) NSMutableArray *itemsListArray;
@property (nonatomic, assign) int tableType;
@property (nonatomic, assign) id <ItemsDelegate> delegate;

@end
