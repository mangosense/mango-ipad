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

#define EVENT_BOOK_PURCHASE_INITIATED @"initiatedBookPurchase"
#define EVENT_BOOK_PURCHASE_COMPLETED @"completedBookPurchase"
#define EVENT_BOOK_PURCHASE_CANCELLED @"cancelledBookPurchase"

#define EVENT_BOOK_SHARED @"sharedBook"
#define EVENT_BOOK_FORKED @"forkedBook"
#define EVENT_TRANSLATE_INITIATED @"translateBookInitiated"
#define EVENT_AUDIO_PAUSED @"audioPaused"
#define EVENT_AUDIO_PLAYED @"audioPlayed"
#define EVENT_GAME_CENTER_OPENED @"openedGameCenter"
#define EVENT_GAME_WORDSEARCH @"wordsearchPlayed"
#define EVENT_GAME_MEMORY @"memoryPlayed"
#define EVENT_GAME_JIGSAW @"jigsawPlayed"

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
#define VIEW_STORE_FOR_ANALYTICS @"Store"
#define VIEW_STORE @"LiveViewController"

#pragma mark - JSON Response KEYS

#define USER_ID @"userId"
#define AUTH_TOKEN @"auth_token"
#define PAGE_NO @"pageNo"
#define LAYERS @"layers"
#define TYPE @"type"
#define TEXT @"text"
#define TEXT_POSITION_X @"left"
#define TEXT_POSITION_Y @"top"
#define TEXT_SIZE_WIDTH @"width"
#define TEXT_SIZE_HEIGHT @"height"
#define TEXT_FRAME @"style"
#define IMAGE @"image"
#define AUDIO @"audio"
#define CAPTURED_IMAGE @"capturedImage"
#define ASSET_URL @"url"
#define PAGES @"pages"
#define LEFT_RATIO @"left_ratio"
#define TOP_RATIO @"top_ratio"
#define PAGE_NAME @"name"
#define GAME @"game"
#define CUES @"wordTimes"
#define WORDMAP @"wordMap"

#pragma mark - URL's

#define BASE_URL @"http://testapi.mangoreader.com/api/v2"
//api.mangoreader.com
//testapi.mangoreader.com
//192.168.2.28:3001/api/v2
#define ASSET_BASE_URL @"http://test.mangoreader.com"

#pragma mark - API Method Names
//Validate receipt
#define ReceiptValidate_SignedIn @"receipt_validate.json"
#define ReceiptValidate_NotSignedIn @"receipt_validate_without_signed_in.json"

#define LIVE_STORIES @"livestories.json"
#define CATEGORIES @"categories.json"
#define LOGIN @"sign_in"
#define DOWNLOAD_STORY @"/livestories/%@/zipped?email=%@&auth_token=%@"
#define PURCHASED_STORIES @"users/purchased"
#define FEATURED_STORIES @"livestories/featured.json"
#define LIVE_STORIES_SEARCH @"livestories/search"
#define STORY_FILTER_CATEGORY @"livestories/by/category/"
#define STORY_FILTER_AGE_GROUP @"/livestories/by/agegroup/"
#define STORY_FILTER_LANGUAGES @"/livestories/"   // /livestoriers/:id/languages
#define SAVE_STORY @"livestories/%@/fork"
#define NEW_STORY @"stories"

#pragma mark - API Parameter Keys

#define EMAIL @"email"
#define PASSWORD @"password"
#define BOOK_JSON @"json"

#pragma mark - Table Types

#define TABLE_TYPE_AUDIO_RECORDINGS 1
#define TABLE_TYPE_TEXT_TEMPLATES 2
#define TABLE_TYPE_CATEGORIES 3
#define TABLE_TYPE_AGE_GROUPS 4 
#define TABLE_TYPE_LANGUAGE 5
#define TABLE_TYPE_GRADE 6
#define TABLE_TYPE_SEARCH 7

#pragma mark - Colors

//orange: #f04e23  (R:240 G:78 B:35)
#define COLOR_ORANGE [UIColor colorWithRed:240.0/255.0 green:78.0/255.0 blue:35.0/255.0 alpha:1.0f]
//Green: #84c54e  (R:132 G:197 B:78)
#define COLOR_GREEN [UIColor colorWithRed:132.0/255.0 green:197.0/255.0 blue:78.0/255.0 alpha:1.0f]
//Dark Grey: #353535  (R:53 G:53 B:53)
#define COLOR_DARK_GREY [UIColor colorWithRed:53.0/255.0 green:53.0/255.0 blue:53.0/255.0 alpha:1.0f]
//Grey:  #5b5b5c  (R:91 G:91 B:91)
#define COLOR_GREY [UIColor colorWithRed:91.0/255.0 green:91.0/255.0 blue:91.0/255.0 alpha:1.0f]
//Light Grey:  #f2f2f3  (R:242 G:242 B:242)
#define COLOR_LIGHT_GREY [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0f]
//Dark Red: #4d0e00 (R:77 G:14 B:0)
#define COLOR_DARK_RED [UIColor colorWithRed:77.0/255.0 green:14.0/255.0 blue:0.0/255.0 alpha:1.0f]
//Dark Red: #9c351e (R:99 G:25 B:9)
#define COLOR_BROWN [UIColor colorWithRed:99.0/255.0 green:25.0/255.0 blue:9.0/255.0 alpha:0.4f]

#pragma mark - Tags

#define iCarousel_VIEW_TAG 601

#pragma mark - Random Keys

#define PURCHASED_BOOKS 1
#define LIVE_BOOKS 2
#define FEATURED_BOOKS 3

@end
