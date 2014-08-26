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
//#define PARAMETER_BOOK_ID @"bookId"
//#define PARAMETER_BOOK_TITLE @"bookTitle"

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



#pragma mark - New Events

//#define SIGN_IN @{ @"action" : @"login", @"eventDescription" : @"Login button click" }////
#define SIGN_UP_VIEW @{ @"value" : @"SIGN_UP_VIEW", @"description" : @"Sign up view" }
#define LOGIN_FACEBOOK @{ @"value" : @"LOGIN_FACEBOOK", @"description" : @"Sign in via Facebook" }
#define SKIP_SIGN_IN @{ @"value" : @"SKIP_SIGN_IN", @"description" : @"Skip Sign in" }
#define SIGN_UP_USER @{ @"value" : @"SIGN_UP_USER", @"description" : @"Sign up" }
#define HOME_CREATE_STORY @{ @"value" : @"HOME_CREATE_STORY", @"description" : @"Create a story" }
#define HOME_STORE_VIEW @{ @"value" : @"HOME_STORE_VIEW", @"description" : @"Go to Store" }
#define HOME_MY_STORIES @{ @"value" : @"HOME_MY_STORIES", @"description" : @"Go to my Stories" }
#define STORE_FILTER @{ @"value" : @"STORE_FILTER", @"description" : @"Filter store books" }
#define STORE_SEARCH @{ @"value" : @"STORE_SEARCH", @"description" : @"Search in store" }
#define STORE_FEATURED_BOOK @{ @"value" : @"STORE_FEATURED_BOOK", @"description" : @"Store featured book" }
#define STORE_AGE_STORE_BOOK @{ @"value" : @"STORE_AGE_STORE_BOOK", @"description" : @"Age group book select in store" }
#define BOOK_DETAIL_BUY_BOOK @{ @"value" : @"BOOK_DETAIL_BUY_BOOK", @"description" : @"Book buy now" }
#define BOOK_DETAIL_AVAILABLE_LANGUAGE @{ @"value" : @"BOOK_DETAIL_AVAILABLE_LANGUAGE", @"description" : @"Book Available Language" }
#define BOOK_DETAIL_NEW_LANGUAGE @{ @"value" : @"BOOK_DETAIL_NEW_LANGUAGE", @"description" : @"Select book in new language"}
#define MYSTORIES_CATEGORY_SELECT @{ @"value" : @"MYSTORIES_CATEGORY_SELECT", @"description" : @"Book category selection" }
#define MySTORIES_SETTINGS_QUES @{ @"value" : @"MySTORIES_SETTINGS_QUES", @"description" : @"My stories setting ques" }
#define MYSTORIES_SETTINGS @{ @"value" : @"MYSTORIES_SETTINGS", @"description" : @"My stories settings" }
#define SETTINGS_VALUE @{ @"value" : @"SETTINGS_VALUE", @"description" : @"Settings category selected" }
#define DETAIL_CATEGORY_DELETE_BOOK @{ @"value" : @"DETAIL_CATEGORY_DELETE_BOOK", @"description" : @"Detail category delete book" }
#define DETAIL_CATEGORY_SETTINGS @{ @"value" : @"DETAIL_CATEGORY_SETTINGS", @"description" : @"Detail Settings" }
#define DETAIL_CATEGORY_SETTING_QUES @{ @"value" : @"DETAIL_CATEGORY_SETTINGS", @"description" : @"Detail Setting ques" }
#define DETAIL_CATEGORY_GET_MORE_BOOKS @{ @"value" : @"DETAIL_CATEGORY_GET_MORE_BOOKS", @"description" : @"Detail get more books" }
#define DETAIL_CATEGORY_BOOK_SELECT @{ @"value" : @"DETAIL_CATEGORY_BOOK_SELECT", @"description" : @"Detail book selection" }
#define BOOKCOVER_SELECTION @{ @"value" : @"BOOKCOVER_SELECTION", @"description" : @"Book cover image selection" }
#define BOOKCOVER_AVAILABLE_LANGUAGE @{ @"value" : @"BOOKCOVER_AVAILABLE_LANGUAGE", @"description" : @"Cover available language" }
#define BOOKCOVER_NEW_LANGUAGE @{ @"value" : @"BOOKCOVER_NEW_LANGUAGE", @"description" : @"Cover new language" }
#define BOOKCOVER_READ_TO_ME @{ @"value" : @"BOOKCOVER_READ_TO_ME", @"description" : @"Read to me" }
#define BOOKCOVER_READ_BY_MYSELF @{ @"value" : @"BOOKCOVER_READ_BY_MYSELF", @"description" : @"Read by myself" }
#define BOOKCOVER_PLAY_GAMES @{ @"value" : @"BOOKCOVER_PLAY_GAMES", @"description" : @"Cover view play games" }
#define BOOKCOVER_SHARE @{ @"value" : @"BOOKCOVER_SHARE", @"description" : @"Cover share book" }
#define READBOOK_OPTIONS @{ @"value" : @"READBOOK_OPTIONS", @"description" : @"Readbook options" }
#define READBOOK_MYSELF_PLAY_PAUSE @{ @"value" : @"READBOOK_MYSELF_PLAY_PAUSE", @"description" : @"Readbook myself play/pause" }
#define READBOOK_READTOME_AUDIO_PLAYING @{ @"value" : @"READBOOK_READTOME_ISAUDIO_PLAYING", @"description" : @"Readbook to me isAudio playing" }
#define READBOOK_PLAYGAMES @{ @"value" : @"READBOOK_PLAYGAMES", @"description" : @"Readbook play games" }
#define READBOOK_CHANGE_LANGUAGE @{ @"value" : @"READBOOK_CHANGE_LANGUAGE", @"description" : @"Readbook change laguage" }
#define READBOOK_NEW_VERSION @{ @"value" : @"READBOOK_NEW_VERSION", @"description" : @"Book create new version" }
#define READBOOK_CLOSE @{ @"value" : @"READBOOK_CLOSE", @"description" : @"Readbook close options" }
#define READBOOK_SHARE @{ @"value" : @"READBOOK_SHARE", @"description" : @"Readbook share" }
#define READBOOK_BOOK_COMPLETE @{ @"value" : @"READBOOK_BOOK_COMPLETE", @"description" : @"Readbook book complete" }
#define LASTPAGE_READ_AGAIN @{ @"value" : @"LASTPAGE_READ_AGAIN", @"description" : @"Lastpage read again" }
#define LASTPAGE_SHARE @{ @"value" : @"LASTPAGE_SHARE", @"description" : @"Lastpage share" }
#define LASTPAGE_PLAYGAMES @{ @"value" : @"LASTPAGE_PLAYGAMES", @"description" : @"Lastpage play games" }
#define LASTPAGE_RECOMMENDED_BOOK @{ @"value" : @"LASTPAGE_RECOMMENDED_BOOK", @"description" : @"Lastpage recommend book" }

#define CREATESTORY_NEWBOOK @{ @"value" : @"CREATESTORY_NEWBOOK", @"description" : @"Create story book" }
#define CREATESTORY_SELECT_BOOK @{ @"value" : @"CREATESTORY_SELECT_BOOK", @"description" : @"Createstory select book" }
#define CREATESTORY_DELETE_BOOK @{ @"value" : @"CREATESTORY_DELETE_BOOK", @"description" : @"Createstory delete book" }
#define CREATESTORY_SETTINGS @{ @"value" : @"CREATESTORY_SETTINGS", @"description" : @"Createstory Settings" }
#define CREATESTORY_SETTING_QUES @{ @"value" : @"CREATESTORY_SETTINGS", @"description" : @"Createstory Setting ques" }
#define EDITOR_ADD_TEXT @{ @"value" : @"EDITOR_ADD_TEXT", @"description" : @"Editor add text" }
#define EDITOR_ADD_IMAGE @{ @"value" : @"EDITOR_ADD_IMAGE", @"description" : @"Editor add image" }
#define EDITOR_ADD_CAMERA_IMAGE @{ @"value" : @"EDITOR_ADD_CAMERA_IMAGE", @"description" : @"Editor add camera image" }
#define EDITOR_ADD_LIBRARY_IMAGE @{ @"value" : @"EDITOR_ADD_LIBRARY_IMAGE", @"description" : @"Editor add library image" }

#define EDITOR_RECORD_PLAY @{ @"value" : @"EDITOR_RECORD_PLAY", @"description" : @"Editor record Play" }

#define EDITOR_ADD_NEW_PAGE @{ @"value" : @"EDITOR_ADD_NEW_PAGE", @"description" : @"Editor add new page" }

#define EDITOR_DELETE_PAGE @{ @"value" : @"EDITOR_DELETE_PAGE", @"description" : @"Editor delete page" }

#define EDITOR_CLOSE @{ @"value" : @"EDITOR_CLOSE", @"description" : @"Editor close book" }
#define EDITOR_NEW_BOOK @{ @"value" : @"EDITOR_NEW_BOOK", @"description" : @"Editor create new book" }
#define EDITOR_MANGO_TAP @{ @"value" : @"EDITOR_MANGO_TAP", @"description" : @"Editor mango tap" }
#define EDITOR_DOODLE_TAP @{ @"value" : @"EDITOR_DOODLE_TAP", @"description" : @"Editor doodle" }
#define GAMES @{ @"value" : @"GAMES", @"description" : @"Games" }

#define PARAMETER_ACTION @"action"////
#define PARAMETER_CURRENT_PAGE @"currentPage"////
#define PARAMETER_EVENT_DESCRIPTION @"eventDescription"////
#define PARAMETER_APP_NAME @"storyasAppName"////
#define PARAMETER_USER_EMAIL_ID @"emailID"////
#define PARAMETER_DEVICE_LANGUAGE @"language"////
#define PARAMETER_DEVICE_COUNTRY @"country"////
#define PARAMETER_UUID @"sessionId"////
#define PARAMETER_DEVICE_UDID @"deviceUDID"////
#define PARAMETER_PASS @"result" ////
#define PARAMETER_RESPONSE_ERROR @"reason"////
#define PARAMETER_SEARCH_FILTER @"filterBy" ////
#define PARAMETER_SEARCH_GROUP @"storeFilter" ////
#define PARAMETER_BOOK_STATUS @"status"////
#define PARAMETER_TIME_TAKEN @"timeTaken"////
#define PARAMETER_PAGES_VISITED @"pagesVisited"////
#define PARAMETER_SIGNUP_EMAIL @"Signup email"
#define PARAMETER_DEVICE @"User device"
#define PARAMETER_FACEBOOK_ID @"Facebook id"
#define PARAMETER_UID @"User id or device udid"
#define PARAMETER_GROUP @"filter group"
#define PARAMETER_SEARCH_KEYWORD @"query"////
#define PARAMETER_BOOK_ID @"bookId"////
#define PARAMETER_BOOK_TITLE @"title"////
#define PARAMETER_BOOK_AGE_GROUP @"Book agegroup"
#define PARAMETER_BOOK_LANGUAGE @"currectLanguage"////
#define PARAMETER_BOOK_NEW_LANGUAGE_SELECT @"new_language"////
#define PARAMETER_NEWLANG_BOOK_ID @"new_book"////
#define PARAMETER_BOOKDETAIL_SOURCE @"source"////
#define PARAMETER_BOOK_CATEGORY_VALUE @"category"////
#define PARAMETER_SUBSCRIPTION_PLAN_ID @"plan_id"////
#define PARAMETER_SUBSCRIPTION_PLAN_NAME @"plan_name"////
#define PARAMETER_SUBSCRIPTION_PLAN_PRICE @"plan_price"////
#define PARAMETER_BOOK_READ_MODE @"mode"////
#define PARAMETER_PAGE_COUNT @"pageCount"////
#define PARAMETER_SETTINGS_QUES_SOL @"Bool solution"
#define PARAMETER_SETTINGS_VALUE @"Setting value"
#define PARAMETER_BOOK_PAGE_NO @"Book page no"
#define PARAMETER_BOOK_TIME_SPEND @"Book time spend"
#define PARAMETER_BOOL_ISPLAYING @"Bool isplaying"
#define PARAMETER_BOOL_ISNEW_VERSION @"Bool new version"
#define PARAMETER_RECOMMEND_BOOKID @"Recommend bookid"
#define PARAMETER_GAME_NAME @"gameId"////


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
#define NAME @"name"
#define USERNAME @"username"
#define NUMBER_OF_GAMES @"widget_count"
#define ALIGNMENT @"alignment"
#define LEFT_ALIGN @"left"
#define RIGHT_ALIGN @"right"
#define TOP_ALIGN @"top"
#define BOTTOM_ALIGN @"bottom"
#define IMAGE_ALIGNMENT @"image_alignment"

#pragma mark - URL's

#define BASE_URL @"http://api.mangoreader.com/api/v2"
//#define BASE_URL @"http://192.168.0.126:3999/api/v2"
//#define BASE_URL @"http://testapi.mangoreader.com/api/v2"
//api.mangoreader.com
//testapi.mangoreader.com
//192.168.2.28:3001/api/v2
#define ASSET_BASE_URL @"http://www.mangoreader.com"

