//
//  StoreViewController.h
//  AePubReader
//
//  Created by Nikhil Dhavale on 24/09/12.
//
//

#import <UIKit/UIKit.h>
#import "AePubReaderAppDelegate.h"
#import "Book.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <StoreKit/StoreKit.h>
#import "PSTCollectionView.h"
#import "PSTCollectionDataSource.h"
@protocol StoreControllerDelegate<NSObject>
-(void)DownloadComplete:(Book *)book;

@end
@interface StoreViewController : UIViewController<NSURLConnectionDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>{
   
}
@property(strong,nonatomic)UICollectionView *collectionView;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
- (void)DownloadBook:(id)sender;
-(void)BuildButtons;
- (IBAction)refreshButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *networkActivityIndicator;
@property(retain,nonatomic)UIMenuController *menu;
@property(assign,nonatomic) id<StoreControllerDelegate> delegate;
@property(assign,nonatomic)NSInteger ymax;
@property(retain,nonatomic) UIAlertView *alert;
@property(retain,nonatomic)NSURLConnection *connection;
//-(void)requestBooksFromServerinit;
//@property(retain,nonatomic)NSMutableData *mutableData;
//@property(assign,nonatomic) AePubReaderAppDelegate *delegateApp;
@property(retain,nonatomic)NSArray *listOfBooks;
- (IBAction)signOut:(id)sender;
@property(retain,nonatomic)Book *book;
@property(retain,nonatomic)UIButton *buttonTapped;
@property(assign,nonatomic)BOOL purchase;
@property(retain,nonatomic)NSError *error;
@property(strong,nonatomic)NSMutableData *data;
@property(strong,nonatomic)PSUICollectionView *pstCollectionView;
@property(strong,nonatomic)PSTCollectionDataSource *dataSource;
-(void)requestBooksFromServer;
-(void)transactionRestore;
-(void)transactionFailed;

@end
