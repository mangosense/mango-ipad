// ----------------------------------------------------------------------------------------------------
//  list of URLs and target unzip directories (e.g. http://foo.com/bar.zip major/bar)  overlay/replace/delete

// index.js
orientation("vertical");
var appSettings = getAppSetting();
background(appSettings.background, true);

end();

/*

example payload

"updates": [
    {
        "name": "hub",
        "action": "replace",
        "layer": "major",
        "url": "http://packages.fingerprintplay.com/package_hub_1.0.zip"
    },
    {
        "name": "hub",
        "action": "replace",
        "layer": "minor",
        "url": "http://packages.fingerprintplay.com/package_hub_1.1.zip"
    },
    {
        "name": "catalog",
        "action": "delete",
        "layer": "major"
    },
    {
        "name": "catalog",
        "action": "overlay",
        "layer": "minor",
        "url": "http://127.0.0.1:8080/catalogzip/v2/0"
    }
]

*/

o = function(s, updates) {

    console.log("UPDATES:");
    console.log(JSON.stringify(updates), null, 4);
    var screenXOffset = (gFullWidth - 320)/2;

    var frame = div({parent:s, x:10+screenXOffset, y:(gFullHeight-120)/2, w:300, h:120});
    $(frame).css("background-color", "white");
    label({parent:frame, x:0, y:20, w:300, h:170, string: i18n('_CHECKING_FOR_UPDATES'), center:true, color:"#4e4e4e", size:20});
    var time = label({parent:frame, x:0, y:90, w:300, h:170, string: i18n('_0_IS_FINISHED'), center:true, font:"light font", color:"#5e5e5e", size:12});
    image({parent: frame, x: 10, y: 60, w: 280, h: 20, src:gImagePath+"progress-bar-background"});
    image({parent: frame, x: 12, y: 62, w: 10, h: 16, src:gImagePath+"progressbar-beginning"});
    var barmid = image({parent: frame, x: 21, y: 62, w: 0, h: 16, src:gImagePath+"progressbar-mid"});
    var barend= image({parent: frame, x: 21, y: 62, w: 10, h: 16, src:gImagePath+"progressbar-end"});
    var barWidth = 256*gScaleX;
    function setProgress(p)
    {
        if (p<0) {
            p = 0;
        } else if (p > 100) {
            p = 100;
        }
        $(barmid).css("width", Math.ceil(barWidth*p/100.0));
        $(barend).css("left", (barWidth)*p/100.0+(21)*gScaleX);
        time.text.innerText = Math.round(p) + "% finished.";
    }

    function updateComplete(bSuccess)
    {
        console.log("updateComplete: " + bSuccess);
        FPWebView.show("self", false); // work around SDK refresh bug (fixed in build 2, can remove soon - 12/19/12)
        FPSetAppValue("updaterRefreshTime", (new Date()).getTime());
        FPUpdater.refresh();
    }

    FPProcessUpdate(updates, setProgress, updateComplete);
};

FPLaunchScreen(o);




