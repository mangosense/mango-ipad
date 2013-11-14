//
//  MangoEditorViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 14/11/13.
//
//

#import "MangoEditorViewController.h"
#import "Constants.h"
#import "MovableTextView.h"
#import "MenuTableViewController.h"
#import "Flickr.h"
#import "FlickrPhoto.h"

#define ENGLISH_TAG 9
#define ANGRYBIRDS_ENGLISH_TAG 17
#define TAMIL_TAG 10
#define MALAY_TAG 12
#define CHINESE_TAG 11
#define GERMAN_TAG 13
#define SPANISH_TAG 14

@interface MangoEditorViewController ()

@property (nonatomic, strong) NSString *bookJsonString;
@property (nonatomic, strong) NSMutableArray *pagesArray;
@property (nonatomic, assign) int currentPageNumber;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) UIButton *audioRecordingButton;
@property (nonatomic, strong) UIPopoverController *menuPopoverController;
@property (nonatomic, strong) NSArray *flickerResultsArray;
@property (nonatomic, strong) NSArray *arrayOfImageNames;
@property (nonatomic, strong) UIView *stickerView;

@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGPoint translatePoint;

@end

@implementation MangoEditorViewController

@synthesize pageImageView;
@synthesize mangoButton;
@synthesize menuButton;
@synthesize imageButton;
@synthesize textButton;
@synthesize audioButton;
@synthesize gamesButton;
@synthesize collaborationButton;
@synthesize playStoryButton;
@synthesize pagesCarousel;
@synthesize chosenBookTag;
@synthesize bookJsonString;
@synthesize pagesArray;
@synthesize currentPageNumber;
@synthesize audioRecorder;
@synthesize audioPlayer;
@synthesize audioRecordingButton;
@synthesize menuPopoverController;
@synthesize flickerResultsArray;
@synthesize arrayOfImageNames;
@synthesize stickerView;
@synthesize rotateAngle;
@synthesize translatePoint;

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
    [self getBookJson];
    [pagesCarousel setClipsToBounds:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gesture Handlers for Assets

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void) addGestureRecognizersforView:(UIView *)someView {
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    panRecognizer.delegate = self;
    [someView addGestureRecognizer:panRecognizer];
    
    UIRotationGestureRecognizer *rotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
    rotateRecognizer.delegate = self;
    someView.multipleTouchEnabled = YES;
    // Removing temporarily for bug fix
    [someView addGestureRecognizer:rotateRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    pinchRecognizer.delegate = self;
    [someView addGestureRecognizer:pinchRecognizer];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPressRecognizer.delegate = self;
    longPressRecognizer.minimumPressDuration = 2.0;
    [someView addGestureRecognizer:longPressRecognizer];
}

- (void) move:(UIPanGestureRecognizer *)recognizer{
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x+translation.x, recognizer.view.center.y+translation.y);
    translatePoint = recognizer.view.center;
    NSLog(@"Rotate Angle = %f \n Translate Point = (%f, %f)", rotateAngle, translatePoint.x, translatePoint.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void) rotate:(UIRotationGestureRecognizer *)recognizer{
    NSLog(@"Rotate");
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    rotateAngle = atan2f(recognizer.view.transform.b, recognizer.view.transform.a);
    NSLog(@"Rotate Angle = %f \n Translate Point = (%f, %f)", rotateAngle, translatePoint.x, translatePoint.y);
    recognizer.rotation = 0;
}

- (void) pinch:(UIPinchGestureRecognizer *)recognizer{
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    if (recognizer.view.frame.size.width < 120) {
        [recognizer.view removeFromSuperview];
    }
}

- (void) longPressed:(UILongPressGestureRecognizer *)recognizer{
    NSLog(@"Long Pressed");
}

#pragma mark - TextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    Flickr *flickr = [[Flickr alloc] init];
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadingView setFrame:CGRectMake(self.view.center.x - 20, self.view.center.y - 20, 40, 40)];
    [loadingView setHidesWhenStopped:YES];
    [self.view addSubview:loadingView];
    [loadingView startAnimating];
    [flickr searchFlickrForTerm:textView.text completionBlock:^(NSString *searchTerm, NSArray *results, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingView stopAnimating];
        });
        if(results && [results count] > 0) {
            NSLog(@"Found %d photos matching %@", [results count],searchTerm);
            NSLog(@"Results: %@", results);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadFlickrPhotos:results];
            });
        } else {
            NSLog(@"Error searching Flickr: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - Show Image Assets

- (void)loadFlickrPhotos:(NSArray *)results {
    flickerResultsArray = [NSArray arrayWithArray:results];
    
    for (UIView *subview in [menuPopoverController.contentViewController.view subviews]) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            [subview removeFromSuperview];
            break;
        }
    }
    UIScrollView *assetsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 105, 250, 500)];
    assetsScrollView.backgroundColor = [UIColor clearColor];
    [assetsScrollView setUserInteractionEnabled:YES];
    for (FlickrPhoto *flickrPhoto in results) {
        UIButton *assetImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [[assetImageButton layer] setBorderColor:[COLOR_DARK_GREY CGColor]];
        [[assetImageButton layer] setBorderWidth:1.0f];
        [assetImageButton setBackgroundColor:COLOR_LIGHT_GREY];
        [assetImageButton setImage:flickrPhoto.thumbnail forState:UIControlStateNormal];
        CGFloat originX = 10;
        if ([results indexOfObject:flickrPhoto]%2 == 0) {
            originX = 10 + 5 + 112;
        }
        int level = [results indexOfObject:flickrPhoto]/2;
        [assetImageButton setFrame:CGRectMake(originX, level*120 + 15, 112, 112)];
        assetImageButton.tag = [results indexOfObject:flickrPhoto];
        [assetImageButton addTarget:self action:@selector(addFlickerPhotoForButton:) forControlEvents:UIControlEventTouchUpInside];
        [assetsScrollView addSubview:assetImageButton];
    }
    CGFloat minContentHeight = MAX(assetsScrollView.frame.size.height, ([arrayOfImageNames count]/2)*140);
    assetsScrollView.contentSize = CGSizeMake(assetsScrollView.frame.size.width, minContentHeight);
    [menuPopoverController.contentViewController.view setBackgroundColor:COLOR_LIGHT_GREY];
    
    [menuPopoverController.contentViewController.view addSubview:assetsScrollView];
}

