// index.js
orientation("vertical");

end();

// logic.js
//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

o = function(s, args) {

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    init();
    function init()
    {
        var appSettings = getAppSetting();
        var d = div({parent:p, x:0, y:0, w:320, h:40});
        addBackgroundImage($(d), "gray-pattern.png");
        label({parent:p, id: "title", string: i18n('_ABOUT_FINGERPRINT', {partner: appSettings.partnerName}), center: true, x: 0, y: 10, w: 320, h: 55, size:15, color:"#4e4e4e"});
        button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "back", string: i18n('_BACK')});

        var listBox = div({parent:p, x:0, y:40, w:320, h:gHubHeight-40});
        listBox.id = "aboutList";
        var list =  div({parent:listBox, x:0, y:0, w:320, h:340});
        image({parent:list, src: gImagePath+"about-fingerprint", x:0, y:0, w:320, h: 170});
        label({parent:list, x:20, y:170, color:"#4e4e4e", string: i18n('_FINGERPRINT_IS_THE', {partner: appSettings.partnerName})
            , w:280, h:150, font:"light font", size:12});
        button({parent:p, src:gImagePath+"greenbutton_half", idleover:"same", id: "version", x: 250, y:5, w:60, h:30, string: i18n('_VERSION'), size: 12});

        new iScroll("aboutList", {hScroll: true, bounce: false});


        p.on_back = function()
        {
            s.close();
        };
        p.on_version = function()
        {
            runScreen(s, "versions", "left", "tos");
        };
    }
};

FPLaunchScreen(o);



