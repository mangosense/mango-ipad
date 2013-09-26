//
//  Copyright 2012, 2013 Fingerprint Digital, Inc. All rights reserved.
//

// index.js
orientation("vertical");
end();

// logic.js
o = function(s, args) {

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background

    button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "back", string: i18n('_BACK')});
    button({parent: p, src:gImagePath+"greenbutton_full", idleover:"same", x: 5, h: 40, w: 310, y: gHubHeight-50, size: 18, id: "moreFriends", string: i18n('_FIND_MORE_FRIENDS')});
    label({parent: p, x: 100, h: 45, w: 200, y: 0, size: 14, vCenter:true, string: i18n('_FRIENDS_YOU_MAY'), color:"#4a4a4a"});

    var list = FPSmartList.create(p, s, 0, 40, 320, gHubHeight-100, [FPListItem]);

    function onFriendsMayKnow(r, list_id)
    {
        FPSmartList.smartUpdate(list, list_id, r, "friendsMayKnow", "person_id", "friendMayKnow", []);
    }
    FPWebRequestForEditList("Account",
        {command: "getFriendsMayKnow", count:10},
        onFriendsMayKnow, list.list_id,
        "friendsMayKnow", "account",
        "friendsMayKnow", "person_id");

    p.on_back = function()
    {
        s.close();
    }

    p.on_moreFriends = function()    {
        runScreen(s, "hub_find_friends", "left", {noCenter:true});
    }
};

FPLaunchScreen(o);



