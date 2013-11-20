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
#import <AssetsLibrary/AssetsLibrary.h>

@implementation StoryJsonProcessor

+ (StoryPageView *)pageViewForJsonString:(NSDictionary *)jsonDict {
    StoryPageView *pageView = [[StoryPageView alloc] initWithFrame:CGRectMake(0, 0, 400, 300)];
    
    NSLog(@"%@", jsonDict);
    for (NSDictionary *layerDict in [jsonDict objectForKey:LAYERS]) {
        if ([[layerDict objectForKey:TYPE] isEqualToString:IMAGE]) {
            pageView.backgroundImageView.incrementalImage = [UIImage imageNamed:[layerDict objectForKey:ASSET_URL]];
            pageView.backgroundImageView.tempImage = [UIImage imageNamed:[layerDict objectForKey:ASSET_URL]];
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:AUDIO]) {
            
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:TEXT]) {
            
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:CAPTURED_IMAGE]) {
            NSURL *asseturl = [layerDict objectForKey:@"url"];
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
            [assetslibrary assetForURL:asseturl resultBlock:^(ALAsset *myasset) {
                ALAssetRepresentation *rep = [myasset defaultRepresentation];
                CGImageRef iref = [rep fullResolutionImage];
                if (iref) {
                    UIImage *image = [UIImage imageWithCGImage:iref];
                    pageView.backgroundImageView.incrementalImage = image;
                }
            } failureBlock:^(NSError *myerror) {
                NSLog(@"Booya, cant get image - %@",[myerror localizedDescription]);
            }];
        }
    }
    
    return pageView;
}

@end
