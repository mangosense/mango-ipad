//
//  DrawingToolsView.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 02/09/13.
//
//

#import "DrawingToolsView.h"

#define RED_BUTTON_TAG 1
#define YELLOW_BUTTON_TAG 2
#define GREEN_BUTTON_TAG 3
#define BLUE_BUTTON_TAG 4
#define PEA_GREEN_BUTTON_TAG 5
#define PURPLE_BUTTON_TAG 6
#define ORANGE_BUTTON_TAG 7
#define ERASER_BUTTON_TAG 8

#define BRUSH_TAG 10
#define ERASER_TAG 11

@interface DrawingToolsView()

@property (nonatomic, strong) UIButton *redColorButton;
@property (nonatomic, strong) UIButton *yellowColorButton;
@property (nonatomic, strong) UIButton *greenColorButton;
@property (nonatomic, strong) UIButton *blueColorButton;
@property (nonatomic, strong) UIButton *purpleColorButton;
@property (nonatomic, strong) UIButton *orangeColorButton;
@property (nonatomic, strong) UIButton *eraserButton;
@property (nonatomic, strong) UISlider *brushSlider;
@property (nonatomic, strong) UISlider *eraserSlider;
@property (nonatomic, strong) UIButton *assetsButton;

@end

@implementation DrawingToolsView

@synthesize redColorButton;
@synthesize yellowColorButton;
@synthesize greenColorButton;
@synthesize blueColorButton;
@synthesize purpleColorButton;
@synthesize orangeColorButton;
@synthesize eraserButton;
@synthesize brushSlider;
@synthesize eraserSlider;
@synthesize assetsButton;
@synthesize colorTag;
@synthesize brushWidth;
@synthesize eraserWidth;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeUI];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Button Methods

- (void)colorButtonTapped:(UIButton *)sender {
    colorTag = sender.tag;
    [delegate selectedColor:colorTag];
}

- (void)sliderValueChanged:(UISlider *)slider {
    switch (slider.tag) {
        case BRUSH_TAG:
            brushWidth = MAX(slider.value*20, 5);
            [delegate widthOfBrush:brushWidth];
            break;
            
        case ERASER_TAG:
            eraserWidth = MAX(slider.value*100, 20);
            [delegate widthOfEraser:eraserWidth];
            break;
            
        default:
            break;
    }
}

- (void)assetsButtonTapped {
    [delegate showAssets];
}
#pragma mark - UI Methods

- (void)initializeUI {
    [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"topdot.png"]]];
    [self addPaintColorButtons];
    [self addSliders];
    [self createAssetsButton];
    [delegate widthOfEraser:10];
    [delegate widthOfBrush:5];
    [delegate selectedColor:RED_BUTTON_TAG];
}