- (void)addFlickerPhotoForButton:(UIButton *)button {
    if ([[pageImageView subviews] containsObject:stickerView]) {
        [self addAssetToView];
    }
    [menuPopoverController dismissPopoverAnimated:YES];
    
    stickerView = [[UIView alloc] initWithFrame:CGRectMake(pageImageView.center.x - 90, pageImageView.center.y - 90, 140, 180)];
    [stickerView setUserInteractionEnabled:YES];
    [stickerView setMultipleTouchEnabled:YES];
    [self addGestureRecognizersforView:stickerView];
    
    UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 120, 120)];
    FlickrPhoto *flickrPhoto = [flickerResultsArray objectAtIndex:button.tag];
    
    assetImageView.image = flickrPhoto.thumbnail;
    [stickerView addSubview:assetImageView];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setImage:[UIImage imageNamed:@"Checkmark.png"] forState:UIControlStateNormal];
    [doneButton setFrame:CGRectMake(50, 130, 44, 44)];
    [doneButton addTarget:self action:@selector(addAssetToView) forControlEvents:UIControlEventTouchUpInside];
    [stickerView addSubview:doneButton];
    
    [self.view addSubview:stickerView];
    
    rotateAngle = 0;
    translatePoint = stickerView.center;
}

- (void)addAssetToView {
    UIImage *viewImage = nil;
    for (UIView *subview in [stickerView subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            UIImageView *subviewImageView = (UIImageView *)subview;
            viewImage = subviewImageView.image;
            if (viewImage) {
                NSLog(@"Rotate Angle = %f \n Translate Point = (%f, %f)", rotateAngle, translatePoint.x, translatePoint.y);
                [pageImageView drawSticker:viewImage inRect:[self.view convertRect:[stickerView convertRect:subview.frame toView:self.view] toView:pageImageView] WithTranslation:CGPointMake(translatePoint.x - pageImageView.frame.origin.x, translatePoint.y - pageImageView.frame.origin.y) AndRotation:-rotateAngle];
            }
            [stickerView removeFromSuperview];
            
            break;
        }
    }
    
}

