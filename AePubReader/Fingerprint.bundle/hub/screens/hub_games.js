//
//  Copyright 2013 Fingerprint Digital, Inc. All rights reserved.
//

// TODO: if scroll icon row with finger not on an icon, then the open game fails to close

// index.js
orientation("vertical");
end();

// logic.js
o = function(s, gotoId) {
    var gamesListFrame = div({parent: s,  x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    gamesListFrame.id = "gamesList" + GUID();

    var gamesList = div({parent: gamesListFrame, x: 0, y: 0, w: 320});
    var gamesListScroll;
    var openGame = null;
    var openGameHeight = 154;
    var overHang = 20; // how much of above category to show
    var threshold = 5*gScaleX;

    function PopulateGameContent(content, game)
    {
        var l = label({parent: content, color: "#000000", string: game.name, x: 10, y: 10, w: 265, ellipsis: true, size: 14});
        $(l).css("white-space", "nowrap");
        image({parent: content, x: 10, y: 34, w: 156, h: 88, src: GetCatalogURL(game.backdrop2)});

        var l =label({parent: content, color: "#000000", string: "Ages 7-11, Free<br>Teaches Reading and Fine<br>Motor Skills", x: 174, y: 34, w: 140, size: 12});

        if (game.video_ipad && game.video_ipad.indexOf("mp4") != -1) {
            content.buttonParent = content;
            playButton = button({parent:content, src:gImagePath+"button-play", id:"play", x:63,y:53, w:50, h:50, idleover:"same"});
            content.on_play = function()
            {
                if (gbAndroid) {
                    // TODO: consider whether Android should have it's own videos
                    FPHelper.playVideo(game.video_ipad, true, true, true, null);
                } else {
                    // TODO: this is still probably not quite right for iOS, but leaving it alone as we fix Android
                    FPHelper.playVideo(gScaleX > 1.5?game.video_ipad:game.video_iphone, true, true, true, null);
                }
            }
        }
    }

    function OpenGame(category, game, arrowX)
    {
        // handle closing old game / category
        var preTop = openGame ? $(openGame.category).position().top : null;
        var bClosed = false;
        if (openGame && openGame.category != category) {
            bClosed = true;
            var oldGame = openGame;
            openGame = null; // gets reset if opening a new game
            $(oldGame).slideUp(gTransitionTime, function()
            {
                $(oldGame).remove();
            });
        }

        // handle opening new game div
        if (game && !openGame) {
            // create parented to fragment to prevent transient issues with being inserted into DOM before hidden
            var frag = document.createDocumentFragment();
            openGame = div({parent: frag, w: 320, h: openGameHeight});
            openGame.content = div({parent: openGame, w: 320, x: 0, y: 12, h: openGameHeight-12, color: "#99C8DB"});
            $(openGame).css("position", "relative");
            $(openGame).hide();
            openGame.category = category;
            $(openGame).insertAfter(category);
            $(openGame).slideDown(gTransitionTime);

            var arrow = div({parent: openGame, w: 0, h: 0, x: arrowX/gScaleX, y: 0, color: null});
            var arrowSize = 12*gScaleX;
            $(arrow).css("border-left", "" + arrowSize + "px solid transparent");
            $(arrow).css("border-right", "" + arrowSize + "px solid transparent");
            $(arrow).css("border-bottom", "" + arrowSize + "px solid #99C8DB");
            openGame.arrow = arrow;

            openGame.buttonParent = openGame;
            button({parent:openGame, id:"close", x:289, y:1+12, w:30, h:30, src:gImagePath+"close-x", idleover:"same"});
            openGame.on_close = function()
            {
                OpenGame(null, null);
            }

            var t = null;
            if (gInstalledGames[game.appId]) {
                t = i18n("_PLAY_NOW");
            } else {
                if (GetGameStage(game) != "comingsoon") {
                    t = i18n("_GET_IT_NOW");
                }
            }
            if (t) {
                button({parent:openGame, id:"go", x:206, y:108, w: 76, h: 26, src:gImagePath+"greenbutton_half", string: t, size: 12, idleover:"same"});
            }
        }

        // if a game is open, update content and scroll position
        if (openGame) {

            $(openGame.arrow).animate({left: arrowX}, gTransitionTime/2);

            $(openGame.content).empty();
            PopulateGameContent(openGame.content, game);

            var top = $(category).position().top - (overHang * gScaleY);
            if (bClosed && preTop < top) {
                  top -= openGameHeight * gScaleY; // category closing that was ABOVE the new category, so take that into account
            }
            if (top < 0) {
                top = 0;
            }
            gamesListScroll.scrollTo(0, -top, gTransitionTime, false);
        }
    }

    function StartCategory(name, iconSize)
    {
        var category = div({parent: gamesList, w: 320, h: iconSize + 46});
        $(category).css("position", "relative");
        category.iconSize = iconSize;
        category.count = 0;

        label({parent: category, x: 6, y: 6, string: name, size: 13, color: "#000000"});
        category.categoryListFrame = div({parent: category, x: 0, y: 26, w: 320, h: iconSize+20});
        category.categoryList = div({parent: category.categoryListFrame, x: 0, y:0, h: iconSize+20});
        return category;
    }

    function AddGame(category, game)
    {
        var i = div({parent: category.categoryList, w: category.iconSize, h: category.iconSize+30});

        var src = GetGameIcons(game.appId).src;

        image({parent: i, x: 0, y: 0, w: category.iconSize, h: category.iconSize, src: src});

        if (gInstalledGames[game.appId]) {
            var cm = category.iconSize * 25/100;
            image({parent: i, x: category.iconSize - cm, y: category.iconSize - cm*3/4, w: cm, h: cm, src: gImagePath + "roundcheckmark.png"});
        }

        var name = game.shortName;
        if (!name || name.length == 0) {
            name = game.name;
        }

        var l = label({parent: i, x: 0, y: category.iconSize+4, w: category.iconSize, h: 12, center: true, string: name, ellipsis: true, size: 10, color: "#838383"});
        $(l).css("white-space", "nowrap");

        $(i).css("float", "left");
        $(i).css("position", "relative");
        $(i).css("margin-right", "5px");
        $(i).css("margin-left", "5px");
        i.category = category;
        i.game = game;
        category.count++;

        var downX = null;
        i.onmousedown = function(e)
        {
            downX = e.x;
        }

        i.onmousemove = function(e)
        {
            if (downX !== null && Math.abs(e.x-downX) > threshold) {
                OpenGame(null, null);
            }
        }

        i.onmouseup = function(e)
        {
            if (Math.abs(e.x-downX) > threshold) {
                OpenGame(null, null);
            } else {
                // we want to scroll the icon so it's entirely on screen
                var adjust = 0;
                var left = $(i).position().left + i.category.iscroll.x;
                var right = left + $(i).width();
                if (left < 0) {
                    adjust = left;
                } else if (right > 315*gScaleX) {
                    adjust = right-315*gScaleX;
                }

                var arrowX = (left+right-adjust-adjust-12*gScaleX)/2;
                i.category.iscroll.scrollTo(adjust, 0, gTransitionTime, true);

                OpenGame(i.category, i.game, arrowX);
            }
            downX = null;
        }
    }

    function EndCategory(category)
    {
        var w = category.count*(category.iconSize+10);
        $(category.categoryList).css("width",  w + "px");
        category.categoryListFrame.id = "categoryList" + GUID();
        category.iscroll = new iScroll(category.categoryListFrame.id, {hScroll: true, bounce: false});
    }

    function next()
    {
        // create Categories
        var category;

        category = StartCategory("What's New", 80);
        var newGames = GetNewGames();
        for (var i=0; i<newGames.length; i++) {
            AddGame(category, newGames[i]);
        }
        EndCategory(category);

        category = StartCategory("Most Popular Games", 60);
        var newGames = GetNewGames();
        for (var i=0; i<newGames.length; i++) {
            AddGame(category, newGames[i]);
        }
        EndCategory(category);

        category = StartCategory("All Games", 60);
        var allGames = GetNewGames();
        for (var i=0; i<allGames.length; i++) {
            AddGame(category, allGames[i]);
        }
        EndCategory(category);

        // add spacer at end (does NOT work out well to dynamically adjust the content height with an iScroll)
        // allow to scroll so that last section starts at the very top
        div({parent: gamesList, w: 320, h: gHubHeight - $(category).height()/gScaleY});

        // create iscroll
        gamesListScroll = new iScroll(gamesListFrame.id);
    }

    GetInstalledGames(next);
}

FPLaunchScreen(o);

