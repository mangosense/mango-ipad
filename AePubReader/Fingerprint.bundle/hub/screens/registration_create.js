orientation("vertical");
var appSettings = getAppSetting();
background(appSettings.background, true);

//header bg
image({id:"headerBg", src: appSettings.headerBg, x:0, y:0, w:gFullWidth, h:45});


label({id: "title", string: i18n('_REGISTER_WITH_FINGERPRINT', {partner: appSettings.partnerName}), center: true, x: 0, y: 10, w: screenW, h: 35, size:16});
end();

//logic.js
o = function(s, args) {

    var fbtoken = args?args.facebook_token:null;

    init();

    function init()
    {
        var contentPanel = div({parent:s, x:0, y:45, w:gFullWidth, h:gFullHeight-45});
        var d = getThreeGroupTemplate(contentPanel, 300, 300, 90, 225, 55);
        var top = d.topPanel, bottom = d.bottomPanel, middle = d.middlePanel;
        bottom.buttonParent = s;
        middle.buttonParent = s;
        var inner_w = parseInt($(top).css("width"))/gScaleX;
        var avatarDiv = div({parent: top, x:0, y:0, w: 78, h: 75});
        var bParent = (args && (args.flow === "GuestAddParent" || args.flow === "GuestsAddParent" || args.flow === "FamilyPlay"));
        drawAvatar(avatarDiv, args.person.avatar, bParent?"parent":"family", null, 60, 3, 0, false);
        var textGroup = div({parent:top, x:85, y: 0, w:FPIsLandscape()?inner_w:inner_w-85, h: FPIsLandscape()?130:90});
        var l = label({parent: textGroup, string: i18n('_SPAN_HI', {name:args.person.name}), vCenter: false, x:0, y: 0, size:FPIsLandscape()?11*gFullWidth/480:14, font: "light font", vCenter:true, color:appSettings.txtColor});
        $(l).css("width", "100%");
        $(l.text).children("span").css("font-family", fixFontFamily("bold font"));
        setPositionRelative(textGroup);
        div({parent: middle, id:"frame", x: 10, y: 0, w: 280, h:225, color: "#ffffff"});
        $(s.div["frame"]).css("border", "1px solid #c2bebe");
        var links = label({parent: middle, string: i18n('_I_CERTIFY_THAT', {privacy: '<a id="pp" style="color:'+appSettings.linkColor+'">'+i18n("_PRIVACY_POLICY")+'</a>', terms:'<a id="tos" style="color:'+appSettings.linkColor+'">'+i18n("_TERMS_OF_USE")+'</a>', partner: appSettings.partnerName}),
            x: 55, y: 108, w: 220, h: 60, size:12, font: "light font", multiColorFunc:getColor, color:"#a6a6a6"});
        field({parent:middle, x: 30, y: 20, w: 240, h: 30, size: 15, id: "email", placeholder: i18n("_EMAIL_ADDRESS"), email: true,
            field: "gray-box.png", icon:{src: gImagePath+"icon_email", w:14, h:12, y:8 }, setTransparent: true, ox: 40});
        field({parent:middle, x: 30, y: 62, w: 240, h: 30, size: 15, id: "password", placeholder: i18n("_PASSWORD"), password:true, maxLength: 16,
            field: "gray-box.png", icon:{src: gImagePath+"icon_password", w:14, h:12, y:8 }, setTransparent: true, ox: 40});
        // checkbox
        button(_CheckBoxButton, {parent:middle, id: "agree", x: 26, y:108, w:25, h:25});
        var t = { src: gImagePath+"password_hide", y: 62, size: 12, string: "", stringOn: "", toggle: true};
        button(t, {parent:middle, id:"show", x: 215, w: 50, h:25});
        button({parent:middle, src:gImagePath+"greenbutton_half", leftCap:5, rightCap:5, idleover:"same", id: "go", x: 156, y:165, w:120, h:45, string: i18n('_REGISTER'), size: 18});
        button({parent:middle, src:gImagePath+"graybutton_half", leftCap:5, rightCap:5, idleover:"same", id: "back", x: 26, y:165, w:120, h:45, string: i18n('_CANCEL'), size: 18});
        var pos = getPosForCenter(bottom, FPIsLandscape()?0.95:0.7);
        button({parent:bottom, src:gImagePath+"facebook_button", idleover:"same", id: "facebook", vCenter:true,
            x: pos.x, y:10, w:pos.w, h:pos.w*0.176, ox:pos.w*0.176, string: i18n("_REGISTER_WITH_FACEBOOK"), size: FPIsLandscape()?pos.w/15:13});

        if (FPIsLandscape()){
            $(textGroup).css("left", 0);
            $(bottom).css("top", parseInt($(top).css("top"))+parseInt($(top).css("height"))-15*gScaleY);
            setChildrenXCenter(top);
            setPositionRelative(top);
        }else{
            setLineHorizontally(top, 85, 5);
            setXCenter(textGroup);
        }
        setChildrenXCenter(contentPanel);

        if (fbtoken)
        {
            $(s.button["facebook"]).hide();
        }
        function getColor(i, words)
        {
            if (words[i] === "Terms" || (words[i] === "of" && i > 10) || words[i] === "Use" ) {
                return appSettings.linkColor;
            } else if ( (words[i] === "Privacy") || words[i] === "Policy" ){
                return appSettings.linkColor;
            }
        }
        var eventName = window["FPNative"]?"touchend":"click";
        $(links.text).css({pointerEvents:"all"});
        $("#tos").on(eventName, onTOS);
        $("#pp").on(eventName, onPolicy);

        function onTOS(){
            $("*:focus").blur();
            runScreen(s, "registration_tos", "left");
        };
        function onPolicy(){
            $("*:focus").blur();
            runScreen(s, "registration_pp", "left");
        };
    }

    s.on_agree = function(){
        $("*:focus").blur();
        SetToggle(s.button["agree"], s.button["agree"].bOn);
    };



    s.on_go = function()
    {
        $("*:focus").blur(); // set blur, even fail register one
        // disable all the button while waiting response from server
        $( s ).attr({ disabled: true });

        function onCreateAccount(r)
        {
            FPChangeAvatar(FPGetPerson(), args.person.avatar, next);
            function next(){
                runScreenCloser(s, "right");

                if (r.bSuccess === undefined)
                {
                    DoAlert(i18n("_ERROR"), i18n("_UNABLE_REACH_SERVER", {partner: appSettings.partnerName}));
                }
                else if ( !r.bSuccess )
                {
                    runScreen(gRoot, "registration_change_login", "left", {flow:args.flow, person:args.person, "email": s.field["email"].value});
                }else
                {
                    runScreen(gRoot, "usersetup_children", "left", {flow:args.flow});
                }
            }


        }

        // ToDo: change to out of focus then trigger the checking

        var pwdLength = s.field["password"].value.length;
        if (s.field["password"].bEmpty) {
            pwdLength = 0;
        }

        // validate email address
        if (!validateEmail(s.field["email"].value)) {
            SetField(s.field["password"], "");
            DoAlert(i18n("_INVALID_EMAIL"), i18n("_INVALID_EMAIL_FORMAT"));
            return;
        } else
        // validate password
        if (pwdLength < 5 || pwdLength > 16) {
            SetField(s.field["password"], "");
            DoAlert(i18n("_INVALID_PASSWORD"), i18n("_PASSWORD_MUST_BE"));
            return;
        } else
        // checking checkbox for TOS
        if (!s.button["agree"].bOn)
        {
            DoAlert(i18n("_TERMS_OF_USE"), i18n("_PLEASE_READ_TERMS"));
            return;
        } else
        {
            var email = s.field["email"].value;
            var password = s.field["password"].value;
            var bNewParent = (args.flow.indexOf("AddParent") >= 0 || args.flow === "FamilyPlay");
            // new person as parent
            var owner = args.person;
            // handle guest registration
            if (args && args.flow === "FamilyPlay")
            {
                FPCreateAccount(owner.name, "", email, password, fbtoken, onCreateAccount);
            }else{
                FPChangeEmail(email, onEmailChanged);
                function onEmailChanged(bSuccess)
                {
                    if (!bSuccess) {
                        SetField(s.field["password"], "");
                        DoAlert(i18n("_INVALID_EMAIL"), i18n("_EMAIL_ALEADY_REGISTERED"));
                    } else {
                        FPWebBatchStart();
                        FPChangePassword(password);
                        if (fbtoken) {
                            FPLinkFacebook(fbtoken);
                        }
                        if (bNewParent){
                            // add a new person that have the accountId as the personId
                            FPSetAccountPerson(FPGetAccountId(), owner.name, "", owner.avatar, false, true, null);

                        }else{
                            // change exist person to parent
                            FPSetParent(FPGetPersonId(), true, null);
                        }

                        FPWebRequest("Authenticate", {command: "validate"}, function(r) {
                            if (r.bSuccess) {
                                // everything is fine - save updated account data (e.g. might've added a facebook_id)
                                FPSaveAuthenticateResponse(r);
                            } else {
                                FPClearAccount();
                                setTimeout(FPResume, 1); // start-over if we got logged out
                            }
                        });

                        FPWebBatchSend(onUpdated, null, "Updating");
                    }
                }
                function onUpdated(){
                    var people = FPGetAccountActivePeople();
                    var person = FPGetPerson();
                    for (var i=0; i<people.length; i++) {
                        if (FPIsParentByPersonData(people[i])) {
                            person = people[i];
                            break;
                        }
                    }
                    FPPersonLogin(person);
                    if (args.flow.match(/Guest(?!s)/g)){
                        // lead to page that add more players in to the account
                        runScreenCloser(s, "right");
                        runScreen(gRoot, "usersetup_children","left", {flow:args.flow});
                    }else if (args.flow.indexOf("Guests") >= 0){
                        runScreenCloser(s, "right");
                        runScreen(gRoot, "registration_congratulations","left");
                    }
                }
            }
        }
    };

    s.on_facebook = function()    {
        function onFacebookResult(facebook_token)
        {
            fbtoken = facebook_token;
            // now we need to ask the Fingerprint Server to map the token to an email address and name
            function onFacebookInfo(r)
            {
                if (fbtoken)
                {
                    $(s.button["facebook"]).hide();
                }
                if (r.info.email)
                {
                    SetField(s.field["email"], r.info.email);
                }
            }
            if (!window["FPNative"]){
                fbtoken = facebook_token.facebook_token;
            }
            FPWebRequest("Facebook", {command: "infoFromToken", facebook_token:fbtoken}, onFacebookInfo, null, i18n("_GETTING_INFO"));
        }
        FPHelper.facebookConnect(onFacebookResult);
    };
    s.on_show = function()
    {
        s.button["show"].checked = s.button["show"].checked !== true;
        SetPasswordMode(s.field["password"], s.button["show"].checked !== true);
    };
    s.on_back = function(){
        runScreenCloser(s, "left");
        if (args && (args.flow.indexOf("AddParent") >= 0 || args.flow === "FamilyPlay")){
            runScreen(gRoot, "guest_name", "right", {flow: args.flow, avatar: args.person.avatar, name: args.person.name});
        }else{
            runScreen(gRoot, "are_you_parent", "right");
        }
    }

};
FPLaunchScreen(o);