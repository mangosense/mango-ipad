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
#import "Flickr.h"
#import "FlickrPhoto.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AudioMappingViewController.h"
#import "AssetCollectionViewLayout.h"
#import "AePubReaderAppDelegate.h"
#import "MangoPage.h"
#import "MangoImageLayer.h"
#import "MangoTextLayer.h"
#import "MangoAudioLayer.h"
#import "MangoCapturedImageLayer.h"
#import "ZipArchive.h"
#import "DataModelControl.h"
#import "ColoringToolsViewController.h"

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

@synthesize isNewBook;
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

    [self renderEditorPage:0];
    [pagesCarousel scrollToItemAtIndex:3 animated:YES];
}

-(void)createACopy{
    NSString *oldDirectoryPath = storyBook.localPathFile;
    
    NSArray *tempArrayForContentsOfDirectory =[[NSFileManager defaultManager] contentsOfDirectoryAtPath:oldDirectoryPath error:nil];
    
    NSString *newDirectoryPath = [[oldDirectoryPath stringByDeletingLastPathComponent]stringByAppendingPathComponent:[_editedBookPath lastPathComponent] ];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:newDirectoryPath  withIntermediateDirectories:YES attributes:nil error:nil];
    
    for (int i = 0; i < [tempArrayForContentsOfDirectory count]; i++)
    {
        
        NSString *newFilePath = [newDirectoryPath stringByAppendingPathComponent:[tempArrayForContentsOfDirectory objectAtIndex:i]];
        
        NSString *oldFilePath = [oldDirectoryPath stringByAppendingPathComponent:[tempArrayForContentsOfDirectory objectAtIndex:i]];
        
        NSError *error = nil;
        [[NSFileManager defaultManager] copyItemAtPath:oldFilePath toPath:newFilePath error:&error];
        
        if (error) {
            // handle error
        }
    }
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
    [newPageDict setObject:[NSNumber numberWithInt:[_mangoStoryBook.pages count]] forKey:@"id"];
    
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
            
            NSMutableArray *tempPagesArray = [[NSMutableArray alloc] initWithArray:_mangoStoryBook.pages];
            [tempPagesArray addObject:newPageDict];
            _mangoStoryBook.pages = tempPagesArray;
            
            [pagesCarousel reloadData];
            [self carousel:pagesCarousel didSelectItemAtIndex:[_mangoStoryBook.pages count] - 1];
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

- (void)saveFrame:(CGRect)textFrame AndText:(NSString *)layerText ForLayer:(NSString *)layerId {
    
    NSLog(@"Text Frame: %@", NSStringFromCGRect(textFrame));
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    MangoTextLayer *textLayer = [appDelegate.ejdbController getLayerForLayerId:layerId];
    if (textLayer) {
        textLayer.actualText = layerText;
        textLayer.fontSize = [NSNumber numberWithInt:30];
        textLayer.height = [NSNumber numberWithFloat:textFrame.size.height];
        textLayer.width = [NSNumber numberWithFloat:textFrame.size.width];
        textLayer.leftRatio = [NSNumber numberWithFloat:924.0f/textFrame.origin.x];
        textLayer.topRatio = [NSNumber numberWithFloat:600.0f/textFrame.origin.y];
        if ([appDelegate.ejdbController insertOrUpdateObject:textLayer]) {
            NSLog(@"Successfully updated textlayer");
            MangoTextLayer *savedLayer = [appDelegate.ejdbController getLayerForLayerId:layerId];
            NSLog(@"Saved height = %@", savedLayer.height);
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView isKindOfClass:[MovableTextView class]]) {
        MovableTextView *newTextview = (MovableTextView *)textView;
        if (!_audioLayer) {
            _audioLayer = [[MangoAudioLayer alloc] init];
            _audioLayer.wordTimes = [[NSArray alloc] init];
            _audioLayer.url = @"";
        }
        _audioLayer.wordMap = [newTextview.text componentsSeparatedByString:@" "];
        
        AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([appDelegate.ejdbController insertOrUpdateObject:_audioLayer]) {
            
        }
        [self saveFrame:textView.frame AndText:textView.text ForLayer:newTextview.layerId];
    } else {
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
    if ([[self.view subviews] containsObject:stickerView]) {
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
    
  /*  UIScrollView *assetsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 105, 250, 500)];
    assetsScrollView.backgroundColor = [UIColor clearColor];
    [assetsScrollView setUserInteractionEnabled:YES];
    CGFloat minContentHeight = MAX(assetsScrollView.frame.size.height, 37/2*140);
    assetsScrollView.contentSize = CGSizeMake(assetsScrollView.frame.size.width, minContentHeight);
    */
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    for (int i = 1; i < 358; i++) {
       // if ([UIImage imageNamed:[NSString stringWithFormat:@"editor_%d", i]]) {
            [imagesArray addObject:[NSString stringWithFormat:@"editor_%d", i]];
       // }
    }
    arrayOfImageNames = [NSArray arrayWithArray:imagesArray];

    AssetCollectionViewLayout *layout=[[AssetCollectionViewLayout alloc]init];
    UICollectionView *collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 105, 250, 500) collectionViewLayout:layout];
    [collectionView registerClass:[AssetCell class] forCellWithReuseIdentifier:@"Cell"];
    _dataSource=[[AssetDatasource alloc]initWithArray:arrayOfImageNames];
    collectionView.dataSource=_dataSource;
    collectionView.delegate=self;
    collectionView.backgroundColor=[UIColor whiteColor];
    /*[layout.sc UICollectionViewScrollDirectionHorizontal];
    [layout setItemSize:CGSizeMake(140, 180)];
    [layout setSectionInset:UIEdgeInsetsMake(30, 30, 30, 30)];
    [layout setMinimumInteritemSpacing:50];
    [layout setMinimumLineSpacing:50];*/
    UIViewController *scrollController=[[UIViewController alloc]init];
    scrollController.view.frame=CGRectMake(0, 0, 250, 500);
    [scrollController.view addSubview:collectionView];
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
    
   /* UIViewController *scrollViewController = [[UIViewController alloc] init];
    [scrollController.view  setFrame:CGRectMake(0, 0, 250, pageImageView.frame.size.height)];
    [scrollViewController.view addSubview:assetsScrollView];*/
    [scrollController.view  addSubview:assetTypeSegmentedControl];
    [scrollController.view  addSubview:takePhotoButton];
    [scrollController.view  addSubview:searchTextView];
    
   
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
       // [assetsScrollView addSubview:assetImageButton];
    }
    
    menuPopoverController = [[UIPopoverController alloc] initWithContentViewController:scrollController];
    [menuPopoverController setPopoverContentSize:CGSizeMake(250, pageImageView.frame.size.height)];
    menuPopoverController.delegate = self;
    [menuPopoverController setPopoverLayoutMargins:UIEdgeInsetsMake(pageImageView.frame.origin.y, 0, 100, 100)];
    [menuPopoverController.contentViewController.view setBackgroundColor:COLOR_LIGHT_GREY];
    
    [menuPopoverController presentPopoverFromRect:imageButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.tag=indexPath.row;
    [self addImageForButton:button];
    
}
#pragma mark - Coming Soon Popover

