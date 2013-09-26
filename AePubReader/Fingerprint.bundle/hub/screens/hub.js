// index.js
orientation("vertical");

end();

// logic.js
//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

o = function(s, args) {

    $(s.gray).hide(); // don't want the gray screen between hub button overlay and the game
    var appSettings = getAppSetting();
    var hubScroll;
    var hubButtonList;
    var currentPanel = {};
    var bScrolling = false;
    var oldPos = {};
    var buttonNames = [i18n("_HOME"),i18n("_GAMES"),i18n("_FRIENDS"),i18n(appSettings.wall),i18n("_COINS"),i18n("_ME"),i18n("_PARENT"), i18n("_CHANGE"),i18n("_SETTINGS")];
    var buttonIds = ["home", "games", "friends", "wall", "coins", "me", "parent", "change", "settings"];
    var panelNames = ["hub_home", "hub_games_main", "hub_friends", "hub_messages", "hub_coins", "hub_change_avatar", "hub_parent_home", "change_player", "hub_settings"];
    var numButtons = gbShowCoinopia ? 9 : 8;
    var barColor = ["#eaa621", "#435dbc", "#993f9a", "#eb6d22", "#6914ad", "#6914ad", "#2792a2", "#4a88d4", "#2aba26"];
    var hubButtons = {};
    var hubButtonSize = appSettings.hubBtSize;
    var hubBtBorder = 2.2;
    var cur_code = FPGetAppValue("language");

    if (FPIsLandscape())
    {

        var spaceForHubTabs = 160;
        var spaceForContent = 320;
        var ox = gFullWidth>480?(gFullWidth-spaceForContent-spaceForHubTabs):0;// extra left offset to move hub buttons to the right edge
        var spaceForCenterContent = ox?(ox+hubBtBorder+hubButtonSize/2)/2:0;
        div({parent: s, x: 320, y: 0, w: 100+ox, h:320, color: "#ffffff", id:"nav-bg2"});
        var h0Bg = div({parent: s, x: 497+ox, y: (gFullHeight-hubButtonSize)/2, w: hubButtonSize, h: hubButtonSize});
        var h1Bg = div({parent: s, x: 322+ox, y: (gFullHeight-hubButtonSize)/2, w: hubButtonSize, h: hubButtonSize});
        image({parent: s, src: gImagePath+"nav-bg-rotate", x: 320+ox, y: 0, w: 230, h:320});
        var h0 = div({parent: s, x: 495+ox, y: (gFullHeight-hubButtonSize)/2, w: hubButtonSize, h: hubButtonSize});
        var mask = div({parent:s, x:348+ox, y:0, w:155, h:480});
        var hubButtonBox = div({parent:mask, x:0, y:0, w:140, h:320});
        div({parent: s, x: 0, y: 0, w: 320, h:320, color: "#ffffff"});
        var hubFrame = div({parent: s, id:"hubFrame", x: 0+spaceForCenterContent, y: 0, w: 320, h:320, color: "#ffffff"});
        var hubExtra = div({parent: s, id:"hubExtra", x: 0, y:0, w:spaceForCenterContent, h:320});
        var h1 = image({parent: s, x: 320+ox, y: (gFullHeight-hubButtonSize)/2-hubBtBorder, w: hubButtonSize+hubBtBorder*2, h: hubButtonSize+hubBtBorder*2, src:gImagePath+"hub_button"});
        $(h1).css({borderRadius:170*gScaleY});
    }else
    {
        div({parent: s, x: 0, y: 117, w: 320, h:63, color: "#ffffff", id:"nav-bg2"});
        var h0Bg = div({parent: s, x: 135, y: 2, w: hubButtonSize, h: hubButtonSize});
        var h1Bg = div({parent: s, x: 135, y: 125, w: hubButtonSize, h: hubButtonSize});
        image({parent: s, src: gImagePath+"nav-bg", x: 0, y: 0, w: 320, h:178});
        var h0 = div({parent: s, x: 135, y: 2, w: hubButtonSize, h: hubButtonSize});
        var mask = div({parent:s, x:0, y:72, w:480, h:55});
        var hubButtonBox = div({parent:mask, x:0, y:0, w:320, h:70});
        var hubFrame = div({parent: s, id:"hubFrame", x: 0, y: 179, w: 320, h:gHubHeight, color: "#ffffff"});
        var h1 = div({parent: s, x: 135, y: 123, w: hubButtonSize, h: hubButtonSize});
    }
    hubButtonBox.id = "hubButtons";
    $(h0Bg).addClass("hubBg");
    $(h1Bg).addClass("hubBg");
    $(h0).addClass("hub");
    h0.id = "hub0";
    $(h1).addClass("hub");
    h1.id = "hub1";
    $(".hubBg").css("border-radius", "75px");
    var rules = "@-webkit-keyframes hubBgAnimation{  0%   {background:#e7571c;}   50%  {background:#edb22f;}  100%  {background:#e7571c;}}";
    cssAnimation(rules);

    $(s).bind('updateHubBtNoti', function() {
        // when the hub is never open for this user in this app
        var key = "bFirstOpenHub"+FPGetPersonId();
        if (!FPGetAppValue(key)){
            addNotifications(h0, 1);
        }else{
            addNotifications(h0, 0);
        }
    });


    s.onUpdateHub = function(hubState)
    {
        function setHubAnimated(e, bOn)
        {
            bOn = false; // FOR NOW, never animate it - it's a performance killer, and making it harder to study Fruit Ninja
            if (bOn) {
                $(e).css("-webkit-animation", "hubBgAnimation 5s infinite");
            } else {
                $(e).css("-webkit-animation", ""); // "" works to remove animation, but undefined does not
                $(e).css("background", appSettings.hubBtColor);
            }
        }
        switch (hubState) {
            case HUB_BUTTON:
                setHubAnimated(h0Bg, true);
                setHubAnimated(h1Bg, false);
                break;
            case HUB_OPENED:
                setHubAnimated(h1Bg, true);
                setHubAnimated(h0Bg, false);
                break;
            default:
                setHubAnimated(h1Bg, false);
                setHubAnimated(h0Bg, false);
                break;
        }

        // if opening hub via API call and never opened before, be sure to show home panel
        if (currentPanel && !currentPanel.name && FPGetAccountToken()) {
            goHubPanel(appSettings.tabOnHubOpen);
        }
    }


    var eventName = window["FPNative"]?"touchstart":"click";
    bindEvent(h0, eventName, "open_hub", function(){

        if (cur_code !== FPGetAppValue("language")){
            $(hubFrame).trigger("updateHubTabsTxt");
            cur_code = FPGetAppValue("language");
        }

        var key = "bFirstOpenHub"+FPGetPersonId();
        if (!FPGetAppValue(key)){
            FPSetAppValue(key, true);
            addNotifications(h0, 0);
        }

        hubButtonPressed();
            hubScroll.scrollToElement(hubButtons["hub_home"]);
            goHubPanel(appSettings.tabOnHubOpen, true);

        if (window.gTestHarness) {
            window.gTestHarness.controller.pushButton("hubButton.0");
        }
    });
    bindEvent(h1, eventName, "hide_hub", function(){
        hubButtonPressed();
            if (currentPanel.panelName==="hub_change_avatar"){
                FPWebView.eval("multiplayer", "refreshGames()", null);
            }

        if (window.gTestHarness) {
            window.gTestHarness.controller.pushButton("hubButton.1");
        }
    });

    if (window.gTestHarness) {
        function doAct0()
        {
            $("#hub0").trigger(eventName);
        }
        function doAct1()
        {
            $("#hub1").trigger(eventName);
        }
        window.gTestHarness.controller.addButton("hubButton.0", gScreen, doAct0);
        window.gTestHarness.controller.addButton("hubButton.1", gScreen, doAct1);
    }

    function makeHubButtons()
    {
        var v;
        var bShortScreen = false;
        var btPos = appSettings.hubTabPos;
        if (FPIsLandscape()) {
            var model = FPGetAppValue("model");
            if (gFullWidth<480|| model && model.indexOf("iPad") != -1) {
                // on ipad, we need to use the portrait oriented hub buttons because of the shorter aspect ratio
                v = btPos.LandscapeShort;
                bShortScreen = true;
            } else {
                v = btPos.Landscape;
            }
            hubButtonList = div({parent:hubButtonBox, x:0, y:0, w:140, h:v[3]*numButtons});
        } else {
            v = btPos.Portrait;
            hubButtonList = div({parent:hubButtonBox, x:0, y:0, w:v[2]*numButtons, h:70});
        }
        hubButtonList.buttonParent = s;

        var j=0;
        for (var i=0; i<9; i++) {
            if (!gbShowCoinopia && i == 4) {
                continue;
            }

            var btId = buttonIds[i];
            var d = div({parent: hubButtonList, id:btId, x: v[2]*j, y: v[3]*j, w: v[4], h: v[5]});
            var imgInfo =GetImageInfo("hub/"+gImagePath+"button-2-"+btId+".png"),
                imgScale = 0.5,
                imgInfoW = imgInfo.w*imgScale,
                imgInfoH = imgInfo.h*imgScale,
                txtH = 11,
                spaceH = 0.5,
                displayW = v[4]-v[0],
                imgX = v[6]? v[0]+(displayW*0.4-imgInfoW)/2: v[0]+(displayW-imgInfoW)/2,
                imgY = v[6]? (v[5]-imgInfoH)/2:(bShortScreen? (v[5]-imgInfoH-txtH-spaceH)/2: v[5]-txtH-imgInfoH-spaceH-5),
                txtX = v[6]? v[0]+displayW*0.4: v[0]+spaceH,
                txtY = v[6]? (v[5]-txtH)/2:imgY+imgInfoH+spaceH,
                txtW = v[6]? v[0]+v[4]-txtX:v[4]-v[0]+2*spaceH;


            image({parent: d, src:gImagePath+"button-2-"+btId+".png", x: imgX, y:imgY, w:imgInfoW, h:imgInfoH});
            var l = label({parent: d, x: txtX, y: txtY, w:txtW, h: txtH, string:buttonNames[i], size: 11, center:!v[6], vCenter:true, color:appSettings.hubTxtColor});
            $(l).css(appSettings.hubTxt());
            $(l.text).addClass("buttonName");
            d.l1 = l;

            

            if (btId === "friends" || btId === "wall"){
                var noti_sign = label({parent:d, string:"", size:9, x:imgX+imgInfoW-10-spaceH, y:imgY-spaceH, w:10, h:10, id:"notification_sign", center:true});
                $(noti_sign).css({
                    display: "none",
                    position:"absolute",
                    backgroundColor:"#e62329",
                    borderRadius:50*gScaleX,
                    border: 1.5*gScaleX+"px solid white"});
                $(noti_sign.text).css({top:1*gScaleX});
                d.noti_sign = noti_sign;
            }
            // add bar color
            d.barColor = barColor[i];
            hubButtons[panelNames[i]] = d;
            var eventName = window["FPNative"]?"touchend":"click";
            bindEvent(d, eventName, "button_"+btId, s["on_"+btId]);
            j++;
        }

        hubScroll = new iScroll("hubButtons", {bounce: false,
            onScrollStart:
                function(e){
                    bScrolling = false;
                    if (window["FPNative"]){
                        oldPos = {x:e.touches[0].clientX, y:e.touches[0].clientY};
                    }else{
                        oldPos = {x:e.clientX, y:e.clientY};
                    }
                },
            onScrollMove:
                function(e){
                    var newPos;
                    if (window["FPNative"]){
                        newPos = {x:e.touches[0].clientX, y:e.touches[0].clientY};
                    }else{
                        newPos = {x:e.clientX, y:e.clientY};
                    }
                    if (Math.abs(newPos.x-oldPos.x)>5*gScaleX || Math.abs(newPos.y-oldPos.y)>5*gScaleY){
                        bScrolling = true;
                    }
                }});
    }


    // frame


    s.refresh = function()
    {
        if (currentPanel && currentPanel.refresh) {
            currentPanel.refresh();
        }
    }

    s.forceRefreshSettings = function()
    {
        goHubPanel("hub_settings", true, null, true);
    }

    function goHubPanel(panelName, bNoTransition, panelArgs, bForce)
    {
        // check notification everytime user change tabs
        getNewNotifications();

        var eventScope = {
            "hub_home": "Homep",
            "hub_games_main": "Games",
            "hub_friends": "Frnds",
            "hub_messages": "Messg",
            "hub_coins": "Coins",
            "hub_change_avatar": "Avatr",
            "hub_parent_home": "Parnt",
            "change_player": "Chnge",
            "hub_settings": "Settn"
        };

        FPSetEventScope2(eventScope[panelName]);

        if (!bScrolling){
            // figure out which direction to slide
            function indexFromName(name)
            {
                var result = 0;
                var i = panelNames.length;
                while (i--) {
                    if (panelNames[i] == name) {
                        result = i;
                        break;
                    }
                }
                return result;
            }

            if (currentPanel.panelName != panelName || bForce) {
                var preIndex = currentPanel ? indexFromName(currentPanel.panelName) : 0;
                var postIndex = indexFromName(panelName);
                var bLeft = (preIndex > postIndex);
                var closeDir = bLeft ? "left" : "right";
                var openDir = bLeft ? "right" : "left";

                var preButton = hubButtons[currentPanel.panelName];
                if (preButton) {
                    appSettings.hubUnSelected(preButton);
                }
                var postButton = hubButtons[panelName];
                if (postButton ) {
                    appSettings.hubSelected(postButton);
                }


                if (panelName==="hub_games_main"||panelName==="hub_coins"||panelName==="change_player")
                {
                    addBackgroundImage($(s.div["nav-bg2"]), "medium-gray-pattern.png");
                    addBackgroundImage($(s.div["hubExtra"]), "medium-gray-pattern.png");
                }else
                {
                    $(s.div["nav-bg2"]).css("background-image", "none");
                    $(s.div["hubExtra"]).css("background-image", "none");
                }


                if (currentPanel.panelName) {
                    if (bNoTransition) {
                        currentPanel.close();
                        runScreen(hubFrame, panelName, "none", panelArgs);
                    } else {
                        runScreenCloser(currentPanel, closeDir);
                        runScreen(hubFrame, panelName, openDir, panelArgs);
                    }
                    if (currentPanel.panelName==="hub_change_avatar"){
                        currentPanel.onScreenClose = function(){
                            FPWebView.eval("multiplayer", "refreshGames()", null);
                        }
                    }
                } else {
                    runScreen(hubFrame, panelName, "none", panelArgs);
                }
                currentPanel = gScreen;
                currentPanel.panelName = panelName;
            }

        }

    }
    s.on_home = function()
    {
        goHubPanel("hub_home");
    }

    s.on_wall = function()
    {
        goHubPanel("hub_messages");
    }

    s.on_friends = function()
    {
        goHubPanel("hub_friends");
    }


    s.on_games = function()
    {
        goHubPanel("hub_games_main");
    }

    s.on_me = function()
    {
        goHubPanel("hub_change_avatar");
    }

    s.on_coins = function()
    {
        goHubPanel("hub_coins");
    }

    s.on_parent = function()
    {
        goHubPanel("hub_parent_home");
    }
    s.on_settings = function()
    {
        goHubPanel("hub_settings");
    }
    s.on_change = function()
    {
        goHubPanel("change_player", null, {bInHub:true});
    }
    makeHubButtons();
    function onNotifications(r){
        if (r.bSuccess) {
            var notifications = r.notifications;
            var newInvitations = notifications.newInvitations;
            var newNotes = notifications.newNotes;
            addNotifications(hubButtons["hub_friends"], newInvitations);
            addNotifications(hubButtons["hub_messages"], newNotes);
        }
    }
    function getNewNotifications(){
        FPWebRequestWithCache("Account",
            {command: "getNotifications"},
            onNotifications, null,
            "mostRecentNotifications", "person");
    }
    s.registerForNotification("notifications");
    s.onNotification_notifications = function()
    {
        getNewNotifications();

    }

    s.onUpdateHub(gHubState); // sync to initial state
    // we don't need to load the panel until the hub button is pushed
    //    goHubPanel("hub_home");

    s.doUpdateHubPanel = function(newPanel, panelArgs, bNoTransition)
    {
        var b = hubButtons[newPanel];
        hubScroll.scrollToElement(b);
        goHubPanel(newPanel, bNoTransition, panelArgs);
    }
    $(hubFrame).bind('updateHubPanel', function(e, newPanel, panelArgs) {
        s.doUpdateHubPanel(newPanel, panelArgs);
    });
    $(hubFrame).bind('showAnimateMessage', function(e, str, callback){
        messageSlideDown(s, str, gFullWidth, (FPIsLandscape()?0:72), callback);
    });

    $(hubFrame).bind('updateHubTabsTxt', function() {
        buttonNames = [i18n("_HOME"),i18n("_GAMES"),i18n("_FRIENDS"),i18n(appSettings.wall),i18n("_COINS"),i18n("_ME"),i18n("_PARENT"), i18n("_CHANGE"),i18n("_SETTINGS")];
        var i = panelNames.length;
        while(i--){
            var id = panelNames[i];
            var bt = hubButtons[id];
            if (bt){
                bt.l1.text.innerText = buttonNames[i];
            }
        }
    });
};

FPLaunchScreen(o);


function addNotifications(bt, num){
    var appSettings = getAppSetting();
    var val = parseInt(num, 10);
    if (val>0){
        val = val > 9? "9+":val;
        if (bt.noti_sign){
            bt.noti_sign.text.innerText = val;
            $(bt.noti_sign).css({display:"block"});
        }else{
            var noti_sign = label({parent: bt, id:"notification_sign", string:val, x:appSettings.hubBtSize - 13, y:1, w:10, h:10, center:true, size:9});
            $(noti_sign).css({
                float:"right",
                backgroundColor:"#e62329",
                borderRadius:10*gScaleX,
                border: 1.5*gScaleX+"px solid white"});
            bt.noti_sign = noti_sign;

            $(noti_sign.text).css({top:1*gScaleX});


        }

    }else if (bt.noti_sign){
        // num is zero remove noti_sign
        $(bt.noti_sign).remove();
        bt.noti_sign = null;
    }

}


