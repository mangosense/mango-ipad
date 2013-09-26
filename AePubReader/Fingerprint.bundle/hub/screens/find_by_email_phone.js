var screenW = gFullWidth;//320
var screenH = gFullHeight;//480
var screenXOffset = (screenW - 320)/2;
var screenYOffset = (FPIsLandscape())?90:0;

// index.js
orientation("vertical");
//header bg
div({id:"headerBg", x:0, y:0, w:screenW, h:45});
end();


o = function(s, args) {
    init();

    function init()
    {
        var appSettings = getAppSetting();
        if (args&&args["noCenter"]){
            screenXOffset = 0;
        }
        label({parent:s, id:"title", string: i18n('_EMAIL_OR_PHONE'), x:0, y:11, w:(args&&args["noCenter"])?320:screenW, h:30, size:20, center:true, color:"#4e4e4e"});
        field({parent:s, id: "email_phone", x: 20+screenXOffset, y:70, w:220, h:35, placeholder: "", setTransparent: true, size: 18, field: "gray-box.png"});
        button({parent:s, src:gImagePath+"greenbutton_half", idleover:"same", x: 250+screenXOffset, y:gScaleY>1?66:61, w:60, h:49, size: 18, id: "go", string: i18n('_GO'), leftCap:5, rightCap:5});
        button({parent:s, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 8, size: 12, id: "back", string: i18n('_BACK')});

        $(s).css("background-color", "white");
        addBackgroundImage($(s.div["headerBg"]), "gray-pattern.png");
        var d = div({parent: s, x: 45+screenXOffset, y: 150, w:170});
        label({parent: d, x: 0, y: 0, w: 170, size: 12, center:true, string: i18n('_TYPE_YOUR_FRIENDS_EMAIL'), color:"#4e4e4e"});
        label({parent: d, x: 10, y: 0, w: 150,  size: 12, center:true, string: i18n('_EXAMPLE_ABC_FINGERPRINTPLAY', {email:  appSettings.exampleEmail, phone: appSettings.examplePhone}), color:"#a6a6a6", font:"light font"});
        setPositionRelative(d);
        image({parent:s, src:gImagePath+"talking-kid", x: 230+screenXOffset, y:130, w:60, h:95});
        image({parent:s, src:gImagePath+"arrow", x: 20+screenXOffset, y:140, w:25, h:20});
    }

    function close()
    {
        s.close();
    }

    s.on_go = function()
    {
        $("*:focus").blur(); // unfocus field and close keyboard when go button pressed
        var v = GetField(s.field["email_phone"]);
        var bValid = validateEmail(v) || validatePhoneNumber(v);
        if (!bValid) {
            DoAlert(i18n("_INVALID_NAME"), i18n("_PLEASE_ENTER_EMAIL_PHONE"));
        } else {
            var v = GetField(s.field["email_phone"]);
            if (v.indexOf("@") != -1) {
                // email
                FPWebRequest("Message", {command: "inviteEmail", email: v});
            } else {
                // phone number
                FPWebRequest("Message", {command: "inviteSMS", phone: v});
            }
            var str = "Your message has been sent";
            if ((args&&args["noCenter"])){
                $(s).trigger("showAnimateMessage", [str, close]);
            }else{
                messageSlideDown(s, str, gFullWidth, close);
            }
        }
    }

    s.on_back = function()
    {
        $("*:focus").blur();
        close();
    }
};

FPLaunchScreen(o);





