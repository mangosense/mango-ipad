//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

gOnDevice = true;
gbIPad = false;
gWebGame = true;

var gWebView = {};
var gWebViewReady = {};
var names = ["tictactoe", "multiplayer", "login", "hub", "alert"];

var gWebX = 52;
var gWebY = 142;
var gWebWidth = 320;
var gWebHeight = 480;

function start(root)
{
    var landscape = GetArg("landscape=");
    FPSetAppValue("bLandscape", landscape);

    var device_id = localStorage["WEB_DEVICE_ID"];
    if (!device_id) {
        device_id = GUID();
        localStorage["WEB_DEVICE_ID"] = device_id;
    }

    console.log("WEB_DEVICE_ID: " + device_id);
    FPSetAppValue("webtest", true);
    FPSetAppValue("device_id", device_id);
    FPSetAppValue("game_id", "tictactoe");
    FPSetAppValue("sdk_version", 1);
    FPSetAppValue("server", GetSite());
    FPSetAppValue("versions", JSON.stringify({web:"web"}));
    FPSetAppValue("bPartnerMode", "true");

    var sizeW = GetArg("w=");
    var sizeH = GetArg("h=");
    if (sizeW && sizeH) {
        gWebX = 0;
        gWebY = 0;
        gWebWidth = parseInt(sizeW);
        gWebHeight = parseInt(sizeH);

    } else {
        var iPhone;
        if (FPIsLandscape()) {
            gWebX = 136;
            gWebY = 33;
            gWebWidth = 480;
            gWebHeight = 320;
            iPhone = image({parent: document.body, x: 10, y: 10, src: "iphone_full.png"});
        } else {
            iPhone = image({parent: document.body, x: -160, y: 190, src: "iphone_full.png"});
            $(iPhone).css("webkitTransform", "rotate(90deg)");
        }
    }

    var clip = div({parent: document.body, x: gWebX, y: gWebY, w: gWebWidth, h: gWebHeight, color: null});

    var count = names.length;
    for (var i=0; i<count; i++) {

        var d = document.createElement("iframe");
        var src = "./index.html?index=" + names[i];
        if (gUNIQUE) {
            src += "&unique=" + gUNIQUE;
        }
        d.src = src;
        $(d).css("width", gWebWidth);
        $(d).css("height", gWebHeight);
        $(d).css("border", "0px");
  		$(d).css("position", "absolute");
      	$(d).css("left", 0);
      	$(d).css("top", 0);
      	$(d).css("overflow", "hidden");
        clip.appendChild(d);

        d.contentWindow.FPWebNative = FPWebNative;
        d.contentWindow.gWebGame = true;
        d.contentWindow.gTestHarness = window.gTestHarness;
        d.contentWindow.gSub = true;
        d.contentWindow.gTestWidth = gWebWidth;
        d.contentWindow.gTestHeight = gWebHeight;

        if (names[i] != "tictactoe") {
            $(d).hide();
        }

        gWebView[names[i]] = d;
    }

    if (!sizeW) {
        var resume = label({parent: document.body, x: 3, y: 3, color: "#000000", string: "<u>resume</u>"});
        resume.onclick = function()
        {
            gWebView["login"].contentWindow.FPResume();
        }
    }

}

/** Return the base url of the window location.
 *  If the site is 127.0.0.1:8080 map to dev.fingerprintplay.com:8080
 *  so that it's possible to test Facebook Connect in local dev environment.
 *  @fn String GetSite
 *  @treturn String a button div.
 */
function GetSite()
{
	// want the base of the URL - keep http/https
	// if the site is 127.0.0.1:8080 map to dev.fingerprintplay.com:8080 so that it's possible
	// to test Facebook Connect in local dev environment (dev.fingerprintplay.com maps to 127.0.0.1 in /etc/hosts locally)
	var l = ""+window.location;
	if (l.indexOf("http://127.0.0.1:8080") == 0) {
		l = "http://dev.fingerprintplay.com:8080";
	} else {
		// want the URL up to (but not including) the 3rd slash
		var i = l.indexOf("//");
		i = l.indexOf("/", i+2);
		l = l.substring(0, i);
	}
	return l;
}

var FPWebNative = {};

var gShowNotificationTarget = null;

function GetTargetFromDocument(document)
{
    var count = names.length;
    for (var i=0; i<count; i++) {
        var target = names[i];
        if (gWebView[target].contentDocument == document) {
            return target;
        }
    }
    return null;
};

FPWebNative.webViewReady = function(document)
{
    var target = GetTargetFromDocument(document);
    gWebViewReady[target] = true;
};

FPWebNative.webViewIsReady = function(document, target)
{
    if (target == "self") {
        target = GetTargetFromDocument(document);
    }
    return gWebViewReady[target];
};

FPWebNative.webViewShow = function(document, target, bShow)
{
    if (target == "self") {
        target = GetTargetFromDocument(document);
    }
    var wv = gWebView[target];
    if (bShow) {
        $(wv).show();
    } else {
        $(wv).hide();
    }

    if (gShowNotificationTarget) {
        gShowNotificationTarget.contentWindow.doEval("onShowNotification(\"" +target + "\", " + bShow + ")");
    }
};

FPWebNative.registerForShowNotifications = function(document)
{
    var target = GetTargetFromDocument(document);
    gShowNotificationTarget = gWebView[target];
}

FPWebNative.isVisible = function(document, target)
{
    if (target == "self") {
        target = GetTargetFromDocument(document);
    }
    var wv = gWebView[target];
    var bVisible = $(wv).is(":visible");
    return bVisible;
};

FPWebNative.eval = function(document, target, js)
{
    var caller = GetTargetFromDocument(document);
    if (target == "self") {
        target = caller;
    }
    var wv = gWebView[target];
    return wv.contentWindow.doEval("gCaller=\"" + caller + "\";" + js);
};

FPWebNative.setFrame = function(document, target, x, y, w, h, bAnimate)
{
    if (target == "self") {
        target = GetTargetFromDocument(document);
    }
    var wv = gWebView[target];

    function next()
    {
        wv.style.left = x + "px";
        wv.style.top = y + "px";
        wv.style.width = w + "px";
        wv.style.height = h + "px";
    }

    if (bAnimate) {
        wv.style.webkitTransitionProperty = "left,top";
        wv.style.webkitTransitionTimingFunction = "ease-in";
        wv.style.webkitTransitionDuration = "333ms";
        setTimeout(next, 1);
    } else {
        next();
    }
}

FPWebNative.callAPIDelegate = function(name, args)
{
    if (name == "onGameUpdate:") {
        gWebView["tictactoe"].contentWindow.gScreen.onGameUpdate(args[0]);
    }
}

var gSending = null;
var gSendingMessage = [];

FPWebNative.showSending = function(bSending, labelText)
{
    if (bSending) {
        gSendingMessage.push(labelText);
    } else {
        gSendingMessage.pop();
    }

    if (gSendingMessage.length > 0) {
        if (!gSending) {
            gSending = div({parent: document.body, x: gWebX, y: gWebY, w: gWebWidth, h: gWebHeight, color: "#000000"});
            $(gSending).css("opacity", 0.5);
        }
        if (gSending.label) {
            $(gSending.label).remove();
        }
        gSending.label = label({parent: gSending, x: 0, y:0, w: gWebWidth, h: gWebHeight, size: 18, string: gSendingMessage[gSendingMessage.length-1], center: true, vCenter: true});
    } else {
        if (gSending) {
            $(gSending).remove();
            gSending = null;
        }
    }
}
