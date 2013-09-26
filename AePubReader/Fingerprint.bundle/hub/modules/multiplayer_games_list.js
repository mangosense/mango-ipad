var FPMultiplayerList = {};
FPMultiplayerList.goGame = function(gameId, s, type)
{
    YourTurn.SetActiveGame(gameId);
    if (type === "play"){
        YourTurn.bContinuePlay = true;
    }else{
        YourTurn.bContinuePlay = false;
    }
    function onClosed()
    {
        function next()
        {
            DoCloseMultiplayer();
        }
        setTimeout(next, 200); // TODO: fix: why is extra time needed on this transition?
    }
    s.close("down", onClosed);
};
FPMultiplayerList.getTimeText = function(started)
{
    var timePassed = new Date().getTime() - new Date(started).getTime();
    var days, hours, minutes;
    var l = (days = parseInt(timePassed/1000/60/60/24)) && days > 0 ? days + (days>1?i18n("_DAYS"):i18n("_DAY")):(
            (hours = parseInt(timePassed/1000/60/60)) && hours > 0 ? hours + (hours>1?i18n("_HOURS"):i18n("_HOUR")):(
            (minutes = parseInt(timePassed/1000/60)) && minutes > 0 ? minutes + (minutes>1?i18n("_MINUTES"):i18n("_MINUTE")):
            parseInt(timePassed/1000) + i18n("_SECONDS")));
    l += i18n("_AGO");
    return l;
};
FPMultiplayerList.Header = function(d, data, w, s)
{
    var imgData = FPCustomAssetsPosition(data.screenName, data.img);
    $(d).css("height", (imgData.h+imgData.y)*gScaleY);
    image(imgData, {parent:d});
    var strId = data.headerText.match(/\w*/).join("_");
    strId = "_"+strId.toUpperCase();
    label(FPCustomAssetsPosition(data.screenName, data.headerText),{parent:d, string:i18n(strId), font:data.font} );
};
FPMultiplayerList.Game = function(d, data, w, s)
{
    $(d).css("height", 60*gScaleY);
    var imgPatten = (data.headerText === "TAKE A TURN TO EARN COINS!")?"yourturn-mid.png":"finishedgames-mid.png";
    image(FPCustomAssetsPosition(data.screenName, imgPatten), {parent: d, h: 60});
    var line = div({parent: d, x: 20, w: 280, h: 60, color: null});
    var playerName = data.playerNames[data.opponentIndex];
    var l1;
    if (playerName.length > 0) {
        if (data.headerText ==="FINISHED GAMES"){
            l1 = "With " +playerName;
        }else{
            l1 = playerName;
        }
    } else {
        l1 = i18n("_FINDING_OPPONENT");
    }
    var l2 = FPMultiplayerList.getTimeText(data.started);
    if (data.bGameOver) {
        l2 = data.gameOverMessage;
    }
    if (data.headerText == "TAKE A TURN TO EARN COINS!"){
        var l = label({parent: line, w: 200, h: 40, x: 50, y: 12, size: 16, string: l1, color: "#6a6a6a", font:data.font});
        label({parent: line, w: 200, h: 40, x: 50, y: 32, size: 10, string: l2, color: "#807e81", font:"light font"});
        drawAvatar(line, data.playerAvatars[data.opponentIndex], FPIsParentInCurrAcc(data.playerIds[data.opponentIndex])?"parent":"friend", "playerIcon." + data.id, 35, 2, 5, true);

        var btImg = "button-coins.png";
        var btText = i18n("_PLAY");
        if (data.finalMove) {
            btImg = "button-coins.png";
            btText = "Coin";
        }
        var b = button(FPCustomAssetsPosition(data.screenName, btImg), {parent: line, idleover:"same", id: "game." + data.id, string:btText, font:data.font});
    }else{
        var l = label({parent: line, w: 200, h: 40, x: 5, y: 12, size: 16, string: l1, color: "#6a6a6a", font:data.font});
        label({parent: line, w: 200, h: 40, x: 5, y: 32, size: 10, string: l2, color: "#807e81", font:"light font"});
        var str = data.headerText === "WAITING FOR"? i18n("_VIEW") :i18n("_RESULTS");
        var l = label(FPCustomAssetsPosition(data.screenName, "view"), {parent: line, id:"view." + data.id, w: 80, h: 40, x: 210, y: 28, size: 12, string: str, font:data.font});
        $(l).addClass("viewGame");
       if (data.headerText == "WAITING FOR" && data.playerNames[data.opponentIndex]!==""){
            button(FPCustomAssetsPosition(data.screenName, "button-nudged.png"), {parent: line, idleover:"same", id: "nudged." + data.id, string: i18n('_NUDGED'), font:data.font});
            var nudgedData = FPGetPersonValue("nudged");
            if (!nudgedData[data.id]){
                button(FPCustomAssetsPosition(data.screenName, "smallbutton.png"), {parent: line, idleover:"same", id: "nudge." + data.id, string: i18n('_NUDGE'), font:data.font});
            }
        }
        var eventName = window["FPNative"]?"touchend":"click";
        $(l).bind(eventName, function(){
            var index = parseInt($(".viewGame").index(this));
            var gameId;
            if (index < YourTurn.games.theirTurn.length){
                gameId =  YourTurn.games.theirTurn[index].id;
            }else{
                index -= YourTurn.games.theirTurn.length;
                gameId =  YourTurn.games.gameOver[index].id;
            }
            FPMultiplayerList.goGame(gameId, s, "view");
        });
    }

    line.on_game = function(gameId)
    {
        FPMultiplayerList.goGame(gameId, s, "play");
    };
    line.on_playIcon = function(gameId)
    {
        FPMultiplayerList.goGame(gameId, s, "play");
    };
    line.on_nudge = function(gameId)
    {
        var game = YourTurn.gameMap[gameId];
        // send a nudge
        sendNudge(gameId, next);
        function next(){
            $(s.button["nudge."+gameId]).hide();
            var nudgedData = FPGetPersonValue("nudged");
            nudgedData[data.id] = true;
            FPSetPersonValue("nudged", nudgedData);
            showResponseMsg("A friendly reminder has been sent to your opponent!");
        }
    };
    line.on_nudged = function(gameId)
    {
        showResponseMsg("You have already sent a reminder to this opponent.");
    }
    function showResponseMsg(str){
        var p = div({parent: s, x:0, y: 72, w: gFullWidth, h: gFullHeight - 20 +1});
        messageSlideDown(p, str, gFullWidth, 0, next);
        function next(){
            $(p).remove();
        }
    }
};

