//  Copyright (c) 2011-2013 Fingerprint Digital, Inc. All rights reserved.

var gUNIQUE = null;
var ua = navigator.userAgent.toLowerCase();
var gbAndroid = (ua.indexOf("android") != -1);

function GetArg(prefix)
{
    var p = ""+window.location;
    var q = p.indexOf(prefix);
    var result = null;
    if (q != -1) {
        p = p.substring(q+prefix.length);
        q = p.indexOf("&");
        if (q != -1) {
            result = p.substring(0, q);
        } else {
            result = p;
        }
    }
    return result;
}

function LoadScript(src, callback)
{
	var headID = document.getElementsByTagName("head")[0];
	var newScript = document.createElement('script');
	newScript.type = 'text/javascript';
    if (gUNIQUE != null) {
        if (gbAndroid) {
            if (src.indexOf("http") == -1) { // only do this for local content provider
                src = src + "_fp_UNIQUE_" + gUNIQUE;
            }
        } else {
            src = src + "?" + gUNIQUE;
        }
    }
	if (callback) {
		newScript.onload = callback;
	}
	newScript.src = src;
	headID.appendChild(newScript);
}

function bootstrap()
{
    //console.log("LOCATION: " + window.location);

    var unique = GetArg("&unique=");
    if (unique) {
        gUNIQUE = unique;
    }

    //console.log("gUNIQUE: " + gUNIQUE);

    if (gbAndroid) {

        // on Android 3.0 - 4.04, query strings are breaking WebView
        // the Unique-scheme works around an iOS UIWebView bug where caching refused to be completely disabled
        // we need to make sure the Android cache is cleared successfully after a Fingerprint update
        gUNIQUE = null;

        // see if we can get unique value passed in alternate way on Android (working around Android query string bug)
        var s = "" + window.location;
        var t = "_fp_UNIQUE_";
        var x = s.indexOf(t);
        if (x != -1) {
            gUNIQUE = s.substring(x+ t.length);
        }

        // on Android, we have a bunch of additional code to load
        function next()
        {
            // load a uniqued loader.js
            LoadScript("code/loader.js");
        }

        LoadScript("./code/android.js", next);
        return;
    }

    // load a uniqued loader.js
    LoadScript("code/loader.js");
}
