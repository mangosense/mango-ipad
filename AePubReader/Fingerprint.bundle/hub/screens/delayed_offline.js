var screenW = gFullWidth;//320
var screenH = gFullHeight;//480
var bVertical = !FPIsLandscape();
var screenXOffset = (screenW - 320)/2;
var screenYOffset = (FPIsLandscape())?80:0;
var ox = screenXOffset - screenYOffset/2;
// index.js
orientation("vertical");
var appSettings = getAppSetting();
background(appSettings.background, true);

//header bg
image({id:"headerBg", src: appSettings.headerBg, x:0, y:0, w:gFullWidth, h:45});

//title
label({string: i18n('_NO_CONNECTION'), x:0, y:11, w:screenW, size:16, center:true, id:"title"});
end();

o = function(s, args) {

    var w = gFullWidth - 80;
    image({parent: s, src: gImagePath+"offline", x: 20+ox+(280 + screenYOffset -150)/2, y: 50, w: 150});
    var frame = div({parent:s, x: (gFullWidth - w) / 2, y: 180, w: w, h: 130, color: "#ffffff"});
    $(frame).css("border", "1px solid #c2bebe");
    button({parent: s, src:gImagePath+"greenbutton_half", idleover:"same", id: "ok", string: i18n('_OK'), x: (gFullWidth-120)/2, y: 260, w:120, h:40, size: 16});

    label({parent:s, string: i18n('_YOU_CAN_SET', {partner: appSettings.partnerName}), x:0,y:200, w:gFullWidth, size: 18, center: true, color:"#4e4e4e"});

    s.on_ok = function()
    {
        s.close();
    }
};

FPLaunchScreen(o);




