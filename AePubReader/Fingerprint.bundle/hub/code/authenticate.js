//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

function FPSaveAuthenticateResponse(r)
{
    var old_account_id = FPGetAccountValue("account_id");
    if (old_account_id !== r.account_id) {
        // re-trigger game played event
        FPQueueRequest("GamePlayed", {command: "setPlayed", timezoneOffset: (new Date()).getTimezoneOffset()});
    }

    FPSetAccountValue("account_token", r.account_token);
    FPSetAccountValue("account_id", r.account_id);
    var person_id = FPGetPersonId();
    if (!person_id || (person_id.indexOf("guest") == 0)) {
        FPSetAccountValue("person_id", r.person_id);
    }
    FPSetAccountValue("facebook_id", r.facebook_id);
    FPSetAccountValue("email", r.email);
}

// handle Authenticate responses
function FPOnAuthenticateResponse(r, callback)
{
    if (r.bSuccess) {
        FPSaveAuthenticateResponse(r);
    }
    if (callback) {
        callback(r);
    }
}

function FPOnAuthenticateResponseWithServerUpdate(r, callback)
{
    function next(r)
    {
        function done()
        {
            if (callback) {
                callback(r);
            }
        }
        if (r.bSuccess) {
            FPServerUpdate(done);
        } else {
            done();
        }
    }
    FPOnAuthenticateResponse(r, next);
}

// this gets called by the FPWebRequest wrapper for "on demand" guest account creation
function FPGuestAuthenticate(callback)
{
    function onResult(r)
    {
        if (r.bSuccess) {
            // old key for guest data
            var guestPersonId = FPGetPersonId();
            var key = FPPersonKey();

            FPOnAuthenticateResponse(r);

            // move the guest state to be stored under assigned person_id
            var new_key = FPPersonKey();
            FPMoveState(key, new_key);

            function onMoved()
            {
                function onDone()
                {
                    callback(r);
                }
                FPServerUpdate(onDone);
            }
            FPStorage.renameDir("game/" + guestPersonId, "game/" + r.person_id, onMoved);
        }
    }

    var guest = FPGetAccountPeople()[0];
    var data = {
        command: "createGuest",
        name: guest.name,
        avatar: guest.avatar
    };
    FPWebRequest("Authenticate", data, onResult, callback, "");
}

// see if we can auto-login based on device_id
function FPAutoLogin(callback, bNoBlock)
{
    var data = {
        command: "autoLogin"
    };
    FPWebRequest("Authenticate", data, FPOnAuthenticateResponse, callback, bNoBlock ? null : "");
}

// log into account using email, password
function FPAccountLogin(email, password, callback, sending)
{
    var hashed_pwd = CryptoJS.SHA1(password).toString();
    var data = {
        command: "login",
        email: email,
        password: hashed_pwd
    };
    var sendingText = sending?sending:i18n("_LOGGING_IN");
    FPWebRequest("Authenticate", data, FPOnAuthenticateResponseWithServerUpdate, callback, sendingText);
}

// log into Astro account using Astro Username, password
function FPAstroLogin(username, password, callback, sending)
{
    var data = {
        command: "astroLogin",
        username: username,
        password: password
    };
    var sendingText = sending?sending:i18n("_LOGGING_IN");
    FPWebRequest("Authenticate", data, FPOnAuthenticateResponseWithServerUpdate, callback, sendingText);
}

// create account using email, password - facebook_token is optional
function FPCreateAccount(name, real_name, email, password, facebook_token, callback)
{
    var hashed_pwd = CryptoJS.SHA1(password).toString();
    var data = {
        command: "create",
        name: name,
        real_name: real_name,
        email: email,
        password: hashed_pwd,
        facebook_token: facebook_token
    };
    function onResult(r)
    {
        if (r.bSuccess) {
            FPHelper.fixsuRegistration();
        }
        callback(r);
    }
    FPWebRequest("Authenticate", data, FPOnAuthenticateResponseWithServerUpdate, onResult, i18n("_CREATE_ACCOUNT"));
}

// logout
function FPAccountLogout(callback)
{
    // if never got a real account token, can logout without talking to server
    if (!FPHaveAccountToken()) {
        FPClearAccount();
        callback();
        return;
    }

    var data = {
        command: "logout"
    };
    function next()
    {
        FPClearAccount();
        FPHelper.callAPIDelegate("onLoginComplete", []);
        callback();
    }
    FPWebRequest("Authenticate", data, FPOnAuthenticateResponse, next, i18n("_LOGGING_OUT"));
}

