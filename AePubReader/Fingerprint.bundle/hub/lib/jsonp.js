//
//  Copyright 2011-2012 Fingerprint Digital, Inc. All rights reserved.
//

function FPIsOffline()
{
	var bOffline;

	// work around for webkit bug on Android
	if (window["gbAndroid"] && JSInterface.isNetworkAvailable) {
		bOffline = !(JSInterface.isNetworkAvailable());

	} else {
		bOffline = (!navigator.onLine);
	}

    return bOffline;
}

// -----------------------------------------------------------------------------------------
// Javascript request/response mechanism

var gRequestCallbacks = new Object();
var gBatchCallbacks = new Object();
var gRequestId = 0;
var gBatchId = 0;
var gBatch = [];

function FPDoCallback(callbacks, id, data, bData)
{
    var callback = callbacks[id];
    if (callback) {
        function doCallback()
        {
            if (callback.callback) {
                if (bData) {
                    callback.callback(data, callback.callbackObj);
                } else {
                    callback.callback(callback.callbackObj);
                }
            }
        }

        if (window["gWebGame"]) {
            doCallback();
        } else {
            try {
                doCallback();
            } catch (e) {
                console.log("FPDoCallback callback exception.");
            }
        }
        delete callbacks[id];
    }
}

function FPResponse(request_id, data)
{
	console.log("RESPONSE:\nid: " + request_id + "\ndata:\n"+JSON.stringify(data, null, 4));
    FPDoCallback(gRequestCallbacks, request_id, data, true);
}

function FPBatchComplete(batch_id)
{
    //console.log("FPBatchComplete: " + batch_id);
    FPDoCallback(gBatchCallbacks, batch_id, null, false);

    var e = document.getElementById("FPBatch" + batch_id);
   	if (e) {
   		var headID = document.getElementsByTagName("head")[0];
   		headID.removeChild(e);
   	}
}

function FPBatchAddRequest(batch, action, data, callback, callbackObj)
{
    gRequestId++;
    var o = {
        action: action,
        data: data,
        request_id: gRequestId
    };
    gRequestCallbacks[gRequestId] = {callback: callback, callbackObj: callbackObj};
    batch.push(o);
}

function FPRequest(action, data, callback, callbackObj)
{
    var batch = [];
    FPBatchAddRequest(batch, action, data, callback, callbackObj);
    FPSendBatch({}, batch, null, null);
}

function FPBatchRequest(action, data, callback, callbackObj)
{
    FPBatchAddRequest(gBatch, action, data, callback, callbackObj);
}

// if timeout is -1, force a failure
// if timeout is 0, null, or undefined, use default timeout
function FPBatchSend(commonData, callback, callbackObj, timeout)
{
    var batch = gBatch;
    gBatch = [];
    FPSendBatch(commonData, batch, callback, callbackObj, timeout);
}

// if timeout is -1, force a failure
// if timeout is 0, null, or undefined, use default timeout
function FPSendBatch(commonData, batch, callback, callbackObj, timeout)
{
    gBatchId++;
    var payload = {
        batch_id: gBatchId,
        batch: batch,
        commonData: commonData
    }

    if (callback) {
        gBatchCallbacks[gBatchId] = {callback: callback, callbackObj: callbackObj};
    }

    // compute API URL
    var q = "" + document.location;
   	var url = "/api/v2/";
   	if (window["FPGetAppValue"]) {
        var v = FPGetAppValue("server");
        if (v) {
       		url = v + url;
        }
   	}
    if (window["FPServerOverride"]) {
   		url = FPServerOverride + url;
   	}
   	console.log("SERVLET URL: " + url);
    url += "?data=" + escape(JSON.stringify(payload));

    // log
    console.log("REQUEST:\n" + JSON.stringify(payload, null, 4));

    // if no server response, fail by calling all callbacks with no data
    function fail()
    {
        var count = batch.length;
        for (var i=0; i<count; i++) {
            var request = batch[i];
            FPResponse(request.request_id, {bNetworkError:true}); // will clear the callback so if server responds later, it will be ignored
        }
        FPBatchComplete(payload.batch_id); // will clear the callback so if server responds later, it will be ignored
    }

    // detect actual lack of network, rather than one that's just not working
    var bOffline = FPIsOffline();

    // act offline if requested by caller
    if (timeout === -1) {
        bOffline = true;
    }

    // process
    if (bOffline) {
        // don't fail synchronously - callers expect asynchronous callback
        setTimeout(fail, 1);
    } else {
        function checkForBatchComplete()
        {
            if (gBatchCallbacks[payload.batch_id]) {
                // server didn't respond within the time-out, fail
                fail();
            }
        }
        var useTimeout = 30*1000; // 30 seconds
        if (timeout > 0) {
            useTimeout = timeout;
        }
        setTimeout(checkForBatchComplete, useTimeout);

        var headID = document.getElementsByTagName("head")[0];
        var newScript = document.createElement('script');
        newScript.type = 'text/javascript';
        newScript.src = url;
        newScript.id = "FPBatch"+gBatchId;
        headID.appendChild(newScript);
    }
}
