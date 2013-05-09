//
//  WebViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 04/10/12.
//
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate>
@property (retain, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)DismissViewControlller:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonItem;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil URL:(NSURL *)url;
@property(nonatomic,retain)NSURL *url;
@property(nonatomic,retain)UIAlertView *alert;
@end
