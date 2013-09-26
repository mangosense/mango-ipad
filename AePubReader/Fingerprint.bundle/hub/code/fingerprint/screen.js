//
//  Copyright 2011, 2012 Fingerprint Digital, Inc. All rights reserved.
//
/**
 * @file
 * Constructor of UI components and utility functions needed.
 */
//----------------------------------------------------------------------------------------------------------------------
/** A global variable that trace the current screen div
 *  and includes all the settings to render the screen.
 *  @var gScreen
 *  @type Object
 */
var gScreen;

/** A global variable that called after current screen launched.
 *  @var gScreenLaunchedCallback
 *  @type Function
 */
var gScreenLaunchedCallback;

/** Flag for one screen loading at one time. When it is true,
 *  there is one screen on loading.
 *  @var gbScreenLoading
 *  @type Boolean
 */
var gbScreenLoading;

/** Set a screen to close transition when opening other screen.
 *  @var gRunScreenCloser
 *  @type Object
 */
var gRunScreenCloser;

/** A global variable to track run screen closer transition direction.
 *  @var gRunScreenCloserDir
 *  @type String
 */
var gRunScreenCloserDir;

/** A global variable  to track current active audio.
 *  @var gActiveAudio
 *  @type Object
 */
var gActiveAudio;

/** A global variable that detect if is the new sdk that combined ui
 *  and logic in the same file for all pages. The default value is true.
 *  @var gbScreenOneFile
 *  @type Boolean
 */
var gbScreenOneFile = true;

/** Call when launching a screen.
 *  @var gSaveScreenFunc
 *  @type Function
 */
var gSaveScreenFunc;

/** A global variable that trace callback of the last screen.
 *  @var gLastScreenCallback
 *  @type Function
 */
var gLastScreenCallback;

var gNotificationRegistry = {};

//----------------------------------------------------------------------------------------------------------------------
// functions for transitioning screens

// TODO: fix "left/right" are backwards
/** Return transition x coordinate of the input direction.
 *  @fn Number getSlideX( Object e, String dir)
 *  @tparam Object e the sliding element.
 *  @tparam String dir the transition direction.
 *  @treturn Number x coordinate.
 *  @see getSlideY
 */
function getSlideX(e, dir)
{
	var x = 0;
    switch (dir) {
        case "down": x = 0; break;
        case "up": x = 0; break;
        case "right": x = -gFullWidth; break;
        case "left": x = gFullWidth; break;
    }
	return x;
}
/** Return transition y coordinate of the input direction.
 *  @fn Number getSlideY( Object e, String dir)
 *  @tparam Object e the sliding element.
 *  @tparam String dir the transition direction.
 *  @treturn Number y coordinate.
 *  @see getSlideX
 */
function getSlideY(e, dir)
{
	var y = 0;
    switch (dir) {
        case "down": y = gFullHeight; break;
        case "up": y = -gFullHeight; break;
        case "right": y = 0; break;
        case "left": y = 0; break;
    }
	return y;
}
/** Show slide in animation if it not running embedded Hub.
 *  @fn slideIn( Object e, String dir)
 *  @tparam Object e the sliding element.
 *  @tparam String dir the transition direction.
 *  @see slideInAndroid
 *  @see slideOut
 */
function slideIn(e, dir)
{
	if (dir == null) {
		dir = "down";
	}

	e.tx = getSlideX(e, dir);
	e.ty = getSlideY(e, dir);
	e.style.webkitTransform = MakeWebkitTransform(e.tx, e.ty, e.or);

    // set transition properties AFTER setting initial transform
    e.style.webkitTransitionProperty = "-webkit-transform";
   	e.style.webkitTransitionDuration = 0;
   	e.style.webkitTransitionTimingFunction = "ease-in";

    function next()
    {
        e.style.webkitTransitionDuration = gTransitionTime +  "ms";
        e.style.webkitTransform = MakeWebkitTransform(0, 0, e.or);

        if (gbAndroid) {
            // we're not rotated - we can remove the transform once we're back in place
            // if we don't, the WebKit text fields don't behave
            // TODO: consider generalizing this change to iOS
            function done()
            {
                if (e.or == 0) {
                    e.style.webkitTransform = null;
                }
            }
            e.addEventListener('webkitTransitionEnd', done, false);
        }
    }
    setTimeout(next, 1);
}
/** Show slide out animation if it not running embedded Hub.
 *  @fn slideOut( Object e, String dir)
 *  @tparam Object e the sliding element.
 *  @tparam String dir the transition direction.
 *  @see slideOutAndroid
 *  @see slideIn
 */
