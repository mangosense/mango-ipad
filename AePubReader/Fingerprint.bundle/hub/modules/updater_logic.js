//
//  Copyright 2012, 2013 Fingerprint Digital, Inc. All rights reserved.
//

function FPProcessUpdate(updates, setProgress, updateComplete)
{
    // pass 0 - downloads
    // pass 1 - unzips
    // pass 2 - only once everything is ok - do the replace, overlay, delete
    var pass = 0;
    var i = 0;
    var count = updates.length;

    function onProgress(p)
    {
        if (p == -1) {
            function onOK()
            {
                console.log("after update failed");
                updateComplete(false);
            }
            DoAlert("", i18n("_UPDATE_FAILED"), onOK);
        } else {
            // advance progress bar - based on weighted phases
            // downloads - first 40%
            // unzips - second 40%
            // actions - last 20%
            var passBase = [0, 40, 80];
            var passSize = [40, 40, 20];
            var useP = passBase[pass] + passSize[pass] * (i + p/100.0) / count;
            setProgress(useP);
            if (p == 100) {
                doNext();
            }
        }
    }

    function doNext()
    {
        //console.log("doNext");

        // go to next update
        i++;
        if (i == count) {
            i = 0;
            pass++;
        }
        doNextUpdate();
    }

    function doNextUpdate()
    {
        //console.log("doNextUpdate pass: " + pass + ", i: " + i);

        if (pass == 0) {
            // next download
            var url = updates[i].url;
            updates[i].tmp = GUID();
            if (url) {
                //console.log("starting download " + url + " to " + updates[i].tmp + ".zip");
                FPUpdater.download(url, updates[i].tmp + ".zip", onProgress)
            } else {
                // no download for this one, advance, but not recursively
                setTimeout(doNext, 1);
            }
        } else if (pass == 1) {
            // next unzip
            var url = updates[i].url;
            if (url) {
                //console.log("starting unzip " + updates[i].tmp + ".zip");
                var zipFile = updates[i].tmp + ".zip";
                function onZipProgress(p)
                {
                    function zipProgressNext()
                    {
                        onProgress(p);
                    }
                    if (p == -1 || p == 100) {
                        // when done, delete the zip file
                        FPUpdater.deletePath(zipFile, zipProgressNext);
                    } else {
                        zipProgressNext();
                    }
                }
                FPUpdater.unzip(zipFile, updates[i].tmp, onZipProgress)
            } else {
                // no download for this one, advance, but not recursively
                setTimeout(doNext, 1);
            }
        } else if (pass == 2) {
            // next action
            setProgress(100); // keep progress bar moving
            var action = updates[i].action;
            //console.log("action: " + action);
            var srcDir = updates[i].tmp + "/" + updates[i].name;
            var dstDir = updates[i].layer + "/" + updates[i].name;
            if (action == "replace") {
                //console.log("FPUpdater.replaceDirectory " + dstDir + " with " + srcDir);
                function onReplaced()
                {
                    FPUpdater.deletePath(updates[i].tmp, doNext);
                }
                FPUpdater.replaceDirectory(dstDir, srcDir, onReplaced);
            } else if (action == "overlay") {
                //console.log("FPUpdater.overlayDirectory " + dstDir + " with " + srcDir);
                function onOverlayed()
                {
                    FPUpdater.deletePath(updates[i].tmp, doNext);
                }

                // TODO: remove this workaround after 3rd parties update their native SDKs
                function startOverlay()
                {
                    FPUpdater.overlayDirectory(dstDir, srcDir, onOverlayed);
                }
                FPUpdater.deletePath(dstDir + "/x", startOverlay);

            } else if (action == "delete") {
                //console.log("FPUpdater.deletePath " + dstDir + " with null");
                FPUpdater.deletePath(dstDir, doNext);
            }
        } else if (pass == 3) {
            // done!
            function next()
            {
                updateComplete(true);
            }
            // wait a little bit just so console statements finish getting printed before we tear down the web view
            setTimeout(next, 200);
        }
    }

    // start it up!
    doNextUpdate();
}