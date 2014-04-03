//
//  BooksCollectionViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 06/03/14.
//
//

#import <UIKit/UIKit.h>
#import "SettingOptionViewController.h"
#import "BooksCollectionViewCell.h"

@interface BooksCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DismissPopOver, SaveBookImage>{
    int deleteBookIndex;
    int settingQuesNo;
    
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;
}

@property (nonatomic, strong) UICollectionView *booksCollectionView;
@property (nonatomic, assign) BOOL toEdit;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIButton *settingButton;
@property (nonatomic, retain) NSArray *settingQuesArray;

- (IBAction)settingsButtonTapped:(id)sender;
- (IBAction)homeButtonTapped:(id)sender;
- (IBAction)libraryButtonTapped:(id)sender;
- (IBAction)trashButtonTapped:(id)sender;

@property (nonatomic, strong) IBOutlet UILabel *headerLabel;
@property (nonatomic, strong) NSDictionary *categorySelected;

@end
