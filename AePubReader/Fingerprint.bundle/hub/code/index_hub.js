//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

gOnDevice = true;

var gbShowCoinopia = false;

var HUB_HIDDEN = 1; // totally hidden
var HUB_BUTTON = 2; // mini tab at bottom
var HUB_OPENED = 3; // fully open

var gHubState = 0; // need to take action on first update

var gbWebViewVisible = {};
var gbPauseScreenVisible = false;
var gbChallengeScreenVisible = false;

var gbWiderScreen = gFullWidth>=480; // hub button text will fit to the right of the icons

var gExtraSize = FPIsLandscape() ?
    // landscape
    ((gbWiderScreen ? 70 : 124)*gScaleX)
    : // portrait
    (72*gScaleY);

var gHubHeight = FPIsLandscape()?gFullHeight:(gFullHeight - 105);

var gHubScreen;

// in portrait hub, because the native web view is actually pushed up off the top of the screen, the
// auto-scroll of a text field above the keyboard is mis-calibrated and ends up pushing the field up too high
// by the amount we're off the of the screen, so we need to push ourselves back down when focused.
// turns out we can't do this by shifting the div, as iOS moves it again on the next keystroke...
// so we need to actually move the webivew.  for some reason, a repaint problem occurs if we reposition the
// webview at the same time that a screen transition occurs (like back button), so we delay buttons if
// they are pressed when the workaround is active - give the frame set to return to the right positio - and then
// trigger the button handler

var gbHubFieldWorkaroundActive = false;

function DoHubFieldWorkaroundFocus()
{
    var model = FPGetAppValue("model"); // only want to do this on device, not in web environment
    if (!FPIsLandscape() && model) {
        FPWebView.setFrame("self", 0, 0, gWindowWidth, gWindowHeight + gExtraSize, false);
        gbHubFieldWorkaroundActive = true;
    }
}

function DoHubFieldWorkaroundBlur()
{
    var model = FPGetAppValue("model"); // only want to do this on device, not in web environment
    if (!FPIsLandscape() && model) {
        FPWebView.setFrame("self", 0, -gExtraSize, gWindowWidth, gWindowHeight + gExtraSize, false);
        gbHubFieldWorkaroundActive = false;
    }
}

function DoHubFieldWorkaroundButtonHandler(handler, arg)
{
    function next()
    {
        handler(arg);
    }
    if (gbHubFieldWorkaroundActive) {
        $("*:focus").blur();
        setTimeout(next, 500);
    } else {
        next();
    }
}

function start(root)
{
    FPSetEventScope1("HUB");

    // load layer specific scripts before continuing
    var scripts = [
        "modules/child_overview.js",
        "modules/list_items.js",
        "modules/game_list.js",
        "modules/profile.js",
        "modules/carousel.js",
        "modules/calculator.js",
        "modules/language_selector.js",
        "yourturn/shared/util.js"  // TODO: some functions seem misplaced if this is needed by the hub layer
    ];

    // also load game specific hub customization script
    scripts.push(FPCustomAssetsPath("code.js"));
    scripts.push(FPCustomAssetsImageInfoPath());

    function next()
    {
        start2(root);
    }
    LoadScripts(scripts, next);
}

function start2(root)
{
    FPWebView.registerForShowNotifications(); // so we find out when web views are shown/hidden

    // get current state
    var layers = ["login", "multiplayer"];
    var n = 0;
    function checkVisible(layer)
    {
        function onVisible(bVisible)
        {
            gbWebViewVisible[layer] = bVisible;
            n++;
            if (n == layers.length) {
                gbWebViewVisible.bReady = true;
                start3(root);
            }
        }
        FPWebView.isVisible(layer, onVisible);

    }
    for (var i=0; i<layers.length; i++) {
        checkVisible(layers[i]);
    }
}

