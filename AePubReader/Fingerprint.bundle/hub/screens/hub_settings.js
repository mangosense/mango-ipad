// index.js
orientation("vertical");

end();

// logic.js
//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

o = function(s, args) {

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    addBackgroundImage($(p), "gray-pattern.png");
    var oldPos;
    init();
    function init()
    {
        var appSettings = getAppSetting();
        var listBox = div({parent: p, x: 0, y: 5, w: 320, h: gHubHeight});
        listBox.id = "settingsList"+GUID();
        $(listBox).css("overflow-y", "scroll");
        var list = div({parent: listBox, x: 0, y: 0, w: 320, h: 400});
        var offset = 5, oy = 44;
        var t_button = {x: 40, idleover:"same", w: 240, h: 35, size: 16};
        if (FPIsParent())
        {
            if (appSettings.bAccountSetting){
                button(t_button, {parent: list, src: gImagePath+"greenbutton_full", id: "account", string: i18n('_ACCOUNT_SETTINGS'), y: offset});
                offset += oy;
            }
            button(t_button, {parent: list, src: gImagePath+"greenbutton_full", id: "message", string: i18n('_MESSAGE_PREFERENCES'), y: offset});
            offset += oy;
            button(t_button, {parent: list, src: gImagePath+"greenbutton_full", id: "player", string: i18n('_EDIT_PLAYERS'), y: offset});
            offset += oy;

        }else if (FPIsGuest())
        {
            // guest
            offset = 76;
            button(t_button, {parent: list, src: gImagePath+"greenbutton_full", id: "register", string: i18n('_REGISTER'), y: 0});
            label(t_button, {parent: list, id:"register", string: i18n('_REGISTER_TO_PLAY'), y: 41, w: 240, h: 35, size: 14, font:"light font", center:true, color:"#4e4e4e"});
            list.on_register = function()
            {
                if (FPIsOffline()) {
                    runScreen(s, "offline", "left", {what: "create your family account"});
                } else {
                    function next()
                    {
                        FPWebView.eval("login", "FPCreateAccountDialog()", null);
                    }
                    DoParentGate(next);
                }
            }

        } else {
            offset = 0;
        }
        if (appSettings.partner === "astro" || FPPartnerMode()){
            button(t_button, {parent: list, src: gImagePath+"bluebutton_half", id: "language", string: i18n('_LANGUAGE_COLON')+langLookUp[FPGetAppValue("language")], y: offset, leftCap:5, rightCap:5});
            offset+=45;
        }
        if (FPPartnerMode()){
            button(t_button, {parent: list, src: gImagePath+"bluebutton_half", id: "partner_mode", string: "Partner Mode", y: offset, leftCap:5, rightCap:5});
            offset+=45;
        }
        /*
        button(t_button, {parent: list, src: gImagePath+"bluebutton_half", id: "grownups", string: i18n('_FOR_GROWN_UPS'), y: offset, leftCap:5, rightCap:5});
        offset+=45;
        */
        button(t_button, {parent: list, src: gImagePath+"bluebutton_half", id: "privacy", string: i18n('_PRIVACY_POLICY'), y: offset, leftCap:5, rightCap:5});
        offset+=45;
        button(t_button, {parent: list, src: gImagePath+"bluebutton_half", id: "tos", string: i18n('_TERMS_OF_USE'), y: offset, leftCap:5, rightCap:5});
        offset+=45;
        button(t_button, {parent: list, src: gImagePath+"bluebutton_half", id: "about", string: i18n('_ABOUT_FINGERPRINT', {partner: appSettings.partnerName}), y: offset, leftCap:5, rightCap:5});
        offset+=45;
        button(t_button, {parent: list, src: gImagePath+"bluebutton_half", id: "help", string: i18n('_HELP'), y: offset, leftCap:5, rightCap:5});
        offset+=45;

        // don't let the child logout
        if (FPIsParent() || FPIsGuest()) {
            var str = FPIsGuest()?i18n("_REMOVE_ALL_PROFILES"):i18n("_SIGN_OUT");
            button(t_button, {parent: list, src: gImagePath+"redbutton_full", id: "signOut", string: str, y: offset});
            offset+=45;
        }
        $(list).css("height", offset*gScaleX);
        if (!window["gWebGame"]) {
            new iScroll(listBox.id, {vScroll: true, bounce: false,
            onScrollStart:
                function(e){
                    if (window["FPNative"]){
                        oldPos = {x:e.touches[0].clientX, y:e.touches[0].clientY};
                    }else{
                        oldPos = {x:e.clientX, y:e.clientY};
                    }
                },
            onScrollMove:
                function(e){
                    var newPos;
                    if (window["FPNative"]){
                        newPos = {x:e.touches[0].clientX, y:e.touches[0].clientY};
                    }else{
                        newPos = {x:e.clientX, y:e.clientY};
                    }
                    if (Math.abs(newPos.x-oldPos.x)>5*gScaleX || Math.abs(newPos.y-oldPos.y)>5*gScaleY){
                        var i = s.buttons.length;
                        while (i--){
                            SetEnabled(s.buttons[i], false);
                        }
                    }
                }});
        }

        list.on_account = function(){
            if (FPIsOffline()) {
                runScreen(s, "offline", "left", {what: "change account settings"});
            } else {
                runScreen(s, "hub_account_settings", "left");
            }
        };
        list.on_message = function(){
            if (FPIsOffline()) {
                runScreen(s, "offline", "left", {what: "change message preferences"});
            } else {
                runScreen(s, "edit_message_preferences", "left");
            }
        };
        list.on_player = function(){
            if (FPIsOffline()) {
                runScreen(s, "offline", "left", {what: "edit players"});
            } else {
                runScreen(s, "hub_edit_players", "left");
            }
        };
        list.on_grownups = function(){
            runScreen(s, "hub_grownups", "left");
        };
        list.on_privacy = function(){
            runScreen(s, "hub_privacy_tos", "left", "privacy");
        };
        list.on_tos = function(){
            runScreen(s, "hub_privacy_tos", "left", "tos");
        };

        list.on_about = function(){
            runScreen(s, "hub_about", "left");
        };
        list.on_help = function(){
            runScreen(s, "hub_help", "left");
        };

        list.on_signOut = function(){
            if (FPIsOffline()) {
                runScreen(s, "offline", "left", {what: "sign out"});
            } else {
                if (FPIsGuest()){
                    DoAlertOnGuestLogout(next);
                    function DoAlertOnGuestLogout(callback)
                    {
                        var args = {
                            callback: RegisterEvalCallback(callback)
                        }
                        FPWebView.eval("alert", "ShowAlertOnGuestLogout(" + JSON.stringify(args) + ")", null);
                    }
                }else{

                    DoAlert(i18n("_SIGN_OUT"), i18n("_ARE_YOU_WANT_SIGN_OUT"), next, i18n("_CANCEL"));
                }
                function next(bSignout){
                    if (bSignout === undefined){
                        $(s).trigger("updateHubPanel", ["hub_parent_home"]);
                    }else if (bSignout){
                        function onLogout(){
                            if (IsGameMultiplayer()) {
                                // open multiplayer list
                                FPWebView.show("multiplayer", true);
                                FPWebView.eval("multiplayer", "openHub('list', null)", null);
                            }
                            hubButtonPressed(); // close hub
                            FPWebView.eval("login", "FPResume()"); // restart login logic
                        }
                        FPAccountLogout(onLogout);
                    }
                }
            }
        };
        list.on_language = function(){
            runScreen(s, "hub_select_language","left");
        };
        list.on_partner_mode = function(){
            runScreen(s, "partner_mode","left");
        };
    }


};

FPLaunchScreen(o);



