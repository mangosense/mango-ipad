orientation("vertical");

end();

o = function(s, args) {

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background

    init();
    function init()
    {
        var d = div({parent:p, x:0, y:0, w:320, h:40});
        addBackgroundImage($(d), "gray-pattern.png");
        label({parent:p, id: "title", string: i18n('_LANGUAGE'), center: true, x: 0, y: 10, w: 320, h: 55, size:15, color:"#4e4e4e"});
        button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "back", string: i18n('_BACK')});

        var cur_code = FPGetAppValue("language");
        FPLanguageSelector(p, 320, gHubHeight-40, 320, 40, langLookUp, FPGetAppValue("language"), false, false, onSelected);
        function onSelected(){
            if (cur_code !== FPGetAppValue("language")){
                $(s).trigger("updateHubTabsTxt");
                //$(s).trigger("updateHubPanel", ["hub_home"]);
            }

            function onClosed()
            {
                gHubScreen.forceRefreshSettings();
            }
            s.close("left", onClosed);
        }
    }

    p.on_back = function(){
        s.close();
    };

};

FPLaunchScreen(o);



