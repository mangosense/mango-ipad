//
//  DetailViewControllerStore.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 01/11/13.
//
//

#import <UIKit/UIKit.h>
#import "DataSourceForLinear.h"
#import "PSTCollectionView.h"
#import "DataSourceForLinearOld.h"

@interface DetailViewControllerStore : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *back;
- (IBAction)back:(id)sender;
@property(retain,nonatomic) DataSourceForLinear *datasource;
@property(retain,nonatomic) UICollectionView *collectionView;
@property(retain,nonatomic) PSTCollectionView *oldCollectionView;
@property(retain,nonatomic)DataSourceForLinearOld *OldDatasource;
@end
