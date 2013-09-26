var screenW = gFullWidth;//320
var screenH = gFullHeight;//480
var bVertical = !FPIsLandscape();
var screenXOffset = (screenW - 320)/2;
var screenYOffset = (FPIsLandscape())?80:0;
var ox = screenXOffset - screenYOffset/2;
// index.js
orientation("vertical");
var appSettings = getAppSetting();
background(appSettings.background, true);

//header bg and logo on center
logo();

//title
if (FPInDelayedRegistrationMode()) {
    if (FPIsSid()) {
        label({string: i18n('_WELCOME_TO_FINGERPRINT_PICK', {partner: appSettings.partnerName}), x:5, y:11, w:screenW, size:16, id:"title"});
    } else {
        label({string: i18n('_WELCOME_TO_FINGERPRINT_PICK', {partner: appSettings.partnerName}), center: true, x:0, y:5, w:screenW, size:16, id:"title"});
    }
    button({src:gImagePath+"close-x", idleover:"same", x: gFullWidth-34, h: 30, w: 30, y: 5, size: 12, id: "close", string: ""});
} else {
    //label({string: i18n('_PICK_YOUR_PICTURE'), x:0, y:11, w:screenW, size:16, center:true, id:"title"});
    // logo image

}
button({src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 8, size: 12, id: "back", string: i18n('_BACK')});

end();

var gAvatarNum = 12;

o = function(s, args) {
    centerLogo(s);
    // frame
    var frameHeight = FPIsLandscape()?245:gFullHeight-45-20;
    frameHeight = frameHeight > 450? 450:frameHeight;
    var ox = (gFullWidth - 320 - (FPIsLandscape()?80:0))/2;
    var oy = (gFullHeight-45-frameHeight)/2;
    var frame = div({parent:s, id:"frame", x: 20+ox, y: 45+oy, w: 280 + (FPIsLandscape()?80:0), h:frameHeight, color: "#ffffff"});

    var avatarId = -1;

    init();

    function init()
    {
        $(s.div["frame"]).css("border", "1px solid "+appSettings.boxFrameRGBA);
        $(s.div["frame"]).css("center", "true");
        $(s.div["frame"]).css("background-color", appSettings.boxRGBA);
        $(s.div["frame"]).unbind('click');
        if (args && args.noBack)
        {
            $(s.button["back"]).hide();
        }
        var title = i18n('_PICK_YOUR_PICTURE');
        if (args && (args.flow === "GuestAddParent" || args.flow === "GuestsAddParent")){
            title = i18n("_PICTURE_FOR_YOUR");
        }

        var bParent = !!(args && (args.flow === "GuestAddParent" || args.flow === "GuestsAddParent" || args.flow === "FamilyPlay" || args.flow === "bPartnerNewAcc"));
        var avatarScrollBox = createAvatarSelector(frame, frameHeight, 0-FPIsLandscape()?80:0, title, null, !FPIsLandscape(), bParent);


        avatarScrollBox.on_avatar = function(i)
        {
            avatarId = i;
            FlashButton(s.button["avatar."+i]);
            var img = generateAvatarImagePath("avatar"+avatarId);
            img = GetImageInfo("hub/"+img).src;
            // change image src and reload
            $(s.image["avatar_selected"]).attr('src',img);
        }

        if (!FPIsLandscape())
        {
            button({parent:frame, src:gImagePath+"greenbutton_half", idleover:"same", id: "agree", x: 20, y:320 + (gFullHeight-426)*0.2, w:240, h:40, string: i18n('_NEXT'), size: 13, leftCap:5, rightCap:5});

        }else
        {
            button({parent:frame, src:gImagePath+"greenbutton_half", idleover:"same", id: "agree", x: 270, y:150, w:80, h:40, string: i18n('_NEXT'), size: 13});

        }
    }

    frame.on_agree = function()
    {
        if (avatarId < 0)
        {
            if (args && (args.flow === "GuestAddParent" || args.flow === "GuestsAddParent")){
                DoAlert(i18n("_PICTURE_FOR_YOUR"), i18n("_PLEASE_PICK_YOUR_PARENT"));
            }else{
                DoAlert(i18n("_PICK_YOUR_PICTURE"), i18n("_PLEASE_PICK_YOUR"));
            }
        }
        else
        {
            if (FPInDelayedRegistrationMode()) {
                runScreenCloser(s, "right");
                runScreen(gRoot, "guest_name", "none", {avatar: "avatar"+avatarId});
                return;
            }

            if (args && args.flow && !args.noBack) {
                runScreenCloser(s, "right");
                runScreen(gRoot, "guest_name", "left", {flow:args.flow, avatar: "avatar"+avatarId});
            } else {
                // TODO: need a way to set avatar that doesn't require synchronous server response
                function next()
                {
                    s.close();
                }
                FPChangeAvatar(FPGetPerson(), "avatar"+avatarId, next);
            }
        }
    }
    s.on_back = function()
    {
        runScreenCloser(s, "left");
        if (args && args.flow){
            switch (args.flow){
                case "GuestPlay":
                    runScreen(gRoot, "select_play_options", "right");
                    break;
                case "FamilyPlay":
                    runScreen(gRoot, "play_as_a_family", "right", {flow:args.flow});
                    break;
                case "GuestAddParent":
                    runScreen(gRoot, "are_you_parent", "right", {flow:args.flow});
                    break;
                case "GuestsAddParent":
                    runScreen(gRoot, "are_you_parent", "right", {flow:args.flow});
                    break;
            }
        }
    };

    s.on_close = function()
    {
        s.close();
    }
};

FPLaunchScreen(o);




