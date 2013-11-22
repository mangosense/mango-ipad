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
#import <AssetsLibrary/AssetsLibrary.h>
#import "AudioMappingViewController.h"

#define ENGLISH_TAG 9
#define ANGRYBIRDS_ENGLISH_TAG 17
#define TAMIL_TAG 10
#define MALAY_TAG 12
#define CHINESE_TAG 11
#define GERMAN_TAG 13
#define SPANISH_TAG 14

#define RECORD 1
#define STOP_RECORDING 2
#define PLAY 3
#define STOP_PLAYING 4

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

@property (nonatomic, strong) UIPopoverController *photoPopoverController;

@property (nonatomic, strong) AudioMappingViewController *audioMappingViewController;

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
@synthesize doodleButton;
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
@synthesize photoPopoverController;
@synthesize audioMappingViewController;
@synthesize storyBook;

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
    pageImageView.selectedBrush = 5.0f;
    pageImageView.selectedEraserWidth = 20.0f;
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

#pragma mark - Add New PhotoPage

- (void)addNewPageWithImageUrl:(NSURL *)assetUrl {
    NSMutableDictionary *newPageDict = [[NSMutableDictionary alloc] init];
    [newPageDict setObject:[NSNumber numberWithInt:[pagesArray count]] forKey:@"id"];
    
    NSMutableArray *layersArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] init];
    
    NSURL *asseturl = assetUrl;
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:asseturl resultBlock:^(ALAsset *myasset) {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            [imageDict setObject:CAPTURED_IMAGE forKey:TYPE];
            [imageDict setObject:assetUrl forKey:ASSET_URL];
            [layersArray addObject:imageDict];
            
            [newPageDict setObject:layersArray forKey:LAYERS];
            
            [pagesArray addObject:newPageDict];
            
            [pagesCarousel reloadData];
            [self carousel:pagesCarousel didSelectItemAtIndex:[pagesArray count] - 1];
        }
    } failureBlock:^(NSError *myerror) {
        NSLog(@"Booya, cant get image - %@",[myerror localizedDescription]);
    }];
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (photoPopoverController) {
        if ([photoPopoverController isPopoverVisible]) {
            [photoPopoverController dismissPopoverAnimated:true];
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Dismissed");
    }];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // Request to save the image to camera roll
    [library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            NSLog(@"error");
        } else {
            NSLog(@"url %@", assetURL);
            [self addNewPageWithImageUrl:assetURL];
        }
    }];
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
    [self.navigationController popViewControllerAnimated:YES];
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
    ItemsListViewController *textTemplatesListViewController = [[ItemsListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    textTemplatesListViewController.itemsListArray = [NSMutableArray arrayWithObjects:@"Once upon a time, there was a school, where Children didn’t like reading the books they had.", @"Everyday, they would get bored of reading and  teachers tried everything, but couldn't figure out what to do.", @"One day, they found mangoreader and read the interactive mangoreader story, played fun games and made their own stories.", @"Because of that, children fell in love with reading and started reading and playing with stories and shared with their friends.", @"Because of that, their teachers and parents were excited and they shared the mangoreader stories with other school teachers, kids and parents to give them the joy of reading.", @"Until finally everyone started using mangoreader to create, share and learn from stories which was so much fun.", @"And they all read happily ever after. :)", nil];
    [textTemplatesListViewController.view setFrame:CGRectMake(0, 0, 250, pageImageView.frame.size.height)];
    textTemplatesListViewController.tableType = TABLE_TYPE_TEXT_TEMPLATES;
    textTemplatesListViewController.delegate = self;
    
    menuPopoverController = [[UIPopoverController alloc] initWithContentViewController:textTemplatesListViewController];
    [menuPopoverController setPopoverContentSize:CGSizeMake(250, pageImageView.frame.size.height)];
    menuPopoverController.delegate = self;
    [menuPopoverController setPopoverLayoutMargins:UIEdgeInsetsMake(pageImageView.frame.origin.y, 0, 100, 100)];
    [menuPopoverController.contentViewController.view setBackgroundColor:COLOR_LIGHT_GREY];
    [menuPopoverController presentPopoverFromRect:audioButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
}

- (IBAction)audioButtonTapped:(id)sender {
    ItemsListViewController *audioListController = [[ItemsListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [audioListController.view setFrame:CGRectMake(0, 0, 250, pageImageView.frame.size.height)];
    audioListController.tableType = TABLE_TYPE_AUDIO_RECORDINGS;
    
    menuPopoverController = [[UIPopoverController alloc] initWithContentViewController:audioListController];
    [menuPopoverController setPopoverContentSize:CGSizeMake(250, pageImageView.frame.size.height)];
    menuPopoverController.delegate = self;
    [menuPopoverController setPopoverLayoutMargins:UIEdgeInsetsMake(pageImageView.frame.origin.y, 0, 100, 100)];
    [menuPopoverController.contentViewController.view setBackgroundColor:COLOR_LIGHT_GREY];
    
    [menuPopoverController presentPopoverFromRect:audioButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (IBAction)gamesButtonTapped:(id)sender {
    
}

- (IBAction)collaborationButtonTapped:(id)sender {
    
}

- (IBAction)playStoryButtonTapped:(id)sender {
    
}

- (IBAction)doodleButtonTapped:(id)sender {
    
}

#pragma mark - Items List Delegate

- (void)itemType:(int)itemType tappedAtIndex:(int)index {
    switch (itemType) {
        case TABLE_TYPE_TEXT_TEMPLATES: {
            // Move to delegate method
            MovableTextView *pageTextView = [[MovableTextView alloc] initWithFrame:CGRectMake(0, 0, 400, 300)];
            pageTextView.font = [UIFont systemFontOfSize:30];
            NSArray *itemsArray = [NSArray arrayWithObjects:@"Once upon a time, there was a school, where Children didn’t like reading the books they had.", @"Everyday, they would get bored of reading and  teachers tried everything, but couldn't figure out what to do.", @"One day, they found mangoreader and read the interactive mangoreader story, played fun games and made their own stories.", @"Because of that, children fell in love with reading and started reading and playing with stories and shared with their friends.", @"Because of that, their teachers and parents were excited and they shared the mangoreader stories with other school teachers, kids and parents to give them the joy of reading.", @"Until finally everyone started using mangoreader to create, share and learn from stories which was so much fun.", @"And they all read happily ever after. :)", nil];
            pageTextView.text = [itemsArray objectAtIndex:index];
            [pageImageView addSubview:pageTextView];
        }
            break;
            
        case TABLE_TYPE_AUDIO_RECORDINGS:
            
            break;
            
        default:
            break;
    }
    [menuPopoverController dismissPopoverAnimated:YES];
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
        NSDictionary *pageDict;
        for (NSDictionary *currentPageDict in pagesArray) {
            if ([[currentPageDict objectForKey:PAGE_NAME] isEqualToString:[NSString stringWithFormat:@"%d", index]]) {
                pageDict = currentPageDict;
                break;
            } else if ([[currentPageDict objectForKey:PAGE_NAME] isEqualToString:@"Cover"] && index == 0) {
                pageDict = currentPageDict;
                break;
            }
        }
        
        NSArray *layersArray = [pageDict objectForKey:LAYERS];
        for (NSDictionary *layerDict in layersArray) {
            if ([[layerDict objectForKey:TYPE] isEqualToString:IMAGE]) {
                [pageThumbnail setImage:[UIImage imageWithContentsOfFile:[storyBook.localPathFile stringByAppendingFormat:@"/%@", [layerDict objectForKey:ASSET_URL]]]];
                break;
            } else if ([[layerDict objectForKey:TYPE] isEqualToString:CAPTURED_IMAGE]) {
                NSURL *asseturl = [layerDict objectForKey:ASSET_URL];
                ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
                [assetslibrary assetForURL:asseturl resultBlock:^(ALAsset *myasset) {
                    ALAssetRepresentation *rep = [myasset defaultRepresentation];
                    CGImageRef iref = [rep fullResolutionImage];
                    if (iref) {
                        UIImage *image = [UIImage imageWithCGImage:iref];
                        [pageThumbnail setImage:image];
                    }
                } failureBlock:^(NSError *myerror) {
                    NSLog(@"Couldn't get image - %@",[myerror localizedDescription]);
                }];
            }
        }
    } else {
        [pageThumbnail setImage:[UIImage imageNamed:@"addnewpage.png"]];
        [pageThumbnail setBackgroundColor:COLOR_LIGHT_GREY];
    }
    
    return pageThumbnail;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (index < [pagesArray count]) {
        [self renderEditorPage:index];
    } else {
        NSMutableDictionary *newPageDict = [[NSMutableDictionary alloc] init];
        [newPageDict setObject:[NSNumber numberWithInt:[pagesArray count]] forKey:@"id"];
        [newPageDict setObject:[NSString stringWithFormat:@"%d", [pagesArray count]] forKey:PAGE_NAME];
        
        NSMutableArray *layersArray = [[NSMutableArray alloc] init];
        NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] init];
        [imageDict setObject:IMAGE forKey:TYPE];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *sourceLocation=[[NSBundle mainBundle] pathForResource:@"white_page" ofType:@"jpeg"];
        NSString *destinationFolder=[sourceLocation lastPathComponent] ;
        destinationFolder=[[NSString alloc]initWithFormat:@"%@/%@",[storyBook.localPathFile stringByAppendingString:@"/res/images"],destinationFolder];
        
        NSLog(@"%@ - %@", sourceLocation, destinationFolder);
        
        if (![fileManager fileExistsAtPath:destinationFolder]) {
            [fileManager copyItemAtPath:sourceLocation  toPath:destinationFolder error:nil];
            NSURL *url=[[NSURL alloc]initFileURLWithPath:destinationFolder];
            [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
        }
        
        [imageDict setObject:@"/res/images/white_page.jpeg" forKey:ASSET_URL];
        [layersArray addObject:imageDict];
        
        [newPageDict setObject:layersArray forKey:LAYERS];
        
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

+ (NSNumber *)numberOfPagesInStory:(NSString *)jsonString {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    NSLog(@"%@", jsonDict);
    NSArray *readerPagesArray = [[NSMutableArray alloc] initWithArray:[jsonDict objectForKey:PAGES]];

    return [NSNumber numberWithInt:[readerPagesArray count]];
}

+ (UIImage *)coverPageImageForStory:(NSString *)jsonString WithFolderLocation:(NSString *)folderLocation {
    UIImage *coverPageImage;
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    NSLog(@"%@", jsonDict);
    NSArray *readerPagesArray = [[NSMutableArray alloc] initWithArray:[jsonDict objectForKey:PAGES]];
    
    NSDictionary *coverPageDict;
    for (NSDictionary *pageDict in readerPagesArray) {
        if ([[pageDict objectForKey:PAGE_NAME] isEqualToString:@"Cover"]) {
            coverPageDict = pageDict;
            break;
        }
    }
    
    NSArray *layersArray = [coverPageDict objectForKey:LAYERS];
    for (NSDictionary *layerDict in layersArray) {
        if ([[layerDict objectForKey:TYPE] isEqualToString:IMAGE]) {
            NSLog(@"%@",[layerDict objectForKey:ASSET_URL]);
            coverPageImage = [UIImage imageWithContentsOfFile:[folderLocation stringByAppendingFormat:@"/%@", [layerDict objectForKey:ASSET_URL]]];
        }
    }
    
    return coverPageImage;
}

#define READ_TO_ME 0
#define READ_BY_MYSELF 1

+ (UIView *)readerPage:(int)pageNumber ForStory:(NSString *)jsonString WithFolderLocation:(NSString *)folderLocation AndAudioMappingViewController:(AudioMappingViewController *)audioMappingViewcontroller AndDelegate:(id<AVAudioPlayerDelegate>)delegate Option:(int)readingOption {
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    NSLog(@"%@", jsonDict);
    NSArray *readerPagesArray = [[NSMutableArray alloc] initWithArray:[jsonDict objectForKey:PAGES]];
    
    NSDictionary *pageDict;
    for (NSDictionary *readerPageDict in readerPagesArray) {
        if ([[readerPageDict objectForKey:PAGE_NAME] isEqualToString:[NSString stringWithFormat:@"%d", pageNumber]]) {
            pageDict = readerPageDict;
            break;
        }
    }

    UIView *pageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 924, 600)];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:pageView.frame];
    
    NSArray *layersArray = [pageDict objectForKey:LAYERS];
    NSString *textOnPage;
    CGRect textFrame;
    NSData *audioData;
    for (NSDictionary *layerDict in layersArray) {
        if ([[layerDict objectForKey:TYPE] isEqualToString:IMAGE]) {
            backgroundImageView.image = [UIImage imageWithContentsOfFile:[folderLocation stringByAppendingFormat:@"/%@", [layerDict objectForKey:ASSET_URL]]];
            NSLog(@"%@", [UIImage imageWithContentsOfFile:[folderLocation stringByAppendingFormat:@"/%@", [layerDict objectForKey:ASSET_URL]]]);
            [pageView addSubview:backgroundImageView];
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:AUDIO]) {
           audioData = [NSData dataWithContentsOfFile:[folderLocation stringByAppendingFormat:@"/%@", [layerDict objectForKey:ASSET_URL]]];
            
            audioMappingViewcontroller.customView.textFont = [UIFont systemFontOfSize:30];
            audioMappingViewcontroller.customView.frame = textFrame;
            [audioMappingViewcontroller.customView setBackgroundColor:[UIColor clearColor]];
            [audioMappingViewcontroller.view setExclusiveTouch:YES];
            [audioMappingViewcontroller.customView setNeedsDisplay];
            NSArray *wordMapDict=[layerDict objectForKey:WORDMAP];
            NSMutableArray *wordMap=[[NSMutableArray alloc]init];
            for (NSDictionary *temp in wordMapDict ) {
                NSString *word=temp[@"word"];
                [wordMap addObject:word];
            }
            wordMapDict=[[NSArray alloc]initWithArray:wordMap];/*list of words created*/
            NSArray *cues=[layerDict objectForKey:CUES];
            [wordMap removeAllObjects];
            for (NSNumber *number in cues) { /* converting cues to miliseconds*/
                float time=number.floatValue;
                time*=1000;
                NSInteger integerTime=roundf(time);
                NSNumber *numberIntTimer=[NSNumber numberWithInteger:integerTime];
                [wordMap addObject:numberIntTimer];
                
            }

            audioMappingViewcontroller.customView.text=wordMapDict;
            audioMappingViewcontroller.cues=wordMap;
            if ([UIDevice currentDevice].systemVersion.integerValue<6) {
                audioMappingViewcontroller.customView.space=[@" " sizeWithFont:audioMappingViewcontroller.customView.textFont];
            }else{
                NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:audioMappingViewcontroller.customView.textFont, NSFontAttributeName, nil];
                audioMappingViewcontroller.customView.space=   [[[NSAttributedString alloc] initWithString:@" " attributes:attributes] size];
            }
            
            audioMappingViewcontroller.index=0;
            audioMappingViewcontroller.customView.backgroundColor = [UIColor clearColor];

            if (readingOption == READ_TO_ME) {
                [audioMappingViewcontroller playAudioForReaderWithData:audioData AndDelegate:delegate];
            }
            
            [audioMappingViewcontroller.customView setNeedsDisplay];
            
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:TEXT]) {
            textOnPage = [layerDict objectForKey:TEXT];
            /*if ([[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_POSITION_X] != nil) {
             textFrame = CGRectMake([[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_POSITION_X] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_POSITION_Y] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_WIDTH] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_HEIGHT] floatValue]);
             } else {*/
            textFrame = CGRectMake(100, 100, 600, 400);
            /*}*/
            if ([[layerDict allKeys] containsObject:TEXT_FRAME]) {
                if ([[[layerDict objectForKey:TEXT_FRAME] allKeys] containsObject:LEFT_RATIO] && [[[layerDict objectForKey:TEXT_FRAME] allKeys] containsObject:TOP_RATIO] && [[[layerDict objectForKey:TEXT_FRAME] allKeys] containsObject:TEXT_SIZE_WIDTH] && [[[layerDict objectForKey:TEXT_FRAME] allKeys] containsObject:TEXT_SIZE_HEIGHT]) {
                    textFrame = CGRectMake(MAX(1024/MAX([[[layerDict objectForKey:TEXT_FRAME] objectForKey:LEFT_RATIO] floatValue], 1), 100), MAX(768/MAX([[[layerDict objectForKey:TEXT_FRAME] objectForKey:TOP_RATIO] floatValue], 1), 100), [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_WIDTH] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_HEIGHT] floatValue]);
                }
            }
            
            
            [pageView addSubview:audioMappingViewcontroller.view];
            [audioMappingViewcontroller.view setHidden:YES];
            audioMappingViewcontroller.customView.textFont = [UIFont systemFontOfSize:30];
            audioMappingViewcontroller.customView.frame = textFrame;
            [audioMappingViewcontroller.customView setBackgroundColor:[UIColor clearColor]];
            [audioMappingViewcontroller.view setExclusiveTouch:YES];
            
            [pageView addSubview:audioMappingViewcontroller.customView];
            
            audioMappingViewcontroller.textForMapping = textOnPage;
            
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:CAPTURED_IMAGE]) {
            NSURL *asseturl = [layerDict objectForKey:@"url"];
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
            [assetslibrary assetForURL:asseturl resultBlock:^(ALAsset *myasset) {
                ALAssetRepresentation *rep = [myasset defaultRepresentation];
                CGImageRef iref = [rep fullResolutionImage];
                if (iref) {
                    UIImage *image = [UIImage imageWithCGImage:iref];
                    backgroundImageView.image = image;
                    [pageView addSubview:backgroundImageView];
                }
            } failureBlock:^(NSError *myerror) {
                NSLog(@"Booya, cant get image - %@",[myerror localizedDescription]);
            }];
        }
       
        
     
      //  else if([layerDict objectForKey:WORDMAP])
    }
    
    return pageView;
}

