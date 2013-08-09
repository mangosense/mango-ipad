//
//  EditorViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 08/08/13.
//
//

#import "EditorViewController.h"
#import <QuartzCore/QuartzCore.h>

#define MAIN_TEXTVIEW_TAG 100

@interface EditorViewController ()

@property (nonatomic, strong) NSArray *arrayOfPages;
- (void)getBookJson;

@end

@implementation EditorViewController

@synthesize backgroundImageView;
@synthesize mainTextView;
@synthesize arrayOfPages;
@synthesize pageScrollView;
@synthesize backgroundImagesArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title=@"Editor";
        self.tabBarItem.image=[UIImage imageNamed:@"library.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.    
    backgroundImageView = [[PageBackgroundImageView alloc] initWithFrame:self.view.frame];
    backgroundImageView.delegate = self;
    // Temporarily adding fixed image
    [self.view addSubview:backgroundImageView];
    
    mainTextView = [[MovableTextView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + 20, self.view.frame.origin.y + 20, self.view.frame.size.width/3, self.view.frame.size.height/4)];
    mainTextView.tag = MAIN_TEXTVIEW_TAG;
    mainTextView.textColor = [UIColor blackColor];
    mainTextView.font = [UIFont boldSystemFontOfSize:24];
    [self.view addSubview:mainTextView];
    
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo1.png"]];
    self.navigationItem.titleView=imageView;
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    
    [self.view bringSubviewToFront:pageScrollView];
    [pageScrollView setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 150)];
    UIImage *image=[UIImage imageNamed:@"footer-bg.png"];
    pageScrollView.backgroundColor= [UIColor colorWithPatternImage:image];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showPageScrollView)];
    swipeUp.numberOfTouchesRequired = 2;
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    swipeUp.delaysTouchesBegan = YES;
    [backgroundImageView addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hidePageScrollView)];
    swipeDown.numberOfTouchesRequired = 2;
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    swipeDown.delaysTouchesBegan = YES;
    [backgroundImageView addGestureRecognizer:swipeDown];

    [self getBookJson];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gesture Handlers

- (void)showPageScrollView {
    [UIView
     animateWithDuration:0.5
     animations:^{
         pageScrollView.frame = CGRectMake(0, self.view.frame.size.height - 150, self.view.frame.size.width, 150);
     }];
}

- (void)hidePageScrollView {
    [UIView
     animateWithDuration:0.5
     animations:^{
         pageScrollView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 150);
     }];
}

#pragma mark - PageBackgroundImageView Delegate Method

- (void)replaceImageAtIndex:(NSInteger)index withImage:(UIImage *)image {
    [backgroundImagesArray replaceObjectAtIndex:index withObject:image];
}

#pragma mark - Prepare UI

- (void)createPageWithPageNumber:(NSInteger)pageNumber {
    NSMutableString *textOnPage = [[NSMutableString alloc] initWithString:@""];
    
    NSDictionary *dictionaryForPage = [arrayOfPages objectAtIndex:pageNumber];
    for (NSDictionary *layerDict in [dictionaryForPage objectForKey:@"layers"]) {
        if ([[layerDict objectForKey:@"type"] isEqualToString:@"audio"]) {
            NSArray *arrayOfWords = [layerDict objectForKey:@"wordMap"];
            for (NSDictionary *wordDict in arrayOfWords) {
                [textOnPage appendFormat:@"%@ ", [wordDict objectForKey:@"word"]];
            }
        }
    }
    if ([backgroundImagesArray objectAtIndex:pageNumber]) {
        [backgroundImageView setImage:[backgroundImagesArray objectAtIndex:pageNumber]];
        backgroundImageView.indexOfThisImage = pageNumber;
    }
    if ([textOnPage length] > 0) {
        mainTextView.text = textOnPage;
        CGSize textSize = [mainTextView.text sizeWithFont:[UIFont boldSystemFontOfSize:24] constrainedToSize:CGSizeMake(700, 500) lineBreakMode:NSLineBreakByWordWrapping];
        [mainTextView setFrame:CGRectMake(mainTextView.frame.origin.x, mainTextView.frame.origin.y, textSize.width, textSize.height + 20)];
    } else {
        mainTextView.text = @"";
    }
}

- (void)createPageForSender:(UIButton *)sender {
    [self createPageWithPageNumber:sender.tag];
}

