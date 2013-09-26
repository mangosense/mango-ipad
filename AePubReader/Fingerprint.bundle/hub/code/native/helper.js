//
//  Copyright 2011, 2012 Fingerprint Digital, Inc. All rights reserved.
//

/**
 Name space for functions that require native implementation support.
 */
var FPHelper = {};

/**
 * friend picker

 @return {void}
 @param {String} account_token for the account
 @param {int} specifies what mode to show. 0 = address book, 1 = Facebook.
 @param {Function} callback to receive the result
 */
FPHelper.friendPicker = function(account_token, mode, title, callback)
{
    if (window["FPNative"])
    {
        FPNativeCall("Helper", "friendPicker:mode:title:", [account_token, mode, title], callback);
    }
    else
    {
        // TODO
        console.log("warning: webHub FPHelper.friendPicker not implemented");
        setTimeout(callback, 1);
    }
};

/**
 * do Facebook connect

 @return {void}
 @param {Function} callback to receive the result (a Facebook token if successful)
 */
FPHelper.facebookConnect = function(callback)
{
    if (window["FPNative"])
    {
        FPNativeCall("Helper", "facebookConnect", [], callback);
    }
    else
    {
        // for now, this is a web-only implementation
        function onLoaded()
        {
            FB.init({
                 appId      : '110706139004475', // App ID
                 channelUrl : 'http://sdk-prod.fingerprintplay.com/channel.html', // Channel File
                 status     : true, // check login status
                 cookie     : true, // enable cookies to allow the server to access the session
                 xfbml      : true  // parse XFBML
               });

            FB.login(function(response) {
               if (response.authResponse) {
                     FB.api('/me', function(me) {
                         me.facebook_token = response.authResponse.accessToken;
                         callback(me);
                     });
               } else {
                   callback(null, null, null);
               }
             });
        }

        LoadScript("http://connect.facebook.net/en_US/all.js", onLoaded);
    }
};

/**
 * do Facebook app Request to the person specified by the facebook_id

 @return {void}
 @param {String} facebook_id of person to send the request
 @param {Function} callback to receive the result (a Facebook token if successful)
 */
FPHelper.facebookAppRequest = function(facebook_id, callback)
{
    if (window["FPNative"])
    {
        FPNativeCall("Helper", "facebookAppRequest:", [facebook_id], callback);
    }
    else
    {
        // TODO
        console.log("warning: webHub FPHelper.facebookAppRequest not implemented");
        setTimeout(callback, 1);
    }
};


/**
 * open App Store id in embedded App Store. Available on iOS 6+ only in apps that are linked to the StoreKit.framework.
 
 @return {void}
 @param {int} App Store id
 @param {int} specifies what transition to use for the hub. If 0, slide up to show App Store, then down when dismissed. If 1, fade in/out.
 */
FPHelper.presentAppStoreForID = function(appStoreID, wantFade)
{
    function next()
    {
        if (window["FPNative"])
        {
            FPNativeCall("Helper", "presentAppStoreForID:transitionType:", [appStoreID, wantFade]);
        }
        else
        {
            // TODO
            console.log("warning: webHub presentAppStoreForID not implemented");
            setTimeout(callback, 1);
        }
    }
    DoParentGate(next);
};

/**
 * open a URL in external browser - without this, we'd be stuck inside of our embedded web views

 @return {void}
 @param {String} url to open
 */
FPHelper.openURL = function(url)
{
    function next()
    {
        if (window["FPNative"])
        {
            FPNativeCall("Helper", "openURL:", [url]);
        }
        else
        {
            window.open(url);
        }
    }
    DoParentGate(next);
};

/**
 * open mail program

 @return {void}
 @param {String} mailTo TODO Docs
 @param {Boolean} subject TODO Docs
 @param {Function} body TODO Docs
 */
FPHelper.mailTo = function(email, subject, body)
{
    if (window["FPNative"])
    {
        var emails = email?[email]:null;
        FPNativeCall("Helper", "mailTo:subject:body:", [emails, subject, body]);
    }
    else
    {
        var url = "mailto:" + email + "?subject=" + subject + "&body=" + body;
        window.open(url);
    }
};

/**
 * get text from a file, even if cross domain

 @return {void}
 @param {String} url for the file
 @param {Function} callback to receive the result
 */
FPHelper.getText = function(url, callback)
{
    if (window["FPNative"])
    {
        FPNativeCall("Helper", "getText:", [url], callback);
    }
    else
    {
        $.get(url, function(data) {
            callback(data);
        });
    }
};

/**
 * find out which of the game ids in an array are installed on the device

 @return {void}
 @param {Array} arrayOfGameIds array of Fingerprint game Ids
 @param {Function} callback to receive the result (object mapping game Ids to booleans)
 */
FPHelper.areGamesInstalled = function(arrayOfGameIds, callback)
{
    // remove any null ids
    var i = 0;
    while (i<arrayOfGameIds.length) {
        if (!arrayOfGameIds[i]) {
            arrayOfGameIds.splice(i, 1);
        } else {
            i++;
        }
    }

    if (window["FPNative"])
    {
        FPNativeCall("Helper", "areGamesInstalled:", [arrayOfGameIds], callback);
    }
    else
    {
        var result = {};
        var count = arrayOfGameIds.length;
        for (var i=0; i<count; i++) {
            result[arrayOfGameIds[i]] = false;
        }
        function next()
        {
            callback(result);
        }
        setTimeout(next, 1);
    }
};


