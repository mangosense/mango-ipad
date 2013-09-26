var FPListItem = {};

FPListItem.spacer = function(d, data, w, s)
{
    $(d).css("height", data.h*gScaleY);
}

FPListItem.sectionHeader = function(d, data, w, s)
{
    w = 300;
    $(d).css("margin-left", 10*gScaleX);
    $(d).css("margin-right", 10*gScaleX);
    $(d).css("height", 29*gScaleY);

    // messages header
    var bg = div({parent: d, x: 0, y: 0, w: w, h:29});
    addBackgroundImage($(bg), data.bg, null, "auto 100%");
    $(bg).css("position", "relative");
    label({parent: bg, size: 14, x: 0, y: 0, w: w, h: 29, center: true, vCenter:true, string: data.string});
}

FPListItem.welcomeMessage = function(line, data, w, s)
{
    var appSettings = getAppSetting();
    $(line).css("margin-left", 10*gScaleX);
    $(line).css("margin-right", 10*gScaleX);
    var l = label({parent:line, x:0, y:0, w:290, h:45, size:16, string: i18n('_WELCOME_TO_FINGERPRINT', {partner: appSettings.partnerName}), color:"#4e4e4e", center:true, vCenter: true, multiColorFunc:getColor});
    $(l).css({position:"relative"});
    var frag = document.createDocumentFragment();
    var t_welcome = {parent:frag, w:205, size:15, font:"light font", color: "#4e4e4e",  vCenter:true, multiColorFunc:getColor };
    var t_text = {padding: 10*gScaleX, backgroundColor:appSettings.welcBubbleColor, borderRadius: 8*gScaleX, overflow:"hidden", minHeight:65*gScaleX};
    var t_box = {overflow:"visible", position:"relative" , margin:5*gScaleX, minHeight:65*gScaleX};

    var _SpeechBubbleTopLeft = {position: "absolute", top: 15*gScaleX, left: 3*gScaleX, width: 50*gScaleX, height: 30*gScaleX, borderRadius: 70*gScaleX, backgroundColor:appSettings.welcBubbleColor};
    var _SpeechBubbleBottomLeft = {position: "absolute", top: 27*gScaleX, left: 0*gScaleX, width: 25*gScaleX, height: 30*gScaleX, borderRadius: 50*gScaleX, backgroundColor:"white"};
    var _SpeechBubbleTopRight = {position: "absolute", top: 15*gScaleX, left: 170*gScaleX, width: 50*gScaleX, height: 30*gScaleX, borderRadius: 70*gScaleX, backgroundColor:appSettings.welcBubbleColor};
    var _SpeechBubbleBottomRight = {position: "absolute", top: 25*gScaleX, left: 198*gScaleX, width: 25*gScaleX, height: 30*gScaleX, borderRadius: 50*gScaleX, backgroundColor:"white"};

    var game_welcome = div({parent:frag, w:230, x:10, color:"white"});
    $(game_welcome).css(t_box);
    var l1 = div({parent:game_welcome});
    var l2 = div({parent:game_welcome});
    var l3 = label(t_welcome, {parent:game_welcome, string:i18n('_CHECK_OUT_ALL')});
    $(l1).css(_SpeechBubbleTopRight);
    $(l2).css(_SpeechBubbleBottomRight);
    $(l3).css({position: "absolute"});
    $(l3.text).css(t_text);
    $(game_welcome).css({height: i18n('_CHECK_OUT_ALL').length*1.5*gScaleX});

    var avatar_welcome = div({parent:frag, w:230,x:60, color:"white"});
    $(avatar_welcome).css(t_box);
    l1 = div({parent:avatar_welcome});
    l2 = div({parent:avatar_welcome});
    l3 = label(t_welcome, {parent:avatar_welcome, string:i18n('_CHANGE_THE_WAY')});
    $(l1).css(_SpeechBubbleTopLeft);
    $(l2).css(_SpeechBubbleBottomLeft);
    $(l3).css({marginLeft:17*gScaleX, height:"100%", clear: "both", position: "absolute"});
    $(l3.text).css(t_text);
    $(avatar_welcome).css({height: i18n('_CHANGE_THE_WAY').length*1.5*gScaleX});

    var invite_welcome = div({parent:frag, w:230,x:10, color:"white"});
    $(invite_welcome).css(t_box);
    l1 = div({parent:invite_welcome});
    l2 = div({parent:invite_welcome});
    l3 = label(t_welcome, {parent:invite_welcome, string:i18n('_INVITE_FRIENDS_FOR')});
    $(l1).css(_SpeechBubbleTopRight);
    $(l2).css(_SpeechBubbleBottomRight);
    $(l3).css({position: "absolute"});
    $(l3.text).css(t_text);
    $(invite_welcome).css({height: i18n('_INVITE_FRIENDS_FOR').length*1.5*gScaleX});

    image({parent:game_welcome, x:230, y:0, w:46, src:gImagePath+"welcome3"});
    image({parent:avatar_welcome, x:-55, y:0, w:58, src:gImagePath+"welcome2"});
    image({parent:invite_welcome, x:230, y:0, w:43, src:gImagePath+"welcome1"});


    line.appendChild(frag);

    $(line).css("height","auto");

    $(game_welcome).bind("click", function(){
        $(s).trigger("updateHubPanel", ["hub_games_main"]);
    });
    $(avatar_welcome).bind("click", function(){
        $(s).trigger("updateHubPanel", ["hub_change_avatar"]);
    });
    $(invite_welcome).bind("click", function(){
        $(s).trigger("updateHubPanel", ["hub_friends"]);
    });
    function getColor(i, words)
    {
        if (words[i] === i18n("_GAMES_LOWERCASE") || (words[i] === i18n("_AVATAR")) || words[i] === i18n("_INVITE") || words[i] === i18n("_FRIENDS_LOWERCASE") ) {
            words.style = "font-family: " + fixFontFamily('bold font');
            return getAppSetting().welMsgColor;
        }else{
            return;
        }
    }
}
var gActionToDisplay = {
    "friends": i18n("_MAKE_FRIENDS"),
    "message": i18n("_SEND"),
    "coinocopia":i18n("_COINS"),
    "gogames":i18n("_SEE_IT"),
    "gogame":i18n("_MAKE_FRIENDS"),
    "launchgame":i18n("_PLAY")
};

