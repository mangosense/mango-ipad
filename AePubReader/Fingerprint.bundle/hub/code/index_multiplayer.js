//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

gOnDevice = true;

function openHub(mode, data)
{
    FPWebView.show("self", true);
    YourTurn.Open(mode, data);
}

function start(root)
{
    FPSetEventScope1("MPG");
    FPSetEventScope2("Mutli");

    // only start up this logic for multiplayer games
    if (IsGameMultiplayer()) {
        // load layer specific scripts before continuing
        var scripts = [
            "lib/jquery.roundabout.min.js",
            "lib/date.js",
            "modules/multiplayer_games_list.js",
            "yourturn/shared/util.js",
            "yourturn/yourturn.js"
        ];

        // also load game specific hub customization script
        scripts.push(FPCustomAssetsPath("code.js"));
        scripts.push(FPCustomAssetsImageInfoPath());
        function next()
        {
            function next2()
            {
                start2(root);
            }
            FPDoCallbackChain(FPLoadAccount, FPLoadPerson, next2);
        }
        LoadScripts(scripts, next);
    }
}

function start2(root)
{
    FPWebView.show("self", true);
    YourTurn.Start();
    runScreen(gRoot,  "yourturn/list", "none");
}

function DoCloseMultiplayer()
{
    FPWebView.show("self", false);
}
