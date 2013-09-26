var screenW = gFullWidth;//320 in vertical
var screenH = gFullHeight;//480
var screenXOffset = (screenW - 320)/2;
var screenYOffset = (FPIsLandscape())?50:0;
var ox = screenW>480?40:0;
// index.js
orientation("vertical");
var appSettings = getAppSetting();
background(appSettings.background, true);
//header bg
image({id:"headerBg", src: appSettings.headerBg, x:0, y:0, w:gFullWidth, h:45});


var appId = FPGetGameId();
var str = i18n("_WELCOME_TO");
if (FPIsSid()){
    str = "Sid's Slide to the Side";
    label({x: 0, y: 0, w: screenW, h: 45, size: 20, string: str, center:true, vCenter:true});
}
end();

//logic.js
o = function(s, args) {

    var title = label({parent:s, id: "welcome", x: 0+screenXOffset, y: 0, w: 320, h: 45, size: 20, vCenter: true, string: str});
    //logo
    var logo = image({parent:title, id:"logo", src: gImagePath+"logo", x:3, y:0, h:28});
    $(title).css({"text-align":"center"});
    $(title.text).css({display: "inline-block", width:"auto", position:"relative"});
    $(logo).css({display: "inline-block", position:"relative", paddingTop: 8.5*gScaleX, paddingTop: 8.5*gScaleX});

    init();

    function init()
    {
        var d = div({parent: s, x: 0, y:0, w: screenW, h: screenH, color: null});
        d.buttonParent = s;

        var gremlins = image({parent:d, id:"gremlins", src: gImagePath+"gremlins", x:207, y:290, w:80});

        // frame
        var f = div({parent:d, id:"frame", x: 20+screenXOffset, y: 115-screenYOffset, w: 280, h:175, color: "#ffffff"});

        button({parent:d, src:gImagePath+"play_as_a_kid", idleover:"same",id: "kidplay", x:35+screenXOffset, y:135-screenYOffset, w:250, h:65, string: i18n('_PLAY_AS_A_KID'), ox: 55, size: 14, center: true});
        button({parent:d, src:gImagePath+"set_up_family_account",idleover:"same",  id: "familyaccount", x:35+screenXOffset, y:205-screenYOffset, w:250, h:65, string: i18n('_PLAY_AS_A_FAMILY'), ox: 55, size: 14, center: true});

        $(f).css("border", "1px solid #c2bebe");
        $(f).css("center", "true");
        $(f).css("background-color", "white");
        $(f).unbind('click');

        if (FPIsLandscape())
        {
            gremlins.style.webkitTransform = "rotate(90deg)";
            $(gremlins).css("left", (screenXOffset-37)*gScaleX);
            $(gremlins).css("top", 175*gScaleX);
            label({parent:d, id: "guide", string: i18n('_ALREADY_HAVE_A', {partner: appSettings.partnerName}), x: 20+screenXOffset, y: 266, w: 150, h: 65, size:16, font: "light font", color:appSettings.txtColor});
            var b_signin = "orangebutton-signin";
            var appId = FPGetGameId();
            if (FPIsSid()){
                b_signin = "bluebutton-signin";
            }
            button({parent:d, id: "signin", src:gImagePath+b_signin, idleover:"same", string: i18n('_SIGN_IN'), x: 200+screenXOffset, y: 270, w: 100, h: 35, size:18});


        }else
        {
            label({parent:d, id: "guide", string: i18n('_ALREADY_HAVE_A', {partner: appSettings.partnerName}), center: true, x: 60+screenXOffset/3+ox, y: 330, w: 200, h: 35, size:12, vCenter:true, font: "light font", color:appSettings.txtColor});
            button({parent:d, id: "signin", src:gImagePath+"orangebutton-signin", idleover:"same", string: i18n('_SIGN_IN'), x: 110, y: 365, w: 100, h: 35, size:18});

        }

        $(d).hide();

        // attempt an auto-login
        function onAutoLogin(r)
        {
            if (r.bSuccess)
            {
                // auto-login successful
                s.close();
            }
            else
            {
                // nope - show the reg options
                $(d).show();
            }
        }
        FPAutoLogin(onAutoLogin);
    }

    s.on_signin = function()
    {
        FPSetEventScope2("Login");
        function next()
        {
            if (FPIsOffline()) {
                runScreen(s, "offline", "left", {what: "sign in to your account"});
            } else {
                runScreenCloser(s, "right");
                runScreen(gRoot, "registration_login", "left");
            }
        }
        DoParentGate(next);
    }

    s.on_kidplay = function()
    {
        FPSetEventScope2("Kidrg");
        runScreenCloser(s, "right");
        runScreen(gRoot, "pick_avatar", "left", {flow:"GuestPlay",bGoName: true, bBack:true});
    }

    s.on_familyaccount = function()
    {
        FPSetEventScope2("Famly");
        function next()
        {
            if (FPIsOffline()) {
                runScreen(s, "offline", "left", {what: "create a family account"});
            } else {
                runScreenCloser(s, "right");
                runScreen(gRoot, "play_as_a_family", "left", {flow:"FamilyPlay"});
            }
        }
        DoParentGate(next);
    }
};
FPLaunchScreen(o);