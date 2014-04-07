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
#import "BookDetailsViewController.h"

@interface LanguageChoiceViewController : UITableViewController <MangoPostApiProtocol, BookViewProtocol>{
    
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;
    NSString *newLanguage;
}

@property (retain,nonatomic) NSArray *array;
@property (assign,nonatomic) id<DismissPopOver> delegate;
@property (nonatomic, strong) NSString *bookId;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSDictionary *bookDict;
@property (nonatomic, strong) NSMutableArray *bookIDArray;
@property (nonatomic, assign) int isReadPage;

@end
