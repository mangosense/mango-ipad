var screenW = gFullWidth;//320
var screenH = gFullHeight;//480
var screenXOffset = (screenW - 320)/2;
var screenYOffset = (FPIsLandscape())?40:0;
// index.js
orientation("vertical");
var appSettings = getAppSetting();
background(appSettings.background, true);

//header bg
image({id:"headerBg", src: appSettings.headerBg, x:0, y:0, w:gFullWidth, h:45});


// frame
div({id:"frame", x: 20+screenXOffset, y: 100-screenYOffset, w: 280, h:205, color: "#ffffff"});

label({id: "title", string: i18n('_FORGOT_PASSWORD'), center: true, x: 35+screenXOffset, y: 0, w: 240, h: 45, vCenter:true, size:20});
label({id: "tutorial", size: 16, x: 35+screenXOffset, y: 120-screenYOffset, w: 250, h:70, string: i18n('_ENTER_YOUR_EMAIL'), color:"#a6a6a6", font:"light font"});

button({src:gImagePath+"greenbutton_half", leftCap:5, rightCap:5, idleover:"same", id: "ok", x: 38+screenXOffset, y:250-screenYOffset, w:240, h:40, string: i18n('_OK'), size: 18});
button({src:gImagePath+"greenbutton_half", idleover:"same", id: "go", x: 165+screenXOffset, y:250-screenYOffset, w:120, h:40, string: i18n('_GO'), size: 18});
button({src:gImagePath+"graybutton_half", idleover:"same", id: "cancel", x: 38+screenXOffset, y:250-screenYOffset, w:120, h:40, string: i18n('_CANCEL'), size: 18});


end();

//logic.js
o = function(s, args) {

    var d;
    init();

    function init()
    {
        $(s.div["frame"]).css("border", "1px solid #c2bebe");
        $(s.div["frame"]).css("center", "true");
        $(s.div["frame"]).css("background-color", "white");
        $(s.div["frame"]).unbind('click');
        $(s.button["ok"]).hide();
        d = div({parent:s, x: 35+screenXOffset, y: 190-screenYOffset, w: 260, h: 60});
        field({parent:d, x: 5, y: 10, w: 240, h: 30, size: 15, id: "email", placeholder: i18n("_EMAIL_ADDRESS"), email: true,
            field: "gray-box.png", icon:{src: gImagePath+"icon_email", w:14, h:12, y:8 }, setTransparent: true, ox: 40});
        if (args.email&&args.email.length>0&&args.email!=="Email address")
        {
            SetField(s.field["email"], args.email);
        }

    };

    s.on_cancel = function()
    {
        runScreenCloser(s, "left");
        runScreen(gRoot, "registration_login", "right");
    }
    s.on_ok = function()
    {
        runScreenCloser(s, "left");
        runScreen(gRoot, "registration_login", "right");
    }

    s.on_go = function()
    {
        $("*:focus").blur(); // close keyboard
        if (s.field["email"].bEmpty) {
            DoAlert(i18n("_MISSING_EMAIL"), i18n("_PLEASE_ENTER_EMAIL"));
        } else if (!validateEmail(s.field["email"].value)){
            DoAlert(i18n("_INVALID_EMAIL"), i18n("_INVALID_EMAIL_FORMAT"));
        }else {
            var email = s.field["email"].value;
            var data = {
                email: email
            };
            FPWebRequest('ForgotPassword', data, onSend, null, i18n("_CONTACTING_FINGERPRINT", {partner: appSettings.partnerName}));
        }
        function onSend()
        {
            $(s.button["ok"]).show();
            $(s.button["cancel"]).hide();
            $(s.button["go"]).hide();
            $(d).hide();
            s.label["tutorial"].text.innerHTML = i18n("_IF_VALID_EMAIL", {email:["<span style='color:#4e4e4e'>", email, "</span>"].join("")});
        }
    }

};
FPLaunchScreen(o);