FPListItem.progressReport = function(d, data, w, s)
{
    w = 320;
    $(d).css("margin-left", 10*gScaleX);
    $(d).css("margin-right", 10*gScaleX);
    var o = data;
    var line = div({parent:d, x: 0, w: w});
    $(line).css("position", "relative");
    line.buttonParent = s;
    var link = parseLinkInfo(o.description);
    var imageOnLeft = o.image, textWidth = 240;
    var bButton = (link&&link.length>0) || (o.action&&o.action.length>0);
    if (bButton){
        // make space for button
        textWidth = 190;
    }
    if (o.image == "avatar"){
        imageOnLeft = generateAvatarImagePath(o.avatar).replace(".png","");
        drawAvatar(line, imageOnLeft, "family", null, 41, 3, 10, false);
    }else{
        if (o.image == "gameIcon") {
            imageOnLeft = GetGameIcons(o.game_id).src;
        }
        image({parent:line, x:3, y:10, w:45, h:45, src:gImagePath +imageOnLeft});
    }
    var l = label({parent:line, x:55, y:8, w:textWidth, size: 12, string: o.description, color:"#4e4e4e", font: "light font"});
    var innerHTML = "";
    if (o.caption) {
        innerHTML += "<span STYLE=\"font-family:'"+fixFontFamily("bold font")+"'\" >" + o.caption + "</span>" + "<br/>";
    }
    innerHTML += o.description;
    l.text.innerHTML = innerHTML;
    $(l).css("position", "relative");
    if (bButton) {
        var actionId = o.action.replace(/-/gi,"");
        var action = gActionToDisplay[actionId];
        if (link){
            // This link is related to ScribbleMyStory and goes to an URL where the story can be viewed.
            action = "See it";
            actionId = "golink";
        }
        button({parent:line, src: gImagePath+"greenbutton_half", idleover:"same", x: 300-55, y:20, id:actionId, string: action, w:55, h:30, size:12});
    }
    $(l).css("min-height", 70*gScaleX);
    var separator = div({parent: line, w: 300, h: 8});
    $(separator).css({position: "relative", borderBottom:1*gScaleX+"px solid #e7e3e2"});

    function parseLinkInfo(str){
        var linkIndex = str.indexOf("[http");
        if (linkIndex != -1) {
            try {
                var pre = str.substring(0, linkIndex);
                var post = str.substring(linkIndex);
                linkIndex = post.indexOf("]");
                link = post.substring(1,linkIndex);
                post = post.substring(linkIndex+1);
                return pre + post;
            } catch (e) {
                return "";
            }
        }
        return "";
    }
    //div({parent: line, x: 0, w: 300, y: lineHeight-1, h: 1, color: "#c2bebe"});
    line.on_coinocopia = function(){
        // opens the Coins tab on the hub
        $(s).trigger("updateHubPanel", ["hub_coins"]);
    };
    line.on_gogames = function(){
        // goes to the “Games” tab on the hub
        $(s).trigger("updateHubPanel", ["hub_games_main"]);
    };
    line.on_gogame = function(){
        // goes to the “Games” tab on the hub, highlight the game
        $(s).trigger("updateHubPanel", ["hub_games_main", data.game_id]);
    };
    line.on_golink = function(){
        FPHelper.openURL(data.link);
    };
    line.on_launchgame = function(){
        // Launch the Game or go to store to download the app
        FPHelper.launchGame(data.game_id.toString(), null);
    };
    line.on_friends = function(){
        // Opens a list of “friends you may know”
        runScreen(s, "hub_friends_mayknow", "down");
    };
    line.on_message = function(){
        // opens the send message interface,
        runScreen(s, "hub_friends", "down", {bPickRecipient:true});
    };
}

