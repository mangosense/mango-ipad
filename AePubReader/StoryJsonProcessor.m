//
//  StoryJsonProcessor.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 18/10/13.
//
//

#import "StoryJsonProcessor.h"
#import "AsyncDataDownloader.h"
#import "Constants.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation StoryJsonProcessor

+ (PageInfo *)pageInfoForJsonString:(NSDictionary *)jsonDict {
    PageInfo *pageInfo = [[PageInfo alloc] init];
    

    for (NSDictionary *layerDict in [jsonDict objectForKey:LAYERS]) {
        if ([[layerDict objectForKey:TYPE] isEqualToString:IMAGE]) {
            pageInfo.backgroundImage = [UIImage imageNamed:[layerDict objectForKey:ASSET_URL]];
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:AUDIO]) {
            
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:TEXT]) {
            //NSDictionary *textFrameDict = [layerDict objectForKey:TEXT_FRAME];
            //CGFloat leftRatio = [[textFrameDict objectForKey:LEFT_RATIO] floatValue];
            //CGFloat topRatio = [[textFrameDict objectForKey:TOP_RATIO] floatValue];
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:CAPTURED_IMAGE]) {
            NSURL *asseturl = [layerDict objectForKey:@"url"];
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
            [assetslibrary assetForURL:asseturl resultBlock:^(ALAsset *myasset) {
                ALAssetRepresentation *rep = [myasset defaultRepresentation];
                CGImageRef iref = [rep fullResolutionImage];
                if (iref) {
                    UIImage *image = [UIImage imageWithCGImage:iref];
                    pageInfo.backgroundImage = image;
                }
            } failureBlock:^(NSError *myerror) {
                NSLog(@"Booya, cant get image - %@",[myerror localizedDescription]);
            }];
        }
    }
    
    return pageInfo;
}

@end
