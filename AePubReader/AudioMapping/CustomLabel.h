//
//  CustomLabel.h
//  Hi
//
//  Created by Nikhil Dhavale on 21/10/13.
//  Copyright (c) 2013 Nikhil Dhavale. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CustomLabelDelegate <NSObject>
-(void)sampleAudio;


@end
@interface CustomLabel : UILabel
@property(assign,nonatomic)  CGPoint touchStart;
@property(assign,nonatomic)   BOOL isResizing;
@property(assign,nonatomic) UIScrollView *scrollView;
@property(assign,nonatomic) NSMutableArray *arrayOfViews;
@property(assign,nonatomic) NSInteger index;
@property(assign,nonatomic) NSMutableArray *cues;
@property(assign,nonatomic) float xmin;
@property(assign,nonatomic) float xmax;
@property(assign,nonatomic) id<CustomLabelDelegate> delegate;
@property(assign,nonatomic) CGPoint point;
@end

