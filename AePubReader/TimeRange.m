//
//  TimeRange.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 23/10/13.
//
//

#import "TimeRange.h"
#import "Constants.h"

@implementation TimeRange

+ (NSString *)getTimeRangeForTime:(NSTimeInterval)timeOnLoginPage {
    NSString *timeRange;
    if (timeOnLoginPage < 10) {
        timeRange = TIME_RANGE_10_SEC;
    } else if (timeOnLoginPage > 10 && timeOnLoginPage < 20) {
        timeRange = TIME_RANGE_10TO20_SEC;
    } else if (timeOnLoginPage > 20 && timeOnLoginPage < 40) {
        timeRange = TIME_RANGE_20TO40_SEC;
    } else if (timeOnLoginPage > 40 && timeOnLoginPage < 60) {
        timeRange = TIME_RANGE_40TO60_SEC;
    } else if (timeOnLoginPage > 60 && timeOnLoginPage < 120) {
        timeRange = TIME_RANGE_1TO2_MIN;
    } else if (timeOnLoginPage > 120 && timeOnLoginPage < 300) {
        timeRange = TIME_RANGE_2TO5_MIN;
    } else if (timeOnLoginPage > 300 && timeOnLoginPage < 600) {
        timeRange = TIME_RANGE_5TO10_MIN;
    } else if (timeOnLoginPage > 600 && timeOnLoginPage < 1200) {
        timeRange = TIME_RANGE_10TO20_MIN;
    } else if (timeOnLoginPage > 1200 && timeOnLoginPage < 1800) {
        timeRange = TIME_RANGE_20TO30_MIN;
    } else if (timeOnLoginPage > 1800 && timeOnLoginPage < 3600) {
        timeRange = TIME_RANGE_30TO60_MIN;
    } else if (timeOnLoginPage > 3600) {
        timeRange = TIME_RANGE_1_HOUR;
    }
    
    return timeRange;
}

@end
