// index.js
orientation("vertical");
var appSettings = getAppSetting();
background(appSettings.background, true);

//header bg
if (FPIsLandscape())
{
    image({src: gImagePath+"termsofuse-kids2.png", x:(gFullWidth - 369)/2, y:45, w:369, h: 70});
}else
{
    image({src: gImagePath+"termsofuse_kids2.png", x:(gFullWidth - 260)/2, y:50, w:260, h: 70});
}
image({id:"headerBg", src: appSettings.headerBg, x:0, y:0, w:gFullWidth, h:45});



// frame
div({id:"frame", x: 20, y: 120, w: gFullWidth - 40, h:gFullHeight - 180, color: "#ffffff"});

label({id: "title", string: i18n('_FINGERPRINT_TERMS_OF', {partner: appSettings.partnerName}), center: true, x: 0, y: 15, w: gFullWidth, h: 35, size:16});

button({src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 8, size: 12, id: "back", string: i18n('_BACK')});
button({src:gImagePath+"bluebutton_full", idleover:"same", id: "agree", x: 40 + (gFullWidth - 320)/2, y:gFullHeight - 55, w:240, h:40, string: i18n('_VIEW_OUR_PRIVACY'), size: 13});

end();


o = function(s, args) {
    init();

    function init()
    {
        $(s.div["frame"]).css("border", "1px solid #c2bebe");

        if (FPIsLandscape())
        {
            $(s.div["frame"]).css("top", 100*gScaleX);
            $(s.div["frame"]).css("height", 215*gScaleX);
        }

        function onText(text)        {

            var wrapper = div({parent: s, x: 25, y: 120, w: gFullWidth - 50, h: gFullHeight - 180});

            var tosScrollBox = div({parent: wrapper, x: 0, y: 0, w: gFullWidth - 50, h: gFullHeight - 180});

            var tosLabel = label({parent: tosScrollBox, string: text, x: 0, y: 0, w: gFullWidth - 50, size: 10, font: "light font", color:"#a6a6a6" });

            FinishLegalText(tosScrollBox, tosLabel);
        }
        if (appSettings.get_tos){
            appSettings.get_tos(onText);
        }else{
            FPHelper.getText('/hub/legal/terms-of-use.html', onText);
        }


    }

    s.on_agree = function()
    {
        var parent = s.parent;
        s.parent = null; // TODO: fix this screen bug workaround
        runScreenCloser(s, "right");
        runScreen(parent, "registration_pp", "left");
    }
    s.on_back = function()
    {
        s.close("left");
    }
};

FPLaunchScreen(o);



