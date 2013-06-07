//
//  StatsViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 28/05/13.
//
//

#import <UIKit/UIKit.h>

@interface StatsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *TimeRead;
@property (weak, nonatomic) IBOutlet UILabel *pageCount;
@property (weak, nonatomic) IBOutlet UILabel *bookCount;
- (IBAction)done:(id)sender;

@end
