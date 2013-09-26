// index.js
orientation("vertical");

end();

// logic.js

o = function(s, args) {

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    init();
    function init()
    {

        var eventName = window["FPNative"]?"touchend":"click";
        var d = div({parent:p, x:0, y:0, w:320, h:40});
        addBackgroundImage($(d), "gray-pattern.png");
        label({parent:p, id: "title", string: i18n('_COIN_O_COPIA'), center: true, x: 0, y: 10, w: 320, h: 55, size:15, color:"#4e4e4e"});
        button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "back", string: i18n('_BACK')});

        var coinHelpBox = div({parent:p, x:0, y:40, w:320, h:gHubHeight-40});
        coinHelpBox.id = "coinHelpBox";
        var coinHelp = div({parent:coinHelpBox, x:0, y:0, w:320, h:320});
        image({parent:coinHelp, x: 15, y: 5, w: 290, h: 60, src: gImagePath+"coinocopia-logo"});
        label({parent:coinHelp, string: i18n('_WELCOME_TO_COIN'),
            x: 20, y: 70, w: 280, h: 65, size:16, color:"#4e4e4e"});
        label({parent:coinHelp, string: i18n('_TO_PLAY_SIMPLY'),
            x: 20, y: 110, w: 280, h: 55, size:12, color:"#4e4e4e", font:"light font"});
        label({parent:coinHelp, string: i18n('_TO_EARN_MORE'),x: 20, y: 180, w: 280, h: 55, size:18, color:"#4e4e4e", center:true});
        var l_game = label({parent:coinHelp, string: i18n('_DOWNLOAD_A_NEW'), id: "game",
            x: 40, y: 210, w: 200, h: 55, size:12, color:"#148342", font:"light font"});
        label({parent:coinHelp, string: i18n('_PLAY_FINGERPRINT_GAMES', {partner: getAppSetting().partnerName}),
            x: 40, y: 235, w: 200, h: 55, size:12, color:"#4e4e4e", font:"light font"});
        var l_friend = label({parent:coinHelp, string: i18n('_INVITE_NEW_FRIENDS'), id:"friend",
            x: 40, y: 260, w: 200, h: 55, size:12, color:"#148342", font:"light font"});
        label({parent:coinHelp, string: i18n('_IN_THE_FUTURE'),
            x: 20, y: 285, w: 280, h: 55, size:12, color:"#4e4e4e", font:"light font"});
        image({parent:coinHelp, x: 20, y: 208, w: 15, h: 15, src:gImagePath+"helpoverlay-icon1"});
        image({parent:coinHelp, x: 20, y: 233, w: 15, h: 15, src:gImagePath+"helpoverlay-icon2"});
        image({parent:coinHelp, x: 20, y: 259, w: 15, h: 15, src:gImagePath+"helpoverlay-icon3"});
        new iScroll("coinHelpBox", {bounce:false});

        p.on_back = function()
        {
            s.close();
        };
        function onClickOnGame(){
            $(s).trigger("updateHubPanel", ["hub_games_main"]);
        }
        bindEvent(l_game, eventName, "label_game", onClickOnGame);
        function onClickOnFriend(){
            $(s).trigger("updateHubPanel", ["hub_friends"]);
        }
        var eventName = window["FPNative"]?"touchend":"click";
        bindEvent(l_friend, eventName, "label_friend", onClickOnFriend);
    }
};

FPLaunchScreen(o);



