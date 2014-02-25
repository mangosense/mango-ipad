//
//  MangoGamesListViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 13/12/13.
//
//

#import "MangoGamesListViewController.h"
#import "MangoEditorViewController.h"
#import "MangoGameViewController.h"
#import <Parse/Parse.h>

#define GAME_DRAW @"draw"
#define GAME_JIGSAW @"jigsaw"
#define GAME_MATCH_IMAGES @"matchimages"
#define GAME_MATCH_WORDS @"matchwords"
#define GAME_MEMORY @"memory"
#define GAME_QA @"question_answer"
#define GAME_QUIZ @"quiz"
#define GAME_SEQUENCE @"sequence"
#define GAME_SEQUENCE_IMAGES @"sequenceimages"
#define GAME_TRUE_FALSE @"true_false"
#define GAME_WORDSEARCH @"wordsearch"

@interface MangoGamesListViewController ()

@property (nonatomic, strong) NSMutableArray *gamesArray;
@property (nonatomic, strong) NSMutableDictionary *dataDict;

@end

@implementation MangoGamesListViewController

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
    _gamesArray = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"word-search-game.jpg"], [UIImage imageNamed:@"memory-puzzle.jpg"], [UIImage imageNamed:@"jigsaw-puzzle.jpg"], nil];
    [_gamesCarousel setType:iCarouselTypeCoverFlow];
    int scrollToIndex = 0;
    if ([_gameNames count] > 2) {
        scrollToIndex = 1;
    }
    [_gamesCarousel scrollToItemAtIndex:scrollToIndex animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - iCarousel Datasource and Delegate Methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [_gameNames count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    UIImageView *storyImageView = [[UIImageView alloc] init];
    [storyImageView setFrame:CGRectMake(0, 0, 400, 350)];
    [storyImageView setImage:[UIImage imageNamed:[_gameNames objectAtIndex:index]]];
    [[storyImageView layer] setCornerRadius:12];
    [storyImageView setClipsToBounds:YES];
    return storyImageView;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    NSString *gameName = [_gameNames objectAtIndex:index];

    NSMutableDictionary *gameViewDict = [MangoEditorViewController readerGamePage:gameName ForStory:_jsonString WithFolderLocation:_folderLocation AndOption:0];
    
    _dataDict = [[NSMutableDictionary alloc] initWithDictionary:[gameViewDict objectForKey:@"data"]];
    [_dataDict setObject:[NSNumber numberWithBool:YES] forKey:@"from_mobile"];
    
    UIWebView *webview = [gameViewDict objectForKey:@"gameView"];
    webview.delegate = self;
    webview.frame = self.view.frame;
    [webview setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth];
    [[webview scrollView] setBounces:NO];
    [self.view addSubview:webview];
    
    [self.view bringSubviewToFront:_closeButton];
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

#pragma mark - Action Methods

- (void)closeGames:(id)sender {
    BOOL hasWeView = NO;
    for (UIView *subview in [self.view subviews]) {
        if ([subview isKindOfClass:[UIWebView class]]) {
            [subview removeFromSuperview];
            hasWeView = YES;
            break;
        }
    }
    if (!hasWeView) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

#pragma mark - UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_dataDict options:NSJSONReadingAllowFragments error:nil];
    NSString *paramString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Param: %@", paramString);
    
    NSString *resultString = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"MangoGame.init(%@)", paramString]];
    NSLog(@"%@", resultString);
}

@end
