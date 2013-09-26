//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

// ---------------------------------------------------------------------------------------------------------------------
// wrapper for FPRequest / FPBatchRequest, FPBatchSend
//
// adds current device_id, account_token, person_id, game_id, date (even if null) to all requests
//
// will process a *** pending guest authentication *** before processing requests, unless the first 1 is an Authenticate
// action (and will include that updated account info in the requests in all cases)
//
// blockingMessage - if null, doesn't use blocking screen, otherwise is the text to use on blocking string - can be ""
//
// This makes it easy to implement "guest login is offline and gets completed the first time we actually need the
// server.

function FPWebRequest(action, data, callback, callbackObj, blockingMessage)
{
    if (gWebBatch) {
        FPWebAddToBatch(gWebBatch, action, data, callback, callbackObj);
    } else {
        var webBatch = [];
        FPWebAddToBatch(webBatch, action, data, callback, callbackObj);
        FPWebSendBatch(webBatch, null, null, blockingMessage);
    }
}

function FPWebBatchStart()
{
    gWebBatch = [];
}

function FPWebBatchSend(callback, callbackObj, blockingMessage)
{
    var webBatch = gWebBatch;
    gWebBatch = null;
    FPWebSendBatch(webBatch, callback, callbackObj, blockingMessage);
}

// ---------------------------------------------------------------------------------------------------------------------
// internal
var gWebBatch = null;

function FPWebAddToBatch(webBatch, action, data, callback, callbackObj)
{
    webBatch.push({
        action: action,
        data: data,
        callback: callback,
        callbackObj: callbackObj
    });
}

function FPWebSendBatch(webBatch, callback, callbackObj, blockingMessage)
{
    if (blockingMessage != null) {
        FPHelper.showSending(true, blockingMessage);
    }

    function onReady(timeout)
    {
        function onComplete()
        {
            if (blockingMessage != null) {
                FPHelper.showSending(false, null);
            }
            if (callback) {
                callback(callbackObj);
            }
        }

        // add info to each request and send
        var count = webBatch.length;
        for (var i=0; i<count; i++) {
            var o = webBatch[i];
            if (o.data) {
                // if data in queue as guest, modify to be obtained server identity (will come from commonData)
                if (o.data.account_token == "guest") {
                    delete o.data.account_token;
                }
                if (o.data.person_id && (o.data.person_id.indexOf("guest") == 0)) {
                    delete o.data.person_id;
                }
            }
            FPBatchRequest(o.action, o.data, o.callback, o.callbackObj);
        }

        var commonData = {
            device_id: FPGetDeviceId(),
            old_device_id: FPGetOldDeviceId(),
            vendor_id: FPGetVendorId(),
            account_token: FPGetAccountToken(),
            person_id: FPGetPersonId(),
            game_id: FPGetGameId(),
            language: FPGetAppValue("language"),
            partner: FPGetAppValue("partner"),
            date: (new Date()).getTime()
        }
        FPBatchSend(commonData, onComplete, null, timeout);
    }

     // if we have a guest account_token, force the request to fail unless we've explicitly requested an
    // override - e.g. for name generator and guest authentication
    var account_token = FPGetAccountToken();
    var timeout = 0;
    if (account_token == "guest") {
        var bGuestAuthenticate = (webBatch[0].action == "Authenticate" && webBatch[0].data.command == "createGuest");
        var bGenerateName = (webBatch[0].action == "GenerateName");
        var bPing = (webBatch[0].action == "Ping");
        var bLarryO = (webBatch[0].action == "LarryO");
        var bGetUpdates = (webBatch[0].action == "GetUpdates");
        if (!(bGuestAuthenticate || bGenerateName || bPing || bLarryO || bGetUpdates)) {
            timeout = -1;
        }
    }
    onReady(timeout);
}

// ---------------------------------------------------------------------------------------------------------------------
// cacheName - name for this request e.g. friendOf_<person_id>
// cacheScope - either "person" or "account" - to decide at what scope to store the data
// callback will get called TWICE - once immediately with cached result (if any) and
// again when the new server result arrived

function FPWebRequestWithCache(action, data, callback, callbackObj, cacheName, cacheScope)
{
    var cacheKey = "cached_requests/";
    if (cacheScope === "account") {
        cacheKey += "account/" + FPGetAccountId();
    } else {
        cacheKey += "person/" + FPGetPersonId();
    }
    cacheKey += "/" + cacheName;

    var bGotServerResult = false;

    function onCache(cachedResult)
    {
        // if server responds before native (unlikely), then don't send the cached result
        if (!bGotServerResult) {
            // try-catch is important so that if bad data gets cached, it's recoverable
            try {
                callback(cachedResult, callbackObj, cacheKey);
            } catch (e) {
            }
        }
    }
    FPStorage.getValue(cacheKey, onCache);

    function onResult(newResult)
    {
        if (newResult && !newResult.bNetworkError) {
            bGotServerResult = true;
            FPStorage.setValue(cacheKey, newResult);
            callback(newResult, callbackObj, cacheKey);
        }
    }
    FPWebRequest(action, data, onResult, null, null);
    return cacheKey;
}
// ---------------------------------------------------------------------------------------------------------------------
// wrapper around FPWebRequestWithCache
// by also supplying the "dataName" (the property of the server result containing an array of items)
// and the "idName" (the unique id for each item in the array), a "removeFunc" will be added to each
// item that can be triggered to remove the item from appearing ever again.  The "removed id" will be
// stored locally until a request to the server comes back completely clear of removed ids and then the
// cache will reset.

function FPWebRequestForEditList(action, data, callback, callbackObj, cacheName, cacheScope, dataName, idName)
{
    var cacheKey;
    function update()
    {
        function onResult(r)
        {
            if (r === undefined) {
                r = {};
            }
            function onData(removed)
            {
                if (!removed) {
                    removed = {};
                }
                process(r, removed);
            }
            FPStorage.getValue(cacheKey, onData);
        }
        cacheKey = FPWebRequestWithCache(action, data, onResult, null, cacheName, cacheScope);
        cacheKey += "_removed";
    }

    function process(r, removed)
    {
        function doRemove(removeId, bNoRequest)
        {
            removed[removeId] = true;
            FPStorage.setValue(cacheKey, removed);
            if (bNoRequest) {
                process(r, removed);
            } else {
                update();
            }
        }

        var a = r[dataName];
        if (a) {
            var count = 0;
            var i = 0;
            while (i < a.length) {
                if (removed[a[i][idName]]) {
                    a.splice(i, 1);
                    count++;
                } else {
                    a[i].removeFunc = doRemove;
                    i++;
                }
            }
            if (count == 0) {
                removed = {};
                FPStorage.setValue(cacheKey, removed);
            }
        }
        callback(r, callbackObj);
    }
    update();
}
