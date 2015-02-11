//
//  GameWhileDownloadViewController.h
//  MangoReader
//
//  Created by Harish on 1/25/15.
//
//

#import <UIKit/UIKit.h>
#import "UserBookDownloadViewController.h"
#import "Book.h"


@interface GameWhileDownloadViewController : UIViewController<BooksJsonAndDownload, UIWebViewDelegate>{
    
    UserBookDownloadViewController *bookDownload;
    NSString *firstBookId;
}

@property (nonatomic, assign) NSString *ageVal;
@property (nonatomic, strong) NSArray *booksArray;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) MBProgressHUD *hud;
@property(strong,nonatomic) Book *book;

@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) IBOutlet UIView *waitViewLabel;

- (IBAction)closeGameView:(id)sender;

@end
