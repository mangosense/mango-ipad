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
        var d = div({parent:p, x:0, y:0, w:320, h:40});
        addBackgroundImage($(d), "gray-pattern.png");
        label({parent:p, id: "title", string: i18n('_HELP'), center: true, x: 0, y: 10, w: 320, h: 55, size:15, color:"#4e4e4e"});
        button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "back", string: i18n('_BACK')});

        image({parent:p, x:102.5, y:80, w:115, h:102, src:gImagePath+"sad-cat-dog"});
        label({parent:p, string: i18n('_HAVE_QUESTIONS_OR'), center: true, vCenter: true, x: 10, y: 210, w: 300, h: 20, size:15, color:"#4e4e4e"});
        label({parent:p, string: i18n('_CONTACT'), center:true, vCenter: true, x: 10, y: 230, w: 300, h: 20, size:15, color:"#4e4e4e"});
        label({parent:p, id:"send", string: i18n('_SUPPORT_FINGERPRINTPLAY_COM'), center:true, vCenter: true, x: 10, y: 250, w: 300, h: 20, size:15, color:"#148342"});


        var hotspot = div({parent: p, x: 30, y: 250, w: 260, h: 55, color: null});

        p.on_back = function()
        {
            s.close();
        };
        hotspot.onmouseup = function()
        {
            function next()
            {
                function onVisible(bVisible)
                {
                    if (bVisible) {
                        setTimeout(next, 100);
                    } else {
                        FPHelper.mailTo("support@fingerprintplay.com", "" , "");
                    }
                }
                FPWebView.isVisible("alert", onVisible);
            }
            DoParentGate(next);
        };
    }
};

FPLaunchScreen(o);



