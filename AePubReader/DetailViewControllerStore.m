//
//  DetailViewControllerStore.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 01/11/13.
//
//

#import "DetailViewControllerStore.h"
#import "CollectionViewLayout.h"
#import "StoreCell.h"
#import "OldStoreCell.h"
@interface DetailViewControllerStore ()

@end

@implementation DetailViewControllerStore

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([UIDevice currentDevice].systemVersion.integerValue<7) {
        PSTCollectionViewFlowLayout *flowLayout=[[PSTCollectionViewFlowLayout alloc]init];
        _OldDatasource=[[DataSourceForLinearOld alloc]initWithString:@"Det"];
        _oldCollectionView=[[PSTCollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        [_oldCollectionView registerClass:[OldStoreCell class] forCellWithReuseIdentifier:@"MY_CELL"];
        _oldCollectionView.backgroundColor=[UIColor whiteColor];
        _oldCollectionView.dataSource=_OldDatasource;
        [self.view addSubview:_oldCollectionView];
        [self.view bringSubviewToFront:_back];
    }else{
    CollectionViewLayout *collectionLayout=[[CollectionViewLayout alloc]init];
    _collectionView=[[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:collectionLayout];
    _datasource=[[DataSourceForLinear alloc]initWithString:@"Det"];
    [_collectionView registerClass:[StoreCell class] forCellWithReuseIdentifier:@"MY_CELL"];
    _collectionView.backgroundColor=[UIColor whiteColor];
    _collectionView.dataSource=_datasource;
    [self.view addSubview:_collectionView];
    [self.view bringSubviewToFront:_back];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
