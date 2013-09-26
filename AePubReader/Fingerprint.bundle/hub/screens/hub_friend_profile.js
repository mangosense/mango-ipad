//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

// index.js
orientation("vertical");
end();

// logic.js
o = function(s, args) {

    FPCreateProfileScreen(s, i18n("_ALL_FRIENDS"), args.friend, [i18n("_GAMES"), i18n("_NOTES"), i18n("_FRIENDS")], false);


    var messageSection;

    function showTab(tabIndex)
    {
        // make new list each time we change tabs so that asynchronous loads can be ignored if they arrive after tab has changed
        var list = FPSmartList.create(s.contentBoxArea, s, 0, 0, 320, gHubHeight-115, [FPChildOverview,FPListItem]);

        messageSection = null;
        switch (tabIndex) {
            case 0:
                // Games
                function onGameList(r, list_id) {
                    FPSmartList.smartUpdate(list, list_id, r, "games", "game_id", "game", []);
                }
                FPCreateGameList(args.friend.person_id, onGameList, list.list_id);
                break;
            case 1:
                // Messages
                messageSection = FPSmartList.addEditListSection(
                    list,
                    "message_id",
                    {t: "message"},
                    "messages",
                    null,
                    "Feed", {command: "getConversation", other_person_id: args.friend.person_id},
                    "conversation_" + args.friend.person_id, "person");
                break;
            case 2:
                // Friends
                s.actionText = i18n("_VISIT");
                function onFriends(r, list_id) {
                    FPSmartList.smartUpdate(list, list_id, r, "friends", "person_id", "friend", []);
                }
                FPWebRequestWithCache("Account",
                    {command: "getFriends", friend_id: args.friend.person_id, bIncludeFamily: false},
                    onFriends, list.list_id,
                    "friends_of_" + args.friend.person_id, "person");
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
            runScreen(s, "hub_create_message", "down", {id:args.friend.person_id});
        }
        DoParentGate(next);
    }

    s.on_tab = function(tabIndex)
    {
        showTab(tabIndex);
    }

    s.on_friend = function(friend)
    {
        // transition to new version of this same screen - preserve the same screen stack
        var parent = s.parent;
        s.parent = null; // TODO: fix this screen bug workaround
        runScreenCloser(s, "right");
        runScreen(parent, "hub_friend_profile", "left", {friend:friend});
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
