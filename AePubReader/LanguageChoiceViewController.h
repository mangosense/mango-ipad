//
//  LanguageChoiceViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/13.
//
//

#import <UIKit/UIKit.h>
#import "DismissPopOver.h"
@interface LanguageChoiceViewController : UITableViewController
@property(retain,nonatomic) NSArray *array;
@property(assign,nonatomic) id<DismissPopOver> delegate;
@end
