//
//  StoryJsonProcessor.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 18/10/13.
//
//

#import <Foundation/Foundation.h>
#import "StoryPageView.h"
#import "PageInfo.h"

@interface StoryJsonProcessor : NSObject {
    
}

+ (PageInfo *)pageInfoForJsonString:(NSDictionary *)jsonDict;

@end