//
//  AudioRecordingsListViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 11/11/13.
//
//

#import <UIKit/UIKit.h>

@interface AudioRecordingsListViewController : UITableViewController {
    NSMutableArray *audioRecordingsListArray;
}

@property (nonatomic, strong) NSMutableArray *audioRecordingsListArray;

@end
