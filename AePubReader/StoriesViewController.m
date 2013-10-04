//
//  StoriesViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 16/08/13.
//
//

#import "StoriesViewController.h"
#import "EditorViewController.h"
#import "AFNetworking.h"
#import "AFURLSessionManager.h"
#import "AFURLConnectionOperation.h"

#define ENGLISH_TAG 9
#define TAMIL_TAG 10
#define MALAY_TAG 12
#define CHINESE_TAG 11

@interface StoriesViewController ()

@property (nonatomic, strong) NSMutableArray *liveStoriesArray;
@property (nonatomic, strong) NSMutableArray *draftStoriesArray;
@property (nonatomic, strong) NSMutableArray *liveStoryCoverImagesArray;

@end

@implementation StoriesViewController

@synthesize englishLanguageButton;
@synthesize tamilLanguageButton;
@synthesize carousel;
@synthesize liveStoriesArray;
@synthesize draftStoriesArray;
@synthesize liveStoryCoverImagesArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title=@"Stories";
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *authToken = [defaults objectForKey:@"auth_token"];
    if (authToken) {
        [self performSelectorInBackground:@selector(getAllBooks) withObject:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Display Carousel

- (void)showCarousel {
    carousel.type = iCarouselTypeCoverFlow2;
    [carousel setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    [carousel reloadData];
}

#pragma mark - Get Cover Images for Books

- (void)getCoverImageForIndex:(NSNumber *)index {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.staging.mangoreader.com%@", [[liveStoriesArray objectAtIndex:[index intValue]] objectForKey:@"cover_image"]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[url lastPathComponent]];
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fullPath append:NO]];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"bytesRead: %u, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", bytesRead, totalBytesRead, totalBytesExpectedToRead);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
        
        UIImage *coverImage = [UIImage imageWithContentsOfFile:fullPath];
        [liveStoryCoverImagesArray addObject:coverImage];
        NSLog(@"%@", liveStoryCoverImagesArray);
        [carousel reloadData];
        
        NSError *error;
        if (error) {
            NSLog(@"ERR: %@", [error description]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERR: %@", [error description]);
    }];
    
    [operation start];
}

#pragma mark - Get List of Books

- (void)getAllBooks {
    [self getLiveStories];
    [self getDraftStories];
    [self performSelectorOnMainThread:@selector(showCarousel) withObject:nil waitUntilDone:NO];
}

- (void)getLiveStories {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *authToken = [defaults objectForKey:@"auth_token"];
    NSLog(@"%@", authToken);
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setObject:authToken forKey:@"auth_token"];
    [paramsDict setObject:[defaults objectForKey:@"email"] forKey:@"email"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://www.staging.mangoreader.com/api/v2/editor/stories/live.json" parameters:paramsDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        liveStoriesArray = [[NSMutableArray alloc] initWithArray:(NSArray *)responseObject];
        liveStoryCoverImagesArray = [[NSMutableArray alloc] init];
        [self performSelectorOnMainThread:@selector(showCarousel) withObject:nil waitUntilDone:NO];
        
        int count = [liveStoriesArray count];
        for (int index = 0; index < count; index++) {
            [self performSelectorOnMainThread:@selector(getCoverImageForIndex:) withObject:[NSNumber numberWithInt:index] waitUntilDone:YES];
        }
        NSLog(@"%@", liveStoriesArray);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)getDraftStories {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *authToken = [defaults objectForKey:@"auth_token"];
    NSLog(@"%@", authToken);
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setObject:authToken forKey:@"auth_token"];
    [paramsDict setObject:[defaults objectForKey:@"email"] forKey:@"email"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://www.staging.mangoreader.com/api/v2/editor/stories/draft.json" parameters:paramsDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        draftStoriesArray = [[NSMutableArray alloc] initWithArray:(NSArray *)responseObject];
        
        /*int count = [draftStoriesArray count];
        for (int index = 0; index < count; index++) {
            [self getCoverImageForIndex:index isStoryLive:NO];
        }
        NSLog(@"%@", draftStoriesArray);*/
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - Get Book Details

- (void)getBookDetailsForId:(NSNumber *)storyId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *authToken = [defaults objectForKey:@"auth_token"];
    NSLog(@"%@", authToken);
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setObject:authToken forKey:@"auth_token"];
    [paramsDict setObject:[defaults objectForKey:@"email"] forKey:@"email"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://www.staging.mangoreader.com/api/v2/editor/stories/%d/show.json", [storyId intValue]] parameters:paramsDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        EditorViewController *editorViewController = [[EditorViewController alloc] initWithNibName:@"EditorViewController" bundle:nil];
        editorViewController.tagForLanguage = ENGLISH_TAG;
        editorViewController.jsonDict = (NSDictionary *)responseObject;
        [self.navigationController pushViewController:editorViewController animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - iCarousel Datasource and Delegate Methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [liveStoriesArray count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    UIImageView *storyImageView = nil;
    UIActivityIndicatorView *loadingIndicator = nil;
    
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 360, 270)];
        storyImageView = [[UIImageView alloc] initWithFrame:view.bounds];
        storyImageView.tag = 1;
        [view addSubview:storyImageView];
        loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(view.center.x - 22, view.center.y - 22, 44, 44)];
        loadingIndicator.tag = 2;
        [loadingIndicator setHidesWhenStopped:YES];
        [loadingIndicator setColor:[UIColor blackColor]];
        [view addSubview:loadingIndicator];
        [loadingIndicator startAnimating];
    } else {
        storyImageView = (UIImageView *)[view viewWithTag:1];
        loadingIndicator = (UIActivityIndicatorView *)[view viewWithTag:2];
    }
    
    if (index < [liveStoryCoverImagesArray count]) {
        [loadingIndicator stopAnimating];
        storyImageView.image = [liveStoryCoverImagesArray objectAtIndex:index];
    } else {
        [loadingIndicator startAnimating];
        storyImageView.image = [UIImage imageNamed:@"Default-Landscape~ipad.png"];
    }
    
    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"Selected Story: %d", index);
    
    [self getBookDetailsForId:[[liveStoriesArray objectAtIndex:index] objectForKey:@"id"]];
    /*switch (index) {
        case 0:
            [self chooseLanguage:TAMIL_TAG];
            break;
            
        case 1:
            [self chooseLanguage:ENGLISH_TAG];
            break;
            
        default:
            break;
    }*/
}

#pragma mark - Action Methods

- (IBAction)languageButtonTapped:(id)sender {
    UIButton *languageButton = (UIButton *)sender;
    [self chooseLanguage:languageButton.tag];
}

- (void)chooseLanguage:(NSInteger)tagForChosenLanguage {
    EditorViewController *editorViewController = [[EditorViewController alloc] initWithNibName:@"EditorViewController" bundle:nil];
    editorViewController.tagForLanguage = tagForChosenLanguage;
    [self.navigationController pushViewController:editorViewController animated:YES];
}

@end
