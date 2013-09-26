//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

// index.js
orientation("vertical");
end();

function FPShowNoFriends(parent, bPickRecipient, s)
{
    var p = div({parent: parent, x: 0, y: 40, w: 320, h: gHubHeight-40, color: "#ffffff"});
    if (bPickRecipient){
        image({parent: p, src:gImagePath+"notes_shortcut", x: 120, w: 80, h: 90, y: 20});
        label({parent: p, x: 40, h: 50, w: 240, y: 140, size: 14, font: "light font", string: i18n('_YOU_DONT_HAVE_ANYONE'), color:"#4e4e4e", center: true});
        button({parent: p, id: "findFriend", src:gImagePath+"greenbutton_half",x: 100, y: 190, w: 120, h: 40, size: 14, string: i18n('_FIND_FRIENDS_NOW'), idleover:"same"});

        p.on_findFriend = function (){
            function next()
            {
                var parent = s.parent;
                s.parent = null;
                runScreenCloser(s, "right");
                runScreen(parent, "hub_find_friends", "left", {noCenter:true});
            }
            DoParentGate(next);
        };

    }else{
        image({parent: p, src:gImagePath+"empty-friendlist", x: 0, w: 320, h: 134, y: 75});
        var a = image({parent: p, src:gImagePath+"arrow", x: 240, w: 25, h: 20, y: 12});
        a.style.webkitTransform = "scaleX(-1)";
        label({parent: p, x: 20, h: 70, w: 280, y: 230, size: 14, font: "light font", string: i18n('_ADD_FRIENDS_AND_SEE'), color:"#4e4e4e", center: true});
        label({parent: p, x: 140, h: 70, w: 110, y: 15, size: 14, string: i18n('_START_HERE_TO_ADD'), color:"#a6a6a6"});

    }


    return p;
}

// logic.js
o = function(s, args) {

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    p.buttonParent = s;

    var person_id = FPGetPersonId();
    var bPickRecipient = (args && args.bPickRecipient);
    var friendCountLabel;
    var list = FPSmartList.create(p, s, 0, 40, 320, gHubHeight-40, [FPListItem]);
    var noFriend = true, responses = 0;
    var invitationsSection;
    if (bPickRecipient) {
        label({parent: p, x: 80, h: 35, w: 160, y: 0, size: 14, string: i18n('_SEND_NOTE_TO'), color:"#4a4a4a", center: true, vCenter:true});
        button({parent: p, src:gImagePath+"graybutton_half", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "cancel", string: i18n('_CANCEL')});
        s.actionText = i18n("_SEND");
    } else {
        invitationsSection = FPSmartList.addEditListSection(list, "id");
        s.actionText = i18n("_VISIT");
        button({parent: p, src:gImagePath+"greenbutton_half", idleover:"same", x: 210, h: 30, w: 100, y: 5, size: 12, id: "moreFriends", string: i18n('_ADD_FRIENDS')});
        friendCountLabel = label({parent: p, x: 10, h: 35, w: 180, y: 12, size: 14, id: "numofFriends", string: "", color:"#4a4a4a"});


    }


    function updateText(){
        var didGetResponses = bPickRecipient?(responses>0):(responses>1);
        if (noFriend && didGetResponses && FPGetAccountPeople().length < 2 && FPGetAccountValue("friends").length < 1){
            noFriend = FPShowNoFriends(p, bPickRecipient, s);
        }else{
            if (noFriend){
                $(noFriend).remove();
            }
        }
    }
    function onUpdatedInvites(r){
        var invitesCount = r?r.length:0;
        // update list with summary of friends invites
        if (invitesCount){
            if (!bPickRecipient){
                var invitationsData = [{t: "invitationSummary", id:"invitations_count",  text: (invitesCount) + (invitesCount>1?" "+i18n("_INVITATIONS"):" "+i18n("_INVITATION"))}];
                invitationsSection.update(invitationsData);
            }
            noFriend = false;
        }
        responses++;


    }
    function onUpdatedFriends(r){
        var friendsCount = r?r.length:0;
        if (friendsCount){
            if (!bPickRecipient){
                friendCountLabel.text.innerHTML = (friendsCount) + (friendsCount>1?" "+i18n("_FRIENDS"):" "+i18n("_FRIEND"));
            }
            noFriend = false;
        }
        responses++;

    }
    function updateFriends()
    {
        FPWebBatchStart();
        if (!bPickRecipient)
        {
            FPSmartList.addEditListSection(
                list,
                "message_id",
                {t: "friendInvites", margin: 10},
                "messages",
                null,
                "Feed", {command: "getMessages", type:"makeFriend"},
                "friendInvites", "person", onUpdatedInvites);
        }


        FPSmartList.addEditListSection(
            list,
            "person_id",
            {t: "friend", margin: 10},
            "friends",
            null,
            "Account", {command: "getFriends", friend_id: person_id, bIncludeFamily:true},
            "friendsInFriendTab", "account", onUpdatedFriends);


        FPWebBatchSend(updateText);
    }

    updateFriends();

    s.on_friend = function(person)
    {
        if (bPickRecipient) {
            var parent = s.parent;
            s.parent = null;
            runScreenCloser(s, "right");
            runScreen(parent,"hub_create_message", "left", {id:person.person_id});
            parent = null;
        } else {
            runScreen(s, "hub_friend_profile", "left", {friend:person});
        }
    }

    s.on_moreFriends = function()
    {
        function next()
        {
            if (FPIsOffline()) {
                runScreen(s, "offline", "left", {what: "add friends"});
            } else {
                if (FPGetPersonValue("bHaveFriendsMayKnow")) {
                    runScreen(s, "hub_friends_mayknow", "down");
                }else {
                    runScreen(s, "hub_find_friends", "left", {noCenter:true});
                }
            }
        }
        DoParentGate(next);
    }

    // do not add cancel handler when cancel button is not on screen for android native back design
    if (bPickRecipient){

        s.on_cancel = function()
        {
            s.close();
        }
    }

    s.registerForNotification("friends");
    s.onNotification_friends = function()
    {
        updateFriends();
    }
};

FPLaunchScreen(o);



