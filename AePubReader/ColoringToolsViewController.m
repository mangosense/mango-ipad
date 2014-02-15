//
//  ColoringToolsViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 06/12/13.
//
//

#import "ColoringToolsViewController.h"

#define RED_BUTTON_TAG 1
#define YELLOW_BUTTON_TAG 2
#define GREEN_BUTTON_TAG 3
#define BLUE_BUTTON_TAG 4
#define PEA_GREEN_BUTTON_TAG 5
#define PURPLE_BUTTON_TAG 6
#define ORANGE_BUTTON_TAG 7
#define ERASER_BUTTON_TAG 8
#define BROWN_BUTTON_TAG 9
#define WHITE_BUTTON_TAG 10
#define PINK_BUTTON_TAG 11

#define RED_BUTTON_TAG_SELECTED 91
#define YELLOW_BUTTON_TAG_SELECTED 92
#define GREEN_BUTTON_TAG_SELECTED 93
#define BLUE_BUTTON_TAG_SELECTED 94
#define PEA_GREEN_BUTTON_TAG_SELECTED 95
#define PURPLE_BUTTON_TAG_SELECTED 96
#define ORANGE_BUTTON_TAG_SELECTED 97
#define ERASER_BUTTON_TAG_SELECTED 98
#define BROWN_BUTTON_TAG_SELECTED 99
#define WHITE_BUTTON_TAG_SELECTED 100
#define PINK_BUTTON_TAG_SELECTED 101

#define SELECTED_DESELECTED_VALUE_DIFF 90

@interface ColoringToolsViewController ()

@property (nonatomic, strong) UIButton *selectedButton;

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
    
    switch (button.tag) {
        case RED_BUTTON_TAG:
        case YELLOW_BUTTON_TAG:
        case GREEN_BUTTON_TAG:
        case BLUE_BUTTON_TAG:
        case PEA_GREEN_BUTTON_TAG:
        case PURPLE_BUTTON_TAG:
        case ORANGE_BUTTON_TAG:
        case BROWN_BUTTON_TAG:
        case WHITE_BUTTON_TAG:
        case PINK_BUTTON_TAG: {
            int colorTag = button.tag;
            
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d", button.tag]] forState:UIControlStateNormal];
            button.tag = button.tag + SELECTED_DESELECTED_VALUE_DIFF;
            
            if (_selectedButton) {
                [self colorButtonTapped:_selectedButton];
            }
            _selectedButton = button;
            [_delegate selectedColor:colorTag];
        }
            break;
            
        case RED_BUTTON_TAG_SELECTED:
        case YELLOW_BUTTON_TAG_SELECTED:
        case GREEN_BUTTON_TAG_SELECTED:
        case BLUE_BUTTON_TAG_SELECTED:
        case PEA_GREEN_BUTTON_TAG_SELECTED:
        case PURPLE_BUTTON_TAG_SELECTED:
        case ORANGE_BUTTON_TAG_SELECTED:
        case BROWN_BUTTON_TAG_SELECTED:
        case WHITE_BUTTON_TAG_SELECTED:
        case PINK_BUTTON_TAG_SELECTED: {
            [_delegate selectedColor:999];
            
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d", button.tag]] forState:UIControlStateNormal];
            button.tag = button.tag - SELECTED_DESELECTED_VALUE_DIFF;
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    CGFloat brushWidth = MAX(slider.value*20, 5);
    [_delegate widthOfBrush:brushWidth];
}

@end
