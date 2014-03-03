//
//  BookDetailsViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 12/02/14.
//
//

#import "BookDetailsViewController.h"
#import "MBProgressHUD.h"
#import "CargoBay.h"
#import "HKCircularProgressLayer.h"
#import "HKCircularProgressView.h"
#import "Constants.h"
#import "BooksFromCategoryViewController.h"
#import "AePubReaderAppDelegate.h"

@interface BookDetailsViewController ()

@property (nonatomic, assign) int bookProgress;
@property (nonatomic, strong) HKCircularProgressView *progressView;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, strong) NSString *bookId;

@end

@implementation BookDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [_bookImageView setContentMode:UIViewContentModeScaleAspectFill];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _bookImageView.layer.cornerRadius = 3.0;
    _dropDownArrayData = [[NSMutableArray alloc] init];
    _descriptionLabel.editable = NO;
    
    _dropDownView = [[DropDownView alloc] initWithArrayData:_dropDownArrayData cellHeight:33 heightTableView:100 paddingTop:-100 paddingLeft:-5 paddingRight:-10 refView:_dropDownButton animation:BLENDIN openAnimationDuration:1 closeAnimationDuration:1];
    _dropDownView.delegate = self;
    
    
	[self.view addSubview:_dropDownView.view];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    //Register observer
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:[CargoBay sharedManager]];
}

#pragma mark - Setters

- (void)setImageUrlString:(NSString *)imageUrlString {
    _imageUrlString = imageUrlString;
    [self getImageForUrl:[_imageUrlString stringByReplacingOccurrencesOfString:@"banner" withString:@"leftright"]];
}

#pragma mark - Action Methods

- (IBAction)buyButtonTapped:(id)sender {
    if (_selectedProductId) {
        [[PurchaseManager sharedManager] itemProceedToPurchase:_selectedProductId storeIdentifier:_selectedProductId withDelegate:self];
    }
    else {
        NSLog(@"Product dose not have relative Id");
    }
}

- (IBAction)closeDetails:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void) {
        //[_delegate openBookViewWithCategory:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:[[_categoriesLabel.text componentsSeparatedByString:@", "] firstObject]] forKey:@"categories"]];
    }];
}

- (void)openBook:(NSString *)bookId {
    if (_delegate && [_delegate respondsToSelector:@selector(openBookViewWithCategory:)]) {
        [_delegate openBookViewWithCategory:[NSDictionary dictionaryWithObject:[[_categoriesLabel.text componentsSeparatedByString:@", "] firstObject] forKey:NAME]];
    }
    [self closeDetails:nil];
}

#pragma mark - Get Image

- (void)getImageForUrl:(NSString *)urlString {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    
    [MBProgressHUD showHUDAddedTo:_bookImageView animated:YES];
    [apiController getImageAtUrl:urlString withDelegate:self];
}

#pragma mark - Purchased Manager Call Back

- (void)itemReadyToUse:(NSString *)productId {
    _bookId = productId;
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController downloadBookWithId:productId withDelegate:self];
}

#pragma mark - Post API Delegate

- (void)reloadImage:(UIImage *)image forUrl:(NSString *)urlString {
    [MBProgressHUD hideAllHUDsForView:_bookImageView animated:YES];
    
    [_bookImageView setImage:image];
}

- (void)bookDownloaded {
    [self openBook:_bookId];
}

-(void)dropDownCellSelected:(NSInteger)returnIndex{
	
	[_dropDownButton setTitle:[_dropDownArrayData objectAtIndex:returnIndex] forState:UIControlStateNormal];
	//handle book language response here ...
}

-(IBAction)dropDownActionButtonClick{
    
    if(_dropDownArrayData.count>1){
        _dropDownButton.userInteractionEnabled = YES;
        [self.dropDownView openAnimation];
    }
    else{
        _dropDownButton.userInteractionEnabled = NO;
    }
}

- (void)updateBookProgress:(int)progress {
    _bookProgress = progress;
    [_buyButton setHidden:YES];
    
    if (progress < 100) {
        [self performSelectorOnMainThread:@selector(showHudOnButton) withObject:nil waitUntilDone:YES];
        [_closeButton setEnabled:NO];
    } else {
        [self performSelectorOnMainThread:@selector(hideHudOnButton) withObject:nil waitUntilDone:YES];
        [_closeButton setEnabled:YES];
    }
}

#pragma mark - HUD Methods

- (void)showHudOnButton {
    if (!_progressView) {
        _progressView = [[HKCircularProgressView alloc] initWithFrame:CGRectMake(_bookImageView.frame.size.width/2 - 100, _bookImageView.frame.size.height/2 - 100, 200, 200)];
        _progressView.max = 100.0f;
        _progressView.step = 0.0f;
        _progressView.fillRadius = 1;
        _progressView.trackTintColor = COLOR_LIGHT_GREY;
        [_progressView setAlpha:0.6f];
        [_bookImageView addSubview:_progressView];
    }
    _progressView.current = _bookProgress;
}

- (void)hideHudOnButton {
    [_progressView removeFromSuperview];
}

@end
