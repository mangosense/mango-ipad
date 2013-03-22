//
//  DetailViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 04/12/12.
//
//

#import <UIKit/UIKit.h>
#import "MyBooksViewController.h"
@interface DetailViewController : UIViewController
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (retain, nonatomic) IBOutlet UIButton *downloadButton;
@property(assign,nonatomic)NSInteger identity;
- (IBAction)downloadBook:(id)sender;
- (IBAction)backButtonPressed:(id)sender;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *bckButton;
@property (retain, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (retain, nonatomic) IBOutlet UIToolbar *topToolbar;
@property(assign,nonatomic)MyBooksViewController *booksMy;
@end
