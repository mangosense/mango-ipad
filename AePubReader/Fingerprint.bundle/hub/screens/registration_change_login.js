// index.js
orientation("vertical");
var appSettings = getAppSetting();
background(appSettings.background, true);

//header bg
image({id:"headerBg", src: appSettings.headerBg, x:0, y:0, w:gFullWidth, h:45});


label({x: 0, y: 10, w: gFullWidth, h: 28, size: 20, string: i18n('_FINGERPRINT_ACCOUNT', {partner: appSettings.partnerName}), center:true});
end();

//logic.js
o = function(s, args) {
    var buttonBox;
    var buttonList;
    init();

    function init()
    {
        var screenW = gFullWidth;
        var screenH = gFullHeight;
        var ox = (screenW - 320)/2;
        var oy = (screenH - 45 - 301)/2;
        oy = oy<0?0:oy;
        buttonBox = div({parent:s, x: 0+ox, y: 45, w: 320, h:screenH-45});
        buttonBox.id = "changeLoginFrame";
        buttonList = div({parent: buttonBox, x: 0, y: 0, w: 320, h:301+oy});
        // frame
        div({parent:buttonList, id:"alertFrame", x: 20, y: oy, w: 280, h:91, color: "#d9472f"});
        div({parent:buttonList, id:"frame", x: 20, y: 90+oy, w: 280, h:210, color: "#ffffff"});


        image({parent:buttonList, id:"alert", src: gImagePath+"error", x:40, y:15+oy, w:20, h: 20});

        button({parent:buttonList, src:gImagePath+"greenbutton_half", leftCap:5, rightCap:5, idleover:"same", id: "signin", x: 40, y:110+oy, w:240, h:40, string: i18n('_SIGN_IN'), size: 18});
        button({parent:buttonList, src:gImagePath+"greenbutton_half", leftCap:5, rightCap:5, idleover:"same", id: "getPwd", x: 40, y:160+oy, w:240, h:40, string: i18n('_RETRIEVE_PASSWORD'), size: 18});
        button({parent:buttonList, src:gImagePath+"greenbutton_half", leftCap:5, rightCap:5, idleover:"same", id: "create", x: 40, y:235+oy, w:240, h:40, string: i18n('_START_OVER'), size: 18});


        $(s.div["alertFrame"]).css("border", "1px solid #bb3e28");
        $(s.div["alertFrame"]).css("center", "true");
        $(s.div["alertFrame"]).unbind('click');
        $(s.div["frame"]).css("border", "1px solid #c2bebe");
        $(s.div["frame"]).css("center", "true");
        $(s.div["frame"]).css("background-color", "white");
        $(s.div["frame"]).unbind('click');
        label({parent:buttonList, id: "guide", string: i18n('_CREATE_AN_ACCOUNT'), x: 40, y: 217+oy, w: 320, h: 35, size:9, font: "light font", color: "#000000"});
        label({parent:buttonList, x: 70, y: 20+oy, w: 200, h: 25, size: 15, id: "email", string: i18n('_JOESMITH12345_HOTMAIL_COM')});
        label({parent:buttonList, id: "alert", string: i18n('_WHOOPS_THIS_EMAIL'), x: 40, y: 45+oy, w: 250, h: 35, size:12});
        //$(s.image["alert"]).css("z-index", "100");
        s.label["email"].text.innerHTML = args["email"];

        new iScroll("changeLoginFrame");
        buttonList.buttonParent = s;
    }

    s.on_signin = function()
    {
        runScreenCloser(s, "right");
        runScreen(gRoot, "registration_login", "left");
    }

    s.on_getPwd = function()
    {
        runScreenCloser(s, "right");
        runScreen(gRoot, "registration_forgot_pwd", "left", {email:args["email"]});

    }

    s.on_create = function()
    {
        runScreenCloser(s, "left");
        runScreen(gRoot, "registration_create", "right", {flow:args.flow, person:args.person});
    }
};
FPLaunchScreen(o);