- (UIButton *)createPaintColorButtonForColor:(int)color AndFrame:(CGRect)frame{
    UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [colorButton setFrame:frame];
    colorButton.tag = color;
    [colorButton addTarget:self action:@selector(colorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    switch (color) {
        case RED_BUTTON_TAG:
            [colorButton setImage:[UIImage imageNamed:@"red-splash.png"] forState:UIControlStateNormal];
            break;
            
        case YELLOW_BUTTON_TAG:
            [colorButton setImage:[UIImage imageNamed:@"yellow-splash.png"] forState:UIControlStateNormal];
            break;
            
        case GREEN_BUTTON_TAG:
            [colorButton setImage:[UIImage imageNamed:@"green-splash.png"] forState:UIControlStateNormal];
            break;
            
        case BLUE_BUTTON_TAG:
            [colorButton setImage:[UIImage imageNamed:@"skyblue-splash.png"] forState:UIControlStateNormal];
            break;
            
        case PURPLE_BUTTON_TAG:
            [colorButton setImage:[UIImage imageNamed:@"purple-splash.png"] forState:UIControlStateNormal];
            break;
            
        case ORANGE_BUTTON_TAG:
            [colorButton setImage:[UIImage imageNamed:@"orange-splash.png"] forState:UIControlStateNormal];
            break;
            
        case ERASER_BUTTON_TAG:
            [colorButton setImage:[UIImage imageNamed:@"eraser.png"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    [self addSubview:colorButton];
    return colorButton;
}

- (void)addPaintColorButtons {
    CGFloat buttonWidth = (self.frame.size.width - 40)/3;
    
    redColorButton = [self createPaintColorButtonForColor:RED_BUTTON_TAG AndFrame:CGRectMake(10, 10, buttonWidth, buttonWidth)];
    yellowColorButton = [self createPaintColorButtonForColor:YELLOW_BUTTON_TAG AndFrame:CGRectMake(10 + buttonWidth + 10, 10, buttonWidth, buttonWidth)];
    greenColorButton = [self createPaintColorButtonForColor:GREEN_BUTTON_TAG AndFrame:CGRectMake(10 + buttonWidth + 10 + buttonWidth + 10, 10, buttonWidth, buttonWidth)];
    blueColorButton = [self createPaintColorButtonForColor:BLUE_BUTTON_TAG AndFrame:CGRectMake(10, 10 + buttonWidth, buttonWidth, buttonWidth)];
    purpleColorButton = [self createPaintColorButtonForColor:PURPLE_BUTTON_TAG AndFrame:CGRectMake(10 + buttonWidth + 10, 10 + buttonWidth, buttonWidth, buttonWidth)];
    orangeColorButton = [self createPaintColorButtonForColor:ORANGE_BUTTON_TAG AndFrame:CGRectMake(10 + buttonWidth + 10 + buttonWidth + 10, 10 + buttonWidth, buttonWidth, buttonWidth)];
    eraserButton = [self createPaintColorButtonForColor:ERASER_BUTTON_TAG AndFrame:CGRectMake(10 + buttonWidth + 10 + 10, 10 + 2*buttonWidth, buttonWidth - 20, buttonWidth - 20)];
}

- (UISlider *)createSliderForOption:(int)optionTag andFrame:(CGRect)frame {
    UIView *sliderView = [[UIView alloc] initWithFrame:frame];
    
    UISlider *optionSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 25, frame.size.width, 50)];
    optionSlider.minimumValue = 0.0f;
    optionSlider.maximumValue = 1.0f;
    optionSlider.tag = optionTag;
    [optionSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [optionSlider setContinuous:NO];
    [sliderView addSubview:optionSlider];
    
    UIImageView *minimumValueImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    UIImageView *maximumValueImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 25, 0, 25, 25)];
    switch (optionTag) {
        case BRUSH_TAG:{
            [minimumValueImageView setImage:[UIImage imageNamed:@"brush-small.png"]];
            [maximumValueImageView setImage:[UIImage imageNamed:@"brush-large.png"]];
        }
            break;
            
        case ERASER_TAG: {
            [minimumValueImageView setImage:[UIImage imageNamed:@"eraser.png"]];
            [maximumValueImageView setImage:[UIImage imageNamed:@"eraser.png"]];
        }
            break;
            
        default:
            break;
    }
    [sliderView addSubview:minimumValueImageView];
    [sliderView addSubview:maximumValueImageView];
    
    [self addSubview:sliderView];
    
    return optionSlider;
}

- (void)addSliders {
    CGFloat buttonHeight = (self.frame.size.width - 40)/3;
    CGFloat sliderWidth = self.frame.size.width - 20;
    brushSlider = [self createSliderForOption:BRUSH_TAG andFrame:CGRectMake(10, 10 + 3*buttonHeight - 20, sliderWidth, 75)];
    eraserSlider = [self createSliderForOption:ERASER_TAG andFrame:CGRectMake(10, 10 + 3*buttonHeight - 20 + 75, sliderWidth, 75)];
}

- (void)createAssetsButton {
    CGFloat buttonHeight = (self.frame.size.width - 40)/3;

    assetsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [assetsButton setFrame:CGRectMake(10, 10 + 3*buttonHeight - 20 + 75 + 75 + 10, self.frame.size.width - 20, 45)];
    [assetsButton setBackgroundImage:[UIImage imageNamed:@"asset_icon.png"] forState:UIControlStateNormal];
    [assetsButton setTitle:@"Assets" forState:UIControlStateNormal];
    [assetsButton addTarget:self action:@selector(assetsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:assetsButton];
}

@end
