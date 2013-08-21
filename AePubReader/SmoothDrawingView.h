//
//  SmoothDrawingView.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 12/08/13.
//
//

#import <UIKit/UIKit.h>

@protocol DoodleDelegate

- (void)replaceImageAtIndex:(NSInteger)index withImage:(UIImage *)image;

@end

@interface SmoothDrawingView : UIView {
    UIImage *incrementalImage;
    UIImage *tempImage;
}

@property (nonatomic, strong) UIImage *incrementalImage;
@property (nonatomic, assign) NSInteger indexOfThisImage;
@property (nonatomic, assign) id <DoodleDelegate> delegate;
@property (nonatomic, assign) NSInteger selectedColor;
@property (nonatomic, assign) NSInteger selectedBrush;
@property (nonatomic, strong) UIImage *tempImage;

@end
