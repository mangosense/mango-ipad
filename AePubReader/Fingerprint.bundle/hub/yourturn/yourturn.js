var gGameScreen = null; // stays null for native
var waitingForGame = false;

function requestGames()
{
    // if we never had any valid data, provide valid empty lists
    var games = FPGetPersonValue("games");
    if (!games || !games.yourTurn) {
        games = {
            yourTurn: [],
            theirTurn: [],
            gameOver: []
        }
        FPSetPersonValue("games", games);
    }

    refreshGames();
    FPWebRequest("TurnBasedGame", {command: "games"}, function(r) {
        if (r.yourTurn) {
            FPSetPersonValue("games", r);
            refreshGames();
        }
    });
}

function onNotification(payload)
{
    if (FPGetPersonId()) {
        FPWebBatchStart();
        FPWebRequest("GameData", {command: "loadAll"}, function(r) {
            if (r.bSuccess) {
                var count = r.values.length;
                for (var i=0; i<count; i++) {
                    FPSaveServerData(r.values[i]);
                }
            }
        });

        requestGames();

        FPWebBatchSend(null, null, null);
    }
}

function refreshGames()
{
    var game = null;
    try {
        YourTurn.LoadGames();
        game = YourTurn.gameMap[YourTurn.activeGameId];
    } catch (e) {
        console.log(e);
    }
    doGameUpdate(game);
}

function doGameUpdate(game)
{
    if (game && !game.id && !game.bPracticeRound) {
        game = null;
    }

    // player can change avatar client side before re-fetch of game state... so keep player's avatar up to date
    if (game && game.playerAvatars) {
        var playerIndex = (1 - game.opponentIndex);
        game.playerAvatars[playerIndex] = FPGetPersonAvatar();
    }

    var s = gRoot;

    if (gGameScreen) {
        if (gGameScreen.refresh) {
            gGameScreen.refresh();
        }
        if (game && gGameScreen.onGameUpdate) {
            gGameScreen.onGameUpdate(game);
        }
    } else {
        if (game) {
            // TODO: remove
            // prevent Alphabetinis from getting randomavatar as avatar
            if (game.playerAvatars[1] == "randomavatar") {
                // make a copy
                var s = JSON.stringify(game);
                game = JSON.parse(s);
                game.playerAvatars[1] = "";
                game.playerNames[1] = "Pending";
            }
            FPHelper.callAPIDelegate("onGameUpdate:", [game]);
        }
    }
    while (s) {
        if (s.refresh) {
            s.refresh();
        }
        if (game && s.onGameUpdate) {
            s.onGameUpdate(game);
        }
        s = s.child;
    }
}

function sendMove(move)
{
    // TODO: be more efficient about updating game state after sending a move
    function next()
    {
        requestGames();
    }
    YourTurn.Request("move", {game: YourTurn.activeGameId, data:move}, next, null);
}

var EMPTY_GAMES = {bWaiting: false, yourTurn: [], theirTurn: [], gameOver: []};

var YourTurn = {

	START: 0

    ,activeGameId: null
	,games: EMPTY_GAMES
    ,bContinuePlay:false
	,gameMap: {}

	,GetGameOver: function(game)
	{
		var bTie = (game.winner == "NONE");
		var bWon = (game.winner == "PLAYER" && game.opponentIndex == 1) || (game.winner == "OPPONENT" && game.opponentIndex == 0);

		var opponentName = game.playerNames[game.opponentIndex];
		var a;

		if (bTie) {
			a = "You and " + opponentName + " have tied!";
		} else if (bWon) {
			a = i18n("_YOU_WON");
        } else {
			a = opponentName + i18n("_WON");
		}

		return a;
	}

	,Start: function()
	{
        // force an update from cache
        refreshGames();
	}

    ,Open: function(mode, data)
    {
        switch (mode) {
            case "list":
                // want all new list screen - if one already open, discard it
                if (gRoot.child) {
                    $(gRoot.child).remove();
                }
                onContinueGame();
                break;
        }
    }

    ,IsMyTurn: function(gameId)
    {
        var bMyTurn = (gameId === null); // pracitce round, it's always my turn
        var game = YourTurn.gameMap[gameId];
        if (game) {
            bMyTurn = game.bMyTurn;
        }
        return bMyTurn;
    }

    ,SetActiveGame: function(gameId)
    {
        if (!gameId) {
            gameId = "practiceRound";
            YourTurn.gameMap[gameId] = {
                bPracticeRound: true,
                playerAvatars: [FPGetPersonAvatar(), ""],
                playerNames: [FPGetPersonName(), ""]
            };
        }

        YourTurn.activeGameId = gameId;
        var game = YourTurn.gameMap[gameId];
        doGameUpdate(game);
    }

	,LoadGames: function()
	{
        var response = FPGetPersonValue("games");

		{
            var bWasWaiting = YourTurn.games.bWaiting;

            if (response) {
    			YourTurn.games = response;
            } else {
                YourTurn.games = EMPTY_GAMES;
            }
            console.log("load games");
            if (!YourTurn.games)
            {
                console.log("games is null");
                return;
            }
            if (!YourTurn.games.yourTurn)
            {
                console.log(" your turn list is null");
                return;
            }
            if (!YourTurn.games.theirTurn)
            {
                console.log(" their turn list is null");
                return;
            }
            if (!YourTurn.games.gameOver)
            {
                console.log(" game over list is null");
                return;
            }
            if (bWasWaiting && !YourTurn.games.bWaiting) {
                // you've started a game with (opponent in newest game)
                var newGame = YourTurn.games.theirTurn[0];
                var newName = newGame.playerNames[newGame.opponentIndex];
                DoAlert(i18n("_SUCCESS"), i18n("_YOU_STARTED") + newName);

            }

			function addToMap(sub)
			{
				var l = sub.length;
				for (var i=0; i<l; i++) {
					YourTurn.gameMap[sub[i].id] = sub[i];

                    if (sub[i].winner != "") {
                        sub[i].gameOverMessage = YourTurn.GetGameOver(sub[i]); // game over message
                    }

                    if (sub[i].id == YourTurn.activeGameId) {
                        doGameUpdate(sub[i]);
                    }
				}
			}
			addToMap(YourTurn.games.yourTurn);
			addToMap(YourTurn.games.theirTurn);
			addToMap(YourTurn.games.gameOver);
		}
	}

	,Request: function(command, data, callback, context)
	{
        function GetBlocking()
        {
            // for now, include "games"
            if (command == "games") return "Updating Games";
            if (command == "create") return "Starting Game";
            if (command == "move") return "Sending";
            return null;
        }

		var d = {
			command: command
		};
        if (data) {
            for (var i in data) {
                d[i] = data[i];
            }
        }

		FPWebRequest("TurnBasedGame", d, callback, context, GetBlocking());
	}
}
function sendNudge(game_id, callback)
{
    var game = YourTurn.gameMap[game_id];
    var d = {
        command: "createNudge",
        game_id: game_id,
        opponentId: game.playerIds[game.opponentIndex],
        playerName: FPGetPersonName(),
        appId: FPGetGameId()
    };
    FPWebRequest("TurnBasedGame", d, callback, null, "");
}