function slideOut(e, dir)
{
    // it's possible to have a screen than had a "none" in, but an animated out - so if this isn't done yet, then do it
    if (e.style.webkitTransitionTimingFunction == 0) {
        e.style.webkitTransitionProperty = "-webkit-transform";
        e.style.webkitTransitionDuration = gTransitionTime + "ms";
        e.style.webkitTransitionTimingFunction = "ease-in";
    }

	function next()
	{
		if (dir == null) {
			dir = "down";
		}

		e.tx = getSlideX(e, dir);
		e.ty = getSlideY(e, dir);
		e.style.webkitTransform = MakeWebkitTransform(e.tx, e.ty, e.or);
	}
	setTimeout(next, 1);

	function done()
	{
		$(e).remove();
        $(e.anchor).remove();
	}
	setTimeout(done, gTransitionTime);
}
/** Show gray in animation of given element.
 *  @fn grayIn( Object e)
 *  @tparam Object e the given element.
 *  @see grayOut
 */
function grayIn(e)
{
	if (!e.gray) return;

	e.gray.style.webkitTransitionProperty = "opacity";
	e.gray.style.webkitTransitionDuration = gTransitionTime + "ms";
	e.gray.style.webkitTransitionTimingFunction = "ease-in";
	function next()
	{
        e.gray.style.backgroundColor = "#000000";
        e.gray.style.opacity = 0.5;
	}
	setTimeout(next, 1);
}
/** Show gray out animation of given element.
 *  @fn grayOut( Object e)
 *  @tparam Object e the given element.
 *  @see grayIn
 */
function grayOut(e)
{
	if (e.shield) {
		$(e.shield).remove();
	}

	if (!e.gray) return;

	e.gray.style.opacity = 0;
	function next()
	{
		$(e.gray).remove();
	}
	setTimeout(next, gTransitionTime);
}
/** Set the listener for the given audio.
 *  @fn setAudioListener( Object audio, Function listener)
 *  @tparam Object audio the given audio.
 *  @tparam Function listener a audio event listener handler.
 */
function setAudioListener(audio, listener)
{
	if (audio.saveListener) {
		audio.removeEventListener('ended', audio.saveListener, false);
		audio.saveListener = null;
	}
	if (listener) {
		audio.addEventListener('ended', listener, false);
		audio.saveListener = listener;
	}
}
/** Make native call to stop all sound. If gActiveAudio is true,
 *  set the audio listener to be null and then set gActiveAudio to be null.
 *  @fn stopAllAudio
 *  @see gActiveAudio
 */
function stopAllAudio()
{
//	FPNativeCall("sound", "stopAll");
	if (gActiveAudio) {
		setAudioListener(gActiveAudio, null);
		gActiveAudio.pause();
		gActiveAudio = null;
	}
}
/** Pause currently playing audio, set gAcitveAudio to input audio,
 *  and add audio listener handler.
 *  @fn playAudio( Object audio, Function completionCallback)
 *  @tparam Object audio the given audio.
 *  @tparam Function completionCallback callback called after the sound is completed.
 *  @see gAcitveAudio
 *  @see setAudioListener
 */
function playAudio(audio, completionCallback)
{
	if (gActiveAudio) {
		gActiveAudio.pause();
	}
	gActiveAudio = audio;
	gActiveAudio.play();
	function audioEnded()
	{
		setAudioListener(gActiveAudio, null);
		gActiveAudio = null;
		if (completionCallback) {
			completionCallback();
		}
	}
	setAudioListener(gActiveAudio, audioEnded);
}
/** Set gRunScreenCloser to given screen, and gRunScreenCloserDir to given direction.
 *  Stop all audio. And clear all sound related components in gScreen,
 *  that is, gScreen.voStartTimer, gScreen.voFlashTimer, gScreen.voInactivityTimer,
 *  gScreen.voCallback, and gScreen.voData.
 *  @fn runScreenCloser( Object s, String dir)
 *  @tparam Object s the screen.
 *  @tparam String dir the transition direction.
 *  @see gRunScreenCloser
 *  @see gRunScreenCloserDir
 *  @see gScreen
 */
// before calling runScreen, can set a screen to close transition in sync with loading transition
function runScreenCloser(s, dir)
{
    $("*:focus").blur();
	gRunScreenCloser = s;
	gRunScreenCloserDir = dir;

	stopAllAudio();
	clearTimeout(gScreen.voStartTimer);
	clearTimeout(gScreen.voFlashTimer);
	clearTimeout(gScreen.voInactivityTimer);
	gScreen.voCallback = null;
	gScreen.voData = null;
}
/** Initialize gOriginalRoot, gbScreenLoading, gScreen.
 *  @fn runScreen( Object parent, String path, String dir, Json args, Function on_close)
 *  @tparam Object parent the parent for the new screen.
 *  @tparam String path the path to UI and logic js file of the screen.
 *  @tparam String dir the transition direction.
 *  @tparam Json args including the settings for the screen.
 *  @tparam Function on_close callback call after screen closed.
 *  @see gOriginalRoot
 *  @see gbScreenLoading
 *  @see gScreen
 */
