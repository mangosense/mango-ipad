//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

// ---------------------------------------------------------------------------------------------------------------------
function FPStateVersion()
{
    if (window.FPNative) {
        return "";
    } else {
        return "FPSV1";
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// for state that we want to store natively, but have available *synchronously* from JavaScript
// (on iOS we can't call JS->native synchronously (sigh).  On Android, we can, but we want it to be the same.
// we LOAD it at start-up
// we modify only from JavaScript
//      - saves to localStorage AND native
// we read only from localStorage

// ---------------------------------------------------------------------------------------------------------------------
function FPLoadState(scopeKey, callback)
{
    function onData(d)
    {
        localStorage[scopeKey] = JSON.stringify(d);
        callback();
    }
    FPStorage.getValue(scopeKey, onData);
}

function FPClearState(scopeKey)
{
    var s = "";
    localStorage[scopeKey] = s;
    FPStorage.setValue(scopeKey, s);
}

function FPMoveState(scopeKey, newScopeKey)
{
    var s = localStorage[scopeKey];
    var o = "";
    if (s) {
        try {
            o = JSON.parse(s);
        } catch (e) {

        }
    }

    localStorage[newScopeKey] = s;
    localStorage[scopeKey] = "";
    FPStorage.setValue(newScopeKey, o);
    FPStorage.setValue(scopeKey, "");
}

function FPGetStateValue(scopeKey, key)
{
    var s = localStorage[scopeKey];
    if (!s || s === "undefined" || s === "null") {
        s = "{}";
    }

    var o = JSON.parse(s);
    return o[key];
}

function FPSetStateValue(scopeKey, key, value)
{
    var s = localStorage[scopeKey];
    if (!s || s === "undefined" || s === "null" || s === "" || s === "\"\"") {
        s = "{}";
    }
    var o = JSON.parse(s);
    o[key] = value;
    s = JSON.stringify(o);
    localStorage[scopeKey] = s;
    FPStorage.setValue(scopeKey, o);
}

// ---------------------------------------------------------------------------------------------------------------------
function FPAppKey()
{
    return FPStateVersion() + "app";
}

function FPLoadApp(callback)
{
    FPLoadState(FPAppKey(), callback);
}

function FPGetAppValue(key)
{
    return FPGetStateValue(FPAppKey(), key);
}

function FPSetAppValue(key, value)
{
    FPSetStateValue(FPAppKey(), key, value);
}

// ---------------------------------------------------------------------------------------------------------------------
function FPAccountKey()
{
    return FPStateVersion() + "account";
}

function FPLoadAccount(callback)
{
    FPLoadState(FPAccountKey(), callback);
}

function FPClearAccount()
{
    FPClearState(FPAccountKey());
}

function FPGetAccountValue(key)
{
    return FPGetStateValue(FPAccountKey(), key);
}

function FPSetAccountValue(key, value)
{
    FPSetStateValue(FPAccountKey(), key, value);
}

// ---------------------------------------------------------------------------------------------------------------------
function FPPersonKey()
{
    var person_id = FPGetAccountValue("person_id");
    return FPStateVersion() + "person/" + person_id;
}

function FPLoadPerson(callback)
{
    FPLoadState(FPPersonKey(), callback);
}

function FPGetPersonValue(key)
{
    return FPGetStateValue(FPPersonKey(), key);
}

function FPSetPersonValue(key, value)
{
    FPSetStateValue(FPPersonKey(), key, value);
}

// ---------------------------------------------------------------------------------------------------------------------
// individual accessors

function FPGetAccountToken()
{
    return FPGetAccountValue("account_token");
}

function FPHaveAccountToken()
{
    var account_token = FPGetAccountToken();
    return (account_token && account_token != "guest");
}

function FPGetAccountId()
{
    return FPGetAccountValue("account_id");
}

function FPGetPersonId()
{
    return FPGetAccountValue("person_id");
}

function FPGetPerson()
{
    // TODO: consider more efficient solution
    var person_id = FPGetPersonId();
    var people = FPGetAccountActivePeople();
    if (people) {
        var count = people.length;
        for (var i=0; i<count; i++) {
            var person = people[i];
            if (person.person_id == person_id) {
                return person;
            }
        }
    }
    return {};
}

function FPGetPersonCoins()
{
    var coins = FPGetPerson().coins;
    return coins ? coins : 0;
}
function FPGetPersonCoinsOut()
{
    var coins = FPGetPerson().coins2;
    return coins ? coins : 0;
}

function FPGetPersonName()
{
    var name = FPGetPerson().name;
    return name ? name : "";
}

function FPGetPersonRealName()
{
    var name = FPGetPerson().real_name;
    return name ? name : "";
}

function FPGetPersonAvatar()
{
    var avatar = FPGetPerson().avatar;
    return avatar ? avatar : "";
}

function FPGetGameId()
{
    return FPGetAppValue("game_id");
}
function FPGetGamesAssets()
{
    return FPGetStateValue(FPAccountKey(), "game_assets");
}

function FPSetGamesAssets(value)
{
    // to reduce loading, use account key,
    // since one account can install multi apps
    FPSetStateValue(FPAccountKey(),"game_assets", value);
}
function FPGetDeviceId()
{
    return FPGetAppValue("device_id");
}

function FPGetOldDeviceId()
{
    return FPGetAppValue("old_device_id");
}

function FPGetVendorId()
{
    return FPGetAppValue("vendor_id");
}

function FPIsLandscape()
{
    if (window.gTestHarness) {
        return gTestHarness.bLandscape;
    }

    return (FPGetAppValue("bLandscape") == "true");
}

function FPPartnerMode()
{
    return (FPGetAppValue("bPartnerMode") == "true");
}

function FPSuppressPauseScreen()
{
    return (FPGetAppValue("bSuppressPauseScreen") == "true");
}

function FPShowParentGateTimer()
{
    return (FPGetAppValue("bShowParentGateTimer") == "true");
}

function FPIsParent()
{
    return FPIsParentByPersonData(FPGetPerson());
}

function FPIsParentByPersonData(person)
{
    return (person.length>0&& FPGetAccountId() === person.person_id) || person.bParent;
}
function FPIsParentInCurrAcc(person_id){
    // check if opponent is parent of this family
    var people = FPGetAccountActivePeople();
    var i = people.length;
    var bParent = false;
    var opponentId = person_id;
    while(i--){
        if (opponentId === people[i].person_id){
            bParent = FPIsParentByPersonData(people[i])?true:false;
            break;
        }
    }
    return bParent;
}
function FPIsGuest()
{
    return (FPGetAccountValue("email") === "" || FPGetAccountValue("email") === undefined);
}
