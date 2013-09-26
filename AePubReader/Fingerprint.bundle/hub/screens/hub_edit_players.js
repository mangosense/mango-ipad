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
        label({parent:p, id: "title", string: i18n('_EDIT_PLAYERS'), center: true, x: 80, y: 0, w: 160, h: 40, vCenter:true, size:15, color:"#4e4e4e"});
        button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "back", string: i18n('_BACK')});
        button({parent:p, src:gImagePath+"greenbutton_full", idleover:"same", id: "rename", x: 40, y:80, w:240, h:40, string: i18n('_PLAYER_REAL_NAMES'), size: 18});
        label({parent:p, x: 40, y: 125, w: 240, h: 45, string: i18n('_ADD_REAL_NAMES'), center:true, size:14, font: "light font", color:"#4e4e4e"});
        button({parent:p, src:gImagePath+"greenbutton_full", idleover:"same", id: "remove", x: 40, y:180, w:240, h:40, string: i18n('_HIDE_PLAYERS'), size: 18});
        label({parent:p, x: 40, y: 225, w: 240, h: 45, string: i18n('_DON_T_WORRY'), center:true, size:14, font: "light font", color:"#4e4e4e"});


        p.on_back = function()
        {
            s.close("left");
        };
        p.on_rename = function()
        {
            runScreen(p,"player_real_names", "left");
        };
        p.on_remove = function()
        {
            runScreen(p,"hub_remove_players", "left");
        };
    }
};

FPLaunchScreen(o);



