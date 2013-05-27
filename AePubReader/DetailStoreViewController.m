//
//  DetailStoreViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 05/12/12.
//
//

#import "DetailStoreViewController.h"
#import "PurchaseFreeIphone.h"
#import <QuartzCore/QuartzCore.h>
#import "Flurry.h"
@interface DetailStoreViewController ()

@end

@implementation DetailStoreViewController

- (IBAction)backButton:(id)sender {
       AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.PortraitOrientation=YES;
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)purchase:(id)sender {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"email"]){
        if (_isFree) {
            NSString *message=[NSString stringWithFormat:@"Do you wish to download book titled %@ now?",_bookStore.title ];

            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Purchase Successful" message:message delegate:_live cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
            // [alertViewDelegate autorelease];
            [alertView show];
          //  [alertView release];
        }else{
            [_purchaseButton setEnabled:NO];
            
       //     NSLog(@"Product %@",_product.localizedTitle);
            SKPayment *payment=[SKPayment paymentWithProduct:_product];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
        // insert the book if free
        return;
    }
   
//    _alertView =[[UIAlertView alloc]init];
//    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
//    [indicator startAnimating];
//    [_alertView addSubview:indicator];
//  //  [indicator release];
//    [_alertView setTitle:@"Loading...."];
//    UIImage *image=[UIImage imageNamed:@"loading.png"];
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, -160, 391, 320)];
//    
//    
//    imageView.image=image;
//    [_alertView addSubview:imageView];
//    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, 25, 66.0f, 66.0f)];
//    indicator.color=[UIColor blackColor];
//    [indicator startAnimating];
//    [_alertView addSubview:indicator];
//    [indicator release];

//    [_alertView setDelegate:self];
//    [_alertView show];

    if (_isFree) {
        
        [_purchaseButton setEnabled:NO];
        NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
        [dictionary setValue:[NSNumber numberWithInteger:0 ] forKey:@"amount"];
        NSNumber *userid=[[NSUserDefaults standardUserDefaults]objectForKey:@"id"];
        // email=@"1";
        //   userid=[NSNumber numberWithInteger:130];
        [dictionary setValue:userid forKey:@"user_id"];
        [dictionary setValue:[NSNumber numberWithInteger:_identity ] forKey:@"book_id"];
        //      [dictionary setValue:[NSNumber numberWithInteger:557 ] forKey:@"book_id"];
        [dictionary setValue:@"INR" forKey:@"currency"];
        [dictionary setValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"auth_token"] forKey:@"auth_token"];
        // [dictionary setValue:@"sxd4igWVyWAY6uzxgzRv" forKey:@"auth_token"];
        NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        
     //   NSString *valueJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    //    NSLog(@"value json request %@",valueJson);
        NSString *stringURL=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
        // NSString *stringURL=[NSString stringWithFormat:@"http://www.mangoreader.com/api/v1/register_a_purchase.json?amount=0&&user_id=%@&book_id=%d&&currency=INR",email,_identity ];
        // NSURL *url=[NSURL URLWithString:stringURL];
        //stringURL=@"http://192.168.2.29:3000/api/v1/";
        // stringURL=@"http://staging.mangoreader.com/api/v1/";
        stringURL=[stringURL stringByAppendingString:@"register_a_purchase.json"];
        NSLog(@"register pur url %@",stringURL);
        NSURL *url=[NSURL URLWithString:stringURL];
        
        NSMutableURLRequest *mutableRequest=[[NSMutableURLRequest alloc]initWithURL:url];
        [mutableRequest setHTTPMethod:@"POST"];
        [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [mutableRequest setHTTPBody:jsonData];
        PurchaseFreeIphone *purchase=[[PurchaseFreeIphone alloc]initWithDetails:self live:_live identity:_identity];
        NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:mutableRequest delegate:purchase];
        [connection start];
//        [connection autorelease];
//        [dictionary release];
//        [mutableRequest release];
//        [purchase release];
//        [valueJson release];
        
    }else{
         [_purchaseButton setEnabled:NO];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        delegate.identity=_identity;
     //   NSLog(@"Product %@",_product.localizedTitle);
         SKPayment *payment=[SKPayment paymentWithProduct:_product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }

    NSString *flurry=@"Purchasing book";
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setValue:[NSNumber numberWithInteger:_identity] forKey:@"identity"];
    [Flurry logEvent:flurry withParameters:dictionary];
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [self backButton:nil];
            [self.live.parentViewController.navigationController popToRootViewControllerAnimated:YES];
            
      
    }else{
        
    }
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil with:(NSInteger)identity
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _identity=identity;
        // Custom initialization
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        NSNumber *number=[[NSNumber alloc]initWithInteger:_identity];
        _bookStore =[delegate.dataModel getBookById:number];
      //  [_bookStore retain];
        _isFree=[_bookStore.free boolValue];
        if (![_bookStore.free boolValue]) {
            if ([SKPaymentQueue canMakePayments]) {
                NSString *iden=[NSString stringWithFormat:@"%d",_identity ];
                NSSet *prodIds=[NSSet setWithObject:iden];
                SKProductsRequest *productRequest=[[SKProductsRequest alloc]initWithProductIdentifiers:prodIds];
                productRequest.delegate=self;
                [productRequest start];
//                _alertView =[[UIAlertView alloc]init];
//                UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
//                [indicator startAnimating];
//                [_alertView addSubview:indicator];
//                [indicator release];
//                [_alertView setTitle:@"Loading...."];
//               // [_alertView setDelegate:self];
//                [_alertView show];
                
            }else{
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"You are not authorsized to make payments" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
           //     [alertView release];
                [self backButton:nil];
            }
        }
    //    [number release];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.tabBarController.view.frame = CGRectMake(0, 0, 480, 320);
