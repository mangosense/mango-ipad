var screenW = gFullWidth;//320
var screenH = gFullHeight;//480
var screenXOffset = (screenW - 320)/2;
var screenYOffset = (FPIsLandscape())?80:0;
var ox = screenW>480?40:0;

// index.js
orientation("vertical");
var appSettings = getAppSetting();
background(appSettings.background, true);

//header bg
image({id:"headerBg", src: appSettings.headerBg, x:0, y:0, w:gFullWidth, h:45});


label({id: "title", string: i18n('_PLAY_AS_A_FAMILY'), center: true, x: 0, y: 10, w: screenW, h: 35, size:16});
var screenshotsH= 237;
if (FPIsLandscape()){
    screenshotsH = 120;
    image({src: gImagePath+"horizontal_images", x:0+ox, y:50, w:screenW-ox*2, h:170});
    label({string: i18n('_REGISTERING_ALLOWS_YOU'), x: 40+ox, y: screenshotsH +110, w: screenW-80-ox*2, h: 60, size:14, font: "light font", color:appSettings.txtColor});
    button({src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 8, size: 12, id: "back", string: i18n('_BACK')});
    button({src:gImagePath+"greenbutton_half", leftCap:5, rightCap:5, idleover:"same", id: "go", metricName: "countMeIn", x: 40+screenXOffset, y:screenshotsH +160, w:240, h:30, string: i18n('_COUNT_ME_IN'), size: 16});
}else{
    image({src: gImagePath+"register-screenshots", x:0, y:60, w:screenW, h:165});
    label({string: i18n('_REGISTERING_ALLOWS_YOU'), x: 20+screenXOffset+ox, y: screenshotsH +10, w: 280, h: 60, size:14, font: "light font", color:appSettings.txtColor});
    button({src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 8, size: 12, id: "back", string: i18n('_BACK')});
    button({src:gImagePath+"greenbutton_half", leftCap:5, rightCap:5, idleover:"same", id: "go", x: 40+screenXOffset+ox, y:screenshotsH +90, w:240, h:30, string: i18n('_COUNT_ME_IN'), size: 16});
}
end();

//logic.js
o = function(s, args) {
    s.on_go = function()
    {
        runScreenCloser(s, "right");
        runScreen(gRoot, "pick_avatar", "left", {flow:args.flow});
    }
    s.on_back = function()
    {
        runScreenCloser(s, "left");
        runScreen(gRoot, "select_play_options", "right");
    };
};
FPLaunchScreen(o);