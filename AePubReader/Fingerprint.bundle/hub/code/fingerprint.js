//
//  fingerprint.js
//
//  Copyright 2011-2012 Fingerprint Digital, Inc. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------------------

var ua = navigator.userAgent.toLowerCase();
var gbAndroid = (ua.indexOf("android") != -1);
var gbIOS = (ua.indexOf("iphone") != -1 || ua.indexOf("ipad") != -1 || ua.indexOf("ipod") != -1);

var gOnDevice = false;
var gRoot = null;
var gOriginalRoot = null;
var gTransitionTime = 300;

var gScaleX;
var gScaleY;
var gWindowWidth;
var gWindowHeight;
var gFullWidth;
var gFullHeight;

// called by image-info.js files for hub, onlinehub and catalog
var gImageInfo = {};
function RegisterImages(root, data)
{
//	console.log("RegisterImages: " + root);
	gImageInfo[root] = data;
}

function MakeWebkitTransform(x, y, rotation)
{
	var result;
	if (FPUse3d()) {
		result = "translate3d(" + x + "px, " + y + "px, 0px) ";
	} else {
		result = "translate(" + x + "px, " + y + "px) ";
	}

	return result;
}

function main(root)
{
    var indexName = GetArg("index=");
    if (gbAndroid && !indexName) {
        // Android specific work-around for passing index name without a query string due to Android bug in 3.0 - 4.04
        var p = ""+window.location;
        var n = "__NAME__";
        var i = p.indexOf(n);
        var t = p.substr(i+ n.length);
        i = t.indexOf(".html");
        indexName = t.substr(0, i);
    }
    var script = "code/index_" + indexName + ".js";
    function onLoaded()
    {
            start(root);
            FPWebView.ready();
    }
    LoadScript(script, onLoaded);
}

function doEval(s)
{
    return eval(s);
}

function onLoad()
{
    // prevent selection and dragging
    document.ondragstart = function () { return false; };
    document.onselectstart = function () { return false; };

    // iOS specific
    var userAgent = window.navigator.userAgent;
    if (gbIOS || gbAndroid) {
        document.ontouchmove = function(e) {e.preventDefault();};
        initTouchEvents();
    }

    onLoad3()
}

function onLoad3()
{
	try {

		var windowWidth = $(window).width();
		var windowHeight = $(window).height();

        // on Android, we were not always getting valid values for window width and height from these JQuery calls
        // so we obtain them natively instead
        if (gbAndroid) {
            var sdk_version = FPGetAppValue("sdk_version");
            if (sdk_version >= 46) {
                windowWidth = JSInterface.getWebViewWidth();
              	windowHeight = JSInterface.getWebViewHeight();
              	console.log("retrieved webview dimensions: " + windowWidth + 
              	    ", " + windowHeight);

              	// meta data tag for density is not available prior to version 
              	// 51 so we still need to apply scale
              	if (sdk_version < 51) {
              		console.log("applying scaling to webview dimensions: " +
              		    window.devicePixelRatio);

              		windowWidth /= window.devicePixelRatio;
              		windowHeight /= window.devicePixelRatio;
              	}
            }
        }

        if (FPIsLandscape()) {
            gFullWidth = 480;
            gFullHeight = 320;
        } else {
            gFullWidth = 320;
            gFullHeight = 480;
        }

        if (!(gbAndroid||gbIOS))
        {
            windowWidth = gFullWidth;
            windowHeight = gFullHeight;
        }

        if (window.gTestHarness) {
            windowWidth = window.gTestWidth;
            windowHeight = window.gTestHeight;
        }

        if (gbAndroid) {
            if (FPIsLandscape()) {
                if (windowHeight > windowWidth) {
                    console.log("WAITING FOR WEB VIEW TO SETTLE - Landscape: " + windowHeight + ", " + windowWidth);
                    // something is wrong... wait and look again
                    setTimeout(onLoad3, 100);
                    return;
                }
            } else {
                if (windowWidth > windowHeight) {
                    console.log("WAITING FOR WEB VIEW TO SETTLE - Portrait: " + windowWidth + ", " + windowHeight);
                    // something is wrong... wait and look again
                    setTimeout(onLoad3, 100);
                    return;
                }
            }
        }

		var scaleX = windowWidth / gFullWidth;
		var scaleY = windowHeight / gFullHeight;

		// avoid any small rounding issues
		if (scaleX > 0.99 && scaleX < 1.01) scaleX = 1;
		if (scaleY > 0.99 && scaleY < 1.01) scaleY = 1;
        if (FPIsLandscape()) {
            // in landscape - the y-scale is dominant, and we'll adjust our layouts in x
            gFullWidth = gFullWidth*scaleX/scaleY;
            scaleX = scaleY;
        } else {
            // in portrait - the x-scale is dominant, and we'll adjust our layouts in y
            gFullHeight = gFullHeight*scaleY/scaleX;
            scaleY = scaleX;
        }

        gScaleX = scaleX;
        gScaleY = scaleY;
        gWindowWidth = windowWidth;
        gWindowHeight = windowHeight;
        console.log("webview layout properties:\n" + gScaleX + ", " + gScaleY + 
            ", " + gWindowWidth + ", " + gWindowHeight);

        gRoot = CreateDiv(document.body, 0, 0, windowWidth, windowHeight);

		main(gRoot);
	} catch (err) {
		LogError(err);
	}
}