//    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
//    UIBarButtonItem *purchaseButton=[[UIBarButtonItem alloc]initWithTitle:@"Purchase" style:UIBarButtonItemStyleBordered target:self action:@selector(purchase:)];
//    self.navigationItem.rightBarButtonItem=purchaseButton;
//    [purchaseButton release];
    


     //  [[SKPaymentQueue defaultQueue]addTransactionObserver:_live];
    _toolBar.tintColor=[UIColor grayColor];
    _imageView.image=[[UIImage alloc]initWithContentsOfFile:_bookStore.localImage];
    _titleLabel.text=_bookStore.title;
    
    [_webView loadHTMLString:_bookStore.desc baseURL:nil];
    
    float size=[_bookStore.size floatValue];
    _toolBarTop.tintColor=[UIColor blackColor];
    // NSLog(@"%@",[NSNumber numberWithLongLong:size] );
    size=size/1024.0f;
    //NSLog(@"%@",[NSNumber numberWithLongLong:size] );
    size=size/1024.0f;
    //NSLog(@"%@",[NSNumber numberWithLongLong:size] );
 _priceLabel.text=@"Please wait....";
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    // CGFloat screenWidth=screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    // CGFloat screenWidht=screenRect.size.width;
    
    if (screenHeight>500.0&& [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
      CGRect frame=  _webView.frame;
        frame.origin.x=frame.origin.x+30;
        _webView.frame=frame;
    }
    NSString *sizeString=[NSString stringWithFormat:@"File Size : %0.2f MB",size];
    _sizeLabel.text=sizeString;
    
    if([_bookStore.free boolValue]==YES){
        _priceLabel.text=@"Price : Free";
    }else{
        [_purchaseButton setEnabled:NO];
      //  _priceLabel.text=@"Price : Paid";
    }
    
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    _product=  [response.products lastObject];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *identity=[[NSString alloc]initWithFormat:@"%d",_identity ];
    StoreBooks *booksStore= [delegate.dataModel getStoreBookById:identity];
    if (_product) {
        //[_product retain];
        booksStore.amount=_product.price;
        [delegate.dataModel saveStoreBookData:booksStore];
        
        NSLocale *priceLocale=_product.priceLocale;
        NSNumberFormatter *formatter=[[NSNumberFormatter alloc]init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [formatter setLocale:priceLocale];
        
        
        
        // _value=[[NSString alloc]initWithString:[formatter stringFromNumber:_number]];
        _priceLabel.text=[NSString stringWithFormat:@"Price : %@",[formatter stringFromNumber:_product.price]];
        _live.price=_product.price;
      //  delegate.price=_product.price;
    //    [_live.price retain];
     //   [formatter release];
     
    }else{
        _isFree=YES;
       _priceLabel.text= [NSString stringWithFormat:@"Price : Free "];
        NSNumber *numbr=[NSNumber numberWithInt:0];
        booksStore.amount=numbr;
        [delegate.dataModel saveStoreBookData:booksStore];
        
        
    }
 //   [identity release];
    [_purchaseButton setEnabled:YES];
   // [_alertView dismissWithClickedButtonIndex:0 animated:YES];
}


-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    [self.tabBarController.tabBar setHidden:YES];

  //  [self.view bringSubviewToFront:self.view];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [self.tabBarController.tabBar setHidden:NO];
//    if (_alertView) {
//        [_alertView dismissWithClickedButtonIndex:0 animated:YES];
//    }
//[ self.view bringSubviewToFront:self.tabBarController.tabBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)dealloc {
    [_titleLabel release];
    [_imageView release];
    [_desc release];
    [_sizeLabel release];
    [_priceLabel release];
    _bookStore=nil;
    [_toolBar release];
    [_toolBarTop release];
    [_purchaseButton release];
    [super dealloc];
}*/
- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setImageView:nil];
   
    [self setSizeLabel:nil];
    [self setPriceLabel:nil];
    [self setToolBar:nil];
    [self setToolBarTop:nil];
    [self setPurchaseButton:nil];
    [self setWebView:nil];
    [super viewDidUnload];
}
@end
