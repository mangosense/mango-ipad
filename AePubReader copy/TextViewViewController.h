//
//  TextViewViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 17/01/13.
//
//

#import <UIKit/UIKit.h>
@protocol TextDelegate<NSObject>
-(void)sendNotes:(NSString *)string;
-(void)updateNotes:(NSString *)string withIdentity:(NSInteger )identity;
@end
@interface TextViewViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITextView *textView;
@property(assign,nonatomic) NSInteger identity;
@property (retain, nonatomic) IBOutlet UIWebView *webview;
@property(assign,nonatomic)id<TextDelegate> delegate;
@property(assign,nonatomic)BOOL update;
@property(retain,nonatomic)NSString *note;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil With:(NSString *)note withUpdate:(BOOL)update withInteger:(NSInteger) identity;
@end