FPListItem.message = function(d, data, w, s)
{
    var o = data;
    if (!o.text) {
        o.text = "";
    }

    var line = div({parent:d, x: 10, w: 300});
    line.buttonParent = s;
    $(line).css("position", "relative");
    var bNoButton = (o.from === FPGetPersonId()); // can't reply to yourself
    var t_text = {}, t_icon = {}, textOx = 55, textWidth = 235;
    if (bNoButton){
        textWidth = 180;
    }
    // display on the right side when message is send out by the user
    if (bNoButton){
        drawAvatar(line, o.avatar, "family", null, 41, 250, 10, false);
        if (o.icon){
            textWidth = 155; // make space for icon
            textOx = 88;
            t_text = {x:textOx-35, y:18, w:textWidth, rightJustify: true};
            t_icon = {x:212, y:15, w:34, h:34};
        }else{
            t_text = {x:textOx-15, y:8, w:textWidth, rightJustify: true};
        }
    }else{
        drawAvatar(line, o.avatar, "family", null, 41, 3, 10, false);
        if (o.icon){
            textWidth = 155; // make space for icon
            textOx = 88;
            t_text = {x:textOx, y:18, w:textWidth};
            t_icon = {x:52, y:15, w:34, h:34};
        }else{
            t_text = {x:textOx, y:8, w:textWidth};
        }
    }
    if (o.icon){
        image(t_icon, {parent:line, src:gImagePath+"emotion"+o.icon});
    }
    var l = label(t_text, {parent:line, size: 12, string:o.text, color:"#4e4e4e", font: "light font"});
    l.text.innerHTML = "<span STYLE=\"font-family:'"+fixFontFamily("bold font")+"'\" >" + o.text + "</span>" + "<br/>" + (o.name?i18n("_FROM")+ o.name:"");
    $(l).css("position", "relative");
    $(l).css("min-height", 70*gScaleY);
    var separator = div({parent: line, w: 300, h: 1, color: "#e7e3e2"});
    $(separator).css("position", "relative");
    if (!bNoButton)
    {
        button({parent:line, src: gImagePath+"greenbutton_half", idleover:"same", x: 300-55, y:20, id: "action", metricName: "reply", string: i18n('_REPLY'), w:55, h:30, size:12});
    }
    line.on_action = function(){
        function next()
        {
            function delayedRemove()
            {
                FPSetMessageStatus(data.message_id, "read");
                if (data.removeFunc) {
                    function next()
                    {
                        data.removeFunc(data.message_id);
                    }
                    setTimeout(next, 500);
                }
            }
            runScreen(s, "hub_create_message", "left", {id:o.from, removeFunc:delayedRemove}, null);
        }
        DoParentGate(next);
    }
}

