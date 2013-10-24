//
//  Constants.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 22/10/13.
//
//

#import <Foundation/Foundation.h>

@protocol Constants <NSObject>

#pragma mark - Analytics Events and Parameters

#define EVENT_LOGIN_FACEBOOK @"loggedInWithFacebook"
#define EVENT_LOGIN_EMAIL @"loggedInWithEmail"
#define EVENT_SKIP_LOGIN @"skippedLogin"
#define EVENT_REDIRECT_TO_SIGNUP @"redirectedTosignup"
#define EVENT_VIDEO @"playedVideo"

#define EVENT_TIME_ON_VIEW @"timeSpentOnView"

#define EVENT_BOOK_TAPPED @"tappedOnBook"

#define PARAMETER_TIME_RANGE @"timeRange"
#define PARAMETER_VIEW_NAME @"viewName"
#define PARAMETER_BOOK_ID @"bookId"
#define PARAMETER_BOOK_TITLE @"bookTitle"

#define TIME_RANGE_10_SEC @"<10 Seconds"
#define TIME_RANGE_10TO20_SEC @"10To20 Seconds"
#define TIME_RANGE_20TO40_SEC @"20To40 Seconds"
#define TIME_RANGE_40TO60_SEC @"40To60 Seconds"
#define TIME_RANGE_1TO2_MIN @"1To2 Minutes"
#define TIME_RANGE_2TO5_MIN @"2To5 Minutes"
#define TIME_RANGE_5TO10_MIN @"5To10 Minutes"
#define TIME_RANGE_10TO20_MIN @"10To20 Minutes"
#define TIME_RANGE_20TO30_MIN @"20To30 Minutes"
#define TIME_RANGE_30TO60_MIN @"30To60 Minutes"
#define TIME_RANGE_1_HOUR @">1 hour"

#pragma mark - Views

#define VIEW_LOGIN @"LoginViewController"
#define VIEW_MY_BOOKS_FOR_ANALYTICS @"MyBooks"
#define VIEW_MY_BOOKS @"LibraryViewController"

@end