- (void)renderEditorPage:(int)pageNumber {
    pageImageView.selectedColor = 7;
    currentPageNumber = pageNumber;
    
    for (UIView *subview in [pageImageView subviews]) {
        [subview removeFromSuperview];
    }
    pageImageView.incrementalImage = nil;
    
    NSDictionary *pageDict;
    for (NSDictionary *readerPageDict in pagesArray) {
        if ([[readerPageDict objectForKey:PAGE_NAME] isEqualToString:[NSString stringWithFormat:@"%d", pageNumber]]) {
            pageDict = readerPageDict;
            break;
        } else if ([[readerPageDict objectForKey:PAGE_NAME] isEqualToString:@"Cover"] && pageNumber == 0) {
            pageDict = readerPageDict;
            break;
        }
    }
    
    NSArray *layersArray = [pageDict objectForKey:LAYERS];
    NSURL *audioUrl;
    NSString *textOnPage;
    CGRect textFrame;
    
    for (NSDictionary *layerDict in layersArray) {
        if ([[layerDict objectForKey:TYPE] isEqualToString:IMAGE]) {
            pageImageView.incrementalImage = [UIImage imageWithContentsOfFile:[storyBook.localPathFile stringByAppendingFormat:@"/%@", [layerDict objectForKey:ASSET_URL]]];
            pageImageView.tempImage = [UIImage imageWithContentsOfFile:[storyBook.localPathFile stringByAppendingFormat:@"/%@", [layerDict objectForKey:ASSET_URL]]];
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:AUDIO]) {
            audioUrl = [NSURL URLWithString:[storyBook.localPathFile stringByAppendingFormat:@"/%@", [layerDict objectForKey:ASSET_URL]]];
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:TEXT]) {
            textOnPage = [layerDict objectForKey:TEXT];
            /*if ([[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_POSITION_X] != nil) {
                textFrame = CGRectMake([[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_POSITION_X] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_POSITION_Y] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_WIDTH] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_HEIGHT] floatValue]);
            } else {*/
                textFrame = CGRectMake(0, 0, 600, 400);
            /*}*/
            if ([[layerDict allKeys] containsObject:TEXT_FRAME]) {
                if ([[[layerDict objectForKey:TEXT_FRAME] allKeys] containsObject:LEFT_RATIO] && [[[layerDict objectForKey:TEXT_FRAME] allKeys] containsObject:TOP_RATIO] && [[[layerDict objectForKey:TEXT_FRAME] allKeys] containsObject:TEXT_SIZE_WIDTH] && [[[layerDict objectForKey:TEXT_FRAME] allKeys] containsObject:TEXT_SIZE_HEIGHT]) {
                    textFrame = CGRectMake(MAX(1024/MAX([[[layerDict objectForKey:TEXT_FRAME] objectForKey:LEFT_RATIO] floatValue], 1), 100), MAX(768/MAX([[[layerDict objectForKey:TEXT_FRAME] objectForKey:TOP_RATIO] floatValue], 1), 100), [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_WIDTH] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_HEIGHT] floatValue]);
                }
            }
            
            MovableTextView *pageTextView = [[MovableTextView alloc] initWithFrame:textFrame];
            pageTextView.font = [UIFont systemFontOfSize:30];
            pageTextView.text = textOnPage;
            [pageImageView addSubview:pageTextView];
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:CAPTURED_IMAGE]) {
            NSURL *asseturl = [layerDict objectForKey:@"url"];
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
            [assetslibrary assetForURL:asseturl resultBlock:^(ALAsset *myasset) {
                ALAssetRepresentation *rep = [myasset defaultRepresentation];
                CGImageRef iref = [rep fullResolutionImage];
                if (iref) {
                    UIImage *image = [UIImage imageWithCGImage:iref];
                    pageImageView.incrementalImage = image;
                }
            } failureBlock:^(NSError *myerror) {
                NSLog(@"Booya, cant get image - %@",[myerror localizedDescription]);
            }];
        }
    }
    
    audioRecordingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (!audioUrl) {
        [audioRecordingButton setImage:[UIImage imageNamed:@"recording_button.png"] forState:UIControlStateNormal];
        audioRecordingButton.tag = RECORD;
    } else {
        [audioRecordingButton setImage:[UIImage imageNamed:@"recording_play_button.png"] forState:UIControlStateNormal];
        audioRecordingButton.tag = PLAY;
    }
    [audioRecordingButton addTarget:self action:@selector(audioRecButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [audioRecordingButton setFrame:CGRectMake(0, pageImageView.frame.size.height - 60, 60, 60)];
    [pageImageView addSubview:audioRecordingButton];
}

#pragma mark - Book JSON Methods

- (void)setStoryBook:(Book *)storyBookChosen {
    storyBook = storyBookChosen;
    NSString *jsonLocation=storyBook.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson lastObject]];
    bookJsonString = [[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
}

- (void)getBookJson {
    NSLog(@"%@", bookJsonString);
        
    NSData *jsonData = [bookJsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    NSLog(@"%@", jsonDict);
    
    pagesArray = [[NSMutableArray alloc] initWithArray:[jsonDict objectForKey:PAGES]];
    [pagesCarousel reloadData];
    [self renderEditorPage:0];
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

- (void)audioRecButtonTapped {
    switch (audioRecordingButton.tag) {
        case RECORD: {
            [self startRecordingAudio];
        }
            break;
            
        case STOP_RECORDING: {
            [self stopRecordingAudio];
        }
            break;
            
        case PLAY: {
            [self startPlayingAudio];
        }
            break;
            
        case STOP_PLAYING: {
            [self stopPlayingAudio];
        }
            break;
            
        default:
            break;
    }
}


- (void)startRecordingAudio {
    [audioRecordingButton setImage:[UIImage imageNamed:@"recording_stop_button.png"] forState:UIControlStateNormal];
    audioRecordingButton.tag = STOP_RECORDING;
    
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
    [audioRecordingButton setImage:[UIImage imageNamed:@"recording_play_button.png"] forState:UIControlStateNormal];
    audioRecordingButton.tag = PLAY;
    
    NSLog(@"stopRecording");
    [audioRecorder stop];
    NSLog(@"stopped");

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
    [self renderEditorPage:currentPageNumber];
}

#pragma mark - Audio Playing

- (void)startPlayingAudio {
    audioRecordingButton.tag = STOP_PLAYING;
    [audioRecordingButton setImage:[UIImage imageNamed:@"recording_stop_button.png"] forState:UIControlStateNormal];

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
    
    // Temporary, for testing audio mapping UI
    [self showAudioMappingScreen];
}

- (void)stopPlayingAudio {
    [audioRecordingButton setImage:[UIImage imageNamed:@"recording_play_button.png"] forState:UIControlStateNormal];
    audioRecordingButton.tag = PLAY;
    
    NSLog(@"stopPlaying");
    [audioPlayer stop];
    NSLog(@"stopped");
}

#pragma mark - Audio Mapping

- (void)showAudioMappingScreen {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sampleRecord_%d.caf", recDir, currentPageNumber]];
    
    NSDictionary *pageDict;
    for (NSDictionary *readerPageDict in pagesArray) {
        if ([[readerPageDict objectForKey:PAGE_NAME] isEqualToString:[NSString stringWithFormat:@"%d", currentPageNumber]]) {
            pageDict = readerPageDict;
            break;
        } else if ([[readerPageDict objectForKey:PAGE_NAME] isEqualToString:@"Cover"] && currentPageNumber == 0) {
            pageDict = readerPageDict;
            break;
        }
    }
    NSArray *layersArray = [pageDict objectForKey:LAYERS];
    NSString *textOnPage;
    CGRect textFrame = CGRectMake(100, 100, 600, 400);
    
    for (NSDictionary *layerDict in layersArray) {
        if ([[layerDict objectForKey:TYPE] isEqualToString:TEXT]) {
            textOnPage = [layerDict objectForKey:TEXT];
            if ([[layerDict allKeys] containsObject:TEXT_FRAME]) {
                if ([[[layerDict objectForKey:TEXT_FRAME] allKeys] containsObject:LEFT_RATIO] && [[[layerDict objectForKey:TEXT_FRAME] allKeys] containsObject:TOP_RATIO] && [[[layerDict objectForKey:TEXT_FRAME] allKeys] containsObject:TEXT_SIZE_WIDTH] && [[[layerDict objectForKey:TEXT_FRAME] allKeys] containsObject:TEXT_SIZE_HEIGHT]) {
                    textFrame = CGRectMake(MAX(1024/MAX([[[layerDict objectForKey:TEXT_FRAME] objectForKey:LEFT_RATIO] floatValue], 1), 100), MAX(768/MAX([[[layerDict objectForKey:TEXT_FRAME] objectForKey:TOP_RATIO] floatValue], 1), 100), [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_WIDTH] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_HEIGHT] floatValue]);
                    break;
                }
            }
        }
    }

    if (audioMappingViewController) {
        [audioMappingViewController.view removeFromSuperview];
    }
    audioMappingViewController = [[AudioMappingViewController alloc] initWithNibName:@"AudioMappingViewController" bundle:nil];
    [pageImageView addSubview:audioMappingViewController.view];
    
    audioMappingViewController.customView.textFont = [UIFont systemFontOfSize:30];
    audioMappingViewController.customView.frame = textFrame;
    [audioMappingViewController.customView setBackgroundColor:[UIColor clearColor]];
    [audioMappingViewController.view setExclusiveTouch:YES];
    
    [pageImageView addSubview:audioMappingViewController.customView];

    audioMappingViewController.textForMapping = textOnPage;
    audioMappingViewController.audioUrl = url;
    
    for (UIView *subview in [pageImageView subviews]) {
        if ([subview isKindOfClass:[MovableTextView class]]) {
            [subview setHidden:YES];
        }
    }
    pageImageView.selectedColor = 8;
}

#pragma mark - Audio Player Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stopPlayingAudio];
}

#pragma mark - UIActionSheet Delegate Method

#define CAMERA_INDEX 1
#define LIBRARY_INDEX 0

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case CAMERA_INDEX: {
            if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.allowsEditing = YES;
                [self presentViewController:imagePicker animated:YES completion:^{
                    NSLog(@"Completed");
                }];
            }
        }
            break;
            
        case LIBRARY_INDEX: {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.allowsEditing = YES;
                
                photoPopoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
                photoPopoverController.delegate = self;
                [photoPopoverController presentPopoverFromRect:CGRectMake(0, 44, 250, 44) inView:pageImageView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Camera Methods

- (void)cameraButtonTapped {
    UIActionSheet *photoActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Library", @"Camera", nil];
    [photoActionSheet showFromRect:CGRectMake(0, 44, 250, 44) inView:pageImageView animated:YES];
}

@end
