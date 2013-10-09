//
//  PreKBooksViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 07/10/13.
//
//

#import "PreKCategoriesViewController.h"
#import "PreKCell.h"
#import "CoverViewController.h"
#import "AePubReaderAppDelegate.h"
#define CATEGORIES_LEVEL 0

@interface PreKCategoriesViewController ()

@property (nonatomic, strong) NSMutableArray *buttonsArray;
@property (nonatomic, assign) int selectedButtonTag;

@end

@implementation PreKCategoriesViewController

@synthesize buttonsArray;
@synthesize preKCategoriesCollectionView;
@synthesize screenLevel;
@synthesize selectedButtonTag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title=@"PreK Stories";
        self.tabBarItem.image=[UIImage imageNamed:@"library.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo1.png"]];
    self.navigationItem.titleView=imageView;
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    
    if (!screenLevel) {
        screenLevel = [NSNumber numberWithInt:CATEGORIES_LEVEL];
    }
    [self createButtonsArrayForLevel:[screenLevel intValue]];
    [self createCollectionView];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.prek=YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Create Buttons

- (void)createCollectionView {
    PSUICollectionViewFlowLayout *collectionViewFlowLayout=[[PSUICollectionViewFlowLayout alloc]init];
    [collectionViewFlowLayout setScrollDirection:PSTCollectionViewScrollDirectionVertical];
    [collectionViewFlowLayout setItemSize:CGSizeMake(300, 253)];
    [collectionViewFlowLayout setSectionInset:UIEdgeInsetsMake(4, 4, 4, 4)];
    [collectionViewFlowLayout setMinimumInteritemSpacing:4];
    [collectionViewFlowLayout setMinimumLineSpacing:20];
    preKCategoriesCollectionView = [[PSTCollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:collectionViewFlowLayout];
    preKCategoriesCollectionView.dataSource = self;
    preKCategoriesCollectionView.delegate = self;
    [self.view addSubview:preKCategoriesCollectionView];
}

// Very BAD method. Created for Frankfurt and Nagesh's Demos. Please REMOVE ASAP.
- (void)createButtonsArrayForLevel:(int)uiLevel {
    switch (uiLevel) {
        case CATEGORIES_LEVEL: {
            buttonsArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < 40; i++) {
                NSString *imageName = [NSString stringWithFormat:@"app-%02d.png", i];
                
                if ([UIImage imageNamed:imageName]) {
                    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 253)];
                    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
                    button.tag = i;
                    [buttonsArray addObject:button];
                }
            }
        }
            break;
        
        default: {
            buttonsArray = [[NSMutableArray alloc] init];
            int imageIndex = 0;
            while ([UIImage imageNamed:[NSString stringWithFormat:@"app-%02d-%02d.png", uiLevel, imageIndex]]) {
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 253)];
                [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"app-%02d-%02d.png", uiLevel, imageIndex]] forState:UIControlStateNormal];
                [buttonsArray addObject:button];
                imageIndex++;
            }
        }
            break;
    }
}

#pragma mark - PSTCollectionView Datasource and Delegates

- (NSInteger)numberOfSectionsInCollectionView:(PSTCollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [buttonsArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = @"buttonCell";
    [collectionView registerClass:[PreKCell class] forCellWithReuseIdentifier:reuseId];
    
    PreKCell *buttonCell = (PreKCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    if (!buttonCell) {
        buttonCell = [[PreKCell alloc] initWithFrame:CGRectMake(0, 0, 300, 253)];
    }
    UIButton *buttonForCell = [buttonsArray objectAtIndex:indexPath.row];
    [buttonCell.cellImageView setImage:[buttonForCell imageForState:UIControlStateNormal]];
    buttonCell.cellImageView.tag = buttonForCell.tag;
    
    return buttonCell;
}

- (void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PreKCell *cell = (PreKCell *)[collectionView cellForItemAtIndexPath:indexPath];

    if ([screenLevel intValue] == 0) {
        PreKCategoriesViewController *preKStoriesViewController = [[PreKCategoriesViewController alloc] initWithNibName:@"PreKCategoriesViewController" bundle:nil];
        preKStoriesViewController.screenLevel = [NSNumber numberWithInt:cell.cellImageView.tag];
        [self.navigationController pushViewController:preKStoriesViewController animated:YES];
    } else {
        CoverViewController *coverViewController=[[CoverViewController alloc]initWithNibName:@"CoverViewController" bundle:nil];
        coverViewController._strFileName=@"45";
        [[NSUserDefaults standardUserDefaults] setInteger:45 forKey:@"bookid"];
        coverViewController.url=nil;
        self.tabBarController.hidesBottomBarWhenPushed=YES;
        coverViewController.hidesBottomBarWhenPushed=YES;
        coverViewController.titleOfBook=@"Title";
        [self.navigationController pushViewController:coverViewController animated:YES];
    }
}

@end
