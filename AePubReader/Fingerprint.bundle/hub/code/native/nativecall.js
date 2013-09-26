//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

// -----------------------------------------------------------------------------------------
// Native call mechanism

var gNativeCallID = 0;
var gNativeCallbacks = {};

// new callbacks only pass back the result - there's no callbackArgs
function FPNativeCallback(nativeCallID, resultDict, bKeep)
{
    var save = gNativeCallbacks[nativeCallID];
    if (!bKeep) {
        delete gNativeCallbacks[nativeCallID];
    }
    save.callback(resultDict.result);
}

// in new version, arguments is an array - ordered arguments, rather than names, for auto native dispatch
function FPNativeCall(target, method, arguments, callback)
{
    if (!arguments) {
        arguments = [];
    }

    var o = new Object();
    o.bNewType = true;
    o.target = target;
    o.method = method;
    o.arguments = arguments;

    if (callback) {
        gNativeCallID++;

        o.nativeCallID = gNativeCallID;

        var save = {};
        save.callback = callback;
        gNativeCallbacks[gNativeCallID] = save;

    } else {
        o.nativeCallID = 0; // no callback specified
    }

    var s = JSON.stringify(o);
    FPNative.send(s);
}
