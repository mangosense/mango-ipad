//
//  SearchResult.m
//  AePubReader
//
//  Created by Federico Frappi on 05/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchResult.h"


@implementation SearchResult

@synthesize pageIndex, chapterIndex, neighboringText, hitIndex, originatingQuery;

- (id)initWithChapterIndex:(int)thechapterIndex pageIndex:(int)thePageIndex hitIndex:(int)theHitIndex neighboringText:(NSString *)theNeighboringText originatingQuery:(NSString *)theOriginatingQuery{
    if((self=[super init])){
        chapterIndex=thechapterIndex;
        pageIndex = thePageIndex;
        hitIndex = theHitIndex;
        self.neighboringText = [theNeighboringText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.originatingQuery = theOriginatingQuery;
    }
    return self;
}

/*- (void)dealloc {
    [neighboringText release];
	[originatingQuery release];
    [super dealloc];
}*/

@end