FPListItem.friend = function(d, data, w, s)
{

    w-=20;
    $(d).css("margin-left", 10*gScaleX);
    $(d).css("margin-right", 10*gScaleX);
    var row = d;
    $(d).css("height", 70*gScaleY);

    var t_name = {size: 18, color:"#4a4a4a", x: 75, w:200, h:40};
    var t_button = {src:gImagePath+"greenbutton_half", idleover:"same", w:60, h:30, x: 240, string:s.actionText, size: 14};

    var name = data.name;

    var div1 = div({parent: row, x: 0, y: 69, w: 300, h: 1, color: "#e7e3e2"});
    $(div1).addClass("friendDiv");
    row.buttonParent = d;
    var bParent = FPIsParentByPersonData(data)?FPIsParentInCurrAcc(data.person_id):false;
    var img = drawAvatar(row, data.avatar, bParent?"parent":"friend", null, 50, 10, 5, false);
    label(t_name, {parent: row, y:27, string: name});
    button(t_button, {parent: row, idleover:"same", id: "Name", y:20});

    d.on_Name = function(index)
    {
        s.on_friend(data);
    }
}

FPListItem.game = function(d, data, w, s)
{
    var t_name = {size: 12, color:"#4a4a4a", x: 75, w:170, h:40};
    var t_button = {src:gImagePath+"greenbutton_half", idleover:"same", h:30, size: 14};

    // get game icon and name by id
    // there must have and only have one object in assets in production
    var assets = GetGameInfoByAppId(data.game_id);
    if (assets) {
        var h = 75;
        var row = div({parent: d, w: w, h: h});
        div({parent: row, x: 10, y: h-1, w: 300, h: 1, color: "#e7e3e2"});
        row.buttonParent = d;

        image({parent: row, id:"icon", src: GetGameIcons(data.game_id).src, x:10, y:10, w:55, h: 55});

 // TODO: fix layout
 //       if (data.recommendation) {
 //           label(t_name, {bold: true, parent: row, y:10, string: assets.name});
 //           label(t_name, {parent: row, y:26, string: data.recommendation});
 //       } else {
 //           label(t_name, {parent: row, y:28,  string: assets.name});
 //       }
        var l = label(t_name, {parent: row, y:0, h: 75, vCenter: true, string: assets.name});

        if (window["FPNative"] && data.bInstalled)
        {
            button(t_button, {parent: row, idleover:"same", id: "play", y:20, string: i18n('_PLAY'), w:60, x: 250});

        }else
        {
            // see if "Get It" is possible
            var bCanGetIt = false;

            var stage = GetGameStage(assets);
            if (stage === "new" || stage === "live") {
                if (gbAndroid) {
                    if (assets.androidPackage) {
                        bCanGetIt = true;
                    }
                } else {
                    if (assets.link || assets.appStoreId) {
                        bCanGetIt = true;
                    }
                }
            }

            if (bCanGetIt) {
                // todo: tmp fontSize for tamil
                var size = FPGetAppValue("language")=== "ta"?10:14;
                button(t_button, {parent: row, idleover:"same", id: "get", y:20, string: i18n('_GET_IT'), w:60, x: 250, size: size});

            } else {
                // no "Get It" button, so make the text label wider
                $(l).css("width", 200*gScaleX);
            }
        }
    }

    d.on_play = function(i)
    {
        FPHelper.launchGame( data.game_id, {person_id:FPGetPersonId()} );
    }

    d.on_get = function(i)
    {
        FPOpenAppStore(GetGameInfoByAppId(data.game_id, false));
    }
}

