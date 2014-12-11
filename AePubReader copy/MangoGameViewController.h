//
//  MangoGameViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 13/12/13.
//
//

#import <UIKit/UIKit.h>

@interface MangoGameViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, strong) NSURLRequest *webViewUrlRequest;

@property (nonatomic, strong) IBOutlet UIWebView *gameWebView;

- (IBAction)closeGame:(id)sender;

@end
