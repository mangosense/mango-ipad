//
//  Copyright 2011, 2012 Fingerprint Digital, Inc. All rights reserved.
//

/**
 Name space for functions that require native implementation support.
 */
var FPWebView = {};

/**
 * called after a web view is fully loaded and is ready to accept JavaScript calls initiated by native code

 @return {void}
 */
FPWebView.ready = function()
{
    if (window["FPNative"])
    {
        FPNativeCall("FPAPI", "webViewReady", []);
    }
    else
    {
        FPWebNative.webViewReady(document);
    }
};


/**
 * ask if a web view is ready

 @param {String} target web view to ask about
 @param {Callback} callback to receive boolean result
 @return {void}
 */
FPWebView.isReady = function(target, callback)
{
    if (window["FPNative"])
    {
        FPNativeCall("FPAPI", "webViewIsReady:", [target], callback);
    }
    else
    {
        var bReady = FPWebNative.webViewIsReady(document, target);
        if (callback) {
            callback(bReady);
        }
    }
};

/**
 * show or hide a web view

 @param {String} target web view to show or hide (e.g. "self", "hub", "multiplayer", "alert")
 @param {Boolean} bShow whether to show (true) or hide (false)
 @return {void}
 */
FPWebView.show = function(target, bShow)
{
    if (window["FPNative"])
    {
        FPNativeCall("FPAPI", "webViewShow:bShow:", [target, bShow]);
    }
    else
    {
        FPWebNative.webViewShow(document, target, bShow);
    }
};


/**
 * calling this will make it so a function "onShowNotification(target, bShow)" is called
 * in the calling webView any time the show state of any web view, including itself, changes

 @return {void}
 */
FPWebView.registerForShowNotifications = function()
{
    if (window["FPNative"])
    {
        FPNativeCall("FPAPI", "webViewRegisterForShowNotifications", []);
    }
    else
    {
        FPWebNative.registerForShowNotifications(document);
    }
};


/**
 * find out whether a given web view is currently being shown

 @param {String} target web view to show or hide (e.g. "self", "hub", "multiplayer", "alert")
 @param {Function} callback to receive Boolean result
 @return {void}
 */
FPWebView.isVisible = function(target, callback)
{
    if (window["FPNative"])
    {
        FPNativeCall("FPAPI", "webViewIsVisible:", [target], callback);
    }
    else
    {
        var bVisible = FPWebNative.isVisible(document, target);
        if (callback) {
            callback(bVisible);
        }
    }
};


/**
 * eval some Javascript in the Targeted web view

 @param {String} target web view to show or hide (e.g. "self", "hub", "multiplayer", "alert")
 @param {String} js Javascript to run
 @param {Function} callback to receive result
 @return {void}
 */
FPWebView.eval = function(target, js, callback)
{
    var bSkipReadyCheck = false;
    var nextFunc;

    function nextNative()
    {
        FPNativeCall("FPAPI", "webViewEval:js:", [target, js], callback);
    }

    function nextWeb()
    {
        var result = FPWebNative.eval(document, target, js);
        if (callback) {
            callback(result);
        }
    }

    if (window["FPNative"])
    {
        var sdk_version = FPGetAppValue("sdk_version");
        if (sdk_version < 6) {
            bSkipReadyCheck = true; // skip because the native isReady call didn't exist before SDK version 6
        }
        nextFunc = nextNative;
    } else {
        nextFunc = nextWeb;
    }

    function onIsReady(bReady)
    {
        if (bReady) {
            nextFunc();
        } else {
            // try again after a short delay
            function again()
            {
                FPWebView.isReady(target, onIsReady);
            }
            setTimeout(again, 100);
        }
    }

    if (bSkipReadyCheck) {
        nextFunc();
    } else {
        FPWebView.isReady(target, onIsReady);
    }
};


/**
 * translate the *native* web view to a given x, y offset - animate the transition

 @param {int} x target x offset
 @param {int} y target y offset
 @return {void}
 */
FPWebView.setFrame = function(target, x, y, w, h, bAnimate)
{
    if (window["FPNative"])
    {
    	var sdk_version = FPGetAppValue("sdk_version");

    	// meta data tag for density is not available prior to version 
      	// 51 so we still need to apply scale
    	if (gbAndroid && (sdk_version < 51)) {
    		var s = window.devicePixelRatio;
    		x = parseInt(x * s);
    		y = parseInt(y * s);
    		w = parseInt(w * s);
    		h = Math.ceil(parseFloat(h * s)); // rounding up for android
    	}
        FPNativeCall("FPAPI", "webViewSetFrame:x:y:w:h:bAnimate:", [target, x, y, w, h, bAnimate]);
    }
    else
    {
        FPWebNative.setFrame(document, target, x, y, w, h, bAnimate);
    }
};