function start3(root)
{
    runScreen(root,  "hub", "none");
    
    gHubScreen = gScreen;

    // the hub screen needs to be extra tall
    if (FPIsLandscape())
    {
        $(root).css("width", gWindowWidth+gExtraSize);
        $(gScreen).css("width", gWindowWidth+gExtraSize);

    }
    else
    {
        $(root).css("height", gWindowHeight+gExtraSize);
        $(gScreen).css("height", gWindowHeight+gExtraSize);

    }

    if (FPGetAppValue("webtest")) {
        updateHub(HUB_BUTTON, false);
        function next()
        {
            if (FPGetAccountToken()) {
                hubButtonPressed();
            }
        }
        setTimeout(next, 100);
    } else {
         updateHub(FPGetAppValue("bShowHubButton") ? HUB_BUTTON : HUB_HIDDEN, false); // set frame before showing so that native visible logic doesn't count it as on then off
    }

    // open hub after an updater refresh, since update was triggered by user opening the hub
    var bHubButtonTriggeredUpdate = FPGetAppValue("bHubButtonTriggeredUpdate");
    if (bHubButtonTriggeredUpdate) {
        FPSetAppValue("bHubButtonTriggeredUpdate", false); // clear the flag
        var updaterRefreshTime = FPGetAppValue("updaterRefreshTime");
        var now = (new Date()).getTime();
        if (now - updaterRefreshTime < 5000) {
            function next()
            {
                refreshHubPanel();
                updateHub(HUB_OPENED, true);
            }
            setTimeout(next, 250);
        }
    }

    FPWebView.show("self", true); // always visible - but might be translated off the bottom of the screen
}

function doNotificationDispatch(o)
{
    var a = gNotificationRegistry[o.type];
    if (a) {
        var count = a.length;
        for (var i=0; i<count; i++) {
            var s = a[i];
            if (s["onNotification_" + o.type]) {
                s["onNotification_" + o.type](o.payload);
            }
        }
   }
}

// called because of registerForShowNotifications
function onShowNotification(target, bShow)
{
    gbWebViewVisible[target] = bShow;
    if (gbWebViewVisible.bReady) {
        refreshHub();
    }
}

// called by game_pause screen - special case where we DO show the hub when the login layer is showing
function showPause(bShow)
{
    gbPauseScreenVisible = bShow;
    refreshHub();
}

function showChallenge(bShow)
{
    gbChallengeScreenVisible = bShow;
    refreshHub();
}

// from native API
function openHub(mode, data)
{
    // only honor this if game is showing
    if (!gbWebViewVisible["login"] && !gbWebViewVisible["multiplayer"]) {
        if (mode == "astro_upsell") {
            var appSettings = getAppSetting();
            DoAlert(appSettings.partnerName, i18n("_PLEASE_SUBSCRIBE_TO"));
        } else if (mode == "pause") {
            FPWebView.eval("login", "FPResumeDialog()");
        } else {
            updateHub(HUB_OPENED, true);
        }
    }
}

// from native API
function showHubButton(bShow)
{
    FPSetAppValue("bShowHubButton", bShow)
    refreshHub();
}

var gLastHubButtonPressTime = 0;

function closeHubOnResume(bAnimated, t)
{
    // on Android, I've seen the close on resume event come in AFTER I've had time to press the hub button to
    // open the hub (that wasn't previously open)... and then it gets closed...
    // so if the button was pressed after the close hub on resume request, then we ignore the close hub request
    if (gLastHubButtonPressTime > t) {
        console.log("closeHubOnResume: skipped because hub button was pressed.")
    } else {
        closeHub(bAnimated);
    }
}

function closeHub(bAnimated)
{
    if (gHubState == HUB_OPENED) {
        updateHub(HUB_BUTTON, bAnimated);
    }
}

function DoPromoteGame(appId, bFloatMode)
{
    if (bFloatMode) {
        updateHub(HUB_OPENED, true);
    } else {
        hubButtonPressed();
    }
    gHubScreen.doUpdateHubPanel("hub_games_main", appId, true);
}

// from hub button
function hubButtonPressed()
{
    gLastHubButtonPressTime = (new Date()).getTime();

    if (FPInDelayedRegistrationMode()) {
        if (FPIsOffline()) {
            FPWebView.eval("login", "FPDelayedOffline()", null);
        } else {
            function next()
            {
                // allow for a slow auto-login to have succeeded in the interim
                if (FPInDelayedRegistrationMode()) {
                    FPWebView.eval("login", "FPContinueGuestRegistration()", null);
                } else {
                    hubButtonPressed();
                }
            }
            if (FPIsSid()){
                DoParentGate(next);
            }else{
                next();
            }
        }
        return;
    }

    if (gHubState == HUB_BUTTON) {
        refreshHubPanel();
        updateHub(HUB_OPENED, true);
    } else {
        updateHub(HUB_BUTTON, true);
    }
}

