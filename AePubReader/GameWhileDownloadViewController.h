//
//  GameWhileDownloadViewController.h
//  MangoReader
//
//  Created by Harish on 1/25/15.
//
//

#import <UIKit/UIKit.h>
#import "UserBookDownloadViewController.h"


@interface GameWhileDownloadViewController : UIViewController<BooksJsonAndDownload, UIWebViewDelegate>{
    
    UserBookDownloadViewController *bookDownload;
    NSString *firstBookId;
}

@property (nonatomic, assign) NSString *ageVal;
@property (nonatomic, strong) NSArray *booksArray;
@property (nonatomic, strong) UIWebView *webView;

- (IBAction)closeGameView:(id)sender;

@end
