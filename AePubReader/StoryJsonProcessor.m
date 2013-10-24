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

@implementation StoryJsonProcessor

+ (NSDictionary *)pageViewForJsonString:(NSDictionary *)jsonDict {
    BOOL isTextDone = NO;
    BOOL isImageDone = NO;
    BOOL isAudioDone = NO;
    
    NSMutableString *textOnPage = [[NSMutableString alloc] initWithString:@""];
    NSMutableData *audioDataForPage = [[NSMutableData alloc] init];
    StoryPageView *currentPageView = [[StoryPageView alloc] init];
    PageInfo *currentPageInfo = [[PageInfo alloc] init];
    currentPageInfo.pageNumber = [NSNumber numberWithInt:[jsonDict objectForKey:@"pageNumber"]];
    
    for (NSDictionary *layerDict in [jsonDict objectForKey:@"layers"]) {
        if (isTextDone && isImageDone && isAudioDone) {
            break;
        }
        
        if ([[layerDict objectForKey:@"type"] isEqualToString:@"text"]) {
            [textOnPage appendString:[layerDict objectForKey:@"text"]];
            
            [currentPageView.pageTextView setText:textOnPage];
            CGSize textSize = [textOnPage sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:CGSizeMake(700, 300)];
            [currentPageView.pageTextView setFrame:CGRectMake([[layerDict objectForKey:@"textPositionX"] floatValue], [[layerDict objectForKey:@"textPositionY"] floatValue], textSize.width, textSize.height)];
            
            currentPageInfo.pageText = textOnPage;
            
            isTextDone = YES;
        } else if ([[layerDict objectForKey:@"type"] isEqualToString:@"image"]) {
            [[[AsyncDataDownloader alloc] initWithMediaURL:[layerDict objectForKey:@"url"] successBlock:^(UIImage *image) {
                [currentPageView.backgroundImageView setImage:image];
                
                currentPageInfo.backgroundImage = image;
            } failBlock:^(NSError *error) {
                NSLog(@"Failed with error: %@", error);
            }] startDownload];
            isImageDone = YES;
        } else if ([[layerDict objectForKey:@"type"] isEqualToString:@"audio"]) {
            [[[AsyncDataDownloader alloc] initWithFileURL:[layerDict objectForKey:@"url"] successBlock:^(NSData *audioData) {
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
