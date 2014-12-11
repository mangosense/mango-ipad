//
//  SearchResultsViewController.h
//  AePubReader
//
//  Created by Federico Frappi on 05/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chapter.h"
#import "SearchResult.h"
@protocol SearchResultsDelegate <NSObject>
@required
-(void)loadSpine:(int)chapter atPageIndex:(int)pageIndex highlightSearchResult:(SearchResult *)hit;
-(void)setSearch:(BOOL)searching;
-(BOOL)getSearch;
@end
@interface SearchResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate> {

    
    int currentChapterIndex;
    NSString* currentQuery;
}

@property (nonatomic, retain) IBOutlet UITableView* resultsTableView;
@property (nonatomic, assign) id<SearchResultsDelegate> epubViewController;
@property (nonatomic, retain) NSMutableArray* results;
@property (nonatomic, retain) NSString* currentQuery;
@property(nonatomic,retain)NSMutableArray *array;
- (void) searchString:(NSString*)query;

@end