- (void)showComingSoonPopover:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    UILabel *comingSoonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
    comingSoonLabel.text = @"Coming Soon...";
    comingSoonLabel.textAlignment = NSTextAlignmentCenter;
    comingSoonLabel.font = [UIFont boldSystemFontOfSize:24];
    comingSoonLabel.textColor = COLOR_GREY;
    
    UIViewController *comingSoonController = [[UIViewController alloc] init];
    [comingSoonController.view addSubview:comingSoonLabel];
    
    menuPopoverController = [[UIPopoverController alloc] initWithContentViewController:comingSoonController];
    [menuPopoverController setPopoverContentSize:CGSizeMake(250, 250) animated:YES];
    [menuPopoverController setPopoverLayoutMargins:UIEdgeInsetsMake(pageImageView.frame.origin.y, 0, 100, 100)];
    [menuPopoverController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

#pragma mark - DrawingTools Delegate

- (void)widthOfBrush:(CGFloat)brushWidth {
    pageImageView.selectedBrush = brushWidth;
}

- (void)selectedColor:(int)color {
    pageImageView.selectedColor = color;
}

#pragma mark - Post API Delegate

- (void)saveStoryId:(NSNumber *)storyId {
    NSLog(@"%d", [storyId intValue]);
}

#pragma mark - Popover Delegates

- (void)goToStoriesList {
    [menuPopoverController dismissPopoverAnimated:YES];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    apiController.delegate = self;
    [apiController saveNewBookWithJSON:@""];

    
    [self mangoButtonTapped:nil];
}

#pragma mark - Action Methods

- (IBAction)mangoButtonTapped:(id)sender {
    
    bookJsonString = [self jsonForBook:_mangoStoryBook];
    NSData *data = [bookJsonString dataUsingEncoding:NSUTF8StringEncoding];
    [self createFileAtPath:[NSString stringWithFormat:@"%@/%@.json", _editedBookPath, _mangoStoryBook.id] WithData:data];

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)menuButtonTapped:(id)sender {
    MenuTableViewController *menuTableViewController = [[MenuTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    menuTableViewController.popDelegate = self;
    menuPopoverController = [[UIPopoverController alloc] initWithContentViewController:menuTableViewController];
    [menuPopoverController setPopoverContentSize:CGSizeMake(250, 250) animated:YES];
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
    [menuPopoverController presentPopoverFromRect:textButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
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
    [self showComingSoonPopover:sender];
}

- (IBAction)collaborationButtonTapped:(id)sender {
    [self showComingSoonPopover:sender];
}

- (IBAction)playStoryButtonTapped:(id)sender {
    
}

- (IBAction)doodleButtonTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    ColoringToolsViewController *coloringToolsController = [[ColoringToolsViewController alloc] initWithNibName:@"ColoringToolsViewController" bundle:nil];
    coloringToolsController.delegate = self;
    
    menuPopoverController = [[UIPopoverController alloc] initWithContentViewController:coloringToolsController];
    [menuPopoverController setPopoverContentSize:CGSizeMake(250, 193) animated:YES];
    [menuPopoverController setPopoverLayoutMargins:UIEdgeInsetsMake(pageImageView.frame.origin.y, 0, 100, 100)];
    [menuPopoverController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

#pragma mark - Items List Delegate

- (void)itemType:(int)itemType tappedAtIndex:(int)index withDetail:(NSString *)detail {
    switch (itemType) {
        case TABLE_TYPE_TEXT_TEMPLATES: {
            // Move to delegate method
            MovableTextView *pageTextView = [[MovableTextView alloc] initWithFrame:CGRectMake(0, 0, 400, 300)];
            pageTextView.font = [UIFont systemFontOfSize:30];
            NSArray *itemsArray = [NSArray arrayWithObjects:@"Once upon a time, there was a school, where Children didn’t like reading the books they had.", @"Everyday, they would get bored of reading and  teachers tried everything, but couldn't figure out what to do.", @"One day, they found mangoreader and read the interactive mangoreader story, played fun games and made their own stories.", @"Because of that, children fell in love with reading and started reading and playing with stories and shared with their friends.", @"Because of that, their teachers and parents were excited and they shared the mangoreader stories with other school teachers, kids and parents to give them the joy of reading.", @"Until finally everyone started using mangoreader to create, share and learn from stories which was so much fun.", @"And they all read happily ever after. :)", nil];
            pageTextView.text = [itemsArray objectAtIndex:index];
            [pageImageView addSubview:pageTextView];
            
            AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
            MangoPage *page = [appDelegate.ejdbController getPageForPageId:[_mangoStoryBook.pages objectAtIndex:currentPageNumber]];
            
            MangoTextLayer *textLayer = [[MangoTextLayer alloc] init];
            textLayer.actualText = pageTextView.text;
            textLayer.fontSize = [NSNumber numberWithInt:30];
            textLayer.leftRatio = [NSNumber numberWithFloat:1000.0f];
            textLayer.topRatio = [NSNumber numberWithFloat:1000.0f];
            textLayer.width = [NSNumber numberWithFloat:600.0f];
            textLayer.height = [NSNumber numberWithFloat:400.0f];
            if ([appDelegate.ejdbController insertOrUpdateObject:textLayer]) {
                _audioLayer = [[MangoAudioLayer alloc] init];
                _audioLayer.wordMap = [textLayer.actualText componentsSeparatedByString:@" "];
                _audioLayer.wordTimes = [[NSArray alloc] init];
                _audioLayer.url = @"";
                if ([appDelegate.ejdbController insertOrUpdateObject:_audioLayer]) {
                    
                }
                
                NSMutableArray *layersArray = [[NSMutableArray alloc] initWithArray:page.layers];
                [layersArray addObject:textLayer.id];
                page.layers = layersArray;
                if ([appDelegate.ejdbController insertOrUpdateObject:page]) {
                    NSLog(@"New text added on new page. Success.");
                }
            }
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
    return [_mangoStoryBook.pages count] + 1;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    PageThumbnailView *pageThumbnail = [[PageThumbnailView alloc] initWithFrame:CGRectMake(0, 0, 130, 90)];
    pageThumbnail.thumbnailImageView.image = [UIImage imageNamed:@"white_page.jpeg"];
    [pageThumbnail setBackgroundColor:[UIColor clearColor]];
    pageThumbnail.delegate = self;
    pageThumbnail.deleteButton.tag = index;
    
    if (index < [_mangoStoryBook.pages count]) {
        
        AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        MangoPage *currentPage = [appDelegate.ejdbController getPageForPageId:[_mangoStoryBook.pages objectAtIndex:index]];
        
        NSArray *layersArray = currentPage.layers;
        for (NSString *layerId in layersArray) {
            id layer = [appDelegate.ejdbController getLayerForLayerId:layerId];
            
            if ([layer isKindOfClass:[MangoImageLayer class]]) {
                MangoImageLayer *imageLayer = (MangoImageLayer *)layer;
                [pageThumbnail.thumbnailImageView setImage:[UIImage imageWithContentsOfFile:[_editedBookPath stringByAppendingFormat:@"/%@", imageLayer.url]]];
                break;
            } else if ([layer isKindOfClass:[MangoCapturedImageLayer class]]) {
                MangoCapturedImageLayer *capturedImageLayer = (MangoCapturedImageLayer *)layer;
                
                NSURL *asseturl = [NSURL URLWithString:capturedImageLayer.url];
                ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
                [assetslibrary assetForURL:asseturl resultBlock:^(ALAsset *myasset) {
                    ALAssetRepresentation *rep = [myasset defaultRepresentation];
                    CGImageRef iref = [rep fullResolutionImage];
                    if (iref) {
                        UIImage *image = [UIImage imageWithCGImage:iref];
                        [pageThumbnail.thumbnailImageView setImage:image];
                    }
                } failureBlock:^(NSError *myerror) {
                    NSLog(@"Couldn't get image - %@",[myerror localizedDescription]);
                }];
            }
        }
    } else {
        UIImage *image = [UIImage imageNamed:@"addnewpage.png"];
        [pageThumbnail.thumbnailImageView setImage:image];
    }
    
    return pageThumbnail;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (index < [_mangoStoryBook.pages count]) {
        [self renderEditorPage:index];
    } else {
        [self createEmptyPage];
        [pagesCarousel reloadData];
        [self carousel:pagesCarousel didSelectItemAtIndex:[_mangoStoryBook.pages count] - 1];
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

-(NSArray *)listFileAtPath:(NSString *)path
{
    //-----> LIST ALL FILES <-----//
    NSLog(@"LISTING ALL FILES FOUND");
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    return directoryContent;
}

#pragma mark - Page Delete Delegate Method

- (void)deletePageNumber:(int)pageNumber {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *mutablePagesArray = [NSMutableArray arrayWithArray:_mangoStoryBook.pages];
    if (pageNumber < [mutablePagesArray count]) {
        [mutablePagesArray removeObjectAtIndex:pageNumber];
        _mangoStoryBook.pages = (NSArray *)mutablePagesArray;
        if ([appDelegate.ejdbController insertOrUpdateObject:_mangoStoryBook]) {
            NSLog(@"Page deleted");
            [pagesCarousel removeItemAtIndex:pageNumber animated:YES];
            [pagesCarousel reloadData];
            [self carousel:pagesCarousel didSelectItemAtIndex:MIN(pageNumber, [_mangoStoryBook.pages count] - 1)];
        }
    }
}

#pragma mark - DoodleDelegate Method

- (void)replaceImageAtIndex:(NSInteger)index withImage:(UIImage *)image {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    MangoPage *currentPage = [appDelegate.ejdbController getPageForPageId:[_mangoStoryBook.pages objectAtIndex:index]];
    
    MangoImageLayer *newLayer = [[MangoImageLayer alloc] init];
    int layerIndex = 0;
    for (NSString *layerId in currentPage.layers) {
        id layer = [appDelegate.ejdbController getLayerForLayerId:layerId];
        layerIndex = [currentPage.layers indexOfObject:layerId];
        if ([layer isKindOfClass:[MangoImageLayer class]]) {
            newLayer = (MangoImageLayer *)layer;
            newLayer.url = [NSString stringWithFormat:@"res/white_page_%d", currentPageNumber];
            newLayer.alignment = @"center";
            
            NSString *destinationString = [_editedBookPath stringByAppendingFormat:@"/%@", newLayer.url];
            NSFileManager *defaultFileManager = [NSFileManager defaultManager];
            if ([defaultFileManager fileExistsAtPath:destinationString]) {
                [defaultFileManager removeItemAtPath:destinationString error:nil];
            }
            
            NSData *imageData = UIImagePNGRepresentation(image);
            if ([defaultFileManager fileExistsAtPath:[_editedBookPath stringByAppendingString:@"/res"]]) {
                NSLog(@"Res Exists");
                [self listFileAtPath:[_editedBookPath stringByAppendingString:@"/res"]];
            }
            BOOL isImageWritten = [defaultFileManager createFileAtPath:destinationString contents:imageData attributes:nil];
            NSLog(@"%d", isImageWritten);
            
            if ([appDelegate.ejdbController insertOrUpdateObject:newLayer]) {
                NSLog(@"Success Updating Layer");
            }
            break;
        }
    }
    
    NSMutableArray *newLayersArray = [[NSMutableArray alloc] initWithArray:currentPage.layers];
    [newLayersArray replaceObjectAtIndex:layerIndex withObject:newLayer.id];
    currentPage.layers = newLayersArray;
    
    if ([appDelegate.ejdbController insertOrUpdateObject:currentPage]) {
        NSLog(@"Success Updating Page");
    }
    
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

+ (UIView *)readerPage:(int)pageNumber ForEditedStory:(MangoBook *)storyBook WithFolderLocation:(NSString *)folderLocation WithAudioMappingViewController:(AudioMappingViewController *)audioMappingViewController andDelegate:(id<AVAudioPlayerDelegate>)delegate Option:(int)readingOption {
    UIView *pageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 924, 600)];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:pageView.frame];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    MangoPage *currentPage = [appDelegate.ejdbController getPageForPageId:[storyBook.pages objectAtIndex:MIN(pageNumber, [storyBook.pages count] - 1)]];
    
    NSString *textOnPage;
    CGRect textFrame;
    NSData *audioData;
    for (NSString *layerId in currentPage.layers) {
        id layer = [appDelegate.ejdbController getLayerForLayerId:layerId];
        
        if ([layer isKindOfClass:[MangoImageLayer class]]) {
            MangoImageLayer *imageLayer = (MangoImageLayer *)layer;
            backgroundImageView.image = [UIImage imageWithContentsOfFile:[folderLocation stringByAppendingFormat:@"/%@", imageLayer.url]];
            NSLog(@"%@", [UIImage imageWithContentsOfFile:[folderLocation stringByAppendingFormat:@"/%@", imageLayer.url]]);
            [pageView addSubview:backgroundImageView];
        } else if ([layer isKindOfClass:[MangoAudioLayer class]]) {
            MangoAudioLayer *audioLayer = (MangoAudioLayer *)layer;
            audioData = [NSData dataWithContentsOfFile:[folderLocation stringByAppendingFormat:@"/%@", audioLayer.url]];
            
            audioMappingViewController.customView.textFont = [UIFont systemFontOfSize:30];
            audioMappingViewController.customView.frame = textFrame;
            [audioMappingViewController.customView setBackgroundColor:[UIColor clearColor]];
            [audioMappingViewController.view setExclusiveTouch:YES];
            [audioMappingViewController.customView setNeedsDisplay];
 
            NSArray *cues=audioLayer.wordTimes;
            
            
            audioMappingViewController.customView.text=audioLayer.wordMap;
            audioMappingViewController.cues=[[NSMutableArray alloc]initWithArray:cues];
            if ([UIDevice currentDevice].systemVersion.integerValue<6) {
                audioMappingViewController.customView.space=[@" " sizeWithFont:audioMappingViewController.customView.textFont];
            }else{
                NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:audioMappingViewController.customView.textFont, NSFontAttributeName, nil];
                audioMappingViewController.customView.space=   [[[NSAttributedString alloc] initWithString:@" " attributes:attributes] size];
            }
            
            audioMappingViewController.index=0;
            audioMappingViewController.customView.backgroundColor = [UIColor clearColor];
            
            if (readingOption == READ_TO_ME) {
                [audioMappingViewController playAudioForReaderWithData:audioData AndDelegate:delegate];
            }
            NSLog(@"%@",audioMappingViewController.cues);
            [audioMappingViewController.customView setNeedsDisplay];
            
        } else if ([layer isKindOfClass:[MangoTextLayer class]]) {
            MangoTextLayer *textLayer = (MangoTextLayer *)layer;
            textOnPage = textLayer.actualText;
            /*if ([[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_POSITION_X] != nil) {
             textFrame = CGRectMake([[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_POSITION_X] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_POSITION_Y] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_WIDTH] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_HEIGHT] floatValue]);
             } else {*/
            textFrame = CGRectMake(100, 100, 600, 400);
            /*}*/
            textFrame = CGRectMake(MAX(1024/MAX([textLayer.leftRatio floatValue], 1), 100), MAX(768/MAX([textLayer.topRatio floatValue], 1), 100), [textLayer.width floatValue], [textLayer.height floatValue]);
            
            
            [pageView addSubview:audioMappingViewController.view];
            [audioMappingViewController.view setHidden:YES];
            audioMappingViewController.customView.textFont = [UIFont systemFontOfSize:30];
            audioMappingViewController.customView.frame = textFrame;
            [audioMappingViewController.customView setBackgroundColor:[UIColor clearColor]];
            [audioMappingViewController.view setExclusiveTouch:YES];
            
            [pageView addSubview:audioMappingViewController.customView];
            
            audioMappingViewController.textForMapping = textOnPage;
            
        } /*else if ([[layerDict objectForKey:TYPE] isEqualToString:CAPTURED_IMAGE]) {
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
        }*/
        
        
        
        //  else if([layerDict objectForKey:WORDMAP])
    }
    
    return pageView;
}

+ (NSMutableDictionary *)readerGamePage:(NSString *)gameName ForStory:(NSString *)jsonString WithFolderLocation:(NSString *)folderLocation AndOption:(NSInteger)readingOption {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    NSLog(@"%@", jsonDict);
    NSArray *readerPagesArray = [[NSMutableArray alloc] initWithArray:[jsonDict objectForKey:PAGES]];
    
    for (NSDictionary *readerPageDict in readerPagesArray) {
        if ([[readerPageDict objectForKey:PAGE_NAME] isEqualToString:gameName]) {
            UIWebView *gameWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            NSString *filePath = [[folderLocation stringByAppendingFormat:@"/games/%@/index.html", [readerPageDict objectForKey:PAGE_NAME]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"%@", filePath);
            [gameWebView loadRequest:[[NSURLRequest alloc ] initWithURL:[NSURL URLWithString:filePath]]];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:gameWebView forKey:@"gameView"];
            [dict setObject:[[readerPageDict objectForKey:LAYERS] lastObject] forKey:@"data"];
            
            return dict;
        }
    }
    
    return nil;
}

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
            

            audioMappingViewcontroller.customView.text=wordMapDict;
            audioMappingViewcontroller.cues=[[NSMutableArray alloc]initWithArray:cues];
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
            NSLog(@"%@",audioMappingViewcontroller.cues);
            [audioMappingViewcontroller.customView setNeedsDisplay];
            
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:TEXT]) {
            textOnPage = [layerDict objectForKey:TEXT];
            textFrame = CGRectMake(100, 100, 600, 400);

            if ([[layerDict allKeys] containsObject:TEXT_FRAME]) {
                if ([[[layerDict objectForKey:TEXT_FRAME] allKeys] containsObject:LEFT_RATIO] && [[[layerDict objectForKey:TEXT_FRAME] allKeys] containsObject:TOP_RATIO] && [[[layerDict objectForKey:TEXT_FRAME] allKeys] containsObject:TEXT_SIZE_WIDTH] && [[[layerDict objectForKey:TEXT_FRAME] allKeys] containsObject:TEXT_SIZE_HEIGHT]) {
                    
                    CGFloat xOrigin = 0;
                    if (![[[layerDict objectForKey:TEXT_FRAME] objectForKey:LEFT_RATIO] isEqual:[NSNull null]]) {
                        xOrigin = MAX(1024/MAX([[[layerDict objectForKey:TEXT_FRAME] objectForKey:LEFT_RATIO] floatValue], 1), 100);
                    }
                    
                    
                    CGFloat yOrigin = 0;
                    if (![[[layerDict objectForKey:TEXT_FRAME] objectForKey:TOP_RATIO] isEqual:[NSNull null]]) {
                        yOrigin = MAX(768/MAX([[[layerDict objectForKey:TEXT_FRAME] objectForKey:TOP_RATIO] floatValue], 1), 100);
                    }
                    
                    CGSize textSize = [textOnPage boundingRectWithSize:CGSizeMake(1024 - xOrigin, 768 - yOrigin) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:30] forKey:NSFontAttributeName] context:nil].size;
                    
                    textFrame = CGRectMake(xOrigin, yOrigin, textSize.width - 100, textSize.height + 100);
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
    
    if ([[pageView subviews] count] > 0) {
        return pageView;
    }
    return nil;
}

- (void)renderEditorPage:(int)pageNumber {
    pageImageView.delegate = self;
    pageImageView.selectedBrush = 5.0f;
    pageImageView.selectedEraserWidth = 20.0f;

    currentPageNumber = pageNumber;
    
    for (UIView *subview in [pageImageView subviews]) {
        [subview removeFromSuperview];
    }
    pageImageView.incrementalImage = nil;
    pageImageView.indexOfThisImage = currentPageNumber;
    
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    MangoPage *mangoStoryPage = [appDelegate.ejdbController getPageForPageId:[_mangoStoryBook.pages objectAtIndex:MIN(pageNumber, [_mangoStoryBook.pages count] - 1)]];
    
    
    NSArray *layersArray = mangoStoryPage.layers;
    //NSURL *audioUrl;
    NSString *textOnPage;
    //CGRect textFrame;
    _audioUrl=nil;
    _audioLayer = nil;
    for (NSString *layerId in layersArray) {
        id mangoStoryLayer = [appDelegate.ejdbController getLayerForLayerId:layerId];
        
        if ([mangoStoryLayer isKindOfClass:[MangoImageLayer class]]) {
            MangoImageLayer *imageLayer = (MangoImageLayer *)mangoStoryLayer;
            
            NSLog(@"%@", [_editedBookPath stringByAppendingFormat:@"/%@", imageLayer.url]);
            pageImageView.incrementalImage = [UIImage imageWithContentsOfFile:[_editedBookPath stringByAppendingFormat:@"/%@", imageLayer.url]];
            pageImageView.tempImage = [UIImage imageWithContentsOfFile:[_editedBookPath stringByAppendingFormat:@"/%@", imageLayer.url]];
        } else if ([mangoStoryLayer isKindOfClass:[MangoTextLayer class]]) {
            MangoTextLayer *textLayer = (MangoTextLayer *)mangoStoryLayer;
            
            textOnPage = textLayer.actualText;
            _textFrame = CGRectMake(0, 0, 600, 400);
            _textFrame = CGRectMake(924.0f/[textLayer.leftRatio floatValue], 600.0f/[textLayer.topRatio floatValue], [textLayer.width floatValue], MAX([textLayer.height floatValue], 100));
            NSLog(@"Rendered Text fRame: %@", NSStringFromCGRect(_textFrame));
            NSLog(@"Rendered height = %f", [textLayer.height floatValue]);
            
            MovableTextView *pageTextView = [[MovableTextView alloc] initWithFrame:_textFrame];
            pageTextView.font = [UIFont systemFontOfSize:30];
            pageTextView.text = textOnPage;
            pageTextView.layerId = textLayer.id;
            pageTextView.textDelegate = self;
            pageTextView.delegate = self;
            [pageImageView addSubview:pageTextView];
        } else if ([mangoStoryLayer isKindOfClass:[MangoAudioLayer class]]) {
            MangoAudioLayer *audioLayer = (MangoAudioLayer *)mangoStoryLayer;
            NSString *audioString= [_editedBookPath stringByAppendingFormat:@"/%@", audioLayer.url];
            if (audioString) {
                _audioUrl = [NSURL fileURLWithPath:audioString];
            }
            _audioLayer=audioLayer;
        } /*else if ([[layerDict objectForKey:TYPE] isEqualToString:CAPTURED_IMAGE]) {
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
        }*/
    }
  //  _audioUrl=nil;
    audioRecordingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (!_audioUrl) {
        [audioRecordingButton setImage:[UIImage imageNamed:@"recording_button.png"] forState:UIControlStateNormal];
        audioRecordingButton.tag = RECORD;
    } else {
        [audioRecordingButton setImage:[UIImage imageNamed:@"recording_play_button.png"] forState:UIControlStateNormal];
        audioRecordingButton.tag = PLAY;
    }
    [audioRecordingButton addTarget:self action:@selector(audioRecButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [audioRecordingButton setFrame:CGRectMake(0, pageImageView.frame.size.height - 60, 60, 60)];
    [pageImageView addSubview:audioRecordingButton];
    
    //Game
    if (mangoStoryPage.layers.count==0) {
        UILabel *comingSoonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pageImageView.frame.size.width, pageImageView.frame.size.height)];
        comingSoonLabel.text = @"Coming Soon...";
        comingSoonLabel.textAlignment = NSTextAlignmentCenter;
        comingSoonLabel.textColor = COLOR_GREY;
        comingSoonLabel.font = [UIFont boldSystemFontOfSize:24];
        comingSoonLabel.backgroundColor=[UIColor whiteColor];
        [pageImageView addSubview:comingSoonLabel];
        return;
    }
}

#pragma mark - Create/Modify Book JSON while saving

- (NSDictionary *)dictionaryForBook:(MangoBook *)book {
    NSMutableDictionary *bookDict;
    
    bookDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:book.id, @"id", book.pages, @"pages", book.title, @"title", nil];
    NSMutableArray *pagesArrayForbook = [[NSMutableArray alloc] init];
    for (NSString *pageId in book.pages) {
        AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        MangoPage *page = [appDelegate.ejdbController getPageForPageId:pageId];
        NSDictionary *pageDict = [self dictionaryForPage:page];
        [pagesArrayForbook addObject:pageDict];
    }
    [bookDict setObject:pagesArrayForbook forKey:@"pages"];
    
    return [NSDictionary dictionaryWithDictionary:bookDict];
}

- (NSString *)jsonForBook:(MangoBook *)book {
    NSString *jsonString;
    
    NSDictionary *bookDict = [self dictionaryForBook:book];
    NSError *error;
    NSData *bookData = [NSJSONSerialization dataWithJSONObject:bookDict options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    jsonString = [[NSString alloc] initWithData:bookData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

#pragma mark - Book JSON Methods

- (NSString *)jsonStringForLocation:(NSString *)jsonLocation {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation = [jsonLocation stringByAppendingPathComponent:[onlyJson lastObject]];
    NSString *jsonString = [[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    return jsonString;
}

- (NSDictionary *)dictionaryForLayer:(id)layer {
    NSDictionary *layerDict;
    
    if ([layer isKindOfClass:[MangoImageLayer class]]) {
        MangoImageLayer *imgLayer = (MangoImageLayer *)layer;
        layerDict = [NSDictionary dictionaryWithObjectsAndKeys:imgLayer.id, @"id", imgLayer.url, @"url", IMAGE, @"type", nil];
    } else if ([layer isKindOfClass:[MangoTextLayer class]]) {
        MangoTextLayer *txtLayer = (MangoTextLayer *)layer;
        layerDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:txtLayer.actualText, txtLayer.fontSize, txtLayer.height, txtLayer.width, txtLayer.leftRatio, txtLayer.topRatio, TEXT, nil] forKeys:[NSArray arrayWithObjects:@"actualText", @"fontSize", @"height", @"width", @"leftRatio", @"topRatio", @"type", nil]];
    } else if ([layer isKindOfClass:[MangoAudioLayer class]]) {
        MangoAudioLayer *audLayer = (MangoAudioLayer *)layer;
        layerDict = [NSDictionary dictionaryWithObjectsAndKeys:audLayer.id, @"id", audLayer.url, @"url", audLayer.wordMap, @"wordMap", audLayer.wordTimes, @"wordTimes", AUDIO, @"type", nil];
    }
    
    return layerDict;
}

- (NSDictionary *)dictionaryForPage:(MangoPage *)page {
    NSMutableDictionary *pageDict;
    
    pageDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:page.name, @"name", page.pageable_id, @"pageable_id", page.layers, @"layers", page.id, @"id", nil];
    NSMutableArray *layersArray = [[NSMutableArray alloc] init];
    for (NSString *layerId in page.layers) {
        AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        id layer = [appDelegate.ejdbController getLayerForLayerId:layerId];
        [layersArray addObject:[self dictionaryForLayer:layer]];
    }
    [pageDict setObject:layersArray forKey:@"layers"];

    return [NSDictionary dictionaryWithDictionary:pageDict];
}

- (NSString *)jsonStringForNewBook:(MangoBook *)book {
    NSString *jsonString;
    
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:book.id, @"id", book.title, @"title", [NSMutableArray array], @"pages", nil];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONReadingAllowFragments error:&error];
    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

- (void)createCoverPage {
    MangoPage *coverPage = [[MangoPage alloc] init];
    coverPage.pageable_id = _mangoStoryBook.id;
    coverPage.name = @"Cover";
    
    NSMutableArray *layersArray = [[NSMutableArray alloc] init];
    
    MangoImageLayer *newImageLayer = [[MangoImageLayer alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *sourceLocation=[[NSBundle mainBundle] pathForResource:@"white_page" ofType:@"jpeg"];
    NSString *destinationFolder=[sourceLocation lastPathComponent] ;
    destinationFolder=[[NSString alloc]initWithFormat:@"%@/%@",[_editedBookPath stringByAppendingString:@"/res"],destinationFolder];
    if (![fileManager fileExistsAtPath:destinationFolder]) {
        [fileManager copyItemAtPath:sourceLocation  toPath:destinationFolder error:nil];
        NSURL *url=[[NSURL alloc]initFileURLWithPath:destinationFolder];
        [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
    
    newImageLayer.url = @"res/white_page.jpeg";
    newImageLayer.alignment = @"center";
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.ejdbController insertOrUpdateObject:newImageLayer]) {
        [layersArray addObject:newImageLayer.id];
        coverPage.layers = layersArray;
        
        if ([appDelegate.ejdbController insertOrUpdateObject:coverPage]) {
            NSMutableArray *existingPagesArray = [[NSMutableArray alloc] initWithArray:_mangoStoryBook.pages];
            [existingPagesArray addObject:coverPage.id];
            _mangoStoryBook.pages = existingPagesArray;
            
            if ([appDelegate.ejdbController insertOrUpdateObject:_mangoStoryBook]) {
                NSLog(@"Successfully updated book");
            }
        }
    }
}

- (void)createEmptyPage {
    MangoPage *newPage = [[MangoPage alloc] init];
    newPage.pageable_id = _mangoStoryBook.id;
    newPage.name = [NSString stringWithFormat:@"%d", [_mangoStoryBook.pages count]];
    
    NSMutableArray *layersArray = [[NSMutableArray alloc] init];
    
    MangoImageLayer *newImageLayer = [[MangoImageLayer alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *sourceLocation=[[NSBundle mainBundle] pathForResource:@"white_page" ofType:@"jpeg"];
    NSString *destinationFolder=[sourceLocation lastPathComponent] ;
    destinationFolder=[[NSString alloc]initWithFormat:@"%@/%@",[_editedBookPath stringByAppendingString:@"/res"],destinationFolder];
    if (![fileManager fileExistsAtPath:destinationFolder]) {
        [fileManager copyItemAtPath:sourceLocation  toPath:destinationFolder error:nil];
        NSURL *url=[[NSURL alloc]initFileURLWithPath:destinationFolder];
        [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
    
    newImageLayer.url = @"res/white_page.jpeg";
    newImageLayer.alignment = @"center";
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.ejdbController insertOrUpdateObject:newImageLayer]) {
        [layersArray addObject:newImageLayer.id];
        newPage.layers = layersArray;
        
        if ([appDelegate.ejdbController insertOrUpdateObject:newPage]) {
            NSMutableArray *existingPagesArray = [[NSMutableArray alloc] initWithArray:_mangoStoryBook.pages];
            [existingPagesArray addObject:newPage.id];
            _mangoStoryBook.pages = existingPagesArray;
            
            if ([appDelegate.ejdbController insertOrUpdateObject:_mangoStoryBook]) {
                NSLog(@"Successfully updated book");
            }
        }
    }
}

- (BOOL)createFolderAtPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"%@", error);
    } else {
        
    }
    return success;
}

- (BOOL)createFileAtPath:(NSString *)filePath WithData:(NSData *)jsonData{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager createFileAtPath:filePath contents:jsonData attributes:nil];

    return success;
}

- (void)saveBook:(MangoBook *)book AtLocation:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        NSURL *url = [[NSURL alloc]initFileURLWithPath:filePath];
        [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
    
    //Adding to database
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![appDelegate.dataModel checkIfIdExists:book.id]) {
        Book *coreDatabook= [appDelegate.dataModel getBookInstance];
        coreDatabook.title=book.title;
        coreDatabook.link=nil;
        coreDatabook.localPathImageFile = filePath;
        coreDatabook.localPathFile = [filePath stringByDeletingPathExtension];
        coreDatabook.id = book.id;
        coreDatabook.size = @23068672;
        coreDatabook.date = [NSDate date];
        coreDatabook.textBook = @4;
        coreDatabook.downloadedDate = [NSDate date];
        coreDatabook.downloaded = @NO;
        coreDatabook.edited = @YES;
        NSError *error=nil;
        if (![appDelegate.managedObjectContext save:&error]) {
            NSLog(@"%@",error);
        }
    }
}

- (void)setStoryBook:(Book *)storyBookChosen {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (isNewBook) {
        MangoBook *newBook = [[MangoBook alloc] init];
        newBook.title = @"My Book";
        newBook.pages = [NSArray array];
        if ([appDelegate.ejdbController insertOrUpdateObject:newBook]) {
            NSLog(@"Saving new book...");
            _mangoStoryBook = newBook;
            
            //Create Core Data Book
            NSString *newBookFilePath = [[appDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:newBook.id];
            [self saveBook:_mangoStoryBook AtLocation:newBookFilePath];
            BOOL success = [self createFolderAtPath:newBookFilePath];
            if (success) {
                success = [self createFolderAtPath:[NSString stringWithFormat:@"%@/res", newBookFilePath]];
            }
            _editedBookPath = newBookFilePath;
            
            //Create JSON String
            bookJsonString = [self jsonStringForNewBook:_mangoStoryBook];
            NSData *data = [bookJsonString dataUsingEncoding:NSUTF8StringEncoding];
            [self createFileAtPath:[NSString stringWithFormat:@"%@/%@.json", newBookFilePath, newBook.id] WithData:data];
            
            //Create Empty Page
            [self createCoverPage];
            [self createEmptyPage];
        }
    } else {
        _mangoStoryBook = [appDelegate.ejdbController getBookForBookId:storyBookChosen.id];
        
        storyBook = storyBookChosen;
        
        //Get JSON String
        bookJsonString = [self jsonStringForLocation:storyBook.localPathFile];
        
        BOOL isDir;
        NSLog(@"%d, %d", [[NSFileManager defaultManager] fileExistsAtPath:_editedBookPath isDirectory:&isDir], isDir);
        
        //If Downloaded, then fork it.
        //Else this is a newly created book. Keep it as it is.
        if ([storyBook.downloaded boolValue]) {
            _editedBookPath = [storyBook.localPathFile stringByAppendingString:@"_fork"];
        } else {
            _editedBookPath = storyBook.localPathFile;
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:_editedBookPath isDirectory:&isDir]) {
            [self createACopy];
            AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
            
            Book *book= [ delegate.dataModel getBookOfId:[NSString stringWithFormat:@"%@",storyBook.id]];
            Book *editedBook=[delegate.dataModel getBookInstance];
            editedBook.localPathFile=_editedBookPath;
            editedBook.localPathImageFile=book.localPathImageFile;
            editedBook.title=book.title;
            editedBook.desc=book.desc;
            editedBook.size=book.size;
            editedBook.downloaded=@YES;
            editedBook.bookId=book.bookId;
            editedBook.edited = @YES;
            
            //Make Duplicate in EJDB
            _mangoStoryBook.id = nil;
            if ([appDelegate.ejdbController insertOrUpdateObject:_mangoStoryBook]) {
                NSLog(@"%@", _mangoStoryBook.id);
                editedBook.id=_mangoStoryBook.id;
                [delegate.managedObjectContext save:nil];
                [delegate.dataModel displayAllData];
                
                NSLog(@"Successfully duplicated book");
            }
        }
        NSLog(@"newPath %@",_editedBookPath);
    }

    [pagesCarousel setClipsToBounds:YES];
    [pagesCarousel reloadData];
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
          //  [self startPlayingAudio];
            [self startPlayingAudioFromDb];
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
    _audioUrl=url;
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
    [self saveAudioDb];
}
- (void)saveAudioDb {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];

    MangoPage *currentPage = [appDelegate.ejdbController getPageForPageId:[_mangoStoryBook.pages objectAtIndex:currentPageNumber]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    NSString *sourceLocation=[NSString stringWithFormat:@"%@/sampleRecord_%d.caf", recDir, currentPageNumber];
    NSString *destinationFolder=[sourceLocation lastPathComponent] ;
    destinationFolder=[[NSString alloc]initWithFormat:@"%@/%@",[_editedBookPath stringByAppendingString:@"/res"],destinationFolder];
    
    NSLog(@"%@ - %@", sourceLocation, destinationFolder);
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:destinationFolder]) {
        [fileManager copyItemAtPath:sourceLocation  toPath:destinationFolder error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
        NSURL *url=[[NSURL alloc]initFileURLWithPath:destinationFolder];
        [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
    
    if (!_audioLayer) {
        _audioLayer = [[MangoAudioLayer alloc] init];
        _audioLayer.wordMap = [[NSArray alloc] init];
        _audioLayer.wordTimes = [[NSArray alloc] init];
    }
    _audioLayer.url = [NSString stringWithFormat:@"res/sampleRecord_%d.caf", currentPageNumber];

    if ([appDelegate.ejdbController insertOrUpdateObject:_audioLayer]) {
        NSMutableArray *layersArray = [[NSMutableArray alloc] initWithArray:currentPage.layers];
        if (![layersArray containsObject:_audioLayer.id]) {
            [layersArray addObject:_audioLayer.id];
        }
        currentPage.layers = layersArray;
        
        if ([appDelegate.ejdbController insertOrUpdateObject:currentPage]) {
            NSLog(@"Success");
            
        }
    }
}

- (void)saveAudio {
    NSMutableDictionary *pageDict = [NSMutableDictionary dictionaryWithDictionary:[_mangoStoryBook.pages objectAtIndex:currentPageNumber]];
    NSMutableArray *layersArray = [[NSMutableArray alloc] initWithArray:[pageDict objectForKey:LAYERS]];
    
    NSMutableDictionary *newAudioDict = [[NSMutableDictionary alloc] init];
    [newAudioDict setObject:AUDIO forKey:TYPE];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    NSString *sourceLocation=[NSString stringWithFormat:@"%@/sampleRecord_%d.caf", recDir, currentPageNumber];
    NSString *destinationFolder=[sourceLocation lastPathComponent] ;
    destinationFolder=[[NSString alloc]initWithFormat:@"%@/%@",[_editedBookPath stringByAppendingString:@"/res"],destinationFolder];
    
    NSLog(@"%@ - %@", sourceLocation, destinationFolder);
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:destinationFolder]) {
        [fileManager copyItemAtPath:sourceLocation  toPath:destinationFolder error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
        NSURL *url=[[NSURL alloc]initFileURLWithPath:destinationFolder];
        [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
    
    [newAudioDict setObject:[NSString stringWithFormat:@"res/sampleRecord_%d.caf", currentPageNumber] forKey:ASSET_URL];
    [layersArray addObject:newAudioDict];
    
    [pageDict setObject:layersArray forKey:LAYERS];
    
    NSMutableArray *tempPagesArray = [NSMutableArray arrayWithArray:_mangoStoryBook.pages];
    [tempPagesArray replaceObjectAtIndex:currentPageNumber withObject:pageDict];
    _mangoStoryBook.pages = (NSArray *)tempPagesArray;
    
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
    
    NSDictionary *pageDict;
    for (NSDictionary *readerPageDict in _mangoStoryBook.pages) {
        if ([[readerPageDict objectForKey:PAGE_NAME] isEqualToString:[NSString stringWithFormat:@"%d", currentPageNumber]]) {
            pageDict = readerPageDict;
            break;
        } else if ([[readerPageDict objectForKey:PAGE_NAME] isEqualToString:@"Cover"] && currentPageNumber == 0) {
            pageDict = readerPageDict;
            break;
        }
    }
    
    NSArray *layersArray = [pageDict objectForKey:LAYERS];
    NSURL *audioUrl;
    
    for (NSDictionary *layerDict in layersArray) {
        if ([[layerDict objectForKey:TYPE] isEqualToString:AUDIO]) {
            audioUrl = [NSURL URLWithString:[_editedBookPath stringByAppendingFormat:@"/%@", [layerDict objectForKey:ASSET_URL]]];
            break;
        }
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    NSURL *url;
    if (audioUrl) {
        url = audioUrl;
    } else {
        url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sampleRecord_%d.caf", recDir, currentPageNumber]];
    }
    
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer.numberOfLoops = 0;
    audioPlayer.delegate = self;
    [audioPlayer play];
    
    // Temporary, for testing audio mapping UI
    [self showAudioMappingScreen];
}
-(void)startPlayingAudioFromDb{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    NSURL *url;
    if (_audioUrl) {
        url = _audioUrl;
    } else {
        url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sampleRecord_%d.caf", recDir, currentPageNumber]];
    }
   /* NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer.numberOfLoops = 0;
    audioPlayer.delegate = self;
    [audioPlayer play];*/
    [self showAudioMappingScreenDb];

    
}
- (void)stopPlayingAudio {
    [audioRecordingButton setImage:[UIImage imageNamed:@"recording_play_button.png"] forState:UIControlStateNormal];
    audioRecordingButton.tag = PLAY;
    
    NSLog(@"stopPlaying");
    [audioPlayer stop];
    NSLog(@"stopped");
}

#pragma mark - Audio Mapping

- (void)saveAudioMapping {
    
    _audioLayer.wordTimes = [audioMappingViewController.cues copy];
    _audioLayer.wordMap = [audioMappingViewController.customView.text copy];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.ejdbController insertOrUpdateObject:_audioLayer]) {
        NSLog(@"Audio mapping saved!");
    }
}

- (void)showAudioMappingScreen {
    [self selectedColor:0];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sampleRecord_%d.caf", recDir, currentPageNumber]];
    
    NSDictionary *pageDict;
    for (NSDictionary *readerPageDict in _mangoStoryBook.pages) {
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
                    textFrame = CGRectMake(MAX(924/MAX([[[layerDict objectForKey:TEXT_FRAME] objectForKey:LEFT_RATIO] floatValue], 1), 100), MAX(600/MAX([[[layerDict objectForKey:TEXT_FRAME] objectForKey:TOP_RATIO] floatValue], 1), 100), [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_WIDTH] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_HEIGHT] floatValue]);
                }
            }
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:AUDIO]) {
            url = [NSURL URLWithString:[_editedBookPath stringByAppendingFormat:@"/%@", [layerDict objectForKey:ASSET_URL]]];
        }
    }

    if (audioMappingViewController) {
        [audioMappingViewController.view removeFromSuperview];
    }
    audioMappingViewController = [[AudioMappingViewController alloc] initWithNibName:@"AudioMappingViewController" bundle:nil];
    [pageImageView addSubview:audioMappingViewController.view];
    
    audioMappingViewController.customView.textFont = [UIFont systemFontOfSize:30];
    audioMappingViewController.customView.frame = textFrame;
    
    [pageImageView addSubview:audioMappingViewController.customView];

    audioMappingViewController.textForMapping = textOnPage;
    [audioMappingViewController.customView setBackgroundColor:[UIColor clearColor]];

    audioMappingViewController.audioUrl = url;
    [pageImageView bringSubviewToFront:audioMappingViewController.view];
    
    for (UIView *subview in [pageImageView subviews]) {
        if ([subview isKindOfClass:[MovableTextView class]]) {
            [subview setHidden:YES];
        }
    }
    

}

-(void)showAudioMappingScreenDb {
    [self selectedColor:0];
    if (audioMappingViewController) {
        [audioMappingViewController.view removeFromSuperview];
    }
    audioMappingViewController = [[AudioMappingViewController alloc] initWithNibName:@"AudioMappingViewController" bundle:nil];
    [pageImageView addSubview:audioMappingViewController.view];
    audioMappingViewController.audioMappingDelegate = self;
    
    audioMappingViewController.customView.textFont = [UIFont systemFontOfSize:30];
    
    [pageImageView addSubview:audioMappingViewController.customView];
      audioMappingViewController.textForMapping=@""; // needed for the space CGSize assignment.
    audioMappingViewController.cues=[[NSMutableArray alloc]initWithArray:_audioLayer.wordTimes];

    audioMappingViewController.customView.text=_audioLayer.wordMap;
    NSLog(@"%@",audioMappingViewController.customView.text);
    NSLog(@"%@",audioMappingViewController.cues);
    [audioMappingViewController.customView setBackgroundColor:[UIColor clearColor]];
    
    audioMappingViewController.audioUrl = _audioUrl;
    [pageImageView bringSubviewToFront:audioMappingViewController.view];
    
    for (UIView *subview in [pageImageView subviews]) {
        if ([subview isKindOfClass:[MovableTextView class]]) {
            audioMappingViewController.customView.frame = subview.frame;
            [subview setHidden:YES];
        }
    }
  
    
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