// first function called in screen loading sequence
function runScreen(parent, path, dir, args, on_close)
{
    if (gbAndroid) {
        $("*:focus").blur();
    }

	if (window["FPMetrics"]) {
		FPMetrics.metricScreen(FPGetScreenToken(path));
	}

	if (dir == null) {
		dir = "down";
	}

	console.log("runScreen: " + path);

	// screen loads can only be 1 at a time
	if (gbScreenLoading) {
		LogError({err: "can only load 1 screen at a time"});
	}
	gbScreenLoading = true;

	// create the div, so we can use it to store screen data
	if (parent == null) {
		parent = gRoot;
	}

    {

		// DISABLE GRAY TRANSITIONS FOR NOW - something about the transitions is causing iOS to reload assets
		// after the gray is removed, causing a huge flash/glitch.  Instead, put a gray screen fixed behind
		// the screens, so that the dialogs still stack with visual muting of the screen behind it.

        var useParent = parent;
        if (parent.anchor) {
            $(parent.anchor).show();
            useParent = parent.anchor;
        }

        var useW = gFullWidth * gScaleX;
        var useH = gFullHeight * gScaleY;

		var gray = CreateDiv(useParent, 0, 0, useW, useH);

        //console.log("GRAY");
        //console.log(parent);

		// however, we still need a "click shield" to prevent double touching a button and opening a screen twice
		var shield = CreateDiv(useParent, 0, 0, useW, useH);

        // create screen hidden so it doesn't render until we have it ready to transition from off-screen
		gScreen = CreateDiv(null, 0, 0, useW, useH);
        gScreen.style.display = "none";
        useParent.appendChild(gScreen);

        gScreen.anchor = CreateDiv(useParent, 0, 0, useW, useH);
        $(gScreen.anchor).hide();

		gScreen.shield = shield;

		gScreen.gray = gray;
		gScreen.gray.style.opacity = 0.0;

		//var alternateGray = CreateDiv(gScreen, 0, 0, useW, useH, "#000000");
		//alternateGray.style.opacity = 0.5;

        //gScreen.alternateGray = alternateGray;

		gScreen.parent = parent;
		gScreen.dir = dir;
	}

    parent.child = gScreen;

	gScreen.path = path;
	gScreen.args = args;
	gScreen.closeCallback = on_close;
	gScreen.images = [];
	gScreen.image = {};
	gScreen.buttons = [];
	gScreen.button = {};
	gScreen.labels = [];
	gScreen.label = {};
	gScreen.fields = [];
	gScreen.field = {};
	gScreen.divs = [];
	gScreen.div = {};
	gScreen.loadlist = [];
    gScreen.renderOrder = [];
	gScreen.background = null;
    gScreen.backgroundBTile = false;

	gScreen.doNext = function()
	{
		if (this != gScreen) {
			return;
		}

		if (this.voCallback) {
			//{voData: {inactivityTime:__, startTime:__, soundId:__, bFromPlatform:__, button:__, flashDelay:__}}
			this.voData = this.voCallback(this.voIndex);
			this.voIndex++;
		}

		if (this.voData) {
			if (this.voData.startTime && this.voData.startTime > 0) {
				var _this = this;
				this.voStartTimer = setTimeout(function() { _this._playThisVO(); }, this.voData.startTime);
			} else if (this.voData.inactivityTime) {
				this.restartInactivity();
			} else {
				this._playThisVO();
			}
		}
	}

	gScreen._playThisVO = function()
	{
		if (this != gScreen) {
			return;
		}

		var _this = this;
		if (this.voData.audio) {
			playAudio(this.voData.audio, function() { _this.doNext(); });
		} else {
//		FPNativeCall("sound", "play", {soundId: this.voData.soundId, bFromPlatform: this.voData.bFromPlatform}, function() { _this.doNext(); }, null);
		}
		if (this.voData.flashDelay != null && this.voData.flashDelay > 0) {
			this.voFlashTimer = setTimeout(function() { _this._flashTheseButtons(); }, this.voData.flashDelay);
		} else {
			this._flashTheseButtons();
		}
	};

	gScreen._flashTheseButtons = function()
	{
		if (this != gScreen) {
			return;
		}

		if (this.voData.customFlashFunction != null) {
			this.voData.customFlashFunction();
		} else {
			FlashButtons(this.voData.buttons);
		}
	};

	gScreen.onmousedown = function()
	{
		this.restartInactivity();
	}

	gScreen.restartInactivity = function()
	{
		if (this.voData != null && this.voData.soundId == null && this.voData.inactivityTime != null && this.voData.inactivityTime > 0) {
			clearTimeout(this.voInactivityTimer);
			var _this = this;
			this.voInactivityTimer = setTimeout(function() { _this.doNext(); }, this.voData.inactivityTime);
		}
	}

	gScreen.startVO = function(voCallback)
	{
		if (this.voCallback) {
			stopAllAudio();
			clearTimeout(this.voStartTimer);
			clearTimeout(this.voFlashTimer);
			clearTimeout(this.voInactivityTimer);
		}

		this.voCallback = voCallback;
		this.voData = null;
		this.voIndex = 0;
		this.doNext();
	}

    // register for a notification type
    gScreen.registerForNotification = function(type)
    {
        var a = gNotificationRegistry[type];
        if (a == null) {
            a = [];
            gNotificationRegistry[type] = a;
        }
        a.push(this);
        if (this.notificationTypes == null) {
            this.notificationTypes = [];
        }
        this.notificationTypes.push(type);
    }

    // unregister for a notification type
    gScreen.unregisterForNotification = function(type)
    {
        var a = gNotificationRegistry[type];
        if (a) {
            var i = a.indexOf(this);
            if (i != -1) {
                a.splice(i, 1);
            }
        }
        var i = this.notificationTypes.indexOf(type);
        if (i != -1) {
            this.notificationTypes.splice(i, 1);
        }
    }

	// establish close functionality
	gScreen.close = function(dir, closeCallback)
	{
        if (window.gTestHarness) {
            window.gTestHarness.controller.removeScreen(this);
        }

        if (dir == undefined) {
            dir = gScreen.dir;
        }

        // unregister from any notifications
        if (this.notificationTypes) {
            while (this.notificationTypes.length > 0) {
                this.unregisterForNotification(this.notificationTypes[0]);
            }
        }

        if (this.parent) {
            this.parent.child = null;
        }

		if (this != gRunScreenCloser) {
			stopAllAudio();
			clearTimeout(this.voStartTimer);
			clearTimeout(this.voFlashTimer);
			clearTimeout(this.voInactivityTimer);
			this.voCallback = null;
			this.voData = null;
		}

		slideOut(this, dir);
		grayOut(this);

		if (this != gRunScreenCloser) {
			gScreen = this.parent;
		}

		// call close callbacks
		if (this.closeCallback) {
			setTimeout(this.closeCallback, gTransitionTime);
		}
		if (closeCallback) {
			setTimeout(closeCallback, gTransitionTime);
		}
        if (this.onScreenClose) {
            this.onScreenClose();
        }

        var self = this;
        function onLastScreen()
        {
            if (self.parent) {
                $(self.parent.anchor).hide();
            }

            if (gScreen == gRoot) {
                if (gLastScreenCallback) {
                    var func = gLastScreenCallback;
                    gLastScreenCallback = null;
                    func();
                }
            }

        }
        setTimeout(onLastScreen, gTransitionTime);
	};

	// show the loading spinner, load the index.js
    if (gbScreenOneFile) {
        if (gScreen.path.indexOf("v2") == -1 && gScreen.path.indexOf("yourturn") == -1 ) {
            LoadScript("screens/" + gScreen.path + ".js"); // will call end()
        } else {
            LoadScript(gScreen.path + ".js"); // will call end()
        }
    } else {
    	LoadScript(gScreen.path + "/index.js"); // will call end()
    }

    if (window.gTestHarness) {
        window.gTestHarness.controller.addScreen(gScreen);
    }
}
/** Second function called in screen loading sequence after calls to
 *  the layout functions like background, orientation, image, button,
 *  label, etc. are complete. Set the orientation to horizontal if
 *  gbDidOrientation is true. Call SetVerical to send message to native
 *  app of the orientation. Load all the images in gScreen loadlist with
 *  runScreen2 as callback.
 *  @fn end
 *  @see gbDidOrientation
 *  @see SetVerical
 *  @see runScreen2
 */
