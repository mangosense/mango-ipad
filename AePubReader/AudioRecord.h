//
//  AudioRecord.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 13/11/13.
//
//

#import <Foundation/Foundation.h>

@interface AudioRecord : NSObject {
    NSString *audioName;
    NSData *audioData;
}

@property (nonatomic, strong) NSString *audioName;
@property (nonatomic, strong) NSData *audioData;

@end
