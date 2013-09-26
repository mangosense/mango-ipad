// index.js
orientation("vertical");

end();

// logic.js
//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

o = function(s, gotoId) {
    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background


    function next()
    {

        // mark the games is installed
        // creating show games section, refresh the page when go new games
        var assets,
            screenShot,
            playButton,
            getItButton,
            comingsoon,
            bScrolling = false,
            oldPos = {};

        var allGames = GetAllGamesDataForDevice();
        var numAllGame = allGames? allGames.length: 0;
        var preGame = numAllGame>0?allGames[numAllGame-1].appId:"";
        var gameIcons = div({parent:p, x: 0, y:180, w:320, h:gHubHeight-180});
        gameIcons.id = "gameIconsList";
        addBackgroundImage($(gameIcons), "dark-gray-pattern.png");
        var iconRows = Math.ceil(numAllGame/4);
        var realGameIconsList = div({parent:gameIcons, x: 0, y:0, w:320, h:iconRows*80});
        var gameIconsList = document.createDocumentFragment();
        var ox = 0;
        var oy = 0;
        var showOneFunc;
        function addButtonEvent(id, name){
            iconDiv["on_"+name]= function(i) {
                $(s.div["iconHighlight."+preGame]).css("border", "none");
                $(s.div["iconHighlight."+preGame]).css("background", "none");
                $(s.div["iconHighlight."+id]).css("background", "#182022");
                $(s.div["iconHighlight."+id]).css("border", 3*gScaleX+"px solid #58a0de");
                $(s.div["iconHighlight."+id]).css("border-radius", 15*gScaleX);
                preGame = id;
                assets = GetGameInfoByAppId(id);
                if (screenShot)
                {
                    $(screenShot).remove();
                    if (playButton) {
                        $(playButton).remove();
                        playButton = null;
                    }
                    $(getItButton).remove();
                    $(comingsoon).remove();
                }
                function showPlayButton()
                {
                    if (assets.video_ipad && assets.video_ipad.indexOf("mp4") != -1) {
                        playButton = button({parent:p, src:gImagePath+"button-play", id:"play", x:135,y:60, w:50, h:50, idleover:"same"});
                    }
                    if (gInstalledGames[id])
                    {
                        // playGame button
                        getItButton =button({parent:p, src:gImagePath+"greenbutton_half", id:"playGame", x:230, y:110, w:80, h:40, idleover:"same", string: i18n('_PLAY_NOW'), size: 12});

                    }else
                    if (GetGameStage(assets) !== "comingsoon")
                    {
                        // add get it button
                        getItButton = div({parent:p, id:"get", x:230, y:110, w:80, h:55});
                        image({parent:getItButton, src:gImagePath+"greenbutton_half", x:2, y:2, w:76, h:26});
                        label({parent:getItButton, x:2, y:4, w:76, h:20, string: i18n("_GET_IT_NOW"), center:true, vCenter:true, size:11});
                        var appStoreImg = gbAndroid? "GooglePlayStore": "AppStoreBadge";
                        image({parent:getItButton, src:gImagePath+appStoreImg, x:2, y:29, w:76, h:24});
                        $(getItButton).css({backgroundColor: "rgba(88, 88, 88, 0.8)"});
                        var eventName = window["FPNative"]?"touchend":"click";
                        bindEvent(getItButton, eventName, "button_get", onGetApp);

                    }else if (GetGameStage(assets) === "comingsoon")
                    {
                        var padding = 24, w = 35, h = 25, r = w/2;
                        comingsoon = label({parent:p, string:i18n("_COMING_SOON"), x:-(r+padding), y:0, w:w, h:h, color:"#ffffff", center:true, vCenter:true, size:8});
                        var addtionalStyle = {};
                        addtionalStyle.backgroundColor = "red";
                        addtionalStyle.paddingTop = (r+padding-h)*gScaleX+"px";
                        addtionalStyle.paddingLeft = (padding)*gScaleX+"px";
                        addtionalStyle.paddingRight = (padding)*gScaleX+"px";
                        addtionalStyle.webkitTransform = "rotate(-45deg)";
                        addtionalStyle.webkitTransformOrigin = "50% 0%";

                        $(comingsoon).css(addtionalStyle);

                    }
                }

                if (FPIsOffline()) {
                    $(getItButton).remove();
                } else {
                    screenShot = image({parent:p, src:GetCatalogURL(assets.backdrop2), id:"screenShot", x:0,y:0, w:320, h:180});
                    $(screenShot).css("box-shadow", "0px 3px 10px #111111");
                    LoadImages([GetCatalogURL(assets.backdrop2)], showPlayButton, null);

                }

            }
            if ((showOneFunc === undefined) || (id === gotoId)) {
                showOneFunc = iconDiv["on_"+name];
                showOneFunc.gameId = id;
                showOneFunc.gameName = name;
            }
        };
        var i = numAllGame;
        while (i--) {
            var iconDiv = div({parent:gameIconsList, id:"icons."+i, x:ox, y:oy, w:80, h:80});
            var game = allGames[i];
            var appId = game.appId;
            var name = game.name;
            var src = GetGameIcons(appId).src;
            var t_button = {parent:iconDiv, src:src, idleover:"same", id:name, x:10, y:10, w:60, h:60};
            div({parent:iconDiv, id:"iconHighlight."+appId, x:3, y:3, w:66, h:66});
            if(GetGameStage(game) === "new")
            {
                button(t_button, {imageBtn:{colors:["#ef1925", "#ef1925", "#ef1925"], string: i18n('_NEW')}});
            }else if (!gInstalledGames[appId] && GetGameStage(game) !=="nopromote")
            {
                var bComing = GetGameStage(game) === "comingsoon";
                var bannerName = bComing?i18n("_COMING"):i18n("_GET_IT");
                var bannerColor =  bComing?["#ef1925", "#ef1925", "#ef1925"]:["#3de24c", "#25c332", "#19b124"];
                // add get it image
                button(t_button, {imageBtn:{colors: bannerColor, string:bannerName}})
            }else
            {
                button(t_button);
            }
            if ( ox > 210)
            {
                oy += 80;
                ox = 0;
            }
            else
            {
                ox += 80;
            }
            addButtonEvent(appId, name);

        }

        realGameIconsList.appendChild(gameIconsList);
        gameIconsList = realGameIconsList;

        if (FPIsOffline()) {
            var offline = div({parent: p, x: 0, y: 0, w: 320, h: 180});
            label({parent:offline, string: i18n('_YOU_CAN_VIEW'), x:0,y:10, w:320, size: 18, center: true, color:"#4e4e4e"});

            image({parent: offline, src: gImagePath+"offline", x: (320-160)/2, y: 64, w: 160});
        } else {
            label({parent:p, string: i18n('_LOADING'), id:"loading", x:0,y:70, w:320, h:110, size: 18, center:true, color:"#4e4e4e"});
            // render the first qualified game's screenshot
            if (showOneFunc) {
                showOneFunc(showOneFunc.gameId, showOneFunc.gameName);
            }
        }

        p.on_play= function() {

            if (gbAndroid) {
                // TODO: consider whether Android should have it's own videos
                FPHelper.playVideo(assets.video_ipad, true, true, true, null);
            } else {
                // TODO: this is still probably not quite right for iOS, but leaving it alone as we fix Android
                FPHelper.playVideo(gScaleX > 1.5?assets.video_ipad:assets.video_iphone, true, true, true, null);


            }
        }
        p.on_playGame= function() {

            var data = {person_id:FPGetPersonId()};
            FPHelper.launchGame(assets.appId,data);


        }
        function onGetApp() {

            FPOpenAppStore(assets, false);
        }

        new iScroll("gameIconsList", {
            vScroll: true,
            bounce: false,
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
                }
        });
        $(gameIconsList).css("height", (oy+100)*gScaleY);
    }

    function init()
    {
        GetInstalledGames(next);
    }
    init();
};

FPLaunchScreen(o);



