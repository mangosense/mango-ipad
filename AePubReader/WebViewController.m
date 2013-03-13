//
//  WebViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 04/10/12.
//
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil URL:(NSURL *)url{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _url=url;
        [_url retain];
    }
    return self;
}
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
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:_url];
    [_url release];
    [_webView loadRequest:request];
    [request release];
    _alert =[[UIAlertView alloc]init];
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        UIImage *image=[UIImage imageNamed:@"loading.png"];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, -160, 391, 320)];
        
        
        imageView.image=image;
        [_alert addSubview:imageView];
        [imageView release];
        UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, 25, 66.0f, 66.0f)];
        indicator.color=[UIColor blackColor];
        [indicator startAnimating];
        [_alert addSubview:indicator];
        [indicator release];
    }
    else{
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
    [indicator startAnimating];
    [_alert addSubview:indicator];
    [indicator release];
        [_alert setTitle:@"Loading...."];}
    [_alert show];
    [_alert release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}
- (void)dealloc {
    [_webView release];
    [super dealloc];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [_alert dismissWithClickedButtonIndex:0 animated:YES];
    _alert =nil;
    NSLog(@"error %@",error);
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
     [_alert dismissWithClickedButtonIndex:0 animated:YES];
    _alert=nil;
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
 

}
- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}
- (IBAction)DismissViewControlller:(id)sender {
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"about:blank"]];
    
    [_webView loadRequest:request];
    [self dismissModalViewControllerAnimated:YES];
    [request release];
}
@end
