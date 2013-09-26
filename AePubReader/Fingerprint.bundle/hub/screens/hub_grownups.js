// index.js
orientation("vertical");

end();

// logic.js
//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

o = function(s, args) {

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    var settings = FPGetAccountSettings();

    init();
    function init()
    {
        var d = div({parent:p, x:0, y:0, w:320, h:40});
        addBackgroundImage($(d), "gray-pattern.png");
        label({parent:p, id: "title", string: i18n('_FOR_GROWN_UPS'), center: true, x: 0, y: 10, w: 320, h: 55, size:15, color:"#4e4e4e"});
        button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 80, y: 5, size: 12, id: "back", string: i18n('_BACK')});
        var alertImg_w = 160;
        var alertBox = div({parent:p, id:"alertBox", x: 120, y: 50, w: alertImg_w, h:144});
        var d = div({parent:alertBox, id: "frame", x: 0, y:0, w: alertImg_w-3, h:142, color: "#ffffff"});
        $(d).css("border", "1px solid #c2bebe");
        d = div({parent:alertBox, id:"alertFrame", x: 0, y: 0, w: alertImg_w-3, h:20, color: "#d9472f"});
        $(d).css(getAppSetting().bgPatternStyle);
        $(d).css("border", "1px solid #bb3e28");
        label({parent: alertBox, x: 0, y: 5, size: 12, w: alertImg_w, string: i18n('_FOR_GROWN_UPS'), center: true });
        image({parent: alertBox, src:gImagePath+"close-x", id: "close", x: alertImg_w-20, y: 4, w:15, h:15});
        var line = div({parent:p, x: 20, y: 180, w: 108, h:1});
        line.style.backgroundColor = "#a6a6a6";
        var calculator = div({parent: alertBox, x: (alertImg_w-100)/2, y: 20, w: 100, h:155});
        FPCalculator.Calculator(calculator, 100, 25, "Zero Nine Seven", false, true);
        div({parent: alertBox, x: (alertImg_w-100)/2, y: 20, w: 100, h:155});
        $(p).css("-webkit-perspective",500*gScaleX);
        $(p).css("-webkit-perspective-origin","30% 40%");
        $(alertBox).css("-webkit-transform","rotateY(-30deg)");
        image({parent: p, src:gImagePath+"gatekid", id: "close", x: 70, y: 90, w:59, h:98});
        label({parent: p, x: 40, y: 230, size: 14, w: 160, h:85, string: i18n('_THIS_FEATURE_ALLOWS'), color:"#4e4e4e" });
        var b = button({parent: p, src:gImagePath+"switch", x: 220, y: 250, w: 80, h: 40, size: 12, id: "switch", string: ""});
        label({parent:b, x: 2, y: 2, w: 36, h:36, size: 12, center: true, vCenter:true, string:i18n('_YES')});
        label({parent:b, x: 42, y: 2, w: 36, h:36, size: 12, center: true, vCenter:true, string:i18n('_NO')});
        if (settings.noParentGate){
            SetToggle(b, true);
        }
        p.buttonParent = s;
    }

    s.on_back = function()
    {
        s.close();
    };
    s.on_switch = function()
    {
        var bOn = s.button["switch"].bOn;
        SetToggle(s.button["switch"], !bOn);
        if (bOn){
            settings.noParentGate = false;
            FPSetAccountSettings(settings);
            next();
        }else{
            DoParentGate(next, {bMultiply:true, noCheckBox:true});
        }
        function next(){
            s.close();
        }
    };

};

FPLaunchScreen(o);