/**
 * launch the specified game (should have confirmed it was installed before calling)

 @return {void}
 @param {String} gameId Fingerprint game Id of game to launch
 @param {Object} data JSON object to pass to the other game
 */
FPHelper.launchGame = function(gameId, data)
{
    if (FPGetGameId() === gameId) {
        // if we're in the game already, then close the hub!
        FPWebView.eval("hub", "closeHub(true)");
        return;
    }

    if (window["FPNative"])
    {
        FPNativeCall("Helper", "launchGame:withData:", [gameId, data]);
    }
    else
    {
        alert("webHub: error openGame shouldn't be called");
    }
};


/**
 * play a video

 @return {void}
 @param {String} url of the video
 @param {Boolean} bURL is the video on the Internet (as opposed to local)?
 @param {Boolean} bAspectFill stretch to fill screen?
 @param {Boolean} bControls allow the user to control the video?
 @param {Function} callback for when video is completed or closed
 */

FPHelper.playVideo = function(url, bURL, bAspectFill, bControls, callback)
{
    console.log("FPHelper.playVideo: " + url);

    if (window["FPNative"])
    {
        FPNativeCall("Helper", "playVideo:bURL:bAspectFill:bControls:", [url, bURL, bAspectFill, bControls]);
    }
    else
    {
        // TODO
        console.log("warning: webHub FPHelper.playVideo not implemented");
    }
};

/**
 * show transparent gray overlay screen with spinning activity indicator and label - blocks interaction with the UI

 @return {void}
 @param {Boolean} bSending whether to show or hide (they nest, so show is a push, hide is a pop)
 @param {String} label to show - can pass empty string if just want activity indicator
 */

FPHelper.showSending = function(bSending, label)
{
    if (label == null) {
        label = "";
    }

    if (window["FPNative"])
    {
        FPNativeCall("SendingScreen", "showSendingScreen:withLabel:", [bSending, label]);
    }
    else
    {
        FPWebNative.showSending(bSending, label);
    }
};


/**
 * call a the natively registered API delegate object

 @return {void}
 @param {String} name of the API delegate object to call
 @param {Array} args array of arguments with correct types for that delegate function
 */

FPHelper.callAPIDelegate = function(name, args)
{
    if (window["FPNative"])
    {
        FPNativeCall("FPAPI", "callAPIDelegate:withArgs:", [name, args]);
    }
    else
    {
        FPWebNative.callAPIDelegate(name, args);
    }
};


/**
 * call the Fiksu SDK registration integration point

 @return {void}
 */

FPHelper.fixsuRegistration = function(s)
{
    if (window["FPNative"])
    {
        FPNativeCall("Helper", "fixsuRegistration", []);
    }
    else
    {
        // TODO
        console.log("warning: webHub FPHelper.fixsuRegistration not implemented");
    }
};


/**
 * get Device's language setting

 @return {String}
 */

FPHelper.getDeviceLanguage = function(callback)
{
    function doFallback()
    {
        function next()
        {
            callback("en"); // web-test environment defaults to English
        }
        setTimeout(next, 1);
    }

    var sdk_version = FPGetAppValue("sdk_version");
    if (sdk_version < 36) {
        doFallback();
    } else {
        if (window["FPNative"])
        {
            FPNativeCall("Helper", "getDeviceLanguage", [], callback);
        }
        else
        {
            doFallback();
        }
    }
};


/**
 * save server data

 @return {void}
 */

FPHelper.saveServerData = function(name, value)
{
    if (window["FPNative"])
    {
        FPNativeCall("Helper", "saveServerData:value:", [name, value]);
    }
    else
    {
        // TODO
        console.log("warning: webHub FPHelper.saveServerData not implemented");
    }
};


/**
 * set the mode string that will be passed to onUIComplete the next time the SDK UI is closed

 @return {void}
 */

FPHelper.setNextUICompleteMode = function(mode)
{
    var sdk_version = FPGetAppValue("sdk_version");
    if (sdk_version < 7) {
        return;
    }

    if (window["FPNative"])
    {
        FPNativeCall("FPAPI", "setNextUICompleteMode:", [mode]);
    }
    else
    {
        // TODO
        console.log("warning: webHub FPHelper.setNextUICompleteMode not implemented");
    }

}


/**
 * tell native code that Javascript platform is fully resumed and running

 @return {void}
 */

FPHelper.platformResumed = function()
{
    var sdk_version = FPGetAppValue("sdk_version");
    if (sdk_version < 35) {
        return;
    }

    if (window["FPNative"])
    {
        function next()
        {
            FPNativeCall("SendingScreen", "hideNativeSplash", []);
        }
        // on 500 ms delay
        setTimeout(next, 500);
    }
    else
    {
        // TODO
        console.log("warning: webHub FPHelper.platformResumed not implemented");
    }

}