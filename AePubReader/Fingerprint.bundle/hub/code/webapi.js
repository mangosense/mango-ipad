//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

// ---------------------------------------------------------------------------------------------------------------------
function FPRegisterPushNotificationToken(token)
{
    var data = {
        command: "register",
        token: token
    };

    FPQueueRequest("RegisterPushNotification", data);
}

function FPPersonLogin(person)
{
    FPSetAccountValue("person_id", person.person_id);

    FPHelper.callAPIDelegate("onLoginComplete", []);
}

function FPGuestLogin(name, avatar)
{
    FPClearAccount();

    var person = {
        person_id: "guest" + GUID(), // real person_id will get assigned at guest authentication time and we'll move data into place
        name: name,
        avatar: avatar
    };

    var people = [];
    people.push(person);

    FPSetAccountValue("people", people);
    FPSetAccountValue("person_id", person.person_id);
    FPSetAccountValue("account_token", "guest");

    FPHelper.callAPIDelegate("onLoginComplete", []);
}

function FPGetAccountSettings()
{
    var settings = FPGetAccountValue("settings");

    // Apple disallowed turning off parent gate, so be sure to override any previous user setting and force it to show
    if (settings) {
        settings.noParentGate = false;
    }
    return settings;
}

function FPSetAccountSettings(settings)
{
    function onResult(r)
    {
        if (r.bSuccess){
            FPSetAccountValue("settings", settings);
        }
    }
    var data = {
        account_token: FPGetAccountToken(),
        command: "setSettings",
        settings: settings
    };

    FPWebRequest("Account", data, onResult, null, i18n("_SENDING"));
}

function FPGetAccountPeople()
{
    return FPGetAccountValue("people");
}
function FPGetAccountActivePeople()
{
    var ActivePeople = [];
    var people = FPGetAccountPeople();
    if (people){
        for (var i = 0; i<people.length;i++){
            if(!people[i].bRemoved){
                ActivePeople.push(people[i]);
            }
        }
    }
    return ActivePeople;
}


function FPSetAccountPerson(person_id, name, real_name, avatar, bRemoved, bParent, callback)
//	person_id: undefined to create new person
{
    function onResult(r)
    {
        if (r.bSuccess) {
            FPSetAccountValue("people", r.people);
        }
        if (callback){
            callback(r);
        }
    }
    var data = {
        account_token: FPGetAccountToken(),
        command: "setPerson",
        person_id: person_id,
        name: name,
        real_name: real_name,
        avatar: avatar,
        bRemoved: bRemoved,
        bParent: bParent?true:false
    };

    FPWebRequest("Account", data, onResult, null, i18n("_SENDING"));
}
function FPSetParent(p, bParent, callback)
{
    var person = p?p:FPGetPerson();
    FPSetAccountPerson( person.person_id,
                        person.name,
                        person.real_name,
                        person.avatar,
                        person.bRemoved,
                        bParent, // only change bParent field
                        callback);
}
function FPAddNewPerson(name,  callback)
//	person_id: undefined to create new person
{
    FPSetAccountPerson("", name, "", "", false, false, callback); // only set name, the other are default values
}
function FPChangeRealName(person, real_name, callback)
{
    FPSetAccountPerson( person.person_id,
                        person.name,
                        real_name, // only change the real_name field
                        person.avatar,
                        person.bRemoved,
                        person.bParent,
                        callback);
}
function FPChangeAvatar(person, avatar, callback)
{
    FPSetAccountPerson( person.person_id,
                        person.name,
                        person.real_name,
                        avatar, // only change the avatar field
                        person.bRemoved,
                        person.bParent,
                        callback);
}
function FPChangeRemoveStatus(person, callback)
{
    FPSetAccountPerson( person.person_id,
                        person.name,
                        person.real_name,
                        person.avatar,
                        !person.bRemoved, // only set bRemoved to be the opposite
                        person.bParent,
                        callback);
}

// set the number of coins that go in coin machine
function FPSetCoinsIn(num, callback){
    function onResult(r){
        if (r && r.bSuccess){
            FPWebRequest("Account", {command: "getPeople"}, function(r) {
                if (r.bSuccess) {
                    FPSetAccountValue("people", r.people);
                }
            });
        }
    }
    var data = {
        account_token: FPGetAccountToken(),
        person_id: FPGetPersonId(),
        command: "setCoinsIn",
        coinsNum: num
    };
    FPWebRequest("Account", data, onResult, null, null); // TODO: consider offline/failed network request
}
// set the sum of coins that come out from coin machine
function FPSetCoinsOut(num, callback){
    function onResult(r){
        if (r && r.bSuccess){
            FPWebRequest("Account", {command: "getPeople"}, function(r) {
                if (r.bSuccess) {
                    FPSetAccountValue("people", r.people);
                }
            });
        }
    }
    var data = {
        account_token: FPGetAccountToken(),
        person_id: FPGetPersonId(),
        command: "setCoinsOut",
        coinsNum: num
    };
    FPWebRequest("Account", data, onResult, null, null); // TODO: consider offline/failed network request
}
// change email with new email address
function FPChangeEmail(email, callback)
{
    function onResult(r)
    {
        if (r.bSuccess) {
            FPSetAccountValue("email", r.email);
            callback(true);
        } else {
            callback(false);
        }
    }
    var data = {
        account_token: FPGetAccountToken(),
        command: "setEmail",
        email: email
    };
    FPWebRequest("Account", data, onResult, null, i18n("_SENDING"));
}
// change password with new password
function FPChangePassword(pwd, callback)
{
    var hashed_pwd = CryptoJS.SHA1(pwd).toString();
    function onResult(r)
    {
        if (callback){
            callback(r);
        }
    }
    var data = {
        account_token: FPGetAccountToken(),
        command: "setPassword",
        password: hashed_pwd
    };
    FPWebRequest("Account", data, onResult, null, i18n("_SENDING"));
}

// link facebook account to fingerprint account
function FPLinkFacebook(token, callback)
{
    function onResult(r)
    {
        FPSetAccountValue("facebook_id", r.facebook_id);
        if (callback){
            callback(r);
        }
    }
    var data = {
        account_token: FPGetAccountToken(),
        command: "setFacebook",
        facebook_token: token
    };
    FPWebRequest("Account", data, onResult, null, i18n("_SENDING"));
}

function FPLinkAccount(to, callback)
// to can be account_id, person_id, facebook_id or email
{
    function onResult(r)
    {
        FPSetAccountValue("friends", r.friends);
        if (callback){
            callback(r);
        }
    }
    var data = {
        account_token: FPGetAccountToken(),
        command: "link",
        to: to
    };
    FPWebRequest("Account", data, onResult, null, i18n("_SENDING"));
}
// action for get friend / friends data
// ==============
function FPGetFriends(callback)
{
    return FPGetAccountValue("friends");
}

function FPGetFriendAccountPeople(friend_id, callback)
{
    var data  = {
        command: "getPeople",
        friend_id:friend_id
    };

    FPWebRequest("Account", data, function(r) {
        if (r.bSuccess) {
            callback(r.people);
        }
    });
}



// message action
// ==============
function FPSendMessage(to, template_id, state, callback)
// to can be account_id, person_id, facebook_id or email
{
    function onResult(r)
    {
        callback(r);
    }

    var from = FPGetPersonId();
    if (!from || from === "undefined") {
        from = FPGetAccountId();
    }
    var command = state&&state.toName?"sendMessageToName":"sendMessage";
    var data = {
        account_token: FPGetAccountToken(),
        from: from,
        to: to,
        game_id: FPGetGameId(),
        template_id: template_id,
        state: state,
        command: command
    };
    if (callback) {
        // if callback provided, do synchronously
        FPWebRequest("Message", data, callback, null, i18n("_SENDING"));
    } else {
        FPQueueRequest("Message", data);
    }
}

function FPSetMessageStatus(message_id, status)
{
    var o = {
        command: "setMessageStatus",
        message_id: message_id,
        status: status
    };
    FPWebRequest("Message", o, null, null, null);
}

function FPGetAccountGamePlay()
{
    return FPGetAccountValue("gamesPlayed");
}

function FPQueueRequest(action, data)
{
    var o = {
        action: action,
        data: data
    };
    FPStorage.appendQueue("outgoing", o);
    FPWebView.eval("login", "FPPumpQueue()");
}

function FPServerUpdateBatchSend(name, value, callback, callbackObj)
{
    var last_value = FPGetAccountValue(name);
    var bBlocking = false;
    if (last_value != value) {
        bBlocking = true;
        FPSetAccountValue(name, value);
    }
    console.log("FPServerUpdateSend: blocking: " + bBlocking + ", name: " + name);

    function onComplete()
    {
        // TODO: what else should refresh?
        FPWebView.eval("hub", "refreshHubPanel()");

        // if blocking, call the callback after request completes
        if (bBlocking) {
            callback(callbackObj);
        }

    }

    FPWebBatchSend(onComplete, null, bBlocking ? "Updating" : null);

    // if non blocking, call the callback immediately
    if (!bBlocking) {
        callback(callbackObj);
    }
}

function FPServerUpdateAccountData(callback, callbackObj)
{
    FPWebBatchStart();

    FPWebRequest("GamePlayed", {command: "getPlayedByAccount"}, function(r) {
        if (r.bSuccess){
            FPSetAccountValue("gamesPlayed", r.gamesPlayed);
        }
    });

    FPWebRequest("Account", {command: "getSettings"}, function(r) {
        if (r.bSuccess) {
            FPSetAccountValue("settings", r.settings);
        }
    });

    FPWebRequest("Account", {command: "getPeople"}, function(r) {
        if (r.bSuccess) {
            FPSetAccountValue("people", r.people);
        }
    });

    FPWebRequest("Account", {command: "getFriends"}, function(r) {
        if (r.bSuccess) {
            FPSetAccountValue("friends", r.friends);
        }
    });

    FPServerUpdateBatchSend("last_update_account_id", FPGetAccountId(), callback, callbackObj);
}

function FPServerUpdatePersonData(callback, callbackObj)
{
    FPWebBatchStart();

    FPWebRequest("GameData", {command: "loadAll"}, function(r) {
        if (r.bSuccess) {
            var count = r.values.length;
            for (var i=0; i<count; i++) {
                FPSaveServerData(r.values[i]);
            }
        }
    });

    if (IsGameMultiplayer()) {
        FPWebView.eval("multiplayer", "requestGames()");
    }

    FPServerUpdateBatchSend("last_update_person_id", FPGetPersonId(), callback, callbackObj);
}

function FPServerUpdate(callback)
{
    // experimental: see if not requiring server response before showing UI dramtically speeds
    // things up in Fruit Ninja - especially from Australia.  If so, we will work on a proper optimization
    if (FPGetGameId() === "HBFPACADEMY") {
        console.log("FPServerUpdate: HBFPACADEMY");
        callback();
        return;
    }
    if (FPHaveAccountToken()) {
        FPServerUpdateAccountData(FPServerUpdate2, callback);
    } else {
        callback();
    }
}

function FPServerUpdate2(callback)
{
    FPServerUpdatePersonData(FPServerUpdate3, callback);
}

function FPServerUpdate3(callback)
{
    // tell hub panel to refresh
    FPWebView.eval("hub", "refreshHubPanel()");

    // tell game we have new info / new player, etc.
    FPHelper.callAPIDelegate("onLoginComplete", []);
    if (callback) {
        callback();
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// random name generator
var gGenerateNameBlockingMessage = i18n("_MAKING_NAME");

// generate name - for populating name field the first time
function FPGenerateName(callback)
{
    function onName(r) {
        callback(r.name);
    }
    FPWebRequest("GenerateName", {command: "generate"}, onName, null, gGenerateNameBlockingMessage);
}

// reject name - reject when going "back" from new name screen
function FPRejectName(name)
{
    FPWebRequest("GenerateName", {command: "reject", reject: name});
}

// reject and generate - batch request to server - use when pulling the level to generate another name
function FPRejectAndGenerateName(name, callback)
{
    FPWebBatchStart();
    FPRejectName(name);
    FPGenerateName(callback);
    FPWebBatchSend(null, null, gGenerateNameBlockingMessage);
}
