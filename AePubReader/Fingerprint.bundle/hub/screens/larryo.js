//
//  Copyright 2013 Fingerprint Digital, Inc. All rights reserved.
//

orientation("vertical");
end();

o = function(s, bFloatMode) {

    var p;
    var left = 0;
    var top = 0;
    var virtualHubButton;

    function fakeButtonMetric(n, callback)
    {
        var eventName = FPGetEventToken(s.path, n);
        FPMetrics.metric(eventName, null);
        if (FPGetAppValue("bShowMetric")){
            showMetricName(this, eventName);
            setTimeout(callback, 2500);
        } else {
            callback();
        }
    }

    var bg = div({parent: s, x: 0, y: 0, w: gFullWidth, h: gFullHeight, color: null});
    bg.onmousedown = function()
    {
        function next()
        {
            s.close();
        }
        fakeButtonMetric("bg_close", next);
    }

    if (bFloatMode) {
        top = -1;
        p = div({parent:s, x:(gFullWidth-175)/2+5, y:(gFullHeight-164)/2, w:175, h: 180, color: null});
        image({parent: p, x: 0, y: 0, w: 175, h: 180, src: "larryo_background_plain"});
        virtualHubButton = {};
    } else {
        if (FPIsLandscape()) {
            left = 25;
            p = div({parent:s, x:55, y:(gFullHeight-200)/2+20, w:200, h: 160, color: null});
            image({parent: p, x: 0, y: 0, w: 200, h: 158, src: "larryo_background"});
            virtualHubButton = image({parent: s, x: 0, y: (gFullHeight-55)/2, w: 55, h: 55, src: "hub_button"});
        } else {
            top = -1;
            p = div({parent:s, x:(gFullWidth-175)/2+5, y:(gFullHeight-180-55), w:175, h: 180, color: null});
            image({parent: p, x: 0, y: 0, w: 175, h: 180, src: "larryo_background_portrait"});
            virtualHubButton = image({parent: s, x: (gFullWidth-55)/2, y: gFullHeight-55, w: 55, h: 55, src: "hub_button"});
        }
    }

    virtualHubButton.onmousedown = function()
    {
        function next()
        {
            s.close();
            FPWebView.eval("hub", "DoPromoteGame(null, " + bFloatMode + ")");
        }
        fakeButtonMetric("hub_button", next);
    }

    $(virtualHubButton).hide();
    var blinkCount = 0;
    function blink()
    {
        if ($(virtualHubButton).is(":visible")) {
            $(virtualHubButton).hide();
        } else {
            $(virtualHubButton).show();
        }
        blinkCount++;
        if (blinkCount<5) {
            setTimeout(blink, 200);
        }
    }
    setTimeout(blink, gTransitionTime+100);

    setTimeout()
    p.buttonParent = s;
    label({parent: p, x: left+10, w: 165, y: top+5, string: "New Game!", color: "#ffffff", center: true, size: 16});
    button({parent: p, x: left+152, y: top+3, w: 20, h: 20, src: "../images/larryo_close", idleover: "same", id: "close"});

    var loading = label({parent: p, x: left, y: top+30, w: 175, h: 100, string: "loading...", color: "#808080", size: 16, vCenter: true, center: true});

    var cycle = FPGetAppValue("larryo_cycle");
    if (cycle === undefined) {
        cycle = 0;
    } else {
        cycle++;
    }
    FPSetAppValue("larryo_cycle", cycle);

    var data = {
        cycle: cycle,
        game_id: FPGetAppValue("game_id"),
        model: FPGetAppValue("model"),
        bAndroid: gbAndroid,
        bRetina: gbRetina
    };

    function onResult(result)
    {
        $(loading).hide();

        var game = result.game;
        button({parent: p, x: left+10, y: 56, src: result.src, idleover: "same", id: "icon", w: 72, h: 72});
        label({parent: p, x: left+5, y: top+26, w: 165, h: 30, center: true, vCenter: true, string: game.name, size: 22, color: "#000000"});
        label({parent: p, x: left+86, y: top+68, w: 84, string: "FREE Download", size: 12, center: true, color: "#07843f"});
        button({parent:p, id: "get", src:gImagePath+"greenbutton_half", idleover: "same", string: i18n("_GET_IT_NOW"),size: 11,  x:left+90, y:top+84, w:76, h:30});
        var seemore = label({parent: p, x: left, y: top+137, w: 175, h: 30, center: true, string: "See More Games", size: 11, font: "light font", color: "#07843f"});

        seemore.onmousedown = function()
        {
            function next()
            {
                s.close();
                FPWebView.eval("hub", "DoPromoteGame(null, " + bFloatMode + ")");
            }
            fakeButtonMetric("see_more", next);
        }

        // once the game is known, update the virtualHubButton handler... before that, it doesn't know the gameId, but still can open to the games page
        virtualHubButton.onmousedown = function()
        {
            function next()
            {
                s.close();
                FPWebView.eval("hub", "DoPromoteGame(\"" + game.appId + "\", " + bFloatMode + ")");
            }
            fakeButtonMetric("hub_button", next);
        }

        s.on_icon = function()
        {
            s.on_get(); // same functionality, but the Metric ID was different
        }

        s.on_get = function()
        {
            // do parent gate,
            // have to wait until the larry-O closes to trigger the parent gate
            // just waiting for transition time is too timing sensitive, so we poll
            // TODO: reconsider nested alerts
            function poll()
            {
                if (!GetOpenAlert()) {
                    FPOpenAppStore(game, true);
                } else {
                    setTimeout(poll, 10);
                }
            }
            poll();
            s.close();
        }

    }
    FPWebRequest("LarryO", data, onResult);

    s.on_close = function()
    {
        s.close();
    }
}

FPLaunchScreen(o);

