//
//  Copyright 2011, 2012 Fingerprint Digital, Inc. All rights reserved.
//

/**
 Name space for functions that require native implementation support.
 NOTE: in web environment, everything is always up to date and Updater is not used
 */
var FPUpdater = {};

/**
 * download a file

 @param {String} url what url to download
 @param {String} path path to download to
 @param {Function} callback function - gets called repeatedly with percent complete 0-100.  100 will be last call.  or -1 for error
 @return {void}
 */
FPUpdater.download = function(url, path, callback)
{
    if (window["FPNative"])
    {
        FPNativeCall("Updater", "download:path:", [url, path], callback);
    }
    else
    {
        console.log("warning: webHub FPUpdater.download not implemented");
        function next()
        {
            callback(-1);
        }
        setTimeout(next, 1);
    }
};

/**
 * unzip a file

 @param {String} path path to file to unzip
 @param {String} dir path to directory to unzip into
 @param {Function} callback function - gets called repeatedly with percent complete 0-100.  100 will be last call.  or -1 for error
 @return {void}
 */
FPUpdater.unzip = function(path, dir, callback)
{
    if (window["FPNative"])
    {
        FPNativeCall("Updater", "unzip:dir:", [path, dir], callback);
    }
    else
    {
        console.log("warning: webHub FPUpdater.unzip not implemented");
        function next()
        {
            callback(-1);
        }
        setTimeout(next, 1);
    }
};


/**
 * delete a file or directory

 @param {String} path path to file or directory to delete
 @param {Function} callback function
 @return {void}
 */
FPUpdater.deletePath = function(path, callback)
{
    if (window["FPNative"])
    {
        FPNativeCall("Updater", "deletePath:", [path], callback);
    }
    else
    {
        console.log("warning: webHub FPUpdater.deletePath not implemented");
        function next()
        {
            callback(-1);
        }
        setTimeout(next, 1);
    }
};


/**
 * replace a directory
 * dirOld is deleted and dirNew is renamed to replace it
 * This allows for clean replacement of changesets (e.g. for update dirs that use seed/major/minor scheme)

 @param {String} dstDir path to the destination directory
 @param {String} srcDir path to the source directory
 @param {Function} callback function - gets called with boolean result
 @return {void}
 */
FPUpdater.replaceDirectory = function(dstDir, srcDir, callback)
{
    if (window["FPNative"])
    {
        FPNativeCall("Updater", "replaceDirectory:src:", [dstDir, srcDir], callback);
    }
    else
    {
        console.log("warning: webHub FPUpdater.replaceDirectory not implemented");
        function next()
        {
            callback(false);
        }
        setTimeout(next, 1);
    }
};

/**
 * overlay a directory
 * rather than replacing the old directory, it moves the new files/directories into the old
 * directory, replacing older items if necessary.
 * This allows the accumulation of changes over time (e.g. the results from the Catalog Zip servlet)
 * After moving all the items into the old directory, the new directory is deleted

 @param {String} dstDir path to the destination directory
 @param {String} srcDir path to the source directory
 @param {Function} callback function - gets called with boolean result
 @return {void}
 */
FPUpdater.overlayDirectory = function(dstDir, srcDir, callback)
{
    if (window["FPNative"])
    {
        FPNativeCall("Updater", "overlayDirectory:src:", [dstDir, srcDir], callback);
    }
    else
    {
        console.log("warning: webHub FPUpdater.overlayDirectory not implemented");
        function next()
        {
            callback(false);
        }
        setTimeout(next, 1);
    }
};

/**
 * tear down and restart all the web views so that they can use new content

 @return {void}
 */
FPUpdater.refresh = function()
{
    if (window["FPNative"])
    {
        FPNativeCall("Updater", "refresh", []);
    }
    else
    {
        console.log("warning: webHub FPUpdater.refresh not implemented");
    }
};

