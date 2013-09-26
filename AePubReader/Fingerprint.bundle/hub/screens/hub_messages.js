// index.js
orientation("vertical");

end();

// logic.js
//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

o = function(s, args) {

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    var list;
    var data = [];
    var feedSectionCount = 5;

    var messageSection;

    init();
    function init()
    {
        button({parent: p, src:gImagePath+"greenbutton_half", idleover:"same", x: 210, h: 30, w: 100, y: 5, size: 12, id: "send", string: i18n('_SEND_NOTE')});
        list = FPSmartList.create(p, s, 0, 40, 320, gHubHeight-40, [FPListItem]);

        /*
         TODO
         WALL
         - game recommendation (if you don't have everything)
         - friends may know (1 suggestion, if possible)
         - game/friend invites (game invite - play/get accepts the fridn request)  (ALL)
         - notes (ALL)
         - platform events (ALL)?
         */

        // game recommendation filter - add bInstalled
        function onRecommendedGames(o, callback) {
            function onInstalled(bInstalled)
            {
                o.bInstalled = bInstalled[o.game_id];
                callback([o]); // make it an array of 1 item
            }
            FPHelper.areGamesInstalled([o.game_id], onInstalled);
        }

        FPWebBatchStart();

        FPSmartList.addEditListSection(
            list,
            "game_id",
            {t: "game", margin: 10},
            "recommendation",
            onRecommendedGames,
            "Feed", {command: "getRecommendedGame"},
            "recommendedGame", "person");

        FPSmartList.addEditListSection(
            list,
            "person_id",
            {t: "friendMayKnow", margin: 10},
            "friendsMayKnow",
            null,
            "Account", {command: "getFriendsMayKnow", count: 2},
            "friendsMayKnow2", "person");

        FPSmartList.addEditListSection(
            list,
            "id",
            {t: "friendInvites", margin: 10},
            "messages",
            null,
            "Feed", {command: "getMessages", type:"makeFriend"},
            "friendInvites", "person");

        messageSection = FPSmartList.addEditListSection(
            list,
            "message_id",
            {t: "message", margin: 10},
            "messages",
            null,
            "Feed", {command: "getMessages", type:"reply"},
            "notes", "person");

        FPSmartList.addEditListSection(
            list,
            "report_id",
            {t: "progressReport"},
            "reports",
            null,
            "Feed", {command: "getWallProgressReports"},
            "platformEvents", "person");

        FPWebBatchSend();
    }

    p.on_send = function()
    {
        function next()
        {
            runScreen(p, "hub_friends", "left", {bPickRecipient:true});
        }
        DoParentGate(next);
    }

    s.registerForNotification("message");
    s.onNotification_message = function()
    {
        messageSection.refresh();
    }
};

FPLaunchScreen(o);