//----------------------------------------------------------------------------------------------------------------------
// native Facebook Connect login dialog glue code
var gbFacebookCallback;

function FacebookReply(access_token)
{
	if (gbFacebookCallback) {
		if (access_token && access_token.length > 1) {
			gbFacebookCallback(access_token);
		} else {
			gbFacebookCallback(null);
		}
	}
}



//----------------------------------------------------------------------------------------------------------------------
function CreateDiv(parent, x, y, width, height, color)
{
   	var d = document.createElement('div');
	$(d).css("width", width);
	$(d).css("height", height);
	if (x != undefined) {
		$(d).css("position", "absolute");
	}
	$(d).css("left", x);
	$(d).css("top", y);
	$(d).css("backgroundColor", color);
	$(d).css("overflow", "hidden");
    if (parent) {
    	parent.appendChild(d);
    }
	return d;
}

//----------------------------------------------------------------------------------------------------------------------
function LoadImages(images, callback, context)
{
	if (images.length == 0) {
        function next()
        {
    		callback(context);
        }
        if (gbScreenOneFile) {
            setTimeout(next, 1);
        } else {
            next();
        }
		return;
	}

	var result = {};
	try {
		var done = 0;
		function ImageLoaded()
		{
			done++;
			if (done == images.length) {
				callback(context, result);
			}
		}
		for (var i=0; i<images.length; i++)
		{
			var img = new Image();
			result[images[i]] = img;
			img.onload = ImageLoaded;
			img.src = GetImageInfo(images[i]).src;
		}
	} catch (err) {
		LogError(err);
	}
}

function LoadImagesSync(images, callback, context)
{
	var result = {};
	try {
		for (var i=0; i<images.length; i++)
		{
			var img = new Image();
			result[images[i]] = img;
            var info = GetImageInfo(images[i]);
			img.src = info.src;
            img.width = info.w;
            img.height = info.h;
		}
	} catch (err) {
		LogError(err);
	}
    callback(context, result);
}

//----------------------------------------------------------------------------------------------------------------------
var gPathPrefix = null;

function MakeImagePath(name)
{
	var i = name.indexOf(".png");
	if (i == -1) {
		i = name.indexOf(".jpg");
	}
    if (i == -1) {
        i = name.indexOf(".gif");
    }
	if (i == -1) {
		// allow catalog images to have no suffix
		if (name.indexOf("/catalog/") == -1) {
			name += ".png";
		}
	}
	if (gPathPrefix) {
		name = gPathPrefix + name;
	}
	return name;
}

