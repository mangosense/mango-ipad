//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

gOnDevice = true;

var gbPerformingUpdate = false;
var gbClearedLarryO = false;

function GetOpenAlert()
{
    var result = null;
    var bOpen = (gScreen && gScreen != gRoot);
    if (bOpen) {
        result = gScreen.path;
    }
    console.log("GetOpenAlert: " + result);
    return result;
}

function start(root)
{
    FPSetEventScope1("ALT");
    FPSetEventScope2("Alert");

    // load layer specific scripts before continuing
    var scripts = [
        "modules/calculator.js"
    ];

    function next()
    {
        console.log("Finished loading scripts");
    }
    LoadScripts(scripts, next);
}

function FPDoPendingUpdate()
{
    if (FPDeferredRegistrationMode()) {
        if (!FPGetAccountToken()) {
            // skip updates if in Sid and no account token yet
            return;
        }
    }

    // skip updates before deferred reg in Sid
    if (FPInDelayedRegistrationMode()) {
        return;
    }

    if (FPIsOffline()) {
        // skip
    } else {
        var updates = FPGetAppValue("updates");
        if (updates) {
            FPSetAppValue("updates", null); // clear it
            FPDoUpdate(updates);
        }
    }
}

function FPDoUpdate(updates)
{
    if (gbPerformingUpdate) {
        return; // never do 2 updates at once
    }
    gbPerformingUpdate = true;
    FPWebView.show("self", true);
    runScreen(gRoot, "updater", "down", updates);
}

// NOTE: this function signature cannot change - it's referred to by iOS SDK Release 32 directly from native code
function ShowParentGate(args)
{
    ShowAlertCore(FPIsSid() ? "parent_gate_sid" : "parent_gate", "down", args);
}

function ShowLarryO(bFloatMode)
{
    console.log("ShowLarryO");

    if (gbClearedLarryO) {
        console.log("ShowLarryO skipping");
        // resumed with previous larryo showing, so allow it to clear and not re-open until next resume
        gbClearedLarryO = false;
        return;
    }

    ShowAlertCore("larryo", FPIsLandscape() ? "right":"down", bFloatMode);
}

function ShowAlert(args)
{
    args.ok = i18n("_OK");
    ShowAlertCore("alert_screen", "down", args);
}

function ShowAlertOnGuestLogout(args)
{
    ShowAlertCore("alert_guestLogout", "down", args);
}

function FPClearLarryO()
{
    console.log("FPClearLarryO");
    var openAlert = GetOpenAlert();
    if (openAlert == "larryo") {
        FPClearAlert();
    }
    gbClearedLarryO = false; // if explicitly cleared it, don't count that
}

function FPClearAlert()
{
    console.log("FPClearAlert");
    var openAlert = GetOpenAlert();
    if (openAlert) {
        console.log("Clearing alert: " + openAlert);
        gScreen.close();
        FPWebView.show("self", false);
    }
    if (openAlert == "larryo") {
        gbClearedLarryO = true; // note that we resumed with larryo still visible, so we won't show it again this time
    }
}

function ShowAlertCore(path, dir, args)
{
    // don't show alerts if layer being used for an update
    if (gbPerformingUpdate) {
        console.log("ShowAlertCore: update in progress")
        return;
    }

    // don't allow 2 alerts at once
    if (GetOpenAlert()) {
        console.log("ShowAlertCore: blocking double alert")
        return;
    }

    // handle callback, if any
    if (gCaller && args && args.callback) {
        var caller = gCaller;
        var callback = args.callback;
        args.callback = onDone;
        function onDone(result)
        {
            DoEvalCallback(caller, callback, result);
        }
    }

    // show the alert layer
    FPWebView.show("self", true);

    // hide the alert layer after the close animation completes and another alert hasn't been opened in the interim
    function onClose()
    {
        function next()
        {
            if (!GetOpenAlert()) {
                FPWebView.show("self", false);
            }
        }
        setTimeout(next, gTransitionTime);
    }

    // open the requested alert screen
    runScreen(gRoot, path, dir, args, onClose);
}