- (void)addImageForButton:(UIButton *)button {
    if ([[pageImageView subviews] containsObject:stickerView]) {
        [self addAssetToView];
    }
    [menuPopoverController dismissPopoverAnimated:YES];
    
    stickerView = [[UIView alloc] initWithFrame:CGRectMake(pageImageView.center.x - 90, pageImageView.center.y - 90, 140, 180)];
    [stickerView setUserInteractionEnabled:YES];
    [stickerView setMultipleTouchEnabled:YES];
    [self addGestureRecognizersforView:stickerView];
    
    UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 120, 120)];
    assetImageView.image = [UIImage imageNamed:[arrayOfImageNames objectAtIndex:button.tag]];
    [stickerView addSubview:assetImageView];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setImage:[UIImage imageNamed:@"Checkmark.png"] forState:UIControlStateNormal];
    [doneButton setFrame:CGRectMake(50, 130, 44, 44)];
    [doneButton addTarget:self action:@selector(addAssetToView) forControlEvents:UIControlEventTouchUpInside];
    [stickerView addSubview:doneButton];
    
    [self.view addSubview:stickerView];
    
    rotateAngle = 0;
    translatePoint = stickerView.center;
}

- (void)assetTypeSelected:(id)sender {
    for (UIView *subview in [menuPopoverController.contentViewController.view subviews]) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            [subview removeFromSuperview];
            break;
        }
    }
    UIScrollView *assetsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 105, 250, 500)];
    assetsScrollView.backgroundColor = [UIColor clearColor];
    [assetsScrollView setUserInteractionEnabled:YES];
    
    UISegmentedControl *control = (UISegmentedControl *)sender;
    int selectedIndex = control.selectedSegmentIndex;
    switch (selectedIndex) {
        case 0: {
            arrayOfImageNames = [NSArray arrayWithObjects:@"1-leaf.png", @"2-Grass.png", @"3-leaves.png", @"10-leaves.png", @"11-leaves.png", @"A.png", @"B.png", @"bamboo-01.png", @"bamboo-02.png", @"bambu-01.png", @"bambu-02.png", @"bambu.png", @"Branch_01.png", @"C.png", @"coconut tree.png", @"grass1.png", @"hills-01.png", @"hills-02.png", @"hills-03.png", @"leaf-02", @"mushroom_01.png", @"mushroom_02.png", @"mushroom_03.png", @"mushroom_04.png", @"rock_01.png", @"rock_02.png", @"rock_03.png", @"rock_04.png", @"rock_05.png", @"rock_06.png", @"rock_07.png", @"rock_08.png", @"rock_09.png", @"rock-10.png", @"rock_11.png", @"rock_12.png", @"tree2.png", nil];
        }
            break;
            
        case 1: {
            arrayOfImageNames = [NSArray arrayWithObjects:@"rock_09.png", @"rock-10.png", @"rock_11.png", @"rock_12.png", @"tree2.png", nil];
        }
            break;
            
        default:
            break;
    }
    
    for (NSString *imageName in arrayOfImageNames) {
        UIImage *image = [UIImage imageNamed:imageName];
        UIButton *assetImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [[assetImageButton layer] setBorderColor:[COLOR_DARK_GREY CGColor]];
        [[assetImageButton layer] setBorderWidth:1.0f];
        [assetImageButton setBackgroundColor:COLOR_LIGHT_GREY];
        [assetImageButton setImage:image forState:UIControlStateNormal];
        CGFloat originX = 10;
        if ([arrayOfImageNames indexOfObject:imageName]%2 == 0) {
            originX = 10 + 5 + 112;
        }
        int level = [arrayOfImageNames indexOfObject:imageName]/2;
        [assetImageButton setFrame:CGRectMake(originX, level*120 + 15, 112, 112)];
        assetImageButton.tag = [arrayOfImageNames indexOfObject:imageName];
        [assetImageButton addTarget:self action:@selector(addImageForButton:) forControlEvents:UIControlEventTouchUpInside];
        [assetsScrollView addSubview:assetImageButton];
    }
    CGFloat minContentHeight = MAX(assetsScrollView.frame.size.height, ([arrayOfImageNames count]/2)*140);
    assetsScrollView.contentSize = CGSizeMake(assetsScrollView.frame.size.width, minContentHeight);
    [menuPopoverController.contentViewController.view setBackgroundColor:COLOR_LIGHT_GREY];
    
    [menuPopoverController.contentViewController.view addSubview:assetsScrollView];
}

