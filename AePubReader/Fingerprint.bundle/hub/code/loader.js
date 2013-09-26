//
//  Copyright 2011, 2012 Fingerprint Digital, Inc. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------------------
// list must be in loader.js which is uniqued on load so that it's possible to update the list

var gFingerprintScripts = [
    // json / jsonp
    "lib/json2.min.js",
    "lib/jsonp.js",

    // iScroll
    "lib/iscroll.js",

    // used by authenticate
    "lib/CryptoJS.sha1.js",

    // fingerprint native calls
    // TODO: consider combining and minifying in distribution
    "code/native/audio.js",
    "code/native/metrics.js",
    "code/native/updater.js",
    "code/native/webview.js",
    "code/native/helper.js",

    // fingerprint UI library
    // TODO: consider combining and minifying in distribution
    "code/fingerprint.js",
    "code/fingerprint/styles.js",
    "code/fingerprint/util.js",
    "code/fingerprint/touch.js",
    "code/fingerprint/font.js",
    "code/fingerprint/retina.js",
    "code/fingerprint/image.js",
    "code/fingerprint/button.js",
    "code/fingerprint/text.js",
    "code/fingerprint/label.js",
    "code/fingerprint/field.js",
    "code/fingerprint/screen.js",
    "modules/smart_list.js",
    "modules/updater_logic.js",
    "modules/event_mapping.js",

    // image-info
    "../catalog/image-info.js",
    "image-info.js",

    // game catalog
    "../catalog/game-data.js",
    "code/gameutils.js",

    // general
    "code/utils.js",
    "code/gamedata.js",
    "code/webrequest.js",
    "code/authenticate.js",
    "code/webapi.js"
];

//----------------------------------------------------------------------------------------------------------------------
function LoadScripts(scripts, callback)
{
    // load all the scripts
    var loaded = 0;
    function inc()
    {
        loaded++;
        if (loaded == scripts.length) {
            callback();
        }
    }

    for (var i=0; i<scripts.length; i++) {
        LoadScript(scripts[i], inc);
    }
}

//----------------------------------------------------------------------------------------------------------------------
var gStringTable = {};
var langLookUp = {
    "ms":"Bahasa Malaysia",
    "zh-CN":"中文 (Chinese)",
    "ta":"தமிழ் (Tamil)",
    "en":"English"
};
function i18n(id, variables)
{
    var result = "## MISSING STRING ##";
    var language = FPGetAppValue("language");
    if (!language) {
        language = "en";
    }
    var st = gStringTable[language];
    if (st && st[id]) {
        result = st[id];
    }
    if (result && variables) {
        result = DoSubstitutions(result, variables);
    }
    return result;
}

function i18n_add(language, strings)
{
    gStringTable[language] = strings;
}



function bootstrap()
{
    function next()
    {
        FPLoadApp(bootstrap2);
    }

    // load storage and state so we can have bLandscape available in time
    var scripts = [
        "lib/jquery.min.js",
        "code/native/nativecall.js",
       "code/native/storage.js",
        "code/state.js"
    ];

    // load string tables
    // TODO: reconsider whether we want to load all languages at once
    var languages = ["en","fr","it", "ms", "nl", "ta", "zh-CN", "de"];
    for (var i=0; i<languages.length; i++) {
        scripts.push("strings_" + languages[i] + ".js");
    }

    LoadScripts(scripts, next);
}

function bootstrap2()
{
    function next()
    {
        // not safe to set app values until bootstrap2 after FPLoadApp is run
        // also, wait until this next, after the native functions are loaded (in gFingerprintScripts list)

        // for web-based testing of partners
        var partner = GetArg("&partner=");
        if (partner){
            FPSetAppValue("partner", partner);
        }

        // bootstrap language setting
        var language = GetArg("&language="); // for web-environment
        if (language) {
            FPSetAppValue("language", language);
            // continue
            next2();
        } else if (FPGetAppValue("language") === undefined) {
            // if the app language value hasn't been set, read the devices language setting
            function onGetDeviceLanguage(code){
                var language;
                if(code === "zh-CN" || code === "zh-TW" || code === "zh-HK" || code === "zh-SG") {
                    language = "zh-CN";
                }else if(code === "ta") {
                    language = "ta";
                }else if(code === "ms") {
                    language = "ms";
                }else{
                    language = "en";
                }
                console.log("DEVICE LANGUAGE: " + code);
                console.log("BOOTSTRAP SETTING LANGUAGE TO: " + language);
                FPSetAppValue("language", language);

                // continue
                next2();
            }

            FPHelper.getDeviceLanguage(onGetDeviceLanguage);
        } else {
            // language already set
            next2();
        }
    }
    
    function next2()
    {
        // Note: can't pass onLoad to LoadScripts, as it doesn't exist until after the scripts are loaded
        onLoad();    // continue to code in fingerprint.js
    }

    LoadScripts(gFingerprintScripts, next);
}

// get things going
bootstrap();
