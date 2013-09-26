//
//  Copyright 2012, 2013 Fingerprint Digital, Inc. All rights reserved.
//

orientation("vertical");
end();

var FPHomeListItem = {};

FPHomeListItem.welcomeSection = function(d, data, w, s)
{
    w-=20;
    $(d).css("margin-left", 10*gScaleX);
    $(d).css("margin-right", 10*gScaleX);

    var personName = FPGetPersonName();
    label({parent:d, id:"name", x:60, y:5, w:w-60, h: 30, string: i18n('_HI') + personName, size:20, color: "#4e4e4e", vCenter:true});
    var role = FPIsParent()?"parent":"family";
    drawAvatar(d, FPGetPersonAvatar(), role, "icon", 45, 2, 10, false);
    var spacer = div({parent: d, w: 1, h: 32});
    $(spacer).css("position", "relative");

    var text, panel, panelCatalog;

    if (gbShowCoinopia) {
        if (data.report && FPGetPersonCoins() > 0) {
            text = data.report.description;
            text = text.replace("Coin-O-Copia", "<span id='coinaction' style='color:#0000ff'>Coin-O-Copia</span>");
            panel = "hub_coins";
        } else {
            text = "You can earn coins by trying a <span id='coinaction' style='color:#0000ff'>new game!</span>";
            panel = "hub_games_main";
        }
    } else {
        var gHomeMessages = [
            {t: i18n('_HOME_MSG_1'), p: "hub_games_main", pc: "games"},
            {t: i18n('_HOME_MSG_2'), p: null, pc: null},
            {t: i18n('_HOME_MSG_3'), p: "hub_games_main", pc: "games"},
            {t: i18n('_HOME_MSG_4'), p: "hub_friends", pc: "friends"},
            {t: i18n('_HOME_MSG_5'),  p: "hub_friends", pc: "friends"}
        ];

        var x = d.x;
        if (x === undefined) {
            x = FPGetAppValue("homeMessage");
            if (x === undefined) {
                x = 0;
            } else {
                x++;
            }
            d.x = x;
        }
        FPSetAppValue("homeMessage", x);
        var o = gHomeMessages[x % gHomeMessages.length];
        text = o.t;
        var i1 = text.indexOf("[");
        panel = o.p;
        if (i1 != -1) {
            var i2 = text.indexOf("]");
            if (i2 != -1) {
                text = text.substring(0, i1) + "<span id='coinaction' style='color:#0000ff'>" + text.substring(i1+1, i2) + "</span>" + text.substring(i2+1);
            }
        }
    }

    var l = label({parent:d, x: 60, w: w-60, size:14, string: text, font: "light font", color: "#4a4a4a"});
    $(l).css("position", "relative");

    $("#coinaction").css("color", "#0000ff");
    $(l).bind("click", function() {
        $(s).trigger("updateHubPanel", [panel]);
    });

    // note sure why min-height was removed here in the past, but to be safe, make this is computed and safety clamped value
    var useH = $(l).height() + 31*gScaleY;
    if (useH < 73*gScaleY) {
        useH = 73*gScaleY;
    } else if (useH > 150*gScaleY) {
        useH = 150*gScaleY;
    }
    $(d).css("height", useH); // must be after setting the text
}

FPHomeListItem.gamePromo = function(gamesSection, data, w, s)
{
    w-=20;
    $(gamesSection).css("margin-left", 10*gScaleX);
    $(gamesSection).css("margin-right", 10*gScaleX);

    // creating show games section, refresh the page when go new games
    var gamesSectionHeight = 144;
    $(gamesSection).css("height", gamesSectionHeight*gScaleY);

    var newGames = GetAllGamesDataForDevice();
    var picsBox = div({parent:gamesSection, x:0, y:0, w:300, h:gamesSectionHeight});
    picsBox.id = "gameSection";
    var pics1 = div({parent:picsBox, x: 0, y:0, w:newGames.length*200, h:gamesSectionHeight});
    addBackgroundImage($(pics1), "gray-pattern.png");
    var ox = 0;
    // todo: first promote five Images, remove later
    var model = FPGetAppValue("model");
    var bIpad = !!(model && model.indexOf("iPad") != -1);
    var appInCenter = bIpad?"lolabig":"DIGITALLEARNINGKLM";
    var promoteImages = ["sid",appInCenter,"bug","rockout","veggiefree"];
    var promoteIds = ["sid",appInCenter,"bug","rockout","veggiefree"];

    // use may like games list from catalog, if available
    var maylike = GetMayLikeData();
    if (maylike) {
        promoteImages = maylike.promoteImages;
        promoteIds = maylike.promoteIds;
    }

    // just promote the newest five
    //for (var i=newGames.length-1; i>=0 && ox < 205*5; i--) {
    for (var i = 0; i< promoteImages.length; i++){
        //var assets = newGames[i];
        // todo: update catalog with new assets
        //if (assets.backdrop)
        //{
        //var img = image({parent: pics1, src:assets.backdrop, id:"game."+i, x: 0+ox, y: 5, w:200, h:140});
        var img = image({parent: pics1, src:gImagePath+promoteImages[i], id:"game."+i, x: 0+ox, y: 5, w:235, h:132});
        img.index = i;
        ox += 240;
        $(img).addClass("screenShot");
        $(img).bind("click", function() {
            $(s).trigger("updateHubPanel", ["hub_games_main", promoteIds[this.index]]);
        });
        //}
    }
    $(pics1).css("width", ox*gScaleX);

    var snapX = [0,208,448,688,900];
    for (var k=0; k<5; k++) {
        snapX[k]*=-gScaleX;
    }

    var pics1_iscroll = new iScroll("gameSection", {hScroll: true, bounce: false, snap: true, snapX:snapX});
    pics1_iscroll.scrollTo(-snapX[1], 0, 100, true);

}

