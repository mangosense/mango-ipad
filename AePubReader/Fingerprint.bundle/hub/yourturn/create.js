// index.js
orientation("vertical");
end();

// logic.js
//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

o = function(s, onGotGame) {
    var fontName = FPCustomGetFontName();
    var screenName = "create";
    var createList;
    var data = [];
    init();
    var people;
    var friendsCircle;
    var friends;

    var t_name;
    var t_button;

    var bClosed = false;
    function onDelay()
    {
        if (!bClosed) {
            FPWebView.eval("hub", "showChallenge(true)");
        }
    }
    setTimeout(onDelay, 1000);
    s.onScreenClose = function()
    {
        bClosed = true;
        FPWebView.eval("hub", "showChallenge(false)");
    }

    function init()
    {
        image(FPCustomAssetsPosition(screenName, "background.png"),{parent:s, x:0, y:0, w:gFullWidth, h:gFullHeight});
        image(FPCustomAssetsPosition(screenName, "challenge-someone.png"), {parent: s, id: "title"});
        label(FPCustomAssetsPosition(screenName, "challenge-someone-text"),{parent:s, string: i18n('_CHALLENGE_SOMEONE'), center:true, font:fontName} );
        FPCustomCreateAddOn(s);
        image(FPCustomAssetsPosition(screenName, "yourturn-mid.png"), {parent: s});
        image(FPCustomAssetsPosition(screenName, "game_logo.png"), {parent: s});
        image(FPCustomAssetsPosition(screenName, "yourturn-bottom.png"), {parent: s});
        button({string: "", size: 16}, FPCustomAssetsPosition(screenName, "button-findfriends.png"), {parent: s, idleover:"same", id: "moreFriends", string:i18n("_FIND_FRIENDS").toUpperCase(), oy: -3, center:true, vCenter:true, font:fontName});
        button({string: ""}, FPCustomAssetsPosition(screenName, "button-back.png"), {parent: s, id:"cancel", idleover:"same", size: 16});

        // fetch all family member
        people = FPGetAccountActivePeople();

        // need to remove the current player from the list - can't start a game against yourself
        var count = people.length;
        for (var i=0; i<count; i++) {
            if (people[i].person_id === FPGetPersonId()) {
                people.splice(i, 1);
                break;
            }
        }

        // fetch all the friends
        friends = FPGetFriends(null);

        var boxData = FPCustomAssetsPosition(screenName, "friendBox");
        createList = FPSmartList.create(s, s, boxData.x, boxData.y, boxData.w, boxData.h, [FPMultiplayerList]);
        $(createList).css("background-color","transparent");

        t_name = cascade({size: 16, color:"#6a6a6a", x: 65, w:150, h:40, font:fontName});
        t_button = cascade(FPCustomAssetsPosition(screenName, "smallbutton.png"), {idleover:"same", string: i18n('_PLAY'), font:fontName});

        renderFriendList();






    }


    function renderFriendList()
    {
        data = [];
        if (friends){
            friendsCircle = people.concat(friends);
        }

        var numFriends = 0;
        if (friendsCircle){
            numFriends = friendsCircle.length;
        }
        data.push({t:"RandomAvatar",
            id:"multiplayerListRandomAvatar",
            t_name:t_name,
            t_button:t_button,
            screenName:screenName,
            font:fontName,
            onGotGame:onGotGame});

        for (var i = 0; i< numFriends; i++)
        {

            if (friendsCircle[i].person_id !== FPGetPersonId()){
                var name = friendsCircle[i].name;
                data.push({t:"CreateGame",
                    id: name+"CreateGame",
                    name:name,
                    numFriends:numFriends,
                    t_name:t_name,
                    t_button:t_button,
                    person_id:friendsCircle[i].person_id,
                    avatar:friendsCircle[i].avatar,
                    onGotGame:onGotGame,
                    i:i,
                    screenName:screenName, font:fontName});
            }
        }
        if (FPGetAppValue("bPracticeRound") === "true") {
            data.push({t:"PracticeRound",
                id:"multiplayerListBottom_practice",
                screenName:screenName,
                font:fontName,
                onGotGame:onGotGame});
        }
        FPSmartList.update(createList, data);
    }
    s.on_moreFriends = function()
    {
        runScreen(s, "hub_find_friends", "left");
    };
    s.on_cancel = function()
    {
        s.close("left");
    };
    s.refresh = function()
    {
        renderFriendList();
    };
};

FPLaunchScreen(o);



