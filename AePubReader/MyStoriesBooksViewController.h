//
//  MyStoriesBooksViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 11/02/14.
//
//

#import <UIKit/UIKit.h>

@interface MyStoriesBooksViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *booksArray;
@property (nonatomic, assign) BOOL toEdit;

@end
