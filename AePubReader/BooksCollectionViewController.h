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
}

@property (nonatomic, strong) UICollectionView *booksCollectionView;
@property (nonatomic, assign) BOOL toEdit;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;

- (IBAction)settingsButtonTapped:(id)sender;
- (IBAction)homeButtonTapped:(id)sender;
- (IBAction)libraryButtonTapped:(id)sender;
- (IBAction)trashButtonTapped:(id)sender;
- (void) setDeleteButtonVisible;

@property (nonatomic, strong) IBOutlet UILabel *headerLabel;
@property (nonatomic, strong) NSDictionary *categorySelected;

@end
