//
//  ColoringToolsViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 06/12/13.
//
//

#import "ColoringToolsViewController.h"

@interface ColoringToolsViewController ()

@end

@implementation ColoringToolsViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods

- (IBAction)colorButtonTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    int colorTag = button.tag;
    [_delegate selectedColor:colorTag];
}

- (IBAction)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    CGFloat brushWidth = MAX(slider.value*20, 5);
    [_delegate widthOfBrush:brushWidth];
}

@end
