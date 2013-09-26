// index.js
orientation("vertical");

end();

// logic.js
//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

o = function(s, args) {

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background

    var email;
    var emailLabel;

    init();
    function init()
    {
        var d = div({parent:p, x:0, y:0, w:320, h:40});
        addBackgroundImage($(d), "gray-pattern.png");
        label({parent:p, id: "title", string: i18n('_ACCOUNT_SETTINGS'), center: true, x: 0, y: 10, w: 320, h: 55, size:15, color:"#4e4e4e"});
        button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "back", string: i18n('_BACK')});

        var d1 = div({parent:p, x: 40, y: 80, w: 240, h: 60});
        $(d1).css("border", "2px solid #efefed");
        emailLabel = label({parent:d1, x: 15, y: 30, w: 200, h: 35, size: 15, id: "email", string: "", color:"#4e4e4e", ellipsis:true});;

        function updateEmailLabel()
        {
            email = FPGetAccountValue("email");
            email = email?email:"";
            emailLabel.text.innerText = email;
        }

        updateEmailLabel();

        label({parent:d1, x: 15, y: 10, w: 240, h: 30, string: i18n('_EMAIL_ADDRESS'),  size:12, font: "light font", color:"#4e4e4e"});
        var d2 = div({parent:p, x: 40, y: 160, w: 240, h: 60});
        $(d2).css("border", "2px solid #efefed");
        label({parent:d2, x: 15, y: 30, w: 240, h: 40, size: 20, id: "password", string: "******", color:"#4e4e4e"});
        label({parent:d2, x: 15, y: 10, w: 240, h: 30, string: i18n('_PASSWORD'),  size:12, font: "light font", color:"#4e4e4e"});

        var t = { src: gImagePath+"rightarrow", idleover:"same", x: 256, size: 12, string: "", stringOn: ""};
        button(t, {parent:p, id:"changeEmail", y: 100, w: 15, h:32});
        button(t, {parent:p, id:"changePwd", y: 180, w: 15, h:32});
        var facebook_id = FPGetAccountValue("facebook_id");
        if (facebook_id){
            validateFacebookToken(next);
        }else{
            next();
        }
        function next(){
            facebook_id = FPGetAccountValue("facebook_id");
            if (!facebook_id){
                button({parent:p, src:gImagePath+"bluebutton_full", idleover:"same", id: "facebookBt", x: 40, y:gHubHeight-70, w:240, h:30, string: i18n('_LINK_TO_FACEBOOK'), size: 12});
                label({parent:p, string: i18n('_LINK_TO_YOUR'), id: "facebookText", center: true, x: 60, y: gHubHeight-30, w: 200, h: 55, size:12, font: "light font", color:"#4e4e4e"});
            }
        }
        var eventName = window["FPNative"]?"touchend":"click";
        $(d1).bind(eventName, function(){
            function onClose()
            {
                updateEmailLabel();
            }
            runScreen(s, "change_account_settings", "left", {toChange: "email"}, onClose);
        });
        $(d2).bind(eventName, function(){
            runScreen(s, "change_account_settings", "left", {toChange: "password"});
        });

        p.on_back = function()
        {
            s.close();
        };
        p.on_facebookBt = function()
        {
            function onFacebookResult(facebook_token)
            {
                FPLinkFacebook(facebook_token, next);
                function next(result)
                {
                    $(s.button["facebookBt"]).hide();
                    $(s.label["facebookText"]).hide();
                }
            }
            FPHelper.facebookConnect(onFacebookResult);
        };
        p.on_changeEmail = function()
        {
            runScreen(s, "change_account_settings", "left", {toChange: "email"});
        };
        p.on_changePwd = function()
        {
            runScreen(s, "change_account_settings", "left", {toChange: "password"});
        };

    }


};

FPLaunchScreen(o);



