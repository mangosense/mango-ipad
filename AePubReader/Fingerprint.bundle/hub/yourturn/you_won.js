// index.js
orientation("vertical");
div({id:"alertFrame", x: 5, y: 140, w: 306, h:91, color: "#d9472f"});
div({id: "frame", x: 5, y:180, w: 306, h:150, color: "#ffffff"});

end();




// logic.js
// the input, title and msg is a must have, others are optional.
// {cancel: "cancel", ok: "ok", title: "Alert", msg: "Please select.", callback: fn }
o = function(s, args) {

    init();

    function init()
    {
        $(s.div["alertFrame"]).css("border", "1px solid #bb3e28");
        $(s.div["frame"]).css("border", "1px solid #c2bebe");
        $(s.div["frame"]).css("center", "true");
        $(s.div["frame"]).css("background-color", "white");
        $(s.div["frame"]).unbind('click');

        var ox = 14;
        var oy = 142;


        if (!FPIsGuest())// not a guest
        {
            $(s.div["frame"]).css("height", "200");

            label({x: 0, y: oy+10, size: 24, w: 320, string: i18n('_YOU_WON'), center: true });

            oy = oy+50;

            var avatar = args.avatar;
            if (avatar === null || avatar === "" || avatar === undefined)
            {
                avatar = gImagePath+"randomavatar.png";
            }else
            {
                avatar = gImagePath+""+avatar;
            }
            image({x: ox, y: oy-150, w: 300, src: "../yourturn/images/confetti1.png"});
            image({x: ox, y: oy+190, w: 300, src: "../yourturn/images/confetti2.png"});
            button({src:gImagePath+"greenbutton_full", idleover:"same", id: "play", string: i18n('_PLAY_ANOTHER_GAME')+ args.name, x: ox + 10, y: oy+10, w:270, h:85, ox: 20, size: 10});
            image({id:"icon", x: ox+ 15, y: oy+15, w: 70, src: avatar});
            button({src:gImagePath+"graybutton_full", idleover:"same", id: "close."+0, string: i18n('_CLOSE'), x: ox + 10, y: oy+120, w:270, h:40, size: 24});

        }
        else{
            $(s.div["frame"]).css("height", "250");
            $(s.div["frame"]).css("top", "130");
            $(s.div["alertFrame"]).css("top", "90");
            label({x: 0, y: oy-40, size: 24, w: 320, string: i18n('_YOU_WON'), center: true });

            image({x: ox, y: oy-150, w: 300, src: "../yourturn/images/confetti1.png"});
            image({x: ox, y: oy+250, w: 300, src: "../yourturn/images/confetti2.png"});
            label({x: ox+10, y: oy+8, w: 270, h: 67, size: 16, string: i18n('_CHALLENGE_YOUR_PARENTS'), center: true, color: "#000000"});
            label({x: ox+10, y: oy+28, w: 270, h: 67, size: 14, string: i18n('_ASK_THEM_TO'), center: true, font: "light font", color: "#000000"});
            button({src:gImagePath+"greenbutton_full", idleover:"same", id: "signup", string: i18n('_ASK_YOUR_PARENT'), x: ox+10, y: oy+50, w:270, h:60, size: 20});
            button({src:gImagePath+"graybutton_full", idleover:"same", id: "close."+1, string: i18n('_MAYBE_NEXT_TIME'), x: ox+10, y: oy+120, w:270, h:40, size:20});
            label({x: ox+10, y: oy+180, w: 270, h: 67, size: 14, string: i18n('_PSST_HEY_PARENTS', {partner: getAppSetting().partnerName}), center: true, font: "light font", color: "#000000"});

        }



    }

    s.on_play = function()
    {
        // TODO: create another with the same opponent
        s.close();
    };

    s.on_close = function(i)
    {
        s.close();
    };

    s.on_signup = function()
    {
        // TODO: open registration_create in Hub layer
        // ToDo: make registration easier for guest, go to registration_create and add email and parent name to guest account

    }
};

FPLaunchScreen(o);