// second function called in screen loading sequence
// (after calls to the layout functions like background, orientation, image, button, label, etc. are complete)
function end()
{
    //console.log("end: " +  gScreen.path);

	// now we can compute the list of images to load
	LoadImages(gScreen.loadlist, runScreen2);
}
/** Third function called in screen loading sequence.
 *  If gbScreenOneFile is true, call FPLaunchScreen2 with gSaveScreenFunc,
 *  otherwise load the logic.js script.
 *  @fn runScreen2
 *  @see gbScreenOneFile
 *  @see FPLaunchScreen2
 *  @see gSaveScreenFunc
 */
// third function called in screen loading sequence
// (the images are now loaded)
function runScreen2()
{
    //console.log("runScreen2: " +  gScreen.path);

	// load the logic.js
    if (gbScreenOneFile) {
        FPLaunchScreen2(gSaveScreenFunc);
        gSaveScreenFunc = null;
    } else {
        LoadScript(gScreen.path + "/logic.js"); // will call FPLaunchScreen()
    }
}
/** Fourth function called in screen loading sequence.
 *  If gbScreenOneFile is true, save screenFunc to gScreenFunc.
 *  Otherwise, call FPLaunchScreen2 to render screen.
 *  @fn FPLaunchScreen( Function screenFunc)
 *  @tparam Function screenFunc.
 *  @see gbScreenOneFile
 *  @see FPLaunchScreen2
 */
// fourth function called in screen loading sequence
// (logic.js is now loaded)
function FPLaunchScreen(screenFunc)
{
    if (gbScreenOneFile) {
        gSaveScreenFunc = screenFunc;
    } else {
        FPLaunchScreen2(screenFunc);
    }
}
/** Create divs, images, labels, buttons, fields, and backgroundDiv
 *  according to data save in gScreen. And the call screenFunc with
 *  gScreen and gScreen.args. Finally, if gScreenLaunchedCallback exists,
 *  call the callback.
 *  @fn FPLaunchScreen2( Function screenFunc)
 *  @tparam Function screenFunc.
 *  @see gScreen
 *  @see gScreenLaunchedCallback
 */
