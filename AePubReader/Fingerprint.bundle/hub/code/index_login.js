//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

// ---------------------------------------------------------------------------------------------------------------------
gOnDevice = true;

var gbDuringLogin = false;
var gbContinueGuestRegistration = false;
var gbRegisterGuest = false;
var gbFirstResume = true;
var gbWasInDeferredRegistration = false;

// ---------------------------------------------------------------------------------------------------------------------
function start(root)
{
    // load layer specific scripts before continuing
    var scripts = [
        "lib/jquery.roundabout.min.js",
        "lib/strophe.js",
        "lib/notification.js",
        "modules/carousel.js",
        "modules/language_selector.js",
        "code/fpapi.js"
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
    gOriginalRoot = gRoot;

    metric("sdk_version", {version: 2.0});
    FPDoCallbackChain(FPLoadAccount, FPLoadPerson, FPResumeLoaded);
    FPPumpQueue();
}

function FPHandleUrl(url)
{
    var str = decodeURIComponent(url);
    var token = "//launch/";
    var i = str.indexOf(token);
    if (i != -1 ){
        var dataStr = str.substring(i+token.length);
        var person = JSON.parse(dataStr);
        var people = FPGetAccountPeople();
        for (var i=0; i<people.length; i++) {
            if (people[i].person_id === person.person_id) {
                FPPersonLogin(person);
                FPWebView.eval("multiplayer", "refreshGames()");
                FPWebView.eval("hub", "refreshHub()");
            }
        }
    }
}

function FPSuspend()
{
    // do we want to do anything on suspend?
}

function FPHandleNotification(data)
{
    try {
        if (data != null && data != undefined) {

            var o = JSON.parse(data);

            function doDispatch()
            {
                FPWebView.eval("hub", "doNotificationDispatch(" + JSON.stringify(o) + ")");
            }

            if (o.type == "multiplayer") {
                // type multiplayer get dispatched to multiplayer view
                FPWebView.eval("multiplayer", "onNotification(" + JSON.stringify(o.payload) + ")");
            } else if (o.type == "coins") {
                FPWebRequest("Account", {command: "getPeople"}, function(r) {
                    if (r.bSuccess) {
                        FPSetAccountValue("people", r.people);
                        doDispatch();
                    }
                });
            } else {
                doDispatch()
            }
        }
    } catch (e) {
        console.log("FPHandleNotification exception");
    }
}

function FPResume()
{
    // on resume, we want to release focus from any text fields
    var cmd = '$("*:focus").blur()';
    FPWebView.eval("login", cmd);
    FPWebView.eval("hub", cmd);
    FPWebView.eval("alert", cmd);
    FPWebView.eval("alert", "FPClearAlert()");

    FPDoCallbackChain(FPLoadApp, FPLoadAccount, FPLoadPerson, FPResumeLoaded);
}

function FPResumeLoaded()
{
    // on Astro, want to keep native Splash screen up until Login screen showing (after auto-login attempt)
    // or we are already logged in - be sure to avoid an "early return" in this function
    var bLoginReady = true;

    // on resume, close hub if it's open
    var now = (new Date()).getTime();
    FPWebView.eval("hub", "closeHubOnResume(" + (gbRegisterGuest || gbContinueGuestRegistration) + ", " + now + ")", null);

    // always check for updates on resume... if it doesn't respond, that's ok
    // this is a little bit aggressive, but we weren't checking enough, so for now it's better
    var bUseUpdater = FPGetAppValue("bUseUpdater");
    console.log("bUseUpdater: " + bUseUpdater);
    // don't request updates if entered guest reg mode - we want to have the guest authentication deferred
    if (bUseUpdater == "true" && !gbRegisterGuest && !gbContinueGuestRegistration) {
        FPWebRequest("GetUpdates", {command: "get", versions: JSON.parse(FPGetAppValue("versions"))}, function(r) {
            if (r.bNeedUpdate) {
                //console.log("found updates: " + JSON.stringify(r.updates));
                FPSetAppValue("updates", r.updates);
                // if we get here and the login layer is visible, apply the updates right away
                if (gbDuringLogin) {
                    FPSetAppValue("bHubButtonTriggeredUpdate", false);
                    FPWebView.eval("alert", "FPDoPendingUpdate()");
                }
            } else {
                console.log("No updates needed");
            }
        });
    }

    var token = FPGetGameId() + "_" + FPGetDeviceId();
    initNotifications(token, FPHandleNotification);

    function onLoginScreensComplete()
    {
        gbDuringLogin = false;
        gbRegisterGuest = false;
        gbContinueGuestRegistration = false;
        gLastScreenCallback = null;
        FPResumeUpdate(true);
    }

    if (gbDuringLogin) {
        // if in the middle of reg-flow - just stay on the reg screen
    } else if (!FPGetAccountToken()) {
        // generate a name when user named "Guest" back to online
        if (FPDeferredRegistrationMode()) {
            function onAutoLogin(r)
            {
                if (r.bSuccess) {
                    // auto-login successful
                } else {
                    // not - be an offline guest for now
                    FPGuestLogin("Guest", "avatar12");
                }
            }
            FPAutoLogin(onAutoLogin, true);
        } else {
            // go to reg screens
            gbDuringLogin = true;
            gLastScreenCallback = onLoginScreensComplete;

            FPClearLayer();
            FPWebView.show("self", true);
            FPSetEventScope1("REG");
            FPSetEventScope2("Landg");
            bLoginReady = false;
            runScreen(gRoot, getAppSetting().landing, "down");
        }
    } else if (gbRegisterGuest) {
        gbDuringLogin = true;
        gLastScreenCallback = onLoginScreensComplete;
        FPClearLayer();
        FPWebView.show("self", true);
        FPSetEventScope1("REG");
        FPSetEventScope2("Upreg");
        runScreen(gRoot, "are_you_parent", "none");
    } else if (gbContinueGuestRegistration) {
        gbDuringLogin = true;
        gLastScreenCallback = onLoginScreensComplete;
        FPClearLayer();
        FPWebView.show("self", true);
        FPSetEventScope1("REG");
        FPSetEventScope2("Kdoff");
        if (FPInDelayedRegistrationMode()) {
            runScreen(gRoot, "pick_avatar", "left", {flow:"DeferredGuest",bGoName: true, noBack:true});
        } else {
            runScreen(gRoot, "guest_name", "none", {avatar: FPGetPersonAvatar()});
        }
    } else {
        // logged in - update with server
        FPResumeUpdate(false);
    }

    // on Astro, want to keep native Splash screen up until Login screen showing (after auto-login attempt)
    // or we are already logged in - be sure to avoid an "early return" in this function
    if (bLoginReady) {
        FPHelper.platformResumed();
    }
}

function FPResumeUpdate(bNoPause)
{
    // queue played event
    FPQueueRequest("GamePlayed", {command: "setPlayed", timezoneOffset: (new Date()).getTimezoneOffset()});

    if (FPHaveAccountToken()) {

        FPWebBatchStart();

        // validate that we're still logged in
        FPWebRequest("Authenticate", {command: "validate"}, function(r) {
            if (r.bSuccess === undefined) {
                // not a valid reply - do nothing
            } else {
                if (r.bSuccess) {
                    // everything is fine - save updated account data (e.g. might've added a facebook_id)
                    FPSaveAuthenticateResponse(r);
                } else {
                    FPClearAccount();
                    setTimeout(FPResume, 1); // start-over if we got logged out
                }
            }
        });

        FPWebBatchSend(null, null, null);

    }

    // get updates from server - could trigger a logout
    function onUpdate()
    {
        if (!FPGetAccountToken()) {
            setTimeout(FPResume, 1); // start-over if we got logged out
        } else {
            FPWebView.eval("multiplayer", "refreshGames()");
            FPWebView.eval("hub", "refreshHub()");

            if (bNoPause) {
                FPClearLayer();
                FPCloseLoginLayer(); // close hub layer, but not multiplayer layer

                if (gbWasInDeferredRegistration && !FPInDelayedRegistrationMode()) {
                    gbWasInDeferredRegistration = false;
                    // open the hub, and make sure no updates trigger this time
                    FPSetAppValue("updates", null); // clear it
                    FPWebView.eval("hub", "hubButtonPressed()");
                }
            } else {
                // go to resume dialog - use FPWebView.eval so it's sure to be after a use of eval to set update data
                FPWebView.eval("login", "FPResumeDialog()");
            }
        }
    }
    FPServerUpdate(onUpdate)
}

function FPClearLayer()
{
    var s = gScreen;

    while (s != gRoot && s != undefined) {
        if (s.path == "player_profile") {
            // if on hub screen, allow it (must be at the bottom of the stack)
        } else {
            // otherwise, pop off screen
            if (s.gray) $(s.gray).remove();
            if (s.alternateGray) $(s.alternateGray).remove();
            if (s.shield) $(s.shield).remove();
            $(s).remove();
            s = s.parent;
        }
    }

    FPWebView.eval("hub", "showPause(false)");
}

function FPResumeDialog()
{
    // show resume dialog - either over the game or over the current player's hub, if a platform screen had been open
    FPClearLayer();

    function onPauseResult()
    {
        // FIXME
        // TODO:  TRIGGER ON LOGIN EVENT
        FPCloseLoginLayer(); // close hub layer, but not multiplayer layer
    }

    function showPause()
    {
        if (FPSuppressPauseScreen() || FPInDelayedRegistrationMode()) {
            FPWebView.eval("hub", "DoLarryO()"); // show cross-promo since not using pause screen
            onPauseResult();
        } else {
            FPWebView.show("self", true);
            FPSetEventScope1("PAU");
            FPSetEventScope2("Pause");
            gLastScreenCallback = onPauseResult;
            runScreen(gRoot, "game_pause", "down");
        }
    }

    if (IsGameMultiplayer()) {
        function onVisible(bVisible)
        {
            // TODO: reconsider
            // if it's the first resume, and we're multiplayer, assume list screen is open - works around race condition
            if (gbFirstResume) {
                gbFirstResume = false;
                bVisible = true;
            }

            if (!bVisible) {
                showPause();
            } else {
                onPauseResult();
            }
        }
        FPWebView.isVisible("multiplayer", onVisible);
    } else {
        showPause();
    }
}

function FPChangePlayerDialog()
{
    FPWebView.show("self", true);
    FPSetEventScope1("PAU");
    FPSetEventScope2("Chnge");
    function next()
    {
        FPCloseLoginLayer();
        FPWebView.eval("multiplayer", "refreshGames()");
    }
    function onPerson()
    {
        // change player dialog might have done a logout - only update server if still logged in
        if (FPGetAccountToken()) {
            FPServerUpdate(next);
        }
    }
    runScreen(gRoot, "change_player", "down", {newBg: true}, onPerson);
}

function FPCreateAccountDialog()
{
    gbRegisterGuest = true;
    FPResumeLoaded();
}

function FPDelayedOffline()
{
    function done()
    {
        FPWebView.show("self", false);
    }
    FPWebView.show("self", true);
    FPSetEventScope1("REG");
    FPSetEventScope2("Offln");
    runScreen(gRoot, "delayed_offline", "down", null, done);
}

function FPContinueGuestRegistration()
{
    gbWasInDeferredRegistration = FPInDelayedRegistrationMode();
    gbContinueGuestRegistration = true;
    FPResumeLoaded();
}

// gets called at startup or when we append to the queue
function FPPumpQueue()
{
    // don't pump if no real account_token yet
    if (!FPHaveAccountToken()) {
        setTimeout(FPPumpQueue, 1000);
        return;
    }

    // don't pump if offline
    if (FPIsOffline()) {
        return;
    }

    // TODO: handle a case where web request fails

    var func = "popQueue";
    var sdk_version = FPGetAppValue("sdk_version");
    if (sdk_version < 15) {
        func = "peekQueue";
    }

    function onQueue(o)
    {
        if (o && o.action) {
            console.log("QUEUED ACTION: " + o.action);
            function onComplete()
            {
                if (sdk_version < 15) {
                    FPStorage.popQueue("outgoing");
                }
                setTimeout(FPPumpQueue, 1);
            }
            FPWebRequest(o.action, o.data, onComplete);
        }
    }
    FPStorage[func]("outgoing", onQueue);
}

function FPCloseLoginLayer()
{
    metricScreen("GAME");
    FPWebView.show("login", false);
}