FPListItem.friendMayKnow = function(d, data, w, s)
{
    var margin = 10;
    $(d).css("margin-left", margin*gScaleX);
    $(d).css("margin-right", margin*gScaleX);
    w-=margin*2;

    $(d).css("height", 69*gScaleY);

    var rowBg = d;

    var colorBg = div({parent: rowBg, w: w, h: 69, x: 0, y: 0, color: getAppSetting().friendMayKnowBg});
    div({parent: rowBg, w: w, h: 1, x: 0, y: 68, color: "#e7e3e2"});

    var t_name = cascade({size: 14, color:"#4a4a4a", x: 65, w:150, h:40});
    var t_button = cascade({idleover:"same", w:90, h:30, x: 205, string: i18n('_MAKE_FRIENDS'), size: 12});

    var name = data.name;

    var img = drawAvatar(rowBg, data.avatar, "friend", "icon", 50, 5, 6, false);
    label(t_name, {parent: rowBg, y:15, string: name});


    var friendName = i18n('_FRIENDS_WITH', {name:data.friendName });

    label(t_name, {parent: rowBg, y:35, string: friendName, font:"light font", w: 135, size: 12, h:50});

    var makeFriendButton = button(t_button, {parent: rowBg, src:gImagePath+"bluebutton_half.png", id: "MakeFriend", metricName: "inviteSuggestedFriend", y:20});
    var invitedButton = button(t_button, {parent: rowBg, src:gImagePath+"lightgraybutton_half.png", id: "Friend", string: i18n('_INVITED'),y:20, color:"#a6a6a6", ox:10});
    SetEnabled(invitedButton, false);
    $(invitedButton).hide();

    rowBg.on_MakeFriend = function(index)
    {
        data.removeFunc(data.person_id, true);
        $(makeFriendButton).hide();
        $(invitedButton).show();
        image({parent: invitedButton, src:gImagePath+"checkmark", x: 28, y:11, w: 12});
        FPSendMessage(data.person_id, "", {name:FPGetPersonName(), type:"makeFriend", avatar:FPGetPersonAvatar(), text:FPGetPersonName() + " wants to be your friend."});
    }
}
FPListItem.messageCount = function(d, data, w, s){
    $(d).css("margin-left", 10*gScaleX);
    $(d).css("margin-right", 10*gScaleX);
    var row = d;
    $(d).css("height", 70*gScaleY);
    image({parent:row, y:5, src:gImagePath+"notes_shortcut", w:60, h:60});
    label({parent:row, y:5, string: data.text, size: 14, color:"#4a4a4a", vCenter:true, x: 65, w:170, h:60});

    var t_button = {src:gImagePath+"greenbutton_half", idleover:"same", h:30, size: 14};

    button(t_button, {parent: row, idleover:"same", id: "wall", y:20, string: i18n('_WALL'), w:60, x: 240});
    row.on_wall = function()
    {
        $(s).trigger("updateHubPanel", ["hub_messages"]);
    }
}
FPListItem.friendInvites = function(d, data, w, s){
    $(d).css("margin-left", 10*gScaleX);
    $(d).css("margin-right", 10*gScaleX);
    $(d).css("height", 90*gScaleY);
    var row = div({parent:d, x:0, y:0, w:320-data.margin*2, h:90});
    $(row).addClass("friendInvitesDiv");
    div({parent: row, x: 0, y: 0, w: 300, h: 90, color: getAppSetting().invitationBg});
    drawAvatar(row, data.avatar, "friend", "icon", 50, 5, 10, false);
    label({parent:row, y:15, string: data.text, size: 14, color:"#4a4a4a", x: 75, w:200, h:40});
    button({parent:row, src: gImagePath+"greenbutton_half", idleover:"same", x: 75, y:55, id: "yes", metricName: "acceptFriend", string: i18n('_YES'), w:55, h:27, size:12});
    button({parent:row, src: gImagePath+"graybutton_half", idleover:"same", x: 140, y:55, id: "no", metricName: "rejectFriend", string: i18n('_NO'), w:55, h:27, size:12});
    div({parent: row, w: w, h: 1, x: 0, y: 89, color: "#e7e3e2"});
    row.on_yes = function(){
        // link to account
        FPLinkAccount(data.from);
        FPSetMessageStatus(data.message_id, "read");
        data.removeFunc(data.id);
    }
    row.on_no = function(){
        FPSetMessageStatus(data.message_id, "read");
        data.removeFunc(data.id);
    }
}
FPListItem.invitationSummary = function(d, data, w, s){
    $(d).css("margin-left", 10*gScaleX);
    $(d).css("margin-right", 10*gScaleX);
    var row = d;
    $(d).css("height", 30*gScaleY);
    $(d).css("width", 300*gScaleY);
    $(d).css("backgroundColor", getAppSetting().invitationBg);
    var l = label({parent:row, y:0, string: data.text, size: 14, color:"#4a4a4a", x: 10, w:290, h:30, vCenter:true});
    //$(l).css("backgroundColor", "#fcf3c5");
    div({parent: row, w: w, h: 1, x: 0, y: 29, color: "#e7e3e2"});
}