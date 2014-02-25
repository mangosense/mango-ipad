//
//  LanguageChoiceViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/13.
//
//

#import <UIKit/UIKit.h>
#import "DismissPopOver.h"
#import "MangoApiController.h"

@interface LanguageChoiceViewController : UITableViewController <MangoPostApiProtocol>

@property (retain,nonatomic) NSArray *array;
@property (assign,nonatomic) id<DismissPopOver> delegate;
@property (nonatomic, strong) NSString *bookId;
@property (nonatomic, strong) NSDictionary *bookDict;

@end
