//
//  CustomMappingView.h
//  Hi
//
//  Created by Nikhil Dhavale on 16/10/13.
//  Copyright (c) 2013 Nikhil Dhavale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomMappingView : UIView
@property(strong,nonatomic) NSArray *text;
@property(assign,nonatomic) CGSize space;
@property(assign,nonatomic) float x;
@property(assign,nonatomic) float y;
@property(assign,nonatomic) float width;
@property(assign,nonatomic) float height;
@property (nonatomic, strong) UIFont *textFont;
@end
