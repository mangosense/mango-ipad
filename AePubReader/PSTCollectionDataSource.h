//
//  PSTCollectionDataSource.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 31/07/13.
//
//

#import <Foundation/Foundation.h>
#import "PSTCollectionView.h"
#import "LibraryOldCell.h"
#import <UIKit/UIKit.h>
@class LibraryViewController;

@interface PSTCollectionDataSource : NSObject<PSTCollectionViewDataSource>
@property(nonatomic,strong) NSArray *array;
@property(nonatomic,weak) UIViewController *controller;
@property(nonatomic,assign) NSInteger controllerCount;
@end