function FPLaunchScreen2(screenFunc)
{
    //console.log("FPLaunchScreen: " +  gScreen.path);

	// screen is done loading - clear flag
	gbScreenLoading = false;

	// actually create the layout elements
	if (gScreen.background) {
        if (gScreen.backgroundBTile) {
            gScreen.backgroundDiv = CreateDiv(gScreen, 0, 0, gFullWidth*gScaleX, gFullHeight*gScaleY);
            $(gScreen.backgroundDiv).css("background-image", "url('"+gScreen.background+"')");
            $(gScreen.backgroundDiv).css("background-repeat", "repeat");
            gScreen.appendChild(gScreen.backgroundDiv);
        } else {
            CreateImage({parent: gScreen, x: 0, y:0, w: gFullWidth*gScaleX, h: gFullHeight*gScaleY, src: gScreen.background});
        }
	}
    renderInOrder();

    function renderImage(i)
    {
        var img = gScreen.images[i];
        if (img.leftCap || img.rightCap) {
            gScreen.image[img.id] = CreatePatchImage(img);
        } else {
            gScreen.image[img.id] = CreateImage(img);
        }
    }

    function renderLabel(i)
    {
        var label = gScreen.labels[i];
        gScreen.label[label.id] = CreateLabel(label);
    }

    function renderField(i)
    {
        var field = gScreen.fields[i];
        gScreen.field[field.id] = CreateField(field);
    }

    function renderDiv(i)
    {
        var div = gScreen.divs[i];
        gScreen.div[div.id] = CreateDiv(div.parent, div.x, div.y, div.w, div.h, div.color);
    }

    function renderButton(i)
    {
        var button = gScreen.buttons[i];
        gScreen.button[button.id] = CreateButton(button);
    }
    function renderInOrder()
    {
        for (var i=0; i<gScreen.renderOrder.length; i++) {
            var elem = gScreen.renderOrder[i];
            var elem_index = elem.index-1;
            switch(elem.type)
            {
                case "div":
                    renderDiv(elem_index);
                    break;
                case "image":
                    renderImage(elem_index);
                    break;
                case "field":
                    renderField(elem_index);
                    break;
                case "button":
                    renderButton(elem_index);
                    break;
                case "label":
                    renderLabel(elem_index);
                    break;
                default:
                    console.log(" The element type is wrong");
                    break;
            }
        }
    }

   
	// transition the open
	if (gScreen.dir != "none") {
		slideIn(gScreen, gScreen.dir);
	}
    // ok, ready for screen to be visible now
    gScreen.style.display = "block";
	grayIn(gScreen);


	// if we had a screen to synchronize open/close transition, close it now
	if (gRunScreenCloser) {
		gRunScreenCloser.close(gRunScreenCloserDir);
		gRunScreenCloser = null;
		gRunScreenCloserDir = null;
	}

	// call the screen func so it can start running
	stopAllAudio();

    if (screenFunc !== undefined)
    {
	    screenFunc(gScreen, gScreen.args);
    }

    if (gScreenLaunchedCallback) {
        var callback = gScreenLaunchedCallback;
        gScreenLaunchedCallback = null;
        callback();
    }
}

//----------------------------------------------------------------------------------------------------------------------
/** A global variable that trace the parent of current object.
 *  @var gParent
 *  @type Object
 */
var gParent = null;
/** Set gParent in order to trace parent of current object.
 *  @fn parent( Object p)
 *  @tparam Object p the parent object.
 *  @see gParent
 */
function parent(p)
{
	gParent = p;
}

function applyScale(data)
{
    if (!data.bScaled) {
        if (data.x) data.x *= gScaleX;
        if (data.y) data.y *= gScaleY;
        if (data.ox) data.ox *= gScaleX;
        if (data.oy) data.oy *= gScaleY;
        if (data.w) data.w *= gScaleX;
        if (data.h) data.h *= gScaleY;
        if (data.size) data.size *= gScaleX;
    }
}

/** Remove duplicated key/value pairs in the input object.
 *  Specify the parent object of the input.
 *  If there is no parent in the input, assign gParent as its parent,
 *  if gParent is null, set gScreen as its parent.
 *  And then return the modified object.
 *  @fn Object cascade()
 *  @treturn Object return object with no duplicated key/value pairs.
 */
function cascade() // takes variable number of arguments
{
	var result = {id:""};
	var len = arguments.length;
	for (var i=0; i<len; i++) {
		var o = arguments[i];
		for (var j in o) {
			result[j] = o[j];
		}
	}
	return result;
}
/** Generate the background image url, push the url into
 *  gScreen loadlist and set gScreen background to this url.
 *  @fn background( String src)
 *  @tparam String src the path of background image.
 *  @see gScreen
 *  @see MakeImagePath
 */
