//
//  PreKBooksViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 07/10/13.
//
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"

@interface PreKCategoriesViewController : UIViewController <PSTCollectionViewDataSource, PSTCollectionViewDelegate> {
    PSTCollectionView *preKCategoriesCollectionView;
    NSNumber *screenLevel;
}

@property (nonatomic, strong) PSTCollectionView *preKCategoriesCollectionView;
@property (nonatomic, strong) NSNumber *screenLevel;

@end
