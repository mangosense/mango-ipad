// index.js
orientation("vertical");
var appSettings = getAppSetting();
background(appSettings.background, true);

//header bg
image({id:"headerBg", src: appSettings.headerBg, x:0, y:0, w:gFullWidth, h:45});

label({id: "title", string: i18n('_REGISTER_WITH_FINGERPRINT', {partner: appSettings.partnerName}), center: true, x: 0, y: 10, w: gFullWidth, h: 35, size:16});
end();

//logic.js
o = function(s, args) {
    init();

    function init()
    {
        var contentPanel = div({parent:s, x:0, y:45, w:gFullWidth, h:gFullHeight-45});

        var centerPanel = div({parent:contentPanel, x:0, y:0, w:gFullWidth*0.9});
        setCenter(centerPanel, 300);
        $(centerPanel).css("border", "1px solid #c2bebe");
        $(centerPanel).css("background-color", "white");
        var inner_w = parseInt($(centerPanel).css("width"))*0.9/gScaleX;
        var topPanel = div({parent:centerPanel, x:0, y:10, w:inner_w});
        setXCenter(topPanel);

        var topLeft_w = 60;
        var padding = 15;
        // dynamic calculate the right part width, whole width minus topLeft_w, minus padding
        var topRight_w = inner_w - topLeft_w - padding*2;
        drawAvatar(topPanel, FPGetPersonAvatar(), FPIsParent()?"parent":"family", null, topLeft_w, 0, 0, false);
        var TextGroup = div({parent:topPanel, x: topLeft_w + padding, y: 0, w:topRight_w });
        label({parent: TextGroup, string: i18n('_CONGRATULATIONS')+FPGetPersonName()+"!", vCenter: false, x: 0, y: 10, w:topRight_w, size:16, color:"#4e4e4e"});
        label({parent: TextGroup, string: i18n('_P_P_YOU'), vCenter: false, x: 0, w:topRight_w, size:12, font: "light font", color:"#4e4e4e"});
        setPositionRelative(TextGroup);
        var bottomPanel = div({parent:centerPanel, x:0, y:topLeft_w+10, w:inner_w});
        $(bottomPanel).css("top", "30%");
        setXCenter(bottomPanel);
        TextGroup = div({parent:bottomPanel, x: 0, y: gFullHeight*0.02, w:inner_w });
        var l = label({parent: TextGroup, string: i18n('_LI_DIV_SEE'), vCenter: false, x: padding, y: 20, w:inner_w-padding*2, size:12, font: "light font", color:"#4e4e4e"});
        label({parent: TextGroup, string: " ", vCenter: false, x: padding-padding*2, w:inner_w, h:20, size:12, font: "light font", color:"#4e4e4e"});
        label({parent: TextGroup, string: i18n('_REMEMBER_FINGERPRINT_IS', {partner: appSettings.partnerName}), vCenter: false, x: padding, w:inner_w-padding*2, size:12, font: "light font", color:"#4e4e4e"});
        setPositionRelative(TextGroup);
        var button_top = (parseInt($(centerPanel).css("height"))+parseInt($(centerPanel).css("top")))/gScaleX;
        var pos = getPosForCenter(centerPanel, 0.81);
        button({parent: centerPanel, src:gImagePath+"greenbutton_half", leftCap:5, rightCap:5, idleover:"same", id: "play", x: pos.x, y:button_top -55, w:pos.w, h:45, string: i18n('_LET_S_PLAY'), size: 18});

        centerPanel.on_play = function(){
            FPWebView.eval("multiplayer", "refreshGames()");
            FPWebView.eval("hub", "refreshHub()", next);
        };

        var chartBox = div({parent:s, x:gFullWidth*0.85, y:gFullHeight*0.35, w:111, h:111});
        var chartBg = div({parent:chartBox, x:1, y:1, w:107, h:107});
        $(chartBg).css("border-radius", 100*gScaleX);
        $(chartBg).css("box-shadow", "1px 1px 5px #999999");
        $(chartBg).css("background-color", "white");
        var chart = div({parent:chartBox, x:4, y:4, w:100, h:100});
        var data = [{"a":8},{"a":4},{"a":6},{"a":3} ];
        chart.innerHTML=(donutChart(data, 50*gScaleX, 25*gScaleX,["#fbde4f","#f9ee93","#8ac248","#1b9248"]));
        label({parent:chartBox, string: i18n('_SESSIONS_THIS_WEEK'), x:35, y:50, w:40, h:44, size: 8, center:true, font: "light font", color:"#4e4e4e"});
        label({parent:chartBox, string: i18n('_20'), x:30, y:35, w:50, h:44, size: 12, center:true, color:"#4e4e4e"});
        drawAvatar(chartBox, "avatar12", "family", null, 30, 0, 0, false);
    }

    function next(){
        FPWebView.show("login", false);
        FPWebView.eval("hub", " hubButtonPressed()", function(){s.close();});
    }

};
FPLaunchScreen(o);