//
//  MovableTextView.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 08/08/13.
//
//

#import <UIKit/UIKit.h>

@protocol TextLayerDelegate

- (void)saveFrame:(CGRect)textFrame AndText:(NSString *)layerText ForLayer:(NSString *)layerId;

@end

@interface MovableTextView : UITextView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *layerId;
@property (nonatomic, assign) id <TextLayerDelegate> textDelegate;

@end
