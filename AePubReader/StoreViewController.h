//
//  StoreViewController.h
//  AePubReader
//
//  Created by Nikhil Dhavale on 24/09/12.
//
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "AePubReaderAppDelegate.h"
#import "Book.h"
@protocol StoreControllerDelegate<NSObject>
-(void)DownloadComplete:(Book *)book;

@end
@interface StoreViewController : UIViewController<ASIHTTPRequestDelegate,ASIProgressDelegate,NSURLConnectionDelegate>{
   
}
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
- (void)DownloadBook:(id)sender;
-(void)BuildButtons;
- (IBAction)refreshButton:(id)sender;
@property(retain,nonatomic)UIMenuController *menu;
@property(assign,nonatomic) id<StoreControllerDelegate> delegate;
@property(assign,nonatomic)NSInteger ymax;
@property(retain,nonatomic) UIAlertView *alert;
@property(retain,nonatomic)NSURLConnection *connection;
//@property(retain,nonatomic)NSMutableData *mutableData;
//@property(assign,nonatomic) AePubReaderAppDelegate *delegateApp;
@property(retain,nonatomic)NSArray *listOfBooks;
- (IBAction)signOut:(id)sender;
@property(retain,nonatomic)Book *book;
@property(retain,nonatomic)UIButton *buttonTapped;
@property(assign,nonatomic)BOOL purchase;
@end
