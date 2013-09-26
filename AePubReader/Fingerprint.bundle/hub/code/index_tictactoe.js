//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

gOnDevice = true;

function start(root)
{
    // load layer specific scripts before continuing
    var scripts = [
        "yourturn/shared/util.js",
        "yourturn/yourturn.js"
    ];
    function next()
    {
        start2(root);
    }
    LoadScripts(scripts, next);
}

function start2(root)
{
    FPSetAppValue("bMultiplayer", "true");

    FPWebView.show("self", true);
    runScreen(root,  "yourturn/game", "none");
}

function runGame(s, game)
{
    var d = YourTurnHeader(s, "Game");

    button(_GreenButton, {parent: d, x: 5, y: 5, w: 60, h: 26, id: "list", string: "List"});

    var dBoard;
    var dTurn;

    s.onGameUpdate = function(game)
    {
        $(dBoard).remove();
        $(dTurn).remove();

        var gameDiv = div({parent: d, x: 5, y: 40, w: 300, h: 340});

        var board = div({parent:gameDiv, x:5, y:40, w:300, h: 300});
        dBoard = board;
        var colors = ["#80ff80", "#8080ff"];
        var state = [["","",""],["","",""],["","",""]];

        var bMyTurn = (game.turn == "PLAYER" && game.opponentIndex == 1) || (game.turn == "OPPONENT" && game.opponentIndex == 0);

        var a = bMyTurn ? "Make your move!" : "Please wait your turn.";
        var size = 24;
        if (game.winner != "") {
            bMyTurn = false; // no one's turn when game is over
            a = game.gameOverMessage;
            size = 16; // smaller font
        }

        var l = label({parent: gameDiv, x: 5, y: 10, w: 300, h:30, color: "#000000", size: size, string: a});
        dTurn = l

        for (var y=0; y<3; y++) {
            for (var x=0; x<3; x++) {
                var c = (y*3+x)%2;
                var square = div({parent: board, x:x*100, y:y*100, w:100, h:100, color: colors[c]});
                square.gameX = x;
                square.gameY = y;
                square.onmousedown = function()
                {
                    doMove(this.gameX, this.gameY);
                }
            }
        }

        if (game.moves) {
            for (var i=0; i<game.moves.length; i++) {
                var move = game.moves[i];
                var letter = (i%2)?"O":"X";
                state[move.x][move.y] = letter;
                label({parent: board, x:move.x*100, y:move.y*100, w:100, h:100, center:true, vCenter: true, size: 60, string: letter});
            }
        }

        if (game.finalMove) {
            var trap = div({parent: board, x:0, y:0, w:300, h:300});
            trap.onmousedown = function()
            {
                // send a final move to end the game
                FPWebView.eval("multiplayer", "sendMove({})");
            }
        }

        function doMove(x, y)
        {
            // has to be player's turn
            // square has to be empty
            if (bMyTurn && state[x][y] == "") {

                // put this move onto the board
                state[x][y] = (game.opponentIndex == 1) ? "X" : "O";

                // see if have any empty spaces
                var bHaveEmpty = false;
                for (var ey=0; ey<3; ey++) {
                    for (var ex=0; ex<3; ex++) {
                        var t = state[ex][ey];
                        if (t.length == 0) {
                            bHaveEmpty = true;
                        }
                    }
                }

                // game is over if board is full or some letter has a three in a row
                var gameOver = null;
                // 3-in a row as x,y's rows, columns, diagonals (8 ways to win)
                var checkX = [0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 0, 0, 1, 1, 1, 2, 2, 2, 0, 1, 2, 0, 1, 2];
                var checkY = [0, 0, 0, 1, 1, 1, 2, 2, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 2, 1, 0];
                for (var j=0; j<8; j++) {

                    var st = "";
                    for (var k=0; k<3; k++) {
                        st += state[checkX[j*3+k]][checkY[j*3+k]];
                    }

                    if (st == "XXX") {
                        gameOver = "PLAYER";
                        break;
                    } else if (st == "OOO") {
                        gameOver = "OPPONENT";
                        break;
                    }
                }

                // no winner found, but all 9 squares are full - it's a tie!
                if (gameOver == null && !bHaveEmpty) {
                    gameOver = "NONE";
                }

                var move = {x: x, y: y, gameOver: gameOver};

                if (gameOver) {
//                    move.finalMove = "Get Coins";
                }

                // fast local echo
                game.moves.push(move);
                s.onGameUpdate(game);

                // send to server
                var js = "sendMove(" + JSON.stringify(move) + ")";
                FPWebView.eval("multiplayer", js);
            }
        }

        d.on_list = function()
        {
            FPWebView.eval("multiplayer", "openHub('list')");
        }
    }

    if (game) {
        s.onGameUpdate(game);
    }
}