#pragma mark - API Method Names
//Validate receipt
#define ReceiptValidate_SignedIn @"receipt_validate.json"

//// New subscription API
#define SubscriptionPlans @"subscriptions/plans"
#define SubscriptionValidate @"subscriptions/validate/receipt.json" //done
#define SubscriptionStatus @"subscriptions/validate/status" //either user id else transction id
#define StoryOfTheDay @"campaign/today"
////

#define ReceiptValidate_NotSignedIn @"receipt_validate_without_signed_in.json"

#define LIVE_STORIES @"livestories.json"
#define CATEGORIES @"categories.json"
#define AGE_GROUPS @"age_groups.json"
#define LANGUAGES @"available_languages.json"
#define GRADES @"grades.json"
#define LOGIN @"sign_in"
#define SIGN_UP @"sign_up"
#define DOWNLOAD_STORY_LOGGED_IN @"/livestories/%@/zipped?email=%@&auth_token=%@&platform=%@&ismobile=%@"
#define DOWNLOAD_STORY_LOGGED_OUT @"/livestories/%@/zipped?transaction_id=%@&mode=%@&platform=%@&ismobile=%@"
#define PURCHASED_STORIES @"users/purchased"
#define FEATURED_STORIES @"livestories/featured.json"
#define LIVE_STORIES_SEARCH @"livestories/search"
#define STORY_FILTER_CATEGORY @"livestories/by/category/"
#define STORY_FILTER_AGE_GROUP @"livestories/by/agegroup/"    
#define STORY_FILTER_ALL_AGE_GROUPS @"livestories/by/all_agegroup"
#define STORY_FILTER_LANGUAGES @"livestories/by/language/"
#define STORY_FILTER_GRADE @"livestories/by/grade/"
#define SAVE_STORY @"livestories/%@/"
#define NEW_STORY @"stories"
#define FACEBOOK_LOGIN @"facebookapplogin.json"
#define LIVE_STORIES_STORE @"live_stories.json"
#define FREE_STORIES @"livestories/free_stories.json"
#define LANGUAGES_FOR_BOOK @"livestories/available_languages"
#define RECOMMENDED_STORIES @"livestories/recommended"
#define LIVE_STORIES_WITH_ID @"livestories"
#define OLD_STORY_INFO @"livestories/%@/info"
#define VERSION @"version"
#define VERSION_NO @"2.0"
#define LINKSUBSCRIPTIONWITHEMAIL @"subscription/connect"

#pragma mark - API Parameter Keys

#define EMAIL @"email"
#define PASSWORD @"password"
#define BOOK_JSON @"json"
#define PAGE_NUMBER @"page"
#define LIMIT @"limit"
#define PLATFORM @"platform"
#define IOS @"ios"
#define ISMOBILE @"is_mobile"
#define FACEBOOK_TOKEN_EXPIRATION_DATE @"expirationDate"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define ISMOBILEVALUE ((IS_IPAD) ? @"false" : @"true")

#pragma mark - Table Types

#define TABLE_TYPE_AUDIO_RECORDINGS 1
#define TABLE_TYPE_TEXT_TEMPLATES 2
#define TABLE_TYPE_CATEGORIES 3
#define TABLE_TYPE_AGE_GROUPS 4 
#define TABLE_TYPE_LANGUAGE 5
#define TABLE_TYPE_GRADE 6
#define TABLE_TYPE_SEARCH 7
#define TABLE_TYPE_MAIN_STORE 8

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
//Color from HEX
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

#pragma mark - Tags
#pragma mark - MangoStoreView Controller

#define iCarousel_VIEW_TAG 601

#define SEGMENT_WIDTH 600
#define SEGMENT_HEIGHT 60
#define FILTER_BUTTON_WIDTH 130
#define CATEGORY_TAG 1
#define AGE_TAG 2
#define LANGUAGE_TAG 3
#define GRADE_TAG 4

#define STORE_BOOK_CELL_ID @"StoreBookCell"
#define STORE_BOOK_CAROUSEL_CELL_ID @"StoreBookCarouselCell"
#define HEADER_ID @"headerId"
#define BOOK_CELL_ID @"BookCell"

#pragma mark - My Stories

#define MY_STORIES_BOOK_CELL @"MyStoriesBookCell"

#pragma mark - Random Keys

#define PURCHASED_BOOKS 1
#define LIVE_BOOKS 2
#define FEATURED_BOOKS 3
#define ALL_BOOKS_CATEGORY @"All Books"

@end
