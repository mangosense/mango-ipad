//
//  Fingerprint.h
//  FingerprintClientSDK
//
//  Copyright 2011-2012 Fingerprint Digital, Inc. All rights reserved.
//

// NOTE: This is the Objective-C version of the API
// The C++ one currently has full documentation and is fundamentally the same
//
// DO NOT MIX'N'MATCH - you must you either the Objective-C API or C++ API, BUT NOT BOTH

/*! \mainpage
 
 <h2>Welcome to the iOS Fingerprint SDK Objective-C API</h2>
 
 */

//----------------------------------------------------------------------------------------------------
#define GAMEOVER_PLAYER1_WON    @"PLAYER"
#define GAMEOVER_PLAYER2_WON    @"OPPONENT"
#define GAMEOVER_TIE            @"NONE"

//----------------------------------------------------------------------------------------------------
@protocol FingerprintDelegate
/**
 after a call to FingerprintAPI::login, onLoginComplete is called when the SDK completes all necessary registration
 and login steps for establishing context for account and active child so that the game code can know it's time to continue.
 
 Each time the onLoginComplete callback is received, the game should reload the user data using the Fingerprint::loadData() call:\n
 +(NSDictionary*)loadData:(NSString*)dataID;
 */
-(void)onLoginComplete;

/**
 When Fingerprint UI layer has appeared. When this happens, silence your game's audio, and then resume in it onUIComplete
 */
-(void)onUIOpen;

/**
 When Fingerprint UI layer has closed.
 
 In your onUIComplete handler, please call Fingerprint::avatarDescription to obtain the current language and see if it has changed.
 
 @param mode empty string in most cases. If the value of mode is "menu", the game should return to its main menu screen (from the optional platform single player game pause dialog).
  */
-(void)onUIComplete:(NSString*)mode;

/** 
 after a call to upload, onUploadComplete is called when an upload has completed
 
 @param uploadID the id that was returned by the call to Fingerprint::upload
 @param bSuccess indicates whether or not the upload was successful
 @param url the URL where the data can now be found on the Internet
 */
-(void)onUploadComplete:(int)uploadID success:(BOOL)bSuccess url:(NSString*)url;

/**
 called when a data state conflict arises
 
 When calling loadData, it's possible for a conflict to arisen if another iOS device uploaded
 state to the Fingerprint server while the current iOS had cached state from an offline play session
 that had not been uploaded yet.
 
 @param dataID the data identifier is being loaded - same as the dataID that was passed to loadData
 @param server the data that was uploaded to the server by another device
 @param client the data that is cached locally on this device that was not uploaded yet
 
 return the reconciled result, or just return server to use the newest data as it is.
 */
-(NSDictionary*)onResolve:(NSString*)dataID server:(NSDictionary*)server client:(NSDictionary*)client;

/** 
 After an allow/deny email response is received, this is called
 
 @param data about the response
*/
-(void)onSendMessageResponse:(NSDictionary*)data;


/**
 Turn-based game update. Called whenever the game state changes and the game should re-render all relevant state.
 
 onGameUpdate is called when a move happens, or when the user switches to entirely different game instance (via the game list).
 
 @param game dictionary containing the game history. Contains the following keys:\n
 bMyTurn: whether it is this player's turn to play\n
 bPlayer2: whether this player is "player 2" (that is, this player did not go first)\n
 bPracticeRound: true if this is a practice round, false if not. If true, dictionary also includes playerAvatars and playerNames.\n
 turn: either "PLAYER" or "OPPONENT"\n
 id: id for this game instance, e.g. "eeb294ea-5aa4-48cc-9647-15eef38d3dd5"\n
 moves: NSArray containing all the NSDictionaries that were sent as moves (see FingerprintAPI::sendMove) in sequence, alternating between Player 1 and Player 2\n
 playerAvatars: the avatars in use by the players. If this is a random game with no opponent yet, the second value is an empty string. If this is a practice round, the second value is an empty string.\n
 playerNames: the names of the players. If this is a random game with no opponent yet, the second value is "Unknown Opponent." If this is a practice round, the second value is an empty string.\n
 started: time the game started in milliseconds since January 1, 1970, 00:00:00 GMT\n
 status: current status message to display (e.g. "Please wait your turn" or "You won!")\n
 time: time of the last move in milliseconds since January 1, 1970, 00:00:00 GMT\n
 winner: the winner of the game. Optional values are "PLAYER", "OPPONENT", "TIE", or "" if the game is not complete.\n
 
 */