FPMultiplayerList.Bottom = function(d, data, w, s){
    // add waiting section at the bottom at the your turn list
    switch(data.headerText){
        case "TAKE A TURN TO EARN COINS!":
            if (data.gameLength>0){
                addNewGameBottom();
            }
            break;
        case "WAITING FOR":
            if (YourTurn.games.gameOver.length===0){
                addImgBottom();
            }
            break;
        case "FINISHED GAMES":
            if(YourTurn.games.gameOver.length>0){
                addImgBottom();
            }
            break;
    }
    if (data.spacer){
        // spacer
        div({parent: d, x:0, w:320, h: data.spacer});
    }

    var imgData;
    function addImgBottom(){
        var imgData = FPCustomAssetsPosition(data.screenName, data.imgName);
        $(d).css("height", (imgData.h+data.spacer)*gScaleY);
        var img = image(imgData, {parent: d});
    }

    function addNewGameBottom(){
        imgData = FPCustomAssetsPosition(data.screenName, "button-newgame3.png");
        $(d).css("height", (imgData.h+data.spacer)*gScaleY);
        var newgame = image(imgData, {parent:d, id:"newGame", y:0});
        button(FPCustomAssetsPosition(data.screenName, "newgame3"),{parent:d, src:gImagePath+"blank", idleover:"same", string: i18n('_NEW_GAME'), id:"newGame3", y:15, font:data.font} );

        var eventName = window["FPNative"]?"touchend":"click";
        $(newgame).bind(eventName, function(){runScreen(s, "yourturn/create", "left", data.onGotGame);});
        d.on_newGame3 = function(){
            runScreen(s, "yourturn/create", "left", data.onGotGame);
        }
    }
};
FPMultiplayerList.NewGame1 = function(d, data, w, s){
    var imgData = FPCustomAssetsPosition(data.screenName, "button-newgame1.png");
    $(d).css("height", (imgData.h+imgData.y)*gScaleY);
    FPCustomListAddOn(d, "new game 1");
    button(FPCustomAssetsPosition(data.screenName, "button-newgame1.png"), {parent: d, idleover:"same", id: "add1", string: i18n('_NEW_GAME'), font:data.font});
    d.on_add1 = function(){
        if (FPHaveAccountToken()) {
            runScreen(s, "yourturn/create", "left", data.onGotGame);
        } else {
            function onPing(r)
            {
                if (r.ping) {
                    FPWebView.eval("login", "FPContinueGuestRegistration()", null);
                } else {
                    DoAlert(i18n("_OFFLINE"), i18n("_CANNOT_REACH_FINGERPRINT", {partner: getAppSetting().partnerName}));
                }
            }
            FPWebRequest("Ping", {}, onPing);
        }
    };
};
FPMultiplayerList.NewGame2 = function(d, data, w, s){
    $(d).css("height", 100*gScaleY);
    FPCustomListAddOn(d, "new game 2");
    button(FPCustomAssetsPosition(data.screenName, "button-newgame2.png"), {parent: d, idleover:"same", id: "add2", string: i18n('_NEW_GAME'), font:data.font});
    d.on_add2 = function(){
        runScreen(s, "yourturn/create", "left", data.onGotGame);
    };
};
FPMultiplayerList.RandomAvatar = function(d, data, w, s){
    $(d).css("height", 60*gScaleY);

    // NOTE: this math is the same as the math in utils.js drawAvatar
    // TODO: make it common?
    var radius = 40;
    var bgColor = "#07793b";
    var borderNum = parseInt(0.07*gScaleX*radius);
    borderNum = borderNum>3?borderNum:3;
    var border = borderNum+"px solid white";

    // box to clip the area with the changing avatar - note that it has a white border that you
    // can't see - this makes it so it uses the same w/h and will have the correct size
    var box = div({parent: d, x:10, y:10, w:radius, h: radius, color: "#07793b"});
    $(box).css("border", border);

    // the sliding images element - called "coverflow"
    var coverflow = div({id: "container", w: radius*8, h: radius, x:0, y:2}, {parent:box});
    $(coverflow).attr("class", "container");
    for (var i= 0; i< 7; i++) {
        var innerDiv = image({parent: coverflow,src:gImagePath+"avatar1"+i, x:0+i*45, y:0, w:39, h:39});
        $(innerDiv).attr("class", "player");
    }
    var rulesText = "@-webkit-keyframes containerAnimation {";
    var interval = parseInt(100/8);
    for (var i= 0; i< 8; i++) {
        rulesText += (0+i*interval) + "% {left:"+(i*45*gScaleX-45*7*gScaleX)+"px;}    ";
        rulesText += (0+i*interval+5) + "% {left:"+(i*45*gScaleX-45*7*gScaleX)+"px;}    ";
    }
    rulesText += "100% {left: "+33*gScaleX+"px;}}";
    cssAnimation(rulesText);
    $(coverflow).css("-webkit-animation", "containerAnimation 10s infinite");

    // big white ring that's thicker than what we want to display - the inner rim clips the
    // coverflow, and the outer rim gets clipped by "box" so that it doesn't go beyond the square
    var animateBox = div({parent: box, x: -20, y: -20, w: radius, h: radius, color: null});
    $(animateBox).css("border", "" + (20*gScaleX) + "px solid white");
    $(animateBox).css("border-radius", 100*gScaleX);

    // the actual ornamental white ring with drop show - drawn ON TOP of the circle that does the clipping
    var avatarElem = div({parent: d, x:10, y:10, w:radius, h: radius});
    $(avatarElem).css("border-radius", 100*gScaleX);
    $(avatarElem).css("border", border);
    $(avatarElem).css("box-shadow", "1px 1px 3px #999999");
    $(avatarElem).css("background-color", null);

    label(data.t_name, { parent: d, y:25, string: i18n('_RANDOM_MATCH') });
    button(data.t_button, {parent: d, id: "random", y:20});
    d.on_random = function(){
        FPMultiplayerList.StartGame({}, data.onGotGame, s);
    };
};
FPMultiplayerList.CreateGame = function(d, data, w, s){
    $(d).css("height", 60*gScaleY);
    var line = div({parent:d, x:0, w:320, h:60});
    drawAvatar(line, data.avatar, FPIsParentInCurrAcc(data.person_id)?"parent":"friend", "icon", 40, 10, 10, false);
    label(data.t_name, {parent: line, y:25, string: data.name});
    button(data.t_button, {parent: line, idleover:"same", id: "Name."+ data.i, y:20});

    line.on_Name = function(){
        var RequestData = {
            appId: FPGetGameId(),
            opponentId: data.person_id
        };
        FPMultiplayerList.StartGame(RequestData, data.onGotGame, s);
    }
};
FPMultiplayerList.PracticeRound = function(d, data, w, s){
    var imageData = FPCustomAssetsPosition(data.screenName, "button-practice-round.png");
    $(d).css("height", (imageData.h+imageData.y+10)*gScaleY);
    button(imageData, {parent: d, idleover:"same", id: "practice", string: i18n('_PRACTICE_ROUND'), font:data.font});
    d.on_practice = function()
    {
        s.close();
        if (data.onGotGame) {
            data.onGotGame(null);
        }
    }
};
FPMultiplayerList.StartGame = function(data, callback, s){
    var createResponse = null;
    function onAddResponse(r){
        createResponse = r;
    }
    // not ready to continue until we get the add response AND have fetched the new games - need
    // to be able to decide immediately if it's "my turn" when onGotGame gets called
    function onContinue(){
        function onOK(){
            s.close();
            if (createResponse.id && createResponse.id.length > 0) {
                if (callback){
                    callback(createResponse.id);
                }
            }
        }

         // already waiting message will show when three waiting for opponent game have been created
         if (createResponse.response == "already waiting") {
            DoAlert("", i18n("_YOU_ARE_ALREADY_WAITING"));
         } else {
            // we always get a game now, but may no have an opponent
            // auto-linking of accounts will now happen on the server-side
            onOK();
         }
    }
    console.log("random game - opponent not specified");
    // random game - opponent not specified
    FPWebBatchStart();
    YourTurn.Request("create", data, onAddResponse);
    requestGames();
    FPWebBatchSend(onContinue, null, "Starting Game");
}