o = function(s, args) {

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background

    var list = FPSmartList.create(p, s, 0, 0, 320, gHubHeight, [FPHomeListItem, FPListItem]);

    var welcomeSection = {t: "welcomeSection", id:"welcomeSection", change: 0};
    var messageCount = {t: "", id:"messageCount"};

    var topData;
    topData = [];
    topData.push(welcomeSection);
    topData.push({t: "sectionHeader", id:"sectionHeader_game", bg: "game_bg_header.png", string: i18n('_GAMES_YOU_MAY')});
    topData.push({t: "gamePromo", id:"gamePromo"});
    topData.push({t: "sectionHeader", id:"sectionHeader_messages", bg: "bg_pattern.png", string: i18n('_MESSAGES')});
    topData.push(messageCount);

    var botData = [];
    botData.push({t: "welcomeMessage"});

    var topSection = FPSmartList.addSection(list, "id", {});

    s.refresh = function()
    {
        welcomeSection.change++;
        topSection.update(topData);
    }

    // update welcome section with most recent coins event
    function onCoinEvent(r) {
        if (r && r.bSuccess) {
            welcomeSection.report = r.report;
            topSection.update(topData);
        }
    }

    // update messages summary
    function onGetMessageCount(r) {
        if (r && r.bSuccess && r.messageCount > 0) {
            var count = r.messageCount;
            if (count>1){
                messageCount.text = i18n("_YOU_HAVE")+ count + i18n("_NEW_NOTES");
            }else if (count===1){
                messageCount.text = i18n("_YOU_HAVE")+ count + i18n("_NEW_NOTES");
            }
            messageCount.t = "messageCount";
        } else {
            messageCount.t = "";
        }
        topSection.update(topData);
    }

    // game recommendation filter - add bInstalled
    function onRecommendedGames(o, callback) {
        function onInstalled(bInstalled)
        {
            o.bInstalled = bInstalled[o.game_id];
            callback([o]); // make it an array of 1 item
        }
        FPHelper.areGamesInstalled([o.game_id], onInstalled);
    }

    function onFriendsMayKnow(o, callback)
    {
        var bHaveFriendsMayKnow = (o && o.length > 0);
        FPSetPersonValue("bHaveFriendsMayKnow", bHaveFriendsMayKnow);
        callback(o);
    }

    FPWebBatchStart();

    if (gbShowCoinopia) {
        FPWebRequestWithCache("Feed",
            {command: "getMostRecentCoinsEvent"},
            onCoinEvent, null,
            "mostRecentCoinsEvent", "person");
    }
    
    FPWebRequestWithCache("Feed",
        {command: "getMessageCount", type:"reply"},
        onGetMessageCount, null,
        "MessageCount", "person");

    // for now, Android has only 1 game, so we can't recommend another
    if (!gbAndroid) {
        FPSmartList.addEditListSection(
            list,
            "game_id",
            {t: "game", margin: 10},
            "recommendation",
            onRecommendedGames,
            "Feed", {command: "getRecommendedGame"},
            "recommendedGame", "person");
    }

    FPSmartList.addEditListSection(
        list,
        "message_id",
        {t: "friendInvites", margin: 10},
        "messages",
        null,
        "Feed", {command: "getMessages", type:"makeFriend"},
        "friendInvites", "person");

    FPSmartList.addEditListSection(
        list,
        "person_id",
        {t: "friendMayKnow", margin: 10},
        "friendsMayKnow",
        onFriendsMayKnow,
        "Account", {command: "getFriendsMayKnow", count: 1},
        "friendsMayKnow1", "person");

    FPWebBatchSend();

    var botSection = FPSmartList.addSection(list, "id", {});
    topSection.update(topData);
    botSection.update(botData);


     /*
     - BOTTOM PART (messages):
     - message summary (need icon) (omitted if 0)
     - game recommendation (if you don't have everything)
     - game/friend invites (game invite - play/get accepts the fridn request)  (up to 5)
     - friends may know (up to 5)
     7 actions
     */

    s.registerForNotification("coins");
    s.onNotification_coins = function()
    {
        FPWebRequestWithCache("Feed",
            {command: "getMostRecentCoinsEvent"},
            onCoinEvent, null,
            "mostRecentCoinsEvent", "person");
    }

    s.registerForNotification("message");
    s.onNotification_message = function()
    {
        FPWebRequestWithCache("Feed",
            {command: "getMessageCount", type:"reply"},
            onGetMessageCount, null,
            "MessageCount", "person");
    }
};

FPLaunchScreen(o);

