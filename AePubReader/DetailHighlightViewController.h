//
//  DetailHighlightViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 22/01/13.
//
//

#import <UIKit/UIKit.h>

@interface DetailHighlightViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITextView *highlight;
@property (retain, nonatomic) IBOutlet UITextView *notes;
@property (retain, nonatomic) IBOutlet UILabel *notesLabel;
@property(retain,nonatomic)NSString *highlightString;
@property(retain,nonatomic)NSString *notesString;
@property(assign,nonatomic)BOOL hasHighlight;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withHighlight:(NSString *)string andNotes:(NSString *)notes;
@end
