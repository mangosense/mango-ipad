//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

// index.js
orientation("vertical");
end();

// logic.js
o = function(s, args) {

    var bParentViewing = (FPIsParent());

    if (bParentViewing) {
        FPCreateProfileScreen(s, "All Children", args.person, [i18n("_PROGRESS"), i18n("_NOTES"), i18n("_GAMES")], true);
    } else {
        FPCreateProfileScreen(s, "Family", args.person, [i18n("_NOTES"), i18n("_GAMES")], true);
    }


    var messageSection;

    function showTab(tabIndex)
    {
        // make new list each time we change tabs so that asynchronous loads can be ignored if they arrive after tab has changed
        var list = FPSmartList.create(s.contentBoxArea, s, 0, 0, 320, gHubHeight-115, [FPChildOverview,FPListItem]);

        // child is missing Progress Tab...
        if (!bParentViewing) {
            tabIndex++;
        }

        messageSection = null;
        switch (tabIndex) {
            case 0:
                // progress
                // all progress reports that are progress report only about this person
                function onReports(r, list_id) {
                    var prepend = [];
                    prepend.push({t: "childOverview", report_id: args.person.person_id, person: args.person, buttonIndex: 0, bAvatarButton: false});
                    FPSmartList.smartUpdate(list, list_id, r, "reports", "report_id", "progressReport", prepend);
                }
                FPWebRequestWithCache("Feed",
                    {command: "getChildProgressReports", child_id: args.person.person_id},
                    onReports, list.list_id,
                    "childProgressReports_" + args.person.person_id, "account");
                break;
            case 1:
                // Messages
                messageSection = FPSmartList.addEditListSection(
                    list,
                    "message_id",
                    {t: "message"},
                    "messages",
                    null,
                    "Feed", {command: "getConversation", other_person_id: args.person.person_id},
                    "conversation_" + args.person.person_id, "person");
                break;
            case 2:
                // Games
                function onGameList(r, list_id) {
                    FPSmartList.smartUpdate(list, list_id, r, "games", "game_id", "game", []);
                }
                FPCreateGameList(args.person.person_id, onGameList, list.list_id);
                break;
        }
    }

    s.on_back = function()
    {
        s.close();
    }

    s.on_send = function()
    {
        function next()
        {
            runScreen(s, "hub_create_message", "down", {id:args.person.person_id});
        }
        DoParentGate(next);
    }

    s.on_tab = function(tabIndex)
    {
        showTab(tabIndex);
    }

    s.registerForNotification("message");
    s.onNotification_message = function()
    {
        if (messageSection) {
            messageSection.refresh();
        }
    }

    showTab(0);
};

FPLaunchScreen(o);
