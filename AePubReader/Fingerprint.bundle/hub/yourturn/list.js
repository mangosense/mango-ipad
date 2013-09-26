// index.js
orientation("vertical");
end();

// logic.js

o = function(s, args) {
    var gamesList;
    var personName = FPGetPersonName();
    var avatar = FPGetPersonAvatar();
    var fontName = FPCustomGetFontName();
    var screenName = "list";
    function onGotGame(gameId){
        // only go into the game if it's this player's turn
        if (YourTurn.IsMyTurn(gameId)) {
            function next()
            {
                FPMultiplayerList.goGame(gameId, s, "play");
            }
            setTimeout(next, 100);
        }
    }
    s.refresh = function ()
    {
        // update game list
        var data = [];

        if (YourTurn.games.yourTurn.length === 0 && YourTurn.games.theirTurn.length<=0 && YourTurn.games.gameOver.length<=0){
            data.push({t:"NewGame1", id:"multiplayerListNewGame1", screenName:screenName, font:fontName, onGotGame:onGotGame});
        } else if (YourTurn.games.yourTurn.length === 0 && (YourTurn.games.theirTurn.length>0 || YourTurn.games.gameOver.length>0)){
            data.push({t:"NewGame2", id:"multiplayerListNewGame2", screenName:screenName, font:fontName, onGotGame:onGotGame});

        }
        function gameSection(name, img, games, bGameOver)
        {
            if (name === "WAITING FOR"){
                var nudgesData = FPGetPersonValue("nudged")?FPGetPersonValue("nudged"):{};
                var tmp_nudgesData = {};
            }
            if (games.length > 0) {
                data.push({t:"Header", id:"multiplayerListHeader_"+name, img:img, headerText:name, screenName:screenName, font:fontName});
                for (var i=0; i<games.length; i++) {
                    data.push({t:"Game", id: games[i].id,
                        headerText:name,
                        playerNames:games[i].playerNames,
                        playerAvatars:games[i].playerAvatars,
                        opponentIndex:games[i].opponentIndex,
                        playerIds:games[i].playerIds,
                        started:games[i].started,
                        bGameOver:bGameOver,
                        gameOverMessage:games[i].gameOverMessage,
                        finalMove:games[i].finalMove,
                        gameIndex:i,
                        screenName:screenName, font:fontName});
                    if (name === "WAITING FOR"){
                        // clean nudged data
                        tmp_nudgesData[games[i].id] = nudgesData[games[i].id]?nudgesData[games[i].id]:false;
                    }
                }
                data.push({t:"Bottom", id:"multiplayerListBottom_"+name, gameLength:games.length, headerText:name, spacer:20, imgName:"finishedgames-bottom.png", screenName:screenName, font:fontName, onGotGame:onGotGame});
                if (name === "WAITING FOR"){
                    FPSetPersonValue("nudged", tmp_nudgesData);
                }
            }
        }
        gameSection("TAKE A TURN TO EARN COINS!", "yourturn-top.png", YourTurn.games.yourTurn, false);
        gameSection("WAITING FOR", "waitingfor-top.png", YourTurn.games.theirTurn, false);
        gameSection("FINISHED GAMES", "finishedgames-top.png", YourTurn.games.gameOver,true);
        FPSmartList.update(gamesList, data);

        // update header

        if (personName !== FPGetPersonName()){
            personName = FPGetPersonName();
            s.label["name"].text.innerText = personName;
        }
        if (avatar !== FPGetPersonAvatar()){
            avatar = FPGetPersonAvatar();
            $(s.image["icon"]).remove();
            $(s).children(".ParentTag").remove();
            var role = FPIsParent()?"parent":"family";
            drawAvatar(s, avatar, role, "icon", 50, FPIsLandscape()?35:15, 5, false);
        }
    }

    function init(){
        image(FPCustomAssetsPosition(screenName, "background.png"),{parent:s, x:0, y:0, w:gFullWidth, h:gFullHeight});
        var d = div({parent: s, id: "mask", x: (gFullWidth - 320)/2, y: 72, w: 320, h: gFullHeight - 20 +1});
        gamesList = FPSmartList.create(d, s, 10, 0, 320, gFullHeight-100, [FPMultiplayerList]);
        $(gamesList).css("background-color","transparent");
        s.refresh();
        // draw header after draw game list
        drawHeaderWithChangePlayer(s, screenName);
    }
    s.on_changeButton = function()
    {
        FPWebView.eval("login", "FPChangePlayerDialog()", null);
    };
    init();
};

FPLaunchScreen(o);



