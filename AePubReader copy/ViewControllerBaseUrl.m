//
//  ViewControllerBaseUrl.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 08/04/13.
//
//

#import "ViewControllerBaseUrl.h"

@interface ViewControllerBaseUrl ()

@end

@implementation ViewControllerBaseUrl

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
    _textFieldBaseUrl.text=  [[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTextFieldBaseUrl:nil];
    [super viewDidUnload];
}
- (IBAction)doneClicked:(id)sender {
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    if (![_textFieldBaseUrl.text isEqualToString:[userDefaults objectForKey:@"baseurl"]]) {
        [userDefaults setObject:_textFieldBaseUrl.text forKey:@"baseurl"];
        [userDefaults setBool:YES forKey:@"changed"];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
