//
//  PageBackgroundImageView.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 09/08/13.
//
//

#import <UIKit/UIKit.h>

@protocol BackgroundImageDelegate

- (void)replaceImageAtIndex:(NSInteger)index withImage:(UIImage *)image;

@end

@interface PageBackgroundImageView : UIImageView {
    
}

@property (nonatomic, assign) CGPoint location;
@property (nonatomic, assign) NSInteger indexOfThisImage;
@property (nonatomic, assign) id <BackgroundImageDelegate> delegate;
@property (nonatomic, assign) NSInteger selectedColor;
@property (nonatomic, assign) NSInteger selectedBrush;

@end