function background(src, bTile)
{
	if (src == "default") {
		src += ".jpg";
	}
	var url = MakeImagePath("_backgrounds/" + src);
	gScreen.loadlist.push(url);
	gScreen.background = url;
    gScreen.backgroundBTile = bTile;
}

function logo(){
    image({id:"headerBg", src: appSettings.headerBg, x:0, y:0, w:gFullWidth, h:45});
    image({id:"logo", src: gImagePath+"logo", x:0, y: 7, w:30, h:31});
}
function centerLogo(p){
    $(p.image["logo"]).css({width:"auto", display: "block", "margin-left": "auto", "margin-right": "auto", right:0, bottom:0});
}

/** Get a new div object by calling CreateDiv(), and add the div to
 *  gScreen divs array if it is loading otherwise change the div in
 *  gScreen divs with the same id to the new one, and then return a new div element.
 *  Arguments are key/value pair to set div style properties.
 *  @note Examples:\n
 *  div({x: 960, y: 50, w: 384, h: 290, color: "#b0b600"});\n
 *  All properties are optional. It includes x, y, w, h, color, id, center, border, parent and etc.
 *  @fn Object div
 *  @treturn Object a new div Object
 *  @see CreateDiv
 *  @see gScreen
 */
function div() // takes variable number of arguments
{
	var data = cascade.apply(null, arguments);
    applyScale(data);

	if (!data.parent) {
        if (!gbScreenLoading) {
            alert("creating div with missing parent");
        }
        data.parent = gScreen;
		gScreen.divs.push(data);
        gScreen.renderOrder.push({type:"div", index:gScreen.divs.length});
	} else {
		var d = CreateDiv(data.parent, data.x, data.y, data.w, data.h, data.color);
		if (gScreen && gScreen.div) {
			gScreen.div[data.id] = d;
		}
		return d;
	}
}
/** Return the image path of the input data.
 *  If the data src contains “http” or “data:”,
 *  then just return data.src itself, otherwise
 *  get image path by calling MakeImagePath.
 *  @fn FixImagePath( Json data)
 *  @tparam Json data including the settings for the button element.
 *  @see MakeImagePath
 */
function FixImagePath(data)
{
	if (data && data.src && data.src.indexOf("http") == 0) {
		// leave it alone
	} else if (data && data.src && data.src.indexOf("data:") == 0) {
		// leave it alone
	} else if (data && data.src == undefined) {
		// leave it alone
	} else {
		if (gOnDevice) {
			data.src = MakeImagePath("images/" + data.src);
		} else {
			data.src = MakeImagePath("/site/img/" + data.src);
		}
	}
}
/** Get a new image object by calling CreateImage() and push the image to
 *  the gScreen loadlist as well as gScreen images, and then return a new div element of the image.
 *  Arguments are key/value pair to set as image properties.
 *  @note Examples:\n
 *  image({id: "name_container", src: "name_container", x: 271, y: 190});\n
 *  Must specify src for the image, but other properties are optional.
 *  It includes x, y, w, h, color, id, src, center, border, parent and etc.
 *  @fn Object image
 *  @treturn Object a new image div
 *  @see CreateImage
 *  @see gScreen
 */
function image() // takes variable number of arguments
{
	var data = cascade.apply(null, arguments);
	FixImagePath(data);
    applyScale(data);

    if (!data.parent) {
        if (!gbScreenLoading) {
            alert("creating image with missing parent");
        }
        data.parent = gScreen;
		gScreen.loadlist.push(data.src);
		gScreen.images.push(data);
        gScreen.renderOrder.push({type:"image", index:gScreen.images.length});
	} else {
		var result = CreateImage(data);
		if (gScreen && gScreen.image) {
			gScreen.image[data.id] = result;
		}
		return result;
	}
}
/** Get a new button object by calling CreateButton() and push the button to
 *  the gScreen loadlist as well as gScreen buttons, and then return a new div element of the button.
 *  Arguments are key/value pair to set as button properties. Must specify id for the button, but other properties are optional.
 *  @note Examples:\n
 *  button({id: "say_thanks", x: 170, y: 245, w: 140, h: 45, string: "Say Thanks!", size: 20, font: "bold font", src: 'red_over', rightCap: 20, leftCap: 20, shadow: "#000000", idleover:"same", idleoverRatio: 0.914});\n
 *  The properties includes x, y, w, h, color, id, src, center, border, parent and etc.\n
 *  \li Use {noImage: "true"} to create css button without images.
 *  For css buttons, background and border is must have.
 *  \li Use {idleover: "same"} to use the same image in idle and over states,
 *  otherwise two image path should be given, one for idle, the other for over state.
 *  @fn Object button
 *  @treturn Object a new button div
 *  @see CreateButton
 *  @see gScreen
 */