- (void)showAssets {
    NSLog(@"Show Assets");
    
    UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePhotoButton setImage:[UIImage imageNamed:@"upload_button.png"] forState:UIControlStateNormal];
    [takePhotoButton addTarget:self action:@selector(cameraButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [takePhotoButton setFrame:CGRectMake(0, 75, 250, 30)];
    
    UIScrollView *assetsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 105, 250, 500)];
    assetsScrollView.backgroundColor = [UIColor clearColor];
    [assetsScrollView setUserInteractionEnabled:YES];
    CGFloat minContentHeight = MAX(assetsScrollView.frame.size.height, 37/2*140);
    assetsScrollView.contentSize = CGSizeMake(assetsScrollView.frame.size.width, minContentHeight);
    
    UISegmentedControl *assetTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"All", @"Story", nil]];
    [assetTypeSegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [assetTypeSegmentedControl setSelectedSegmentIndex:0];
    [assetTypeSegmentedControl addTarget:self action:@selector(assetTypeSelected:) forControlEvents:UIControlEventValueChanged];
    [assetTypeSegmentedControl setFrame:CGRectMake(0, 0, 250, 30)];
    
    UITextView *searchTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 44, 250, 30)];
    searchTextView.delegate = self;
    [searchTextView setReturnKeyType:UIReturnKeyGo];
    [[searchTextView layer] setBorderColor:[COLOR_DARK_GREY CGColor]];
    [[searchTextView layer] setBorderWidth:1.0f];
    [[searchTextView layer] setCornerRadius:5.0f];
    
    UIViewController *scrollViewController = [[UIViewController alloc] init];
    [scrollViewController.view setFrame:CGRectMake(0, 0, 250, pageImageView.frame.size.height)];
    [scrollViewController.view addSubview:assetsScrollView];
    [scrollViewController.view addSubview:assetTypeSegmentedControl];
    [scrollViewController.view addSubview:takePhotoButton];
    [scrollViewController.view addSubview:searchTextView];
    
    arrayOfImageNames = [NSArray arrayWithObjects:@"1-leaf.png", @"2-Grass.png", @"3-leaves.png", @"10-leaves.png", @"11-leaves.png", @"A.png", @"B.png", @"bamboo-01.png", @"bamboo-02.png", @"bambu-01.png", @"bambu-02.png", @"bambu.png", @"Branch_01.png", @"C.png", @"coconut tree.png", @"grass1.png", @"hills-01.png", @"hills-02.png", @"hills-03.png", @"leaf-02", @"mushroom_01.png", @"mushroom_02.png", @"mushroom_03.png", @"mushroom_04.png", @"rock_01.png", @"rock_02.png", @"rock_03.png", @"rock_04.png", @"rock_05.png", @"rock_06.png", @"rock_07.png", @"rock_08.png", @"rock_09.png", @"rock-10.png", @"rock_11.png", @"rock_12.png", @"tree2.png", nil];
    for (NSString *imageName in arrayOfImageNames) {
        UIImage *image = [UIImage imageNamed:imageName];
        UIButton *assetImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [[assetImageButton layer] setBorderColor:[COLOR_DARK_GREY CGColor]];
        [[assetImageButton layer] setBorderWidth:1.0f];
        [assetImageButton setBackgroundColor:COLOR_LIGHT_GREY];
        [assetImageButton setImage:image forState:UIControlStateNormal];
        CGFloat originX = 10;
        if ([arrayOfImageNames indexOfObject:imageName]%2 == 0) {
            originX = 10 + 5 + 112;
        }
        int level = [arrayOfImageNames indexOfObject:imageName]/2;
        [assetImageButton setFrame:CGRectMake(originX, level*120 + 15, 112, 112)];
        assetImageButton.tag = [arrayOfImageNames indexOfObject:imageName];
        [assetImageButton addTarget:self action:@selector(addImageForButton:) forControlEvents:UIControlEventTouchUpInside];
        [assetsScrollView addSubview:assetImageButton];
    }
    
    menuPopoverController = [[UIPopoverController alloc] initWithContentViewController:scrollViewController];
    [menuPopoverController setPopoverContentSize:CGSizeMake(250, pageImageView.frame.size.height)];
    menuPopoverController.delegate = self;
    [menuPopoverController setPopoverLayoutMargins:UIEdgeInsetsMake(pageImageView.frame.origin.y, 0, 100, 100)];
    [menuPopoverController.contentViewController.view setBackgroundColor:COLOR_LIGHT_GREY];
    
    [menuPopoverController presentPopoverFromRect:imageButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

#pragma mark - Action Methods

- (IBAction)mangoButtonTapped:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)menuButtonTapped:(id)sender {
    MenuTableViewController *menuTableViewController = [[MenuTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    menuPopoverController = [[UIPopoverController alloc] initWithContentViewController:menuTableViewController];
    [menuPopoverController setPopoverContentSize:CGSizeMake(250, 350) animated:YES];
    [menuPopoverController setPopoverLayoutMargins:UIEdgeInsetsMake(pageImageView.frame.origin.y, 0, 100, 100)];
    [menuPopoverController presentPopoverFromRect:menuButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (IBAction)imageButtonTapped:(id)sender {
    [self showAssets];
}

- (IBAction)textButtonTapped:(id)sender {
    MovableTextView *pageTextView = [[MovableTextView alloc] initWithFrame:CGRectMake(0, 0, 400, 300)];
    pageTextView.font = [UIFont boldSystemFontOfSize:24];
    pageTextView.text = @"";
    [pageImageView addSubview:pageTextView];
}

- (IBAction)audioButtonTapped:(id)sender {
    
}

- (IBAction)gamesButtonTapped:(id)sender {
    
}

- (IBAction)collaborationButtonTapped:(id)sender {
    
}

- (IBAction)playStoryButtonTapped:(id)sender {
    
}

#pragma mark - iCarousel Datasource And Delegate Methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [pagesArray count] + 1;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    UIImageView *pageThumbnail = [[UIImageView alloc] init];
    [pageThumbnail setFrame:CGRectMake(0, 0, 130, 90)];
    [pageThumbnail setImage:[UIImage imageNamed:@"page.png"]];
    if (index < [pagesArray count]) {
        NSDictionary *pageDict = [pagesArray objectAtIndex:index];
        NSArray *layersArray = [[pageDict objectForKey:@"json"] objectForKey:LAYERS];
        for (NSDictionary *layerDict in layersArray) {
            if ([[layerDict objectForKey:TYPE] isEqualToString:IMAGE]) {
                [pageThumbnail setImage:[UIImage imageNamed:[layerDict objectForKey:ASSET_URL]]];
                break;
            }
        }
    } else {
        [pageThumbnail setImage:[UIImage imageNamed:@"addnewpage.png"]];
    }
    
    return pageThumbnail;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (index < [pagesArray count]) {
        [self renderPage:index];
    } else {
        NSMutableDictionary *newPageDict = [[NSMutableDictionary alloc] init];
        [newPageDict setObject:[NSNumber numberWithInt:[pagesArray count]] forKey:@"id"];
        
        NSMutableArray *layersArray = [[NSMutableArray alloc] init];
        NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] init];
        [imageDict setObject:IMAGE forKey:TYPE];
        [imageDict setObject:@"white_page.jpeg" forKey:ASSET_URL];
        [layersArray addObject:imageDict];
        
        NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:layersArray, LAYERS, nil];
        [newPageDict setObject:jsonDict forKey:@"json"];
        
        [pagesArray addObject:newPageDict];
        
        [pagesCarousel reloadData];
        [self carousel:pagesCarousel didSelectItemAtIndex:[pagesArray count] - 1];
    }
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return NO;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        default:
        {
            return value;
        }
    }
}

