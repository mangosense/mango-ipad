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
        if (args&&args["noCenter"]){
            screenXOffset = 0;
        }
        label({parent:s, id:"title", string: i18n('_FIND_FRIENDS'), x:70, y:0, w:(args&&args["noCenter"])?180:(screenW-140), h:45, size:20, center:true, vCenter:true, color:"#4e4e4e"});
        button({parent:s, src:gImagePath+"greenbutton_full", idleover:"same", id: "username", x: 20+screenXOffset, y:60, w:280, h:45, string: i18n('_NICKNAME'), size: 18});
        button({parent:s, src:gImagePath+"greenbutton_full", idleover:"same", id: "email_phone", x: 20+screenXOffset, y:117, w:280, h:45, string: i18n('_EMAIL_OR_PHONE'), size: 18});
        button({parent:s, src:gImagePath+"greenbutton_full", idleover:"same", id: "contact", x: 20+screenXOffset, y:174, w:280, h:45, string: i18n('_CONTACT_LIST'), size: 18});
        button({parent:s, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 8, size: 12, id: "back", string: i18n('_BACK')});

        $(s).css("background-color", "white");
        addBackgroundImage($(s.div["headerBg"]), "gray-pattern.png");
        $(s.button["email_phone"]).hide();
        $(s.button["facebook"]).hide();
        $(s.button["contact"]).hide();
        if (FPIsGuest())
        {
            image({parent:s, src:gImagePath+"talk-bubble", x: 30+screenXOffset, y:190, w:180, h:60});
            image({parent:s, src:gImagePath+"talking-kid", x: 230+screenXOffset, y:180, w:60, h:90});
            var l = label({parent: s, id:"guestLabel",x: 40+screenXOffset, y: 205, w: 150, h: 30, size: 12, string: i18n('_ASK_YOUR_PARENT'), color:"#4e4e4e", font: "light font", multiColorFunc:getColor});
            var eventName= window["FPNative"]?"touchstart":"click";
            $(l).bind(eventName, function(){
                function next()
                {
                    FPWebView.eval("login", "FPCreateAccountDialog()", null);
                }
                DoParentGate(next);
            });
        }else if (FPIsParent()){
            $(s.button["email_phone"]).show();
            $(s.button["facebook"]).show();
            $(s.button["contact"]).show();
        }else{
            image({parent:s, src:gImagePath+"talk-bubble", x: 30+screenXOffset, y:190, w:180, h:60});
            image({parent:s, src:gImagePath+"talking-kid", x: 230+screenXOffset, y:180, w:60, h:90});
            label({parent: s, id:"childLabel",x: 40+screenXOffset, y: 205, w: 160, h: 30, size: 12, string: i18n('_ASK_YOUR_PARENT'), color:"#4e4e4e", font: "light font", multiColorFunc:getColor});
        }

        function getColor(i, words)
        {
            if (words[i] === "Register" ) {
                return appSettings.linkColor;
            }else{
                return "#a6a6a6";
            }
        }

    }
    s.on_username = function()
    {
        runScreen(s, "find_by_username", "left", {noCenter:args&&args["noCenter"]});
    };
    s.on_email_phone = function()
    {
        runScreen(s, "find_by_email_phone", "left", {noCenter:args&&args["noCenter"]});
    };
    s.on_contact = function()
    {
        openNativeFriendPicker(false);
    };

    s.on_back = function()
    {
        s.close();
    };
};

FPLaunchScreen(o);