function button() // takes variable number of arguments
{
	var data = cascade.apply(null, arguments);
    applyScale(data);
    if (data.imageBtn)
    {
        applyScale(data.imageBtn);
    }
    if (data.noImage !== true)
    {
        if (gOnDevice && data.noImage !== true) {
            if (data.idleover == "same") {
                if (data.src.indexOf("http") == 0) {
                    data.idle = data.src;
                    data.over = data.src;
                } else {
                    data.idle = MakeImagePath("_buttons/" + data.src);
                    data.over = MakeImagePath("_buttons/" + data.src);
                }
            } else {
                if (data.idle == null) {
                    data.idle = MakeImagePath("_buttons/" + data.src + "_idle");
                }
                if (data.over == null) {
                    data.over = MakeImagePath("_buttons/" + data.src + "_over");
                }
            }
        } else {
            if (data.idleover == "same") {
                data.idle = MakeImagePath("/site/img/controls/" + data.src);
                data.over = MakeImagePath("/site/img/controls/" + data.src);
            } else {
                if (data.idle == null) {
                    data.idle = MakeImagePath("/site/img/controls/" + data.src + "_idle");
                }
                if (data.over == null) {
                    data.over = MakeImagePath("/site/img/controls/" + data.src + "_over");
                }
            }
        }
    }

    if (!data.parent) {
        data.parent = gScreen;
        if (!gbScreenLoading) {
            alert("creating button with missing parent");
        }
        if (data.noImage !== true)
        {
		    gScreen.loadlist.push(data.idle);
		    gScreen.loadlist.push(data.over);
        }
		gScreen.buttons.push(data);
        gScreen.renderOrder.push({type:"button", index:gScreen.buttons.length});
	} else {
		var result = CreateButton(data);
		if (gScreen && gScreen.button) {
			gScreen.button[data.id] = result;
		}
		return result;
	}
}
/** Get a new label object by calling CreateLabel() and push the button to
 *  the gScreen lables array, and then return the new label.
 *  Arguments are key/value pair to set as label properties.
 *  Must specify string for the label, but other properties are optional.
 *  @note Examples:\n
 *  label({parent: f, w: 384, h: 44, x: 22, y: 1, font: "bold font", string: "People", size: 33});\n
 *  The optional properties includes x, y, w, h, color, id, src, center, border, parent and etc.
 *  @fn Object label
 *  @treturn Object a new label div
 *  @see CreateLabel
 *  @see gScreen
 */
function label() // takes variable number of arguments
{
	var data = cascade.apply(null, arguments);
    applyScale(data);
    if (!data.parent) {
        if (!gbScreenLoading) {
            alert("creating label with missing parent");
        }
        data.parent = gScreen;
		gScreen.labels.push(data);
        gScreen.renderOrder.push({type:"label", index:gScreen.labels.length});
	} else {
		var result = CreateLabel(data);
		if (gScreen && gScreen.label) {
			gScreen.label[data.id] = result;
		}
		return result;
	}
}
/** Get a new input field div by calling CreateField() and push the field to
 *  the gScreen as well as cascade structure, and then return a new div element of the field.
 *  Arguments are key/value pair to set as field properties.
 *  @note Examples:\n
 *  field({parent: mode2, x: 50, y: 68, w: 261, h: 25, size: 15, id: "password", placeholder: "Password", password:true, maxLength: 16});\n
 *  The optional properties includes x, y, w, h, color, id, src, font, center, size, border, parent and etc.
 *  \li Use placeholder to set the default string, for example {placeholder: "Password"}.
 *  \li Use maxLength to put restriction on input length, for example  {maxLength: 16}.
 *  \li Use {multiline: "true"} to get a new textarea div instead of input div.
 *  \li Use {password: "true"} to get a new password input div.
 *  \li Use {field:"path_to_image"} to set new background image for the field.
 *  \li Use ox to set the x axis offset of text.
 *  @fn Object field
 *  @treturn Object a new field div
 *  @see CreateField
 *  @see gScreen
 */
function field() // takes variable number of arguments
{
	var data = cascade.apply(null, arguments);
    applyScale(data);
    if (!data.parent) {
        if (!gbScreenLoading) {
            alert("creating field with missing parent");
        }
        data.parent = gScreen;
		gScreen.fields.push(data);
        gScreen.renderOrder.push({type:"field", index:gScreen.fields.length});
	} else {
		var result = CreateField(data);
		if (gScreen) {
			gScreen.field[data.id] = result;
		}
		return result;
	}
}

/** Change the orientation of gScreen. Set gbDidOrientation to true.
 *  @fn orientation( String o)
 *  @tparam String o specify the orientation to be vertical or horizontal.
 *  @see gScreen
 *  @see gbDidOrientation
 */
//----------------------------------------------------------------------------------------------------------------------
function orientation(o)
{
}

/** Bind event to UI Object, tracking these events
 *  @fn orientation( String o)
 *  @tparam Object obj the obj trigger the event.
 *  @tparam String eventName the event.
 *  @tparam String metricName of the event
 *  @tparam String callback the function to call when receive the event from the obj.
 */
//----------------------------------------------------------------------------------------------------------------------
function bindEvent(obj, eventName, metricName, callback)
{
    // find parent screen of obj
    var screenName = "";
    var p = obj;
    while (p) {
        if (p.path) {
            screenName = p.path;
            break;
        }
        p = $(p).parent()[0];
    }

    function onEvent(){
        var eventName = FPGetEventToken(screenName, metricName);
        FPMetrics.metric(eventName, {});// do not pass null data to metric call
        var that = obj;
        if (FPGetAppValue("bShowMetric") && metricName==="open_hub"){
            //show metric after action
            callback();
            setTimeout(function(){
                showMetricName(that, eventName);
            }, 1000);
        }else if (FPGetAppValue("bShowMetric")){
            // show metric before action
            showMetricName(that, eventName);
            setTimeout(callback, 2500);
        }else{
            callback();
        }

    }

    $(obj).bind(eventName, onEvent);
}
// show eventName
function showMetricName(ele, eventName){
    var parent = ele.data?(ele.buttonParent || ele.data.parent): gScreen;
    var parentW = $(parent).width()/gScaleX || 320;
    // parent box is too small change to show MetricName on gScreen
    if (parentW < 200 || eventName.indexOf("hide_hub") !== -1  || eventName.indexOf("open_hub") !== -1){
        parent = gScreen;
        parentW = 320;
    }

    messageSlideDown(parent, eventName, parentW, 0, null);
}
// make obj center in X and Y in parent object
function setCenter(obj, maxHeight)
{
    $(obj).css("height", "100%");
    if (maxHeight){
        $(obj).css("max-height", maxHeight*gScaleX);
    }
    $(obj).css("bottom", 0);
    $(obj).css("right", 0);
    $(obj).css("margin", "auto");
}
// make obj center in X in parent object
function setXCenter(obj)
{
    $(obj).css("bottom", 0);
    $(obj).css("right", 0);
    $(obj).css("marginLeft", "auto");
    $(obj).css("marginRight", "auto");
}

// make obj center in X in parent object
function setChildrenXCenter(p)
{
    var children = $(p).children();
    for (var i = 0; i < children.length; i++){
        setXCenter(children[i]);
    }
}
// set all the children to be position relative
function setPositionRelative(p)
{
    var children = $(p).children();
    for (var i = 0; i < children.length; i++){
        $(children[i]).css("position", "relative");
    }
}
// set all the children in horizontal line
function setLineHorizontally(p, w)
{
    var children = $(p).children();
    for (var i = 0; i < children.length; i++){
        $(children[i]).css("left", w*i*gScaleX);
    }
}
// set button to be the center of the parent,
// if bFill is true, scale the button to fit the size of parent
// return the calculated position
function getPosForCenter(p, percentage, w, padding)
{
    var pos = {x:0, y:0, w:0, h:0};
    if (percentage){
        pos.w = parseInt($(p).css("width"))*percentage/gScaleX;
        pos.x = parseInt($(p).css("width"))*(1-percentage)/2/gScaleX;
    } else if (w){
        pos.x = (parseInt($(p).css("width"))-w)/2/gScaleX;
    }
    return pos;
}
// get three panels in for create layout
// if it landscape the top and bottom is in the right side
// if it portrait just return the middle, which is center in the screen
// in each panel, element flow in Y
// h1, h2, h3 is the estimated height for three parts
function getThreeGroupTemplate(p, h2_minW, h2_maxW, h1, h2, h3){
    var layout = {};
    if (FPIsLandscape()){
        layout.center = div({parent:p, x:0, y:0, h:h2});
        $(layout.center).css("width", "95%");
        setCenter(layout.center, h2 + 20);
        var right_w = parseInt($(layout.center).css("width"))/gScaleX-h2_maxW;
        var h = parseInt($(layout.center).css("height"))/gScaleX;
        var top = (h - h2)/2;
        var left = div({parent:layout.center, x:0, y:0, h:h, w:h2_maxW});
        layout.middlePanel = div({parent:left, x:0, y:top, h:h2, w:h2_maxW});
        layout.topPanel = div({parent:layout.center, x:h2_maxW, y:top, h:h1*2, w:right_w});
        layout.bottomPanel = div({parent:layout.center, x:h2_maxW, y:top+h2-h3*2, h:h3*2, w:right_w});
    }else{
        layout.center = div({parent:p, x:0, y:0, h:h1+h2+h3+20});
        $(layout.center).css("width", "95%");
        setXCenter(layout.center);
        var left =  (parseInt($(layout.center).css("width"))/gScaleX - h2_minW -10)/2;
        layout.topPanel = div({parent:layout.center, x:left, y:10, h:h1, w:h2_minW});
        layout.middlePanel = div({parent:layout.center, x:left, y:h1+10, h:h2, w:h2_minW});
        layout.bottomPanel = div({parent:layout.center, x:left, y: h1+h2+10, h:h3, w:h2_minW});
    }
    return layout;
}
// add background image to div
function addBackgroundImage($ele, imgUrl, repeat, size){
    var newImgUrl = "hub/"+gImagePath+imgUrl;
    var repeat = repeat?repeat:"repeat";
    var size = size?size:"auto auto";
    $ele.css({
        backgroundImage: "url('"+newImgUrl+"')",
        backgroundRepeat: repeat,
        backgroundSize: size

    });

}