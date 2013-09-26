// index.js
orientation("vertical");

end();

// logic.js
//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

o = function(s, args) {
    var settings = FPGetAccountSettings();

    var modes = ["email", "facebook"];
    var keys = ["achievements", "promotion"];

    // provide initial settings, if not there
    if (!settings) {
        settings = {};
    }
    for (var i=0; i<modes.length; i++) {
        if (settings[modes[i]] === undefined) {
            settings[modes[i]] = {};
        }
        for (var j=0; j<keys.length; j++) {
            if (settings[modes[i]][keys[j]] === undefined) {
                settings[modes[i]][keys[j]] = true;
            }
        }
    }

    var bHaveFacebook = false;
    var facebook_id = FPGetAccountValue("facebook_id");
    if (facebook_id && facebook_id.length > 0) {
        bHaveFacebook = true;
        validateFacebookToken();
    }

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    init();
    function init()
    {
        var d = div({parent:p, x:0, y:0, w:320, h:40});
        addBackgroundImage($(d), "gray-pattern.png");
        label({parent:p, id: "title", string: i18n('_EDIT_MESSAGE_PREFERENCES'), center: true, vCenter:true, x: 80, y: 0, w: 160, h: 40, size:12.5, color:"#4e4e4e"});
        button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "back", string: i18n('_BACK')});
        label({parent:p, x: 190, y: 45, w: 50, h: 30, size: 15, string: i18n('_EMAIL'), color:"#4e4e4e"});
        var facebookLabel = label({parent:p, x: 245, y: 45, w: 80, h: 30, size: 15, string: i18n('_FACEBOOK'), color:"#4e4e4e"});
        var displayText = [i18n("_GAME_ACHIEVEMENTS"), i18n("_PROMOTIONAL"), i18n("_ALL")];
        var countTrue = {email:0, facebook:0};
        var oy = 0;
        var listBox = div({parent:p, x:0, y:60, w:320, h:212});
        listBox.id = "msgPreferenceList";
        var list =  div({parent:listBox, x:0, y:0, w:320, h:displayText.length*50+2});
        for (var i = 0; i< displayText.length; i++)
        {
            var line = div({parent:list, x: 5, y: oy, w: 310, h: 70, id:"line."+i});
            var l = label({parent:line, x: 0, y: 0, w: 150, h: 70, size: 15, vCenter: true, id: "Name."+i, string: displayText[i], color:"#4e4e4e"});
            $(l).css("text-align", "right");
            button(_CheckBoxButton, {parent:line, id: "email."+i, x: 200, y:20, w:25, h:25});
            button(_CheckBoxButton, {parent:line, id: "facebook."+i, x: 250, y:20, w:25, h:25});
            if (i < displayText.length -1){
                var key = keys[i];
                SetToggle(s.button["email."+i], settings["email"][key]);
                SetToggle(s.button["facebook."+i], settings["facebook"][key]);
                countTrue["email"] = settings["email"][key]?countTrue["email"]+1:countTrue["email"];
                countTrue["facebook"] = settings["facebook"][key]?countTrue["facebook"]+1:countTrue["facebook"];
            }
            oy += 50;
            line.on_email = function(i){
                checkBoxAction("email", i);
            }
            line.on_facebook = function(i){
                checkBoxAction("facebook", i);
            }
        }
        setAllBtStatus("email", countTrue);
        setAllBtStatus("facebook", countTrue);

        if (!bHaveFacebook) {
            var opacity = 0.3;
            $(facebookLabel).css("opacity", opacity);
            for (var i=0; i<3; i++) {
                SetToggle(s.button["facebook."+i], false);
                SetEnabled(s.button["facebook."+i], false);
                $(s.button["facebook."+i]).css("opacity", opacity);
            }
        }

        function checkBoxAction(name, i)
        {
            SetToggle(s.button[name+"."+i], s.button[name+"."+i].bOn);
            countTrue[name] = s.button[name+"."+i].bOn?countTrue[name]+1:countTrue[name]-1;
            // when check all make other checked
            if (i===(displayText.length-1).toString())
            {
                var bAll = s.button[name+"."+i].bOn;

                for (var j = 0; j < displayText.length-1; j++){
                    SetToggle(s.button[name+"."+j], bAll);
                }
                countTrue[name] = bAll ? keys.length : 0;
            }
            setAllBtStatus(name, countTrue);
        }
        function setAllBtStatus(name, countObj)
        {
            SetToggle(s.button[name+"."+keys.length], (countObj[name]=== keys.length));
        }
        new iScroll("msgPreferenceList", {hScroll: true, bounce: false});

        button({parent:p, src:gImagePath+"greenbutton_full", idleover:"same", id: "save", x: 40, y:270, w:240, h:40, string: i18n('_SAVE'), size: 18});


        p.on_back = function()
        {
            s.close();
        };
        p.on_save = function()
        {
            var bEdited = false;
            var oldSettings = FPGetAccountSettings();
            for (var i=0; i<displayText.length-1; i++) {
                var key = keys[i];
                settings["email"][key] = s.button["email."+i].bOn;
                settings["facebook"][key] = s.button["facebook."+i].bOn;
                if( oldSettings["email"] === undefined  ||
                    oldSettings["email"][key]!==settings["email"][key] ||
                    oldSettings["facebook"] === undefined ||
                    oldSettings["facebook"][key]!==settings["facebook"][key]){
                    bEdited = true;
                }
            }
            if (bEdited){
                FPSetAccountSettings(settings);
                s.close();
            }else{
                s.close();
            }
        };
    }
};

FPLaunchScreen(o);