- (void)createScrollView {
    CGFloat minContentWidth = MAX(pageScrollView.frame.size.width, [arrayOfPages count]*150);
    pageScrollView.contentSize = CGSizeMake(minContentWidth, pageScrollView.frame.size.height);
    for (NSDictionary *dictionaryForPage in arrayOfPages) {
        for (NSDictionary *layerDict in [dictionaryForPage objectForKey:@"layers"]) {
            if ([[layerDict objectForKey:@"type"] isEqualToString:@"image"]) {
                
                if (!backgroundImagesArray) {
                    backgroundImagesArray = [[NSMutableArray alloc] init];
                }
                [backgroundImagesArray addObject:[UIImage imageNamed:[layerDict objectForKey:@"url"]]];
                
                UIButton *pageButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [pageButton setImage:[UIImage imageNamed:[layerDict objectForKey:@"url"]] forState:UIControlStateNormal];
                [pageButton addTarget:self action:@selector(createPageForSender:) forControlEvents:UIControlEventTouchUpInside];
                CGFloat xOffsetForButton = [arrayOfPages indexOfObject:dictionaryForPage]*150;
                [pageButton setFrame:CGRectMake(15 + xOffsetForButton, 15, 120, 120)];
                pageButton.tag = [arrayOfPages indexOfObject:dictionaryForPage];
                
                [[pageButton layer] setMasksToBounds:NO];
                [[pageButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
                [[pageButton layer] setShadowOffset:CGSizeMake(10, 10)];
                [[pageButton layer] setShadowOpacity:0.3f];
                [[pageButton layer] setShadowRadius:2];
                [[pageButton layer] setShouldRasterize:YES];
                
                [pageScrollView addSubview:pageButton];
                
            }
        }
    }
}

#pragma mark - Parsing Book Json

- (void)getBookJson {
    // Temporarily adding hardcoded string
    NSString *bookJsonString = @"[{\"id\":\"Cover\",\"name\":\"Cover\",\"layers\":[{\"type\":\"image\",\"url\":\"a9457d95f7.jpg\",\"alignment\":\"left\",\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"original_id\":1317},{\"id\":1,\"name\":1,\"layers\":[{\"type\":\"image\",\"url\":\"71b1a3e2b0.jpg\",\"alignment\":\"middle\",\"order\":0,\"name\":\"\"},{\"type\":\"audio\",\"url\":\"51d029a922.mp3\",\"wordTimes\":[1.70530104637146,2.2062370777130127,2.7171740531921387,3.218951940536499,3.7340469360351562,3.9840149879455566,4.5863800048828125,4.836188793182373,5.338126182556152,6.100030899047852,6.598808765411377,7.39418888092041,7.644157886505127,8.151094436645508,8.402063369750977,8.901841163635254,9.151650428771973,9.402618408203125,9.907554626464844,10.159363746643066,10.661300659179688,11.420206069946289,11.671014785766602,11.924983024597168,12.440077781677246,12.690047264099121,13.459952354431152,13.709919929504395,13.991363525390625,14.994919776916504,15.502857208251953,15.752823829650879,16.002792358398438,17.00634765625,17.287792205810547,17.796728134155273,18.563793182373047,19.06357192993164,19.5633487701416,20.063125610351562,21.814586639404297,22.319364547729492,22.570331573486328,22.821300506591797,23.57304573059082,23.822856903076172,24.072824478149414,24.574602127075195,24.82457160949707,25.07453727722168,25.5753173828125,26.325063705444336,26.826841354370117,27.077808380126953,27.328777313232422,27.831554412841797,28.081523895263672,28.331331253051758,28.837268829345703,29.089237213134766,29.598173141479492,30.09895133972168],\"wordMap\":[{\"word\":\"Neelu\",\"step\":17,\"wordIdx\":1},{\"word\":\"the\",\"step\":22,\"wordIdx\":2},{\"word\":\"butterfly\",\"step\":27,\"wordIdx\":3},{\"word\":\"was\",\"step\":32,\"wordIdx\":4},{\"word\":\"scolding\",\"step\":37,\"wordIdx\":5},{\"word\":\"her\",\"step\":40,\"wordIdx\":6},{\"word\":\"son\",\"step\":46,\"wordIdx\":7},{\"word\":\"Katty,\",\"step\":48,\"wordIdx\":8},{\"word\":\"the\",\"step\":53,\"wordIdx\":9},{\"word\":\"caterpillar,\",\"step\":61,\"wordIdx\":10},{\"word\":\"Why\",\"step\":66,\"wordIdx\":11},{\"word\":\"did\",\"step\":74,\"wordIdx\":12},{\"word\":\"you\",\"step\":76,\"wordIdx\":13},{\"word\":\"eat\",\"step\":82,\"wordIdx\":14},{\"word\":\"all\",\"step\":84,\"wordIdx\":15},{\"word\":\"the\",\"step\":89,\"wordIdx\":16},{\"word\":\"leaves\",\"step\":92,\"wordIdx\":17},{\"word\":\"of\",\"step\":94,\"wordIdx\":18},{\"word\":\"the\",\"step\":99,\"wordIdx\":19},{\"word\":\"plants?\",\"step\":102,\"wordIdx\":20},{\"word\":\"Why\",\"step\":107,\"wordIdx\":21},{\"word\":\"do\",\"step\":114,\"wordIdx\":22},{\"word\":\"you\",\"step\":117,\"wordIdx\":23},{\"word\":\"overeat?\",\"step\":119,\"wordIdx\":24},{\"word\":\"The\",\"step\":124,\"wordIdx\":25},{\"word\":\"gardener\",\"step\":127,\"wordIdx\":26},{\"word\":\"is\",\"step\":135,\"wordIdx\":27},{\"word\":\"angry.\",\"step\":137,\"wordIdx\":28},{\"word\":\"He\",\"step\":140,\"wordIdx\":29},{\"word\":\"is\",\"step\":150,\"wordIdx\":30},{\"word\":\"looking\",\"step\":155,\"wordIdx\":31},{\"word\":\"for\",\"step\":158,\"wordIdx\":32},{\"word\":\"you.\",\"step\":160,\"wordIdx\":33},{\"word\":\"Why?\",\"step\":170,\"wordIdx\":34},{\"word\":\"don't\",\"step\":173,\"wordIdx\":35},{\"word\":\"yath'ever\",\"step\":178,\"wordIdx\":36},{\"word\":\"use\",\"step\":186,\"wordIdx\":37},{\"word\":\"your\",\"step\":191,\"wordIdx\":38},{\"word\":\"brain?\",\"step\":196,\"wordIdx\":39},{\"word\":\"What\",\"step\":201,\"wordIdx\":40},{\"word\":\"can\",\"step\":218,\"wordIdx\":41},{\"word\":\"I\",\"step\":223,\"wordIdx\":42},{\"word\":\"do\",\"step\":226,\"wordIdx\":43},{\"word\":\"mother?\",\"step\":228,\"wordIdx\":44},{\"word\":\"My\",\"step\":236,\"wordIdx\":45},{\"word\":\"brain\",\"step\":238,\"wordIdx\":46},{\"word\":\"is\",\"step\":241,\"wordIdx\":47},{\"word\":\"in\",\"step\":246,\"wordIdx\":48},{\"word\":\"my\",\"step\":248,\"wordIdx\":49},{\"word\":\"tummy,\",\"step\":251,\"wordIdx\":50},{\"word\":\"so\",\"step\":256,\"wordIdx\":51},{\"word\":\"I\",\"step\":263,\"wordIdx\":52},{\"word\":\"do\",\"step\":268,\"wordIdx\":53},{\"word\":\"what\",\"step\":271,\"wordIdx\":54},{\"word\":\"my\",\"step\":273,\"wordIdx\":55},{\"word\":\"tummy\",\"step\":278,\"wordIdx\":56},{\"word\":\"tells\",\"step\":281,\"wordIdx\":57},{\"word\":\"me\",\"step\":283,\"wordIdx\":58},{\"word\":\"to\",\"step\":288,\"wordIdx\":59},{\"word\":\"do,\",\"step\":291,\"wordIdx\":60},{\"word\":\"replied\",\"step\":296,\"wordIdx\":61},{\"word\":\"Katty.\",\"step\":301,\"wordIdx\":62}],\"order\":0,\"name\":\"\"},{\"type\":\"color\",\"color\":\"rgb(255,204,102)\",\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"original_id\":1329}]";
    NSData *jsonData = [bookJsonString dataUsingEncoding:NSUTF8StringEncoding];
    arrayOfPages = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"number of pages: %d", [arrayOfPages count]);
    
    [self createScrollView];
    [self createPageWithPageNumber:0];

}

@end
