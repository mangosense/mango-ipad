// index.js
orientation("vertical");
var appSettings = getAppSetting();
background(appSettings.background, true);

//header bg
image({id:"headerBg", src: appSettings.headerBg, x:0, y:0, w:gFullWidth, h:45});

label({id: "title", string: i18n('_WELCOME_TO_FINGERPRINT', {partner: appSettings.partnerName}), center: true, x: 0, y: 10, w: gFullWidth, h: 35, size:16});
end();

//logic.js
o = function(s, args) {
    init();

    function init()
    {
        var contentPanel = div({parent:s, x:0, y:45, w:gFullWidth, h:gFullHeight-45});
        var centerPanel = div({parent:contentPanel, x:0, y:0, w:gFullWidth*0.9});
        setCenter(centerPanel, 360);
        $(centerPanel).css("border", "1px solid #c2bebe");
        $(centerPanel).css("background-color", "white");
        var inner_w = parseInt($(centerPanel).css("width"))/gScaleX;

        label({parent: centerPanel, string: i18n('_THERE_S_LOTS'), vCenter: false, x: 0, y: 12, w:inner_w, h:35, size:12, font: "light font", color:"#4e4e4e", center:true});


        var middlePanel = div({parent:centerPanel, x:0, y:10, w:inner_w});
        setXCenter(middlePanel);
        var middle_w = 200;
        var x_space = 20;
        var layout = getThreeGroupTemplate(middlePanel, middle_w+x_space, middle_w+x_space, 0, 185, 130);
        var bottom = layout.bottomPanel, middle = layout.middlePanel;
        var imageGroup = div({parent:middle, x: 0, y: 0, w:middle_w/2, h:92 });
        image({parent:imageGroup, src:GetGameIcons("veggiehero").src, x:8, y:30, w:40, h:40});
        image({parent:imageGroup, src:GetGameIcons("sms").src, x:50, y:30, w:40, h:40});
        image({parent:imageGroup, src:GetGameIcons("pandafull").src, x:30, y:13, w:40, h:40});
        label({parent: imageGroup, string: i18n('_FIND_NEW_GAMES'), vCenter: false, x: 0, y:77, w:middle_w/2, h:20, size:11, color:"#4e4e4e", center:true});

        imageGroup = div({parent:middle, x: middle_w/2+x_space, y: 0, w:middle_w/2, h:92 });
        image({parent:imageGroup, x:20, y:20, src:gImagePath+"mail", w:63, h:39});
        label({parent: imageGroup, string: i18n('_SEND_MESSAGES'), vCenter: false, x: 0, y:77, w:middle_w/2, h:20, size:11, color:"#4e4e4e", center:true});

        imageGroup = div({parent:middle, x: 0, y: 92, w:middle_w/2, h:92 });
        image({parent:imageGroup, x:13, y:13, src:gImagePath+"support-kids", w:70, h:60});
        label({parent: imageGroup, string: i18n('_PLAY_WITH_FRIENDS'), vCenter: false, x: 0, y:77, w:middle_w/2, h:20, size:11, color:"#4e4e4e", center:true});

        imageGroup = div({parent:middle, x: middle_w/2+x_space, y: 92, w:middle_w/2, h:92 });
        drawAvatar(imageGroup, "avatar2", "family", null, 35, 0, 20, false);
        image({parent:imageGroup, x:45, y:35, src:gImagePath+"gray-arrow", w:10, h:10});
        drawAvatar(imageGroup, "avatar7", "family", null, 35, 57, 20, false);
        label({parent:imageGroup, string: i18n('_CHANGE_CHARACTERS'), vCenter: false, x: 0, y:77, w:middle_w/2, h:20, size:11, color:"#4e4e4e", center:true});

        var bottom_w = parseInt($(bottom).css("width"))/gScaleX;
        var bottom_h = parseInt($(bottom).css("height"))/gScaleX;
        var y_space = FPIsLandscape()?20:0;
        image({parent:bottom, x:(bottom_w-65)/2, y:bottom_h-130-y_space*2, src:gImagePath+"hubsell-fpbutton", w:65, h:46});
        label({parent: bottom, string: i18n('_JUST_TAP_THE', {partner: appSettings.partnerName}), vCenter: false, x: 5, y: bottom_h-85-y_space, w:bottom_w-10, h:40, size:12, font: "light font", color:"#4e4e4e", center:true});
        var pos = getPosForCenter(bottom, 0.7);
        button({parent: bottom, src:gImagePath+"greenbutton_half", leftCap:5, rightCap:5, idleover:"same", id: "play", x: pos.x, y:bottom_h-42, w:pos.w, h:40, string: i18n('_LET_S_PLAY'), size: 18});

        bottom.on_play = function(){
            FPWebView.eval("login", "FPResumeLoaded()", function(){s.close()});
        };
    }
};
FPLaunchScreen(o);