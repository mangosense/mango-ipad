// index.js
orientation("vertical");
//header bg
div({id:"headerBg", x:0, y:0, w:gFullWidth, h:45});
end();


o = function(s, args) {
    var screenXOffset = (gFullWidth - 320)/2;
    if (args&&args["noCenter"]){
        screenXOffset = 0;
    }
    label({parent:s, id:"title", string: i18n('_NICKNAME'), x:0, y:11, w:(args&&args["noCenter"])?320:gFullWidth, h:30, size:20, center:true, color:"#4e4e4e"});
    button({parent:s, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 8, size: 12, id: "back", string: i18n('_DONE')});

    var username = field({parent: s, id: "username", x: 20+screenXOffset, y:70, w:280, h:35, placeholder: "", setTransparent: true, size: 18, field: "gray-box.png"});

    username.id = "username";

    var lastQuery = "";
    var listBox, list, listHeight, iscroll;
    var names;

    function clearList()
    {
        $("#nameListBox").empty();
    }

    function onChange()
    {
        var v = username.value;
        if (v.length && v != lastQuery) {
            function makeLine(text, i)
            {
                var line = div({parent: list, w: 280, h: 40});
                line.buttonParent = s;
                $(line).css("position", "relative");
                label({parent: line, h: 40, vCenter: true, string: text, size: 18, color: "#000000"});
                if (i != -1) {
                    var b = button({parent: line, id:"friend." + i, src:gImagePath+"lightgraybutton_half.png", idleover:"same", x:190, y:5, w:90, h:30, string: i18n('_INVITED'), size: 13});
                    button({parent: line, id:"invite." + i, src: gImagePath+"greenbutton_half", idleover:"same", x:190, y:5, w:90, h:30, string: i18n('_ADD_FRIEND'), size: 13});
                    SetEnabled(b, false);
                }
            }
            function onNames(r)
            {
                clearList();
                names = FPNamesExceptFamilyFriends(r.names);
                var count = names?names.length:0;

                var h = count*40;
                h = h > 0? h: 40;
                var frag = document.createDocumentFragment();
                list = div({parent: frag, x: 0, y: 0, w: 280, h: h});
                if (count == 0) {
                    makeLine("- no matches found -", -1);
                    iscroll.scrollTo(0, 0);
                } else {
                    var i = count;
                    while (i--) {
                        makeLine(names[i], i);
                    }
                }
                listBox.appendChild(frag);
                listBox.style.backgroundColor = "white";

                iscroll =new iScroll("nameListBox");
            }
            FPWebRequest("FindName", {partialName: v}, onNames);
        } else if (lastQuery.length != 0) {
            clearList();
        }
        lastQuery = v;
    }

    username.addEventListener('input', onChange, false);

    $(s).css("background-color", "white");
    addBackgroundImage($(s.div["headerBg"]), "gray-pattern.png");
    var d = div({parent: s, x: 65+screenXOffset, y: 140, w:150});
    label({parent: d, x: 0, y: 0, w: 150, size: 12, center: true, string: i18n('_TYPE_YOUR_FRIEND'), color:"#4e4e4e"});
    label({parent: d, x: 0, w: 150, size: 12, center: true, string: i18n('_THIS_IS_THE', {partner: getAppSetting().partnerName}), color:"#a6a6a6", font:"light font"});
    setPositionRelative(d);
    image({parent:s, src:gImagePath+"talking-kid", x: 230+screenXOffset, y:130, w:60, h:95});
    image({parent:s, src:gImagePath+"arrow", x: 38+screenXOffset, y:140, w:25, h:20});
    listHeight = (typeof gHubHeight!== "undefined")?gHubHeight:gFullHeight;
    listHeight -= 126;
    listBox = div({parent: s, x: 20, y: 124, w: 280, h: listHeight});
    listBox.id = "nameListBox";


    s.on_back = function()
    {
        s.close();
    }

    s.on_invite = function(i)
    {
        $(s.button["invite."+i]).hide();
        var sendto = names[i];
        var name = FPGetPersonName();
        var text = name + i18n("_WANT_TO_INVITE")+GetGameNameByAppId(FPGetGameId())+"."; // invite from the game
        if (args&&args["noCenter"]){
            // invite from the platform
            text = name + i18n("_WANT_TO_BE");
        }
        FPSendMessage(sendto, "", {name:name, type:"makeFriend", avatar:FPGetPersonAvatar(), text:text, toName:true});
    }
};

FPLaunchScreen(o);



FPNamesExceptFamilyFriends = function(names){
    if (!names) return;
    var family = FPGetAccountPeople();
    var friends = FPGetAccountValue("friends");
    var n = family.length;
    var nameDic = {};
    var results = [];
    while(n--){
        var name = family[n].name;
        nameDic[name] = true;
    }
    n = friends.length;
    while(n--){
        var name = friends[n].name;
        nameDic[name] = true;
    }
    n = names.length;
    while(n--){
        var name = names[n];
        if (!nameDic[name]){
            results.push(name);
        }
    }
    return results;
}

