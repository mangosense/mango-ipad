//
//  PublishViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 16/09/13.
//
//

#import "PublishViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface PublishViewController ()

@end

@implementation PublishViewController

@synthesize titleTextField;
@synthesize descriptionTextView;
@synthesize languagePickerView;
@synthesize ageGroupPickerView;
@synthesize categoryTextField;

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
    [[descriptionTextView layer] setBorderWidth:1.0f];
    [[descriptionTextView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