-(void)onGameUpdate:(NSDictionary*)game;


/**
 Hint to the game that the SDK is doing the CPU-intensive operation of loading its web views.
 In high frame-rate OpenGL games, it's a good idea to lower the frame rate (or even pause the animation)
 between a call to loading YES and loading NO. This can significantly speed the loading on low-end
 devices (e.g. on an iPad 1 could be the difference between 14 seconds and 2 seconds).
 Note that this can happen at startup AND after an update, so be prepared that it could happen more
 than 1 time.

 @param bLoading YES if loading starting, NO if loading completed.
 */
-(void)onLoading:(BOOL)bLoading;


/**
 Response from the parent gate
 
 @param bIsParent TRUE if proven to be parent
 @param details for future expansion
 */
-(void)onParentGate:(BOOL)bIsParent details:(NSDictionary*)details;

@end

//----------------------------------------------------------------------------------------------------
@interface Fingerprint : NSObject {
}

/**
 Call when your App is launched and ready to start
 If you have a splash screen sequence, call this BEFORE that starts, so that the SDK can start communicating 
 with the Fingerprint server and be ready to go faster when it's time to Login.
 
 call from
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
 
 This does not trigger any User Interface.
 
 @param launchOptions the launchOptions passed to didFinishLaunchingWithOptions by iOS
 @param fpOptions specifies the Fingerprint options settings for your app. Options include the following:\n\n
 Name: "bMultiplayer"\n
 Possible Values: YES or NO\n
 Description: If the app is a multiplayer game, you must set "bMultiplayer" to YES in fpOptions. If "bMultiplayer" is not provided or is NO, the Fingerprint platform treats the app as a single player game.\n\n
 Name: "bLandscape"\n
 Possible Values: YES or NO\n
 Description: If the app is a landscape game, you must set "bLandscape" to YES in fpOptions. If "bLandscape" is not provided or is NO, the app is treated as a portrait game.\n\n
 Name: "bPracticeRound"\n
 Possible Values: YES or NO\n
 Description: If the app supports a practice round, set to YES. If "bPracticeRound" is not provided or is NO, the platform will not allow a practice round.\n\n
 Name: "bSuppressPauseScreen"\n
 Possible Values: YES or NO\n
 Description: When the user suspends and resumes the app, bSuppressPauseScreen controls whether the user is returned to the game or the Fingerprint platform's
 pause screen upon resume. If "bSuppressPauseScreen" is YES, the user will be taken to the game (which may provide its own pause screen). If "bSuppressPauseScreen"
 is not provided or is NO, the Fingerprint platform will present its own pause screen.\n\n
 @param delegate The delegate is a pointer to an object that implements the FingerprintDelegate for your game. This delegate will receive callbacks such as onUIOpen, onUIComplete, and others so that your game can respond appropriately to these SDK events.
 
 returns TRUE if game has been launched via the hub (game switching) or returning from Facebook connect - in this case, please suppress splash screens
 */
+(BOOL)startup:(NSDictionary*)launchOptions fpOptions:(NSDictionary*)fpOptions fpDelegate:(id)delegate;

/**
 Call when iOS asks your app to open a URL
 
 call from
 - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

 returns TRUE if the URL is handled as part of game switching or Facebook Connect.
 */
