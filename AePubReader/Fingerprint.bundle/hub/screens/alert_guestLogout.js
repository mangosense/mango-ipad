// index.js
orientation("vertical");
end();
// logic.js
o = function(s, args) {

    init();

    function init()
    {
        var appSettings = getAppSetting();
        var centerPanel = div({parent:s, x:0, y:0, w:300});
        setCenter(centerPanel, 350);

        var d = div({parent:centerPanel, id: "frame", x: 0, y:0, w: 298, h:300, color: "#ffffff"});
        $(d).css("border", "1px solid #c2bebe");
        d = div({parent:centerPanel, id:"alertFrame", x: 0, y: 0, w: 298, h:45, color: "#d9472f"});
        $(d).css(appSettings.bgPatternStyle);
        $(d).css("border", "1px solid " + appSettings.alertBorder);


        label({parent: centerPanel, x: 0, y: 12, size: 16, w: 300, string: i18n('_REMOVE_ALL_PROFILES'), center: true });
        label({parent: centerPanel, x: 20, y: 68, w: 260, h: 100, size: 16, string: i18n('_ARE_YOU_SURE'), center: true, font: "light font", color: "#000000"});
        button({parent: centerPanel, src:gImagePath+"greenbutton_half", idleover:"same", id: "cancel", string: i18n('_DON_T_REMOVE'), x: 151, y: 170, w:120, h:40, size: 16});
        button({parent: centerPanel, src:gImagePath+"redbutton_full", idleover:"same", id: "ok", string: i18n('_REMOVE'), x: 24, y: 170, w:120, h:40, size: 16});

        var l = label({parent: centerPanel, x: 20, y: 240, w: 260, h: 60, size: 14, string: i18n('_YOU_CAN_SAFELY', {partner: appSettings.partnerName}), center: true, font: "light font", multiColorFunc:getColor});
        function getColor(i, words)
        {
            if (words[i] === "Find" || (words[i] === "Out") || words[i] === "How" ) {
                return appSettings.linkColor;
            } else{
                return "#4e4e4e";
            }
        }
        l.onmousedown = function(){
            s.close();
            s.close();
            if (args.callback) {
                args.callback();
            }
        }
        centerPanel.on_ok = function()
        {
            s.on_ok();
        };

        centerPanel.on_cancel = function()
        {
            s.on_cancel();
        };
    }

    s.on_ok = function()
    {
        s.close();
        if (args.callback) {
            args.callback(true);
        }
    };

    s.on_cancel = function()
    {
        s.close();
        if (args.callback) {
            args.callback(false);
        }
    };
};

FPLaunchScreen(o);



