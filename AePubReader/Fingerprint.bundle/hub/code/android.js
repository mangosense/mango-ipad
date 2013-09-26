//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

//-----------------------------------------------------------------------------------------------------
// hide the ugly orange "focus rects"
var head = document.getElementsByTagName('head')[0],
	style = document.createElement('style'),
	rules = document.createTextNode('* { -webkit-tap-highlight-color: rgba(0, 0, 0, 0); }');

style.type = 'text/css';
if(style.styleSheet)
	style.styleSheet.cssText = rules.nodeValue;
else style.appendChild(rules);
head.appendChild(style);


//-----------------------------------------------------------------------------------------------------
// need to make it so that the page can be scrolled - just add this once - can keep it there
var e = document.createElement("div");
document.body.appendChild(e);
var gbFixedPage = false;

var nativeVersion = null;

var lastTouchPosition = 0;

// poll for native callbacks and keyboard
function androidPoll()
{
    if (!window["$"] ||
        !window["JSInterface"])
    {
        setTimeout(androidPoll, 1000);
        return;
    }

    // to avoid calling FPGetAppValue every polling iteration, lazy load the 
    // native version
    if (nativeVersion == null) {
    	var returnVal = FPGetAppValue("sdk_version");

    	// FPGetAppValue can return undefined so make sure the value is 
    	// valid before setting it
    	if (typeof returnVal != 'undefined') {
    		nativeVersion = returnVal;
    	}
    }

    // it is still possible for the nativeVersion to be null since 
    // FPGetAppValue can return undefined initially 
    // NOTE: With version 45 and beyond, keyboard panning is handled at the
    // native layer so keyboard polling is no longer required
    if ((nativeVersion != null) && (nativeVersion < 45)) {

        // if we need to do JS scrollTo, we need to make sure the page is tall enough to scroll
        if (!gbFixedPage) {
            $(e).css("height", "5000px");
            gbFixedPage = true;
        }

    	var bKeyboardVisible = false;
    	var yScrollPos = 0;

    	if (nativeVersion < 37) {
    		var bKeyboardVisible = JSInterface.isKeyboardVisible();
    		if (bKeyboardVisible) {
                yScrollPos = 110;
    		}

    	} else if(nativeVersion >= 40) {
    		var visibleHeight = JSInterface.getVisibleHeight();

    		if (visibleHeight > 0) {
    			// adjust the reported visible height by the scaling factor back 
        		// into the scale from the webview perspective
    			visibleHeight = visibleHeight / window.devicePixelRatio;

        		var scrollDownThreshold = visibleHeight - (visibleHeight / 3);
        		var centerPosition = visibleHeight / 2;

    			if (lastTouchPosition > scrollDownThreshold) {
    				yScrollPos = centerPosition;
    			}
    		}
    	}

        window.scrollTo(0, yScrollPos);
    }

    try {
        while (true) {
            var s = JSInterface.pollCallback();
            if (s && s.length>0) {
                eval(s);
            } else {
                break;
            }
        }
    } catch (e) {
    }
    setTimeout(androidPoll, 100);
}

androidPoll();

function doBackFunction(s)
{
    var bUsed = false;
    if (s.on_close != null)
    {
        bUsed = true;
        s.on_close();
    }
    else
    {
        if (s.on_cancel != null)
        {
            bUsed = true;
            s.on_cancel();
        }
        else
        {
            if (s.on_back != null)
            {
                bUsed = true;
                s.on_back();
            }
            else
            {
                if (s.on_home != null)
                {
                    bUsed = true;
                    s.on_home();
                }
            }
        }
    }
    return bUsed;
}

function onBackButton()
{
    var bUsed = false;
    if (gScreen != null) {
        bUsed = doBackFunction(gScreen);
        if (!bUsed) { // in V2, most of the hub panels have a hubFrame sub-element that parents the buttons
            var p = gScreen.children[0]
            bUsed = doBackFunction(p);
        }
    }
    return bUsed;
}
