//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

// index.js
orientation("vertical");
end();

// logic.js
o = function(s, mode) {
    var appSettings = getAppSetting();
    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background

    var title = (mode == "tos") ? i18n("_TERMS_OF_USE") : i18n("_PRIVACY_POLICY");
    var buttonTitle = (mode == "tos") ? i18n("_VIEW_OUR_PRIVACY") : i18n("_VIEW_OUR_TERMS");

    var d = div({parent:p, x:0, y:0, w:320, h:40});
    addBackgroundImage($(d), "gray-pattern.png");
    label({parent:p, id: "title", string: title, center: true, x: 0, y: 10, w: 320, h: 55, size:15, color:"#4e4e4e"});
    button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "back", string: i18n('_BACK')});
    button({parent:p, src:gImagePath+"bluebutton_full", idleover:"same", id: "view", x: 40, y:gHubHeight-72, w:240, h:46, string: buttonTitle, size: 18});

    if (mode ==="tos"){

        image({parent:s, src: gImagePath+"termsofuse-kids2.png", x:30, y:50, w:260, h: 68});
        if ( appSettings.get_tos){
            appSettings.get_tos(onText);
        }else{
            FPHelper.getText('/hub/legal/terms-of-use.html', onText);
        }

    }else if (mode ==="privacy"){

        image({parent:s, src: gImagePath+"privacypolicy-kids2.png", x:30, y:50, w:260, h: 55});
        if ( appSettings.get_pp){
            appSettings.get_pp(onText);
        }else{

            FPHelper.getText('/hub/legal/privacy-policy.html', onText);
        }

    }
    function onText(text)        {

        var wrapper = div({parent: s, x: 25, y: 120, w: 265, h: gHubHeight-200});

        var tosScrollBox = div({parent: wrapper, x: 0, y: 0, w: 265, h: gHubHeight-200});

        var tosLabel = label({parent: tosScrollBox, string: text, x: 0, y: 0, w: 265, size: 10, font: "light font", color:"#444444" });

        FinishLegalText(tosScrollBox, tosLabel);
    }


    p.on_back = function()
    {
        s.close();
    };

    p.on_view = function()
    {
        mode = (mode == "tos") ? "privacy" : "tos";
        var parent = s.parent;
        s.parent = null; // TODO: fix this screen bug workaround
        runScreenCloser(s, "right");
        runScreen(parent, "hub_privacy_tos", "left", mode);
    }
};

FPLaunchScreen(o);



