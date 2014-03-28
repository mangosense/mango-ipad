//
//  MangoGameViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 13/12/13.
//
//

#import "MangoGameViewController.h"

@interface MangoGameViewController ()

@end

@implementation MangoGameViewController

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
    _gameWebView.delegate = self;
//    NSString *thisURLString = [_webViewUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [_gameWebView loadRequest:_webViewUrlRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    
    NSLog(@"game played");
}

#pragma mark - UIWebView Delegate

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"web view error : %@",[error localizedDescription]);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_dataDict options:NSJSONReadingAllowFragments error:nil];
    NSString *paramString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Param: %@", paramString);
    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"MangoGame.init(%@)", paramString]];
}

#pragma mark - Action Methods

- (IBAction)closeGame:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