function refreshHubPanel()
{
    if (gHubScreen) {
        if (gHubScreen.refresh) {
            gHubScreen.refresh();
            $(gHubScreen).trigger("updateHubBtNoti");
        }
    }
}

var gbLarryOFirstLaunch = true;

function DoLarryO()
{
    // don't count first launch as a resume for the LarryO
    if (gbLarryOFirstLaunch) {
        gbLarryOFirstLaunch = false;
        return;
    }

    // no LarryO on Android for now, as we only have 1 game
    if (gbAndroid) {
        return;
    }

    if (!FPIsOffline()) {

        var bShowLarryO = true;
        var bHubButtonShowing = (gHubState == HUB_BUTTON);
        var bFloatMode = !bHubButtonShowing;

        var larryoMode = GetLarryOMode();
        if (larryoMode === "off") {
            // skip
            bShowLarryO = false;
        } else if (larryoMode === "nofloat") {
            if (bFloatMode) {
                bShowLarryO = false;
            }
        }

        if (bShowLarryO) {
            FPWebView.eval("alert","ShowLarryO(" + bFloatMode + ")");
        }
    }
}

// refresh the state when web view visibilities or game_pause screen visibility changes
function refreshHub()
{
    updateHub(gHubState, true);
}

// do the update
function updateHub(state, bAnimate)
{
    console.log("updateHub: " + state + ", " + bAnimate);
    console.log("updateHub Multiplayer Visible: " + gbWebViewVisible["multiplayer"]);
    console.log("updateHub Login Visible: " + gbWebViewVisible["login"]);
    console.log("updateHub gbPauseScreenVisible: " + gbPauseScreenVisible);
    console.log("updateHub gbChallengeScreenVisible: " + gbChallengeScreenVisible);
    console.log("updateHub game bShowHubButton: " + FPGetAppValue("bShowHubButton"));

    if (state != HUB_OPENED) {
        var bShowHubButton = false;
        if (gbWebViewVisible["login"]) {
            bShowHubButton = gbPauseScreenVisible;
        } else if (gbWebViewVisible["multiplayer"]) {
            bShowHubButton = !gbChallengeScreenVisible;
        } else {
            bShowHubButton = FPGetAppValue("bShowHubButton");
        }
        state = bShowHubButton ? HUB_BUTTON : HUB_HIDDEN;
    }

    console.log("updateHub selected: " + state + ", " + bAnimate);

    if (state != gHubState) {

        if (state != HUB_BUTTON) {
            FPWebView.eval("alert", "FPClearLarryO()");
        }

        gHubState = state;
        var offset = 0;
        if (FPIsLandscape())
        {
            if (state == HUB_HIDDEN) {
                offset = -(gWindowWidth + gExtraSize);
            } else if (state == HUB_BUTTON) {
                offset = -(gWindowWidth + gExtraSize) + 54*gScaleX;
            }
        } else {
            offset = -gExtraSize;
            if (state == HUB_HIDDEN) {
                offset = gWindowHeight;
            } else if (state == HUB_BUTTON) {
                offset = gWindowHeight - 54*gScaleY;
            }
        }

        offset = parseInt(""+offset); // force to Integer so type is right and native call doesn't fail
        // rounding up for android
        var intExtraSize = Math.ceil(parseFloat(""+gExtraSize)); // force to Integer so type is right and native call doesn't fail

        if (FPIsLandscape())
        {
            FPWebView.setFrame("self", offset, 0, gWindowWidth + intExtraSize, gWindowHeight, bAnimate);
        } else {
            FPWebView.setFrame("self", 0, offset, gWindowWidth, gWindowHeight + intExtraSize, bAnimate);
        }

        if (gHubScreen && gHubScreen["onUpdateHub"]) {
            gHubScreen.onUpdateHub(gHubState);
        }

        // when opening hub, apply any pending updates
        if (state == HUB_OPENED) {
            if (FPGetAppValue("updates")) {
                FPSetAppValue("bHubButtonTriggeredUpdate", true);
                FPWebView.eval("alert", "FPDoPendingUpdate()");
            } else if (!FPHaveAccountToken()) {
                // otherwise, if we have no account token, continue guest reg if we can ping the server
                function onPing(r)
                {
                    if (r.ping) {
                        FPWebView.eval("login", "FPContinueGuestRegistration()", null);
                    }
                }
                FPWebRequest("Ping", {}, onPing);
            }
        }
    }
}
