//
//  StoriesViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 16/08/13.
//
//

#import "StoriesViewController.h"
#import "EditorViewController.h"

#define ENGLISH_TAG 9
#define TAMIL_TAG 10
#define MALAY_TAG 12
#define CHINESE_TAG 11
#define GERMAN_TAG 13
#define SPANISH_TAG 14
#define ANGRYBIRDS_ENGLISH_TAG 17

@interface StoriesViewController ()

@end

@implementation StoriesViewController

@synthesize englishLanguageButton;
@synthesize tamilLanguageButton;
@synthesize carousel;

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
    
    carousel.type = iCarouselTypeCoverFlow2;
    [carousel setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    self.navigationController.navigationBarHidden=YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - iCarousel Datasource and Delegate Methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return 5;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    UIImageView *storyImageView = nil;
    
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 360, 270)];
        storyImageView = [[UIImageView alloc] initWithFrame:view.bounds];
        storyImageView.tag = 1;
        [view addSubview:storyImageView];
    } else {
        storyImageView = (UIImageView *)[view viewWithTag:1];
    }
    
    switch (index) {
        case 0:
            [storyImageView setImage:[UIImage imageNamed:@"b62ef7c141.jpg"]];
            break;
            
        case 1:
            [storyImageView setImage:[UIImage imageNamed:@"2b9713c03f.jpg"]];
            break;
            
        case 2:
            [storyImageView setImage:[UIImage imageNamed:@"e1b23e9390.jpg"]];
            break;
            
        case 3:
            [storyImageView setImage:[UIImage imageNamed:@"8517823664.jpg"]];
            break;
            
        case 4:
            [storyImageView setImage:[UIImage imageNamed:@"abad124338.jpg"]];
            break;
            
        default:
            break;
    }
    
    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"Selected Story: %d", index);
    
    switch (index) {
        case 0:
            [self chooseLanguage:ENGLISH_TAG];
            break;
            
        case 1:
            [self chooseLanguage:GERMAN_TAG];
            break;
            
        case 2:
            [self chooseLanguage:SPANISH_TAG];
            break;
            
        case 3:
            [self chooseLanguage:ANGRYBIRDS_ENGLISH_TAG];
            break;
            
        case 4:
            [self chooseLanguage:TAMIL_TAG];
            break;
            
        default:
            break;
    }
}

#pragma mark - Action Methods

- (IBAction)languageButtonTapped:(id)sender {
    UIButton *languageButton = (UIButton *)sender;
    [self chooseLanguage:languageButton.tag];
}
- (IBAction)switchTabs:(id)sender {
    UISegmentedControl *control=(UISegmentedControl *) sender;
    [self.tabBarController setSelectedIndex:control.selectedSegmentIndex];
}

- (void)chooseLanguage:(NSInteger)tagForChosenLanguage {
    EditorViewController *editorViewController = [[EditorViewController alloc] initWithNibName:@"EditorViewController" bundle:nil];
    editorViewController.tagForLanguage = tagForChosenLanguage;
    [self.navigationController pushViewController:editorViewController animated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    _segmentedcontrol.selectedSegmentIndex=0;
    
}
@end