+(BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

/**
 This will handle (including the visual presentation) any necessary Fingerprint platform Login and Registration. 
 Call after your splash/start-up sequence - usually just before you are ready to present your main menu.
 
 onLoginComplete will get called when everything is ready to go
 */
+(void)login;

/**
 Call when your App received applicationDidEnterBackground 
 
 call from
 - (void)applicationDidEnterBackground:(UIApplication *)application
 
 This does not trigger any User Interface.
 
 */
+(void)suspend;

/**
 Call when your App received applicationDidBecomeActive
 
 call from
 - (void)applicationDidBecomeActive:(UIApplication *)application
 
 This does not trigger any User Interface.
 
 */
+(void)resume;

/**
 Call when your App is shutting down.  This gives the Fingerprint platform a chance to free allocated resources, save data, and generally shutdown cleanly.
 
 call from
 - (void)applicationWillTerminate:(UIApplication *)application
 
 This does not trigger any User Interface.
 
 */
+(void)shutdown;

/**
 openHub can be used to open either the Fingerprint Hub interface or a partner-specific hub.
 
 For the Fingerprint Hub interface, if you're using the standard Hub button, you probably
 will not need to call openHub. Otherwise, you can open the Fingerprint Hub with this call:
 
 [Fingerprint openHub:@"" withData:nil];
 
 The Fingerprint platform can also display partner-specific hubs, depending on the partner
 value returned from Fingerprint::avatarDescription(). For instance, if the partner is "astro",
 openHub can be used to bring up the Astro Upsell alert from game code as follows:
 
 [Fingerprint openHub:@"hub:astro_upsell" withData:nil];
 
 When the user is done interacting with the hub and returns to the game,
 onUIComplete will be called on the FingerprintDelegate.
 
 @param mode if @"", this is a request to show the standard Fingerprint hub. If populated, specifies a partner's hub. Currently supported strings include @"" and @"hub:astro_upsell".
 @param data currently unused. For upcoming features.
 */
+(void)openHub:(NSString*)mode withData:(NSDictionary*)data;

/**
 sendMessage is for sending email and/or Facebook messages to the Parent
 
 @param templateID
 the message template.  The messages are written by Fingerprint producers and are stored on the Fingerprint server so
 that they can be edited and updated.
 
 @param data
 the message templates include substitution variables.  Please work with your Fingerprint producer to determine what
 values your game needs to pass in for a given message template. 
 
 NOTE: the key names in the JSON data must not contain "." or "$" and may not be the empty string

 @param bInteractive
 if false, then the message is sent without anything visual
 if true, then a dialog is presented to the child so that he/she can see what will be sent and be given the chance to
 record accompanying audio
 
 If bInteractive is true, then when the user is done interacting with the message and returns to the game, 
 the delegate method onUIComplete will be called.
 
 */	
+(void)sendMessage:(NSString*)templateID withData:(NSDictionary*)data interactive:(BOOL)bInteractive;

/**
 Send data to the metrics server.
 
 This does not trigger any User Interface.  It simply sends the data to the server (or, if off-line,
 caches it to be sent later when an connection is available.)
 
 Please work with your Fingerprint producer to determine what events to track for your game.
 
 This is for tracking events e.g. a button push
 
 @param metricID 
 name of this tracking event, as it will appear in the analytics portal
 
 @param data
 tags for this event as name/value pairs (optional)
 
 NOTE: the key names in the JSON data must not contain "." or "$" and may not be the empty string

 */
+(void)metric:(NSString*)metricID withData:(NSDictionary*)data;

/**
 Send data to the metrics server.
 
 This does not trigger any User Interface.  It simply sends the data to the server (or, if off-line,
 caches it to be sent later when an connection is available.)
 
 Please work with your Fingerprint producer to determine what events to track for your game.
 
 This is for tracking screens e.g. menu, end of level, etc.
 
 @param screenID name of this screen, as it will appear in the analytics portal
 */
+(void)metricScreen:(NSString*)screenID;

/**
 for progress report events
 
 This does not trigger any User Interface.  It simply sends the data to the server (or, if off-line,
 caches it to be sent later when an connection is available.)
 
 @param progressID template id for the progress report that will shown to the parent
 @param data name/value pairs to populate the game specific substitution variables in the progress report template
 
 NOTE: the key names in the JSON data must not contain "." or "$" and may not be the empty string

 Please work with your Fingerprint producer to determine what events we'd like to track for your game.	 
 */
+(void)reportProgress:(NSString*)progressID withData:(NSDictionary*)data;


/**
 Part of the Fingerprint platform is the ability for the child to earn points and achieve goals
 to win additional Sidekicks (virtual pets).
 
 This is how your game awards points.  100 points earns a Sidekick.  
 
 Please work with your Fingerprint producer to determine when and how many points your game should award.
 
 This call triggers a visual dialog that shows the child progress towards the goal, and perhaps
 even the achivement of the goal and granting of Sidekick.
 
 When the user is done interacting with the achievement dialog and returns to the game, 
 the delegate method onUIComplete will be called.	 
 
 @param points how many points to award
 */
+(void)awardFingerprintPoints:(int)points;

/**
 Avatar support is meta-data only, nothing graphical.
 
 avatarDescription returns an NSDictionary with contain the following name/value pairs:\n\n
 Name: "hair"\n
 Possible Values: "brown", "black", "red", "blond"\n\n
 Name: "eyes"\n
 Possible Values: value is always "black".\n\n
 Name: "id"\n
 Possible Values: For instance, "boy2". Can be boy[1-6], or girl[1-6].\n\n
 Name: "partner"\n
 Possible Values: can be "fingerprint", "astro", etc.\n\n
 Name: "bHasKidOrFamily"\n
 Possible Values: YES or NO\n\n
 Name: "language"\n
 Possible Values: "en" for English, "zh-CN" for Mandarin, "ms" for Malaysian, "ta" for Tamil, etc.\n\n
  
 The values for hair, eyes and id are totally subject to interpretation by the game if the game wants to render an avatar, but the
 standard artwork for girl 1-6 and boy 1-6 can be provided if the game wants to incorporate it.

 This does not trigger any User Interface.
 
 returns the attributes in a dictionary
 */
+(NSDictionary*)avatarDescription;

/**
 Persist the data.  Can be arbitrary JSON.  Gets stored to cloud (with device caching for optimization/offline use).
 
 Note that the data is stored speciifcally for the current game, account and child.
 
 This does not trigger any User Interface.
 
 @param dataID name of data to save
 @param data object to persist

 NOTE: both the dataID *and* the key names in the JSON data must not contain "." or "$" and may not be the empty string
 */
+(void)saveData:(NSString*)dataID withData:(NSDictionary*)data;

/**
 Load persisted data. 
 
 Note that if a data conflict occurs, the delegate method onResolve will be called.
 
 This does not trigger any User Interface.
 
 @param dataID name of data to save
 
 returns the data loaded.
 */
+(NSDictionary*)loadData:(NSString*)dataID;

/**
 Delete data
 
 @param dataID name of data to delete
 */
+(void)deleteData:(NSString*)dataID;

/**
 Upload data to create an file hosted by Fingerprint on the Internet
 
 When the upload is complete, FingerprintDelegate protocol method onUploadComplete will be called with the returned uploadID,
 whether or not the upload was successful, and if it was, the URL where the data can now be found on the Internet
 
 @param fileSuffix the filename on the Internet will be a unique string, but you can supply the file suffix to
 help in identifying the format of the data when it is downloaded later.
 @param data the data to upload
 
 @return returns an integer id to identify the completion event to FingerprintDelegate protocol method onUploadComplete
 */
+(int)upload:(NSString*)fileSuffix withData:(NSData*)data;


/**
 Set whether the hub button "tray" is showing
 
 @param bShow whether to show the hub button, or to hide it
 */
+(void)showHubButton:(BOOL)bShow;


/**
 Invoke the Parent Gate (UI to have user "prove" they are a parent)
 
 @param details for future expansion
 */
+(void)parentGate:(NSDictionary*)details;

/**
 send multiplayer game move

 When a move ends the game, you must supply one additional key/value pair in the move dictionary with key name "gameOver". The value should be one of these constants from Fingerprint.h:
 
 #define GAMEOVER_PLAYER1_WON    @"PLAYER"
 #define GAMEOVER_PLAYER2_WON    @"OPPONENT"
 #define GAMEOVER_TIE            @"NONE"
 
 @param move object representing the move. Can contain whatever information you choose, although data should be as minimal as possible since it will be stored in the database for every move of every game, and also transmitted over the network.
 */
+(void)sendMove:(NSDictionary*)move;

/**
 Call when your App receives:
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
 
 After the SDK is started, it will automatically request that the user register the device for iOS push notifications. If the user accepts,
 application:didRegisterForRemoteNotificationsWithDeviceToken will be called from iOS with the device token. This device token should be passed
 along to storePushNotificationToken.
 
 This does not trigger any User Interface.
 
 @param deviceToken the deviceToken passed to application:didRegisterForRemoteNotificationsWithDeviceToken by iOS
 */
+(void)storePushNotificationToken:(NSData*)deviceToken;

/**
 Call when your App receives this call for a push notification initiated by Fingerprint:
 - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
 
 This will adjust the number set as the badge of the application icon if necessary.
 
 @param userInfo is the userInfo passed to application:didReceiveRemoteNotification by iOS
 */
+(void)receivedRemoteNotification:(NSDictionary*)userInfo;

@end



