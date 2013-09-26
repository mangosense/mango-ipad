// index.js
orientation("vertical");
end();
// logic.js
o = function(s, args) {
    var settings = FPGetAccountSettings();
    var bMultiply = args.bMultiply;
    var bCheck = false;
    init();

    function init()
    {
        var centerPanel = div({parent:s, x:0, y:0, w:320, h:320});
        setXCenter(centerPanel);

        var d = div({parent:centerPanel, id: "frame", x: 5, y:0, w: 310, h:320, color: "#ffffff"});
        $(d).css("border", "1px solid #c2bebe");
        d = div({parent:centerPanel, id:"alertFrame", x: 5, y: 0, w: 310, h:45, color: "#d9472f"});
        $(d).css(getAppSetting().bgPatternStyle);
        $(d).css("border", "1px solid #bb3e28");
        label({parent: centerPanel, x: 5, y: 12, size: 22, w: 310, string: i18n('_FOR_GROWN_UPS'), center: true });
        button({parent: centerPanel, src:gImagePath+"close-x", idleover:"same", id: "close", string: "", x: 280, y: 8, w:30, h:30});
        if (bMultiply){
            label({parent: centerPanel, x: 22, y: 58, w: 95, h: 75, size: 12, string: i18n('_OK_ENTER_THE'), font:"light font", center: true, color: "#000000"});
            label({parent: centerPanel, x: 22, y: 130, w: 95, h: 100, size: 10, string: i18n('_YOU_CAN_ALWAYS'), center: true, font:"light font", color: "#000000"});
            image({parent:centerPanel, src:gImagePath+"Quote1", x: 20, y:130, w: 5, h:37});
            image({parent:centerPanel, src:gImagePath+"Quote2", x: 113, y:130, w: 5, h:37});
            image({parent:centerPanel, src:gImagePath+"Settings", x: 26, y:131, w: 10, h:10});
        }else{
            label({parent: centerPanel, x: 22, y: 68, w: 95, h: 25, size: 13, string: i18n('_HI_GROWN_UP'), center: true, color: "#000000"});
            label({parent: centerPanel, x: 22, y: 93, w: 95, h: 100, size: 13, string: i18n('_ENTER_THE_NUMBERS'), center: true, font:"light font", color: "#000000"});
        }
        var calculator = div({parent: centerPanel, x: 127, y: 50, w: 185, h:265});
        $(calculator).css({borderRadius:5*gScaleX, backgroundColor:"#f1f1f1", border:"1px solid #d5d5d5"});
        FPCalculator.Calculator(calculator, 185, 52, "", bMultiply, right, wrong);

        /*
        Apple forced removal of don't show again feature

        if (!args.noCheckBox && settings !== undefined){
            var cBox = button(_CheckBoxButton, {parent: centerPanel, id: "notShow", x: 134, y: 285, w:25, h:25});
            label({parent: centerPanel, x: 155, y: 290, w: 160, h: 25, size: 14, string: i18n('_DON_T_SHOW'), center: true, color:"#148241"});
            if (bCheck){
                SetToggle(cBox, true);
            }
        }
        */

        centerPanel.buttonParent = s;
        var rules = ["@-webkit-keyframes bouncing{",
            "0% {-webkit-transform:translateX(-50%);}",
            "5% {-webkit-transform:translateX(50%);}",
            "15% {-webkit-transform:translateX(-25%);}",
            "30% {-webkit-transform:translateX(25%);}",
            "40% {-webkit-transform:translateX(-15%);}",
            "50% {-webkit-transform:translateX(15%);}",
            "70% {-webkit-transform:translateX(-5%);}",
            "80% {-webkit-transform:translateX(5%);}",
            "90% {-webkit-transform:translateX(-3%);}",
            "95% {-webkit-transform:translateX(3%);}",
            "97% {-webkit-transform:translateX(-1%);}",
            "99% {-webkit-transform:translateX(1%);}",
            "100% {-webkit-transform:translateX(0);}",
            "}"].join(" ");
        cssAnimation(rules);

        function right(){
            FPSetAccountSettings(settings);
            s.close();
            args.callback(true);
        }
        function wrong(){
            $(centerPanel).css("-webkit-animation", "bouncing 0.5s");
            setTimeout(clear, 500);
        }
        function clear(){
            $(centerPanel).css("-webkit-animation", "none");
        }
    }

    s.on_close = function()
    {
        args.callback(false);
        s.close();
    };
    s.on_notShow = function(){

        if (!bCheck){
            bCheck = true;
            settings.noParentGate = true;
            bMultiply = true;
            $(s).empty();
            init();
        }else{
            bCheck = false;
            settings.noParentGate = false;
            bMultiply = false;
            $(s).empty();
            init();
        }
    }

};

FPLaunchScreen(o);



