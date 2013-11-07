//
//  StoryJsonProcessor.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 18/10/13.
//
//

#import "StoryJsonProcessor.h"
#import "AsyncDataDownloader.h"
#import "PageInfo.h"
#import "Constants.h"

@implementation StoryJsonProcessor

+ (NSDictionary *)pageViewForJsonString:(NSDictionary *)jsonDict {
    BOOL isTextDone = NO;
    BOOL isImageDone = NO;
    BOOL isAudioDone = NO;
    
    NSMutableString *textOnPage = [[NSMutableString alloc] initWithString:@""];
    NSMutableData *audioDataForPage = [[NSMutableData alloc] init];
    StoryPageView *currentPageView = [[StoryPageView alloc] init];
    PageInfo *currentPageInfo = [[PageInfo alloc] init];
    currentPageInfo.pageNumber = [NSNumber numberWithInt:[jsonDict objectForKey:PAGE_NO]];
    
    for (NSDictionary *layerDict in [jsonDict objectForKey:LAYERS]) {
        if (isTextDone && isImageDone && isAudioDone) {
            break;
        }
        
        if ([[layerDict objectForKey:TYPE] isEqualToString:TEXT]) {
            [textOnPage appendString:[layerDict objectForKey:TEXT]];
            CGRect textFrame = CGRectMake([[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_POSITION_X] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_POSITION_Y] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_WIDTH] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_HEIGHT] floatValue]);
            
            [currentPageView.pageTextView setText:textOnPage];
            [currentPageView.pageTextView setFrame:CGRectMake(textFrame.origin.x, textFrame.origin.y, textFrame.size.width, textFrame.size.height)];
            
            currentPageInfo.pageText = textOnPage;
            
            isTextDone = YES;
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:IMAGE]) {
            [[[AsyncDataDownloader alloc] initWithMediaURL:[layerDict objectForKey:ASSET_URL] successBlock:^(UIImage *image) {
                [currentPageView.backgroundImageView setImage:image];
                
                currentPageInfo.backgroundImage = image;
            } failBlock:^(NSError *error) {
                NSLog(@"Failed with error: %@", error);
            }] startDownload];
            isImageDone = YES;
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:AUDIO]) {
            [[[AsyncDataDownloader alloc] initWithFileURL:[layerDict objectForKey:ASSET_URL] successBlock:^(NSData *audioData) {
                [audioDataForPage appendData:audioData];
                
                currentPageInfo.pageAudioData = audioDataForPage;
            } failBlock:^(NSError *error) {
                NSLog(@"Failed with error: %@", error);
            }] startDownload];
            isAudioDone = YES;
        }
        
    }
    NSMutableDictionary *pageDict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:currentPageView, currentPageInfo, nil] forKeys:[NSArray arrayWithObjects:@"pageView", @"pageInfo", nil]];
    return pageDict;
}

@end