#pragma mark - DoodleDelegate Method

- (void)replaceImageAtIndex:(NSInteger)index withImage:(UIImage *)image {
    
}

#pragma mark - Render JSON (Temporary - For Demo Story)

- (void)renderPage:(int)pageNumber {
    currentPageNumber = pageNumber;
    
    for (UIView *subview in [pageImageView subviews]) {
        [subview removeFromSuperview];
    }
    pageImageView.incrementalImage = nil;
    
    NSDictionary *pageDict = [pagesArray objectAtIndex:pageNumber];
    NSArray *layersArray = [[pageDict objectForKey:@"json"] objectForKey:LAYERS];
    NSURL *audioUrl;
    NSString *textOnPage;
    CGRect textFrame;
    
    for (NSDictionary *layerDict in layersArray) {
        if ([[layerDict objectForKey:TYPE] isEqualToString:IMAGE]) {
            pageImageView.incrementalImage = [UIImage imageNamed:[layerDict objectForKey:ASSET_URL]];
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:AUDIO]) {
            audioUrl = [NSURL URLWithString:[layerDict objectForKey:AUDIO]];
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:TEXT]) {
            textOnPage = [layerDict objectForKey:TEXT];
            textFrame = CGRectMake([[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_POSITION_X] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_POSITION_Y] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_WIDTH] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_HEIGHT] floatValue]);
            
            MovableTextView *pageTextView = [[MovableTextView alloc] initWithFrame:textFrame];
            pageTextView.font = [UIFont boldSystemFontOfSize:24];
            pageTextView.text = textOnPage;
            [pageImageView addSubview:pageTextView];
        }
    }
    
    audioRecordingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (!audioUrl) {
        [audioRecordingButton setImage:[UIImage imageNamed:@"recording_button.png"] forState:UIControlStateNormal];
        [audioRecordingButton addTarget:self action:@selector(startRecordingAudio) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [audioRecordingButton setImage:[UIImage imageNamed:@"recording_play_button.png"] forState:UIControlStateNormal];
        [audioRecordingButton addTarget:self action:@selector(startPlayingAudio) forControlEvents:UIControlEventTouchUpInside];
    }
    [audioRecordingButton setFrame:CGRectMake(0, pageImageView.frame.size.height - 60, 60, 60)];
    [pageImageView addSubview:audioRecordingButton];
}

#pragma mark - Book JSON Methods

- (void)getBookJson {
    bookJsonString = @"{\"id\":829,\"title\":\"rahul\",\"language\":\"English\",\"pages\":[{\"id\":584,\"json\":{\"id\":\"Cover\",\"name\":\"Cover\",\"layers\":[{\"type\":\"image\",\"name\":\"image\",\"url\":\"91f501c53a.jpg\",\"alignment\":\"left\",\"order\":0,\"style\":{}}],\"order\":0,\"pageNo\":1,\"original_id\":584}},{\"id\":585,\"json\":{\"id\":1,\"name\":1,\"type\":\"page\",\"layers\":[{\"type\":\"text\",\"name\":\"text-1\",\"alignment\":\"left\",\"order\":0,\"style\":{\"top\":253,\"left\":401,\"width\":431,\"height\":173},\"text\":\"testing the tex box for json attributes\",\"words\":[{\"index\":0,\"text\":\"testing\"},{\"index\":1,\"text\":\"the\"},{\"index\":2,\"text\":\"tex\"},{\"index\":3,\"text\":\"box\"},{\"index\":4,\"text\":\"for\"},{\"index\":5,\"text\":\"json\"},{\"index\":6,\"text\":\"attributes\"}]},{\"type\":\"image\",\"name\":\"image\",\"url\":\"91f501c53a.jpg\",\"alignment\":\"middle\",\"order\":0,\"style\":{}}],\"order\":0,\"pageNo\":1,\"original_id\":585}},{\"id\":586,\"json\":{\"id\":3,\"name\":3,\"type\":\"page\",\"layers\":[{\"type\":\"text\",\"name\":\"text\",\"alignment\":\"left\",\"order\":0,\"style\":{}},{\"type\":\"image\",\"name\":\"image\",\"url\":\"91f501c53a.jpg\",\"alignment\":\"left\",\"order\":0,\"style\":{}}],\"order\":0,\"pageNo\":1,\"original_id\":586}},{\"id\":587,\"json\":{\"id\":2,\"name\":2,\"type\":\"page\",\"layers\":[{\"type\":\"text\",\"name\":\"text\",\"alignment\":\"left\",\"order\":0,\"style\":{}},{\"type\":\"image\",\"name\":\"image\",\"url\":\"91f501c53a.jpg\",\"alignment\":\"left\",\"order\":0,\"style\":{}}],\"order\":0,\"pageNo\":1,\"original_id\":587}},{\"id\":588,\"json\":{\"id\":4,\"name\":4,\"type\":\"page\",\"layers\":[{\"type\":\"text\",\"name\":\"text\",\"alignment\":\"left\",\"order\":0,\"style\":{}}],\"order\":0,\"pageNo\":1}},{\"id\":589,\"json\":{\"id\":4,\"name\":4,\"type\":\"page\",\"layers\":[{\"type\":\"text\",\"name\":\"text-1\",\"alignment\":\"left\",\"order\":0,\"style\":{\"top\":156,\"left\":112},\"text\":\"Mysql create user and grant privileges.\",\"words\":[{\"index\":0,\"text\":\"Mysql\"},{\"index\":1,\"text\":\"create\"},{\"index\":2,\"text\":\"user\"},{\"index\":3,\"text\":\"and\"},{\"index\":4,\"text\":\"grant\"},{\"index\":5,\"text\":\"privileges.\"}]},{\"type\":\"image\",\"name\":\"image\",\"url\":\"91f501c53a.jpg\",\"alignment\":\"left\",\"order\":0,\"style\":{}}],\"order\":0,\"pageNo\":1,\"original_id\":589}}]}";
    
    NSData *jsonData = [bookJsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    NSLog(@"%@", jsonDict);
    
    pagesArray = [[NSMutableArray alloc] initWithArray:[jsonDict objectForKey:PAGES]];
    [pagesCarousel reloadData];
    [self renderPage:0];
}

#pragma mark - Audio Recording

enum
{
    ENC_AAC = 1,
    ENC_ALAC = 2,
    ENC_IMA4 = 3,
    ENC_ILBC = 4,
    ENC_ULAW = 5,
    ENC_PCM = 6,
} encodingTypes;


- (void)startRecordingAudio {
    [audioRecordingButton setImage:[UIImage imageNamed:@"recording_stop_button.png"] forState:UIControlStateNormal];
    [audioRecordingButton addTarget:self action:@selector(stopRecordingAudio) forControlEvents:UIControlEventTouchUpInside];
    
    // Init audio with record capability
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];
    if(recordEncoding == ENC_PCM)
    {
        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    }
    else
    {
        NSNumber *formatObject;
        
        switch (recordEncoding) {
            case (ENC_AAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatMPEG4AAC];
                break;
            case (ENC_ALAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleLossless];
                break;
            case (ENC_IMA4):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
                break;
            case (ENC_ILBC):
                formatObject = [NSNumber numberWithInt: kAudioFormatiLBC];
                break;
            case (ENC_ULAW):
                formatObject = [NSNumber numberWithInt: kAudioFormatULaw];
                break;
            default:
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
        }
        
        [recordSettings setObject:formatObject forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sampleRecord_%d.caf", recDir, currentPageNumber]];
    
    NSError *error = nil;
    audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    
    if ([audioRecorder prepareToRecord] == YES){
        [audioRecorder record];
    }else {
        int errorCode = CFSwapInt32HostToBig ([error code]);
        NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
        
    }
    NSLog(@"recording");
}

- (void)stopRecordingAudio
{
    NSLog(@"stopRecording");
    [audioRecorder stop];
    NSLog(@"stopped");
    [audioRecordingButton setImage:[UIImage imageNamed:@"recording_play_button.png"] forState:UIControlStateNormal];
    [audioRecordingButton addTarget:self action:@selector(startPlayingAudio) forControlEvents:UIControlEventTouchUpInside];

    //[self saveAudio];
}

- (void)saveAudio {
    NSMutableDictionary *audioDict = [[NSMutableDictionary alloc] init];
    [audioDict setObject:AUDIO forKey:TYPE];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    [audioDict setObject:[NSString stringWithFormat:@"%@/sampleRecord_%d.caf", recDir, currentPageNumber] forKey:ASSET_URL];
    
    NSData *jsonData = [bookJsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    //[[[[[jsonDict objectForKey:PAGES] objectAtIndex:currentPageNumber] objectForKey:@"json"] objectForKey:LAYERS] addObject:audioDict];
    
    NSData *newJsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONReadingAllowFragments error:nil];
    bookJsonString = [[NSString alloc] initWithData:newJsonData encoding:NSUTF8StringEncoding];
    [self renderPage:currentPageNumber];
}

#pragma mark - Audio Playing

- (void)startPlayingAudio {
    [audioRecordingButton setImage:[UIImage imageNamed:@"recording_stop_button.png"] forState:UIControlStateNormal];
    [audioRecordingButton addTarget:self action:@selector(stopPlayingAudio) forControlEvents:UIControlEventTouchUpInside];

    NSLog(@"playRecording");
    // Init audio with playback capability
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sampleRecord_%d.caf", recDir, currentPageNumber]];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer.numberOfLoops = 0;
    audioPlayer.delegate = self;
    [audioPlayer play];
}

- (void)stopPlayingAudio {
    [audioRecordingButton setImage:[UIImage imageNamed:@"recording_play_button.png"] forState:UIControlStateNormal];
    [audioRecordingButton addTarget:self action:@selector(startPlayingAudio) forControlEvents:UIControlEventTouchUpInside];

    NSLog(@"stopPlaying");
    [audioPlayer stop];
    NSLog(@"stopped");
}

#pragma mark - Audio Player Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stopPlayingAudio];
}

@end
