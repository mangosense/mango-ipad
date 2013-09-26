var screenW = gFullWidth;//320
var screenH = gFullHeight;//480
var screenXOffset = (screenW - 320)/2;
var screenYOffset = (FPIsLandscape())?50:0;
// index.js
orientation("vertical");
end();




// logic.js
o = function(s, args) {


    init();
    FPWebView.eval("hub", "showPause(true)");
    s.onScreenClose = function()
    {
        FPWebView.eval("hub", "showPause(false)");
    }

    function init()
    {
        var screenName = "game_pause";
        var fontName = FPCustomGetFontName();
        image(FPCustomAssetsPosition(screenName, "background.png"),{parent:s, x:0, y:0, w:gFullWidth, h:gFullHeight});
        FPCustomPauseAddOn(s, "behind");
        button(FPCustomAssetsPosition(screenName, "button-mainmenu.png"), {parent: s, idleover:"same", id: "main", string: i18n('_MAIN_MENU'), font:fontName, center: true});
        button(FPCustomAssetsPosition(screenName, "button-keepplaying.png"), {parent: s, idleover:"same", id: "play", string: i18n('_KEEP_PLAYING'), font:fontName, center: true});
        FPCustomPauseAddOn(s, "front");

        drawHeaderWithChangePlayer(s, screenName);

        s.on_changeButton = function()
        {
            // if in multiplayer game, and going to change player, must have user go the list screen
            // as cannot return to a game in progress after changing players
            if (IsGameMultiplayer())
            {
                // open multiplayer list
                FPWebView.show("multiplayer", true);
                FPWebView.eval("multiplayer", "openHub('list', null)", null);
            }
            s.close();
            FPWebView.eval("login", "FPChangePlayerDialog()", null);
        }
    }


    s.on_play = function()
    {
        s.close();
    }

    s.on_main = function()
    {
        if (IsGameMultiplayer())
        {
            // open multiplayer list
            FPWebView.show("multiplayer", true);
            FPWebView.eval("multiplayer", "openHub('list', null)", null);
            s.close();
        }
        else
        {
            FPHelper.setNextUICompleteMode("menu");
            s.close();
        }
    }
};

FPLaunchScreen(o);