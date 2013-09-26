//
//  Copyright 2011, 2012 Fingerprint Digital, Inc. All rights reserved.
//

/**
 Name space for functions that require native implementation support.
 */
var FPStorage = {};

/* webHub test version uses localStorage with this preface */
var STORAGE = "FPStorage1";

/**
 * get a stored value

 @return {void}
 @param {String} name of value to retrieve
 @param {Function} callback to receive the value object
 */
FPStorage.getValue = function(name, callback)
{
    function onResult(r)
    {
        if (r) {
            callback(JSON.parse(r));
        } else {
            callback(undefined);
        }
    }

    if (window["FPNative"])
    {
        FPNativeCall("Storage", "getValue:", [name], onResult);
    }
    else
    {
        function next()
        {
            onResult(localStorage[STORAGE+name]);
        }
        setTimeout(next, 1);
    }
};

/**
 * set a stored value

 @return {void}
 @param {String} name of value to store
 @param {Object} value to store (null will delete the key from storage)
 */
FPStorage.setValue = function(name, value)
{
    var valueStr = JSON.stringify(value, null, 4);
    if (window["FPNative"])
    {
        FPNativeCall("Storage", "setValue:value:", [name, valueStr]);
    }
    else
    {
        localStorage[STORAGE+name] = valueStr;
    }
};

/**
 * rename a stored data directory.  used when guest is assigned a person_id

 @return {void}
 @param {String} oldName name of directory to rename
 @param {String} newName new name for the directory
 @param {Function} callback to call when complete
 */
FPStorage.renameDir = function(oldName, newName, callback)
{
    if (window["FPNative"])
    {
        FPNativeCall("Storage", "moveState:to:", [oldName, newName], callback);
    }
    else
    {
        // TODO
        console.log("warning: webHub FPStorage.renameDir not implemented");
        setTimeout(callback, 1);
    }
};

/**
 * append a JSON object to the specified queue

 @return {void}
 @param {String} queueName name of the queue
 @param {Object} o object to append
 */
FPStorage.appendQueue = function(queueName, o)
{
    var oStr = JSON.stringify(o, null, 4);
    if (window["FPNative"])
    {
        FPNativeCall("Storage", "appendQueue:value:", [queueName, oStr]);
    }
    else
    {
        var queue = [];
        var queueStr = localStorage[STORAGE+"queue_"+queueName];
        if (queueStr) {
            queue = JSON.parse(queueStr);
        }
        queue.push(oStr);
        queueStr = JSON.stringify(queue);
        localStorage[STORAGE+"queue_"+queueName] = queueStr;
    }
};

/**
 * peek at the object on the front of the specified queue

 @return {void}
 @param {String} queueName name of the queue
 @param {Function} callback to receive the object
 */
FPStorage.peekQueue = function(queueName, callback)
{
    function onResult(r)
    {
        if (r) {
            callback(JSON.parse(r));
        } else {
            callback(undefined);
        }
    }

    if (window["FPNative"])
    {
        FPNativeCall("Storage", "peekQueue:", [queueName], onResult);
    }
    else
    {
        var result = undefined;
        var queue = [];
        var queueStr = localStorage[STORAGE+"queue_"+queueName];
        if (queueStr) {
            queue = JSON.parse(queueStr);
            if (queue.length) {
                result = queue[0];
            }
        }
        function next()
        {
            onResult(result);
        }
        setTimeout(next, 1);
    }
};

/**
 * remove first element from the front of the specified queue :-)

 @return {void}
 @param {String} queueName name of the queue
 @param {Function} callback to receive the object (sdk_version 15+)
 */
FPStorage.popQueue = function(queueName, callback)
{
    function onResult(r)
    {
        if (r) {
            callback(JSON.parse(r));
        } else {
            callback(undefined);
        }
    }

    if (window["FPNative"])
    {
        FPNativeCall("Storage", "popQueue:", [queueName], callback ? onResult : null);
    }
    else
    {
        var queue = [];
        var queueStr = localStorage[STORAGE+"queue_"+queueName];
        if (queueStr) {
            queue = JSON.parse(queueStr);
            if (queue.length) {
                queue.shift();
                queueStr = JSON.stringify(queue);
                localStorage[STORAGE+"queue_"+queueName] = queueStr;
            }
        }
    }
};


