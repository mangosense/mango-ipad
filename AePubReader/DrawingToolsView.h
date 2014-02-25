//
//  DrawingToolsView.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 02/09/13.
//
//

#import <UIKit/UIKit.h>

@protocol DrawingToolsDelegate

@optional
- (void)widthOfBrush:(CGFloat)brushWidth;
- (void)widthOfEraser:(CGFloat)eraserWidth;
- (void)selectedColor:(int)color;
- (void)showAssets;

@end

@interface DrawingToolsView : UIView {
    CGFloat brushWidth;
    CGFloat eraserWidth;
    int colorTag;
}

@property (nonatomic, assign) CGFloat brushWidth;
@property (nonatomic, assign) CGFloat eraserWidth;
@property (nonatomic, assign) int colorTag;
@property (nonatomic, assign) id <DrawingToolsDelegate> delegate;

@end
