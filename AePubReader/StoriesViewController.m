//
//  StoriesViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 16/08/13.
//
//

#import "StoriesViewController.h"
#import "EditorViewController.h"

@interface StoriesViewController ()

@end

@implementation StoriesViewController

@synthesize englishLanguageButton;
@synthesize tamilLanguageButton;

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
    
    [[tamilLanguageButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[tamilLanguageButton layer] setShadowOffset:CGSizeMake(5, 5)];
    [[tamilLanguageButton layer] setShadowOpacity:0.7f];
    [[tamilLanguageButton layer] setShadowRadius:5];
    [[tamilLanguageButton layer] setShouldRasterize:YES];
    
    [[englishLanguageButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[englishLanguageButton layer] setShadowOffset:CGSizeMake(5, 5)];
    [[englishLanguageButton layer] setShadowOpacity:0.7f];
    [[englishLanguageButton layer] setShadowRadius:5];
    [[englishLanguageButton layer] setShouldRasterize:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
