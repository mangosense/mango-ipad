// index.js
orientation("vertical");
var appSettings = getAppSetting();
background(appSettings.background, true);

//header bg and logo on center
logo();

button({src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 8, size: 12, id: "back", string: i18n('_BACK')});
end();


var gAvatarNum = 12;

o = function(s, args) {
    centerLogo(s);
    var actionText = i18n("_DONE");
    var name = (args&&args.name)?args.name:"Guest";
    var avatar = (args&&args.avatar)?args.avatar:"";
    var nameLabel;
    var generatedName;

    if (name !== "Guest"){
        init(name);
    }else{
        FPGenerateName(init);
    }

    function init(n)
    {
        if (FPInDelayedRegistrationMode() && n === undefined) {
            runScreenCloser(s, "up");
            runScreen(gRoot, "delayed_offline", "down");
            return;
        }

        if (gbContinueGuestRegistration){
            // hide the back button
            $(s.button["back"]).hide();
        }
        var centerPanel = div({parent:s, x:0, y:FPIsLandscape()?50:Math.max(50, gFullHeight*0.2), w:280, h:255});
        setXCenter(centerPanel);
        $(centerPanel).css({backgroundColor:appSettings.boxRGBA});
        label({parent: centerPanel, x: 0, y: 0, w: 280, h: 40, size: 14, center:true, vCenter:true, string: i18n('_PICK_YOUR_NICKNAME'), color:"#4e4e4e"});

        generatedName = n;
        name = (n === undefined) ? "Guest" : n;

        var bParent = (args && (args.flow === "GuestAddParent" || args.flow === "GuestsAddParent" || args.flow === "FamilyPlay"));
        drawAvatar(centerPanel, avatar, bParent?"parent":"family", "avatar", 56, 30, 40, false);
        var msg = i18n("_PULL_THE_LEVER");
        if (args && (args.flow === "GuestAddParent" || args.flow === "GuestsAddParent")) {
            msg = i18n("_PARENT_PULL_THE_LEVER")
        }else if (args && (args.flow === "DeferredGuest")){
            msg = i18n("_CONGRATULATIONS_NICKNAMES");
        }
        if (n === undefined) {
            msg = i18n("_CANT_REACH", {partner: appSettings.partnerName});
        }
        label({parent: centerPanel, x: 105, y: 40, w: 160, h: 60, size: 12, vCenter:true, string: msg, color:"#4e4e4e", font:"light font"});

        var nameGenBox = div({parent:centerPanel, x:20, y:100, w:283, h:63});
        image({parent: nameGenBox, src: gImagePath+"name-generator-box", x:0, y:11, w:240, h:40});
        nameLabel = label({parent:nameGenBox, id:"nameLabel", string:name, x:15, y:22, w:240, h:40, size:16, color:"#4e4e4e"});
        // only show name generation lever if we have a name
        if (n !== undefined) {
            var leverImage =image({parent: nameGenBox, src: gImagePath+"lever1", x:221, y:0, w:20, h:63});
            leverImage.id = "anim";
            var eventName = window["FPNative"]?"touchstart":"click";
            $(nameGenBox).bind(eventName, function(){
                changeName();
            });
        }

        var bChangingName = false;

        function changeName()
        {
            // saw this was getting run twice when I touched the level, so making sure that doesn't happen, as I fear
            // it was leading to "wasted names" since one of the 2 wouldn't get rejected...
            if (bChangingName) return;

            bChangingName = true;

            lever.init();
            lever.startAnimation();
            FPRejectAndGenerateName(name, onName);
            function onName(n) {

                if (FPInDelayedRegistrationMode() && n === undefined) {
                    runScreenCloser(s, "up");
                    runScreen(gRoot, "delayed_offline", "down");
                    return;
                }

                bChangingName = false;

                name = n;
                nameLabel.text.innerText = name;
            }
        }
        var lever = new SpriteAnim({
            numOfImages: 3,
            backgroundImage: "lever",
            elementId : "anim"
        });
        var text_y = 0;
        if (FPIsGuest() && args.flow === "GuestPlay")
        {
            text_y = 49;
            actionText = i18n("_DONE");
            var links = label({parent: centerPanel, x: 30, y: 160, w: 220, h: 45, size: 12, center:true, string: i18n('_I_CERTIFY_THAT_I', {privacy: '<a id="pp" style="color:'+appSettings.linkColor+'">'+i18n("_PRIVACY_POLICY")+'</a>', terms:'<a id="tos" style="color:'+appSettings.linkColor+'">'+i18n("_TERMS_OF_USE")+'</a>', partner: appSettings.partnerName}), color:"#4e4e4e", font: "light font", color:"#4e4e4e"});
            var eventName = window["FPNative"]?"touchend":"click";
            $(links.text).css({pointerEvents:"all"});
            $("#tos").on(eventName, onTOS);
            $("#pp").on(eventName, onPolicy);
            function onTOS(){
                runScreen(s, "registration_tos", "left");
            };
            function onPolicy(){
                runScreen(s, "registration_pp", "left");
            };
        }
        button({parent:centerPanel, src:gImagePath+"greenbutton_half", leftCap:5, rightCap:5, idleover:"same", id: "agree", x: 20, y:text_y+160, w:240, h:40, string: actionText, size: 13});
        centerPanel.on_agree = function(){
            s.on_agree();
        };
    }

    s.on_agree = function()
    {
        if (!name.match(/\S/) ) {
            DoAlert(i18n("_INVALID_NAME"), i18n("_PLEASE_ENTER_YOUR_NAME"));
            return;
        }
        else
        {
            if (FPIsGuest() && args.flow === "GuestPlay" ){
                FPGuestLogin(name, avatar);
                if (generatedName === undefined) {
                    s.close();
                } else {
                    function next()
                    {
                        runScreenCloser(s, "right");
                        runScreen(gRoot, "hub_sell", "left");
                    }
                    FPGuestAuthenticate(next);
                }
            }else if (args && (args.flow === "GuestAddParent" || args.flow === "GuestsAddParent" || args.flow === "FamilyPlay")) {
                // Guest Registration, new person added to be the parent
                var person = {};
                person.name = name;
                person.avatar = avatar;
                person.real_name = "";
                runScreenCloser(s, "right");
                runScreen(gRoot, "registration_create", "left", {flow:args.flow, person:person});

            }else if (args && args.flow === "bPartnerNewAcc"){
                FPSetAccountPerson(FPGetAccountId(), name, "", avatar, false, true, onSetPerson);
                function onSetPerson(){
                    runScreen(gRoot, "usersetup_children", "left", {flow:args.flow});
                }
            }
            else{
                // generate a name when user named "Guest" back to online
                var p = FPGetPerson();
                FPGuestLogin(name, p.avatar);
                FPGuestAuthenticate(function(){s.close();});
            }
        }

    };
    s.on_back = function()
    {
        runScreenCloser(s, "left");
        FPRejectName(name);
        runScreen(gRoot, "pick_avatar", "right", {flow:args.flow});
    };
};

FPLaunchScreen(o);





