// index.js
orientation("vertical");

end();

// logic.js
//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

o = function(s, args) {

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    // div show the new generated message
    var emotionBox;
    var emotionSection;
    var textSection;
    var msgSection;
    var newMsgSection;
    var iconSelected;
    var iconId;
    var textSelected;
    var text;
    var textList;
    var recordIcon;
    var that;
    var bScroll = gHubHeight<388;
    var screenYOffset = (bScroll)?70:0;

    init();
    function init()
    {
        button({parent: p, src:gImagePath+"graybutton_half", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "cancel", string: i18n('_CANCEL')});
        label({parent: p, x: 100, h: 30, w: 120, y: 5, center: true, vCenter:true, size: 14, string: i18n('_CREATE_A_NOTE'), color:"#4a4a4a"});
        button({parent: p, src:gImagePath+"graybutton_half", idleover:"same", x: 5, h: 40, w: 150, y: 340-screenYOffset, size: 20, id: "clear", string: i18n('_CLEAR')});
        button({parent: p, src:gImagePath+"greenbutton_half", idleover:"same", x: 165, h: 40, w: 150, y: 340-screenYOffset, size: 20, id: "send", string: i18n('_SEND')});

        if (bScroll)
        {
            image({parent: p, x: 3, y: 40, w: 142, h:(bScroll)?170:230, src:gImagePath+"gray-box"});
        }
        emotionBox = div({parent: p, x: 0, y: 40, w: 150, h:(bScroll)?170:230});
        emotionBox.id = "emotionBox"+GUID();
        emotionSection = div({parent: emotionBox, x: 0, y: 0, w: 150, h:250});


        image({parent: p, x: 155, y: 40, w: 160, h:(bScroll)?170:230, src:gImagePath+"gray-box"});
        textSection = div({parent: p, x: 155, y: 40, w: 160, h:(bScroll)?170:230});
        textSection.id = "textList"+GUID();
        var textArray = getDefaultText();
        var numText = textArray.length;
        textList = div({parent: textSection, x: 0, y: 0, w: 160, h:numText*40});

        msgSection = div({parent: p, x: 5, y: 285-screenYOffset, w: 310, h:50});
        // create new message section
        if (!bScroll)
        {
            image({parent: msgSection, x: 0, y: 0, w: 310, h:50, src:gImagePath+"textbox"});

        }
        newMsgSection = div({parent: msgSection, x: 0, y: 0, w: 310, h:50});

        // create emotion section
        var numEmotion = 15;
        var ox = 3;
        var oy = 3;
        for (var i = 0; i < numEmotion; i++)
        {
            if (ox > 100)
            {
                ox = 3;
                oy += 47;
            }
            button({parent: emotionSection, x:ox, y:oy, w:44, h:44, src:gImagePath+"emotion"+i, idleover:"same", id: "emotion."+i});
            ox += 47;

        }
        new iScroll(emotionBox.id, {vScroll:true, bounce: false});

        if (bScroll)
        {
            div({parent: p, x: 0, y: 40, w: 3, h:gHubHeight-150, color:"#ffffff"});
        }
        emotionSection.on_emotion = function(i)
        {
            if (iconSelected)
            {
                $(iconSelected).remove();
            }

            iconSelected = image({parent: newMsgSection, x: 3, y: 3, w: 44, h:44, src:gImagePath+"emotion"+i});
            if (iconId)
            {
                SetGlow(s.button["emotion."+iconId], null);
            }
            iconId = i;
            SetGlow(s.button["emotion."+iconId], "#6ead41", "#ffffff", 20);
        }

        // create text section

        oy = 0;
        for (var i = 0; i < numText; i++)
        {
            var line = div({parent:textList, x:0, y:oy, w:160, h:40});
            $(line).css("border-top", "1px solid #c2bebe");
            var l = label({parent: line, x:5, y:0, w:155, h:40, vCenter:true, string:textArray[i], size: 16, font: "light font", color:"#4a4a4a", id:"text."+i});
            oy += 40;

            s.label["text."+i].onmousedown = function()
            {
                if (textSelected)
                {
                    $(textSelected).remove();
                }
                if (that)
                {
                    $(that).parent().css("background-color", "transparent");
                }
                that = this;
                text = that.text.innerHTML;
                textSelected = label({parent: newMsgSection, x: 50, y: 13, w: 160, h:40, string:text, size: 16, color:"#4a4a4a"});

                $(that).parent().css("background-color", "#a8cce6");

            }


        }


        new iScroll(textSection.id, {vScroll:true, bounce: false});




    }


    p.on_cancel = function()
    {
        s.close();
    }

    p.on_clear = function()
    {
        if (that)
        {
            $(that).parent().css("background-color", "transparent");
        }
        if (iconId)
        {
            SetGlow(s.button["emotion."+iconId], null);
        }
        $(newMsgSection).empty();
    }
    p.on_send = function()
    {
        function next()
        {
            $(s).trigger("showAnimateMessage", ["Your message has been sent", function(){
                if (args&&args.removeFunc){
                    args.removeFunc();
                }
                s.close();
            }]);
        }
        FPSendMessage(args.id, "", {name:FPGetPersonName(), type:"reply", avatar:FPGetPersonAvatar(), icon:iconId, text:text});
        next();
    }

};

FPLaunchScreen(o);



