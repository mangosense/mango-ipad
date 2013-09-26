// index.js
orientation("vertical");
end();
var FPChangePlayerItem = {};
FPChangePlayerItem.player = function(d, data, w, s)
{
    $(d).css("margin-left", 10*gScaleX);
    $(d).css("margin-right", 10*gScaleX);
    var row = d;
    $(d).css("height", 85*gScaleY);
    var name = data.name;
    var realName = data.real_name? " ( " + data.real_name + " )": "";
    var oy = realName? -20:0;
    var t_name = {size: 16, x: 110, y:0, w:200, h:85+oy, vCenter:true};
    row.buttonParent = d;
    drawAvatar(row, data.avatar, data.role, null, 50, 25, 12.5, false);
    label(t_name, {parent: row, string: name});
    label(t_name, {parent: row, string: realName, size: 12, y:20, color:"#d3d7d9"});
    var eventName = window["FPNative"]?"touchend":"click";
    bindEvent(row, eventName, "button_choose", onChoose);
    function onChoose()
    {
        s.on_choose(data);
    }
}
FPChangePlayerItem.text = function(d, data, w, s)
{
    $(d).css("margin-left", 10*gScaleX);
    $(d).css("margin-right", 10*gScaleX);
    var row = d;
    $(d).css("height", 40*gScaleY);
    label({parent:d, x:0, y:0, w:320, h:25, string:data.string, size:22, id:data.id, center:true, color:"#d3d7d9"});
}
// logic.js
o = function(s, args) {

    var bInHub = (args&&args.bInHub)?true:false;
    var screenW = bInHub?320:gFullWidth;
    var screenH = bInHub?gHubHeight:gFullHeight;
    var screenXOffset = (screenW - 320)/2;
    var newBg = div({parent:s, x:0, y:0, w:screenW, h:screenH});
    addBackgroundImage($(newBg), "medium-gray-pattern.png");
    var list = FPSmartList.create(s, s, 0+screenXOffset, bInHub?0:75, 320, bInHub?screenH:screenH-75, [FPChangePlayerItem]);
    $(list).css("background", "transparent");
    FPCreateAddPlayerPanel(s, list, screenH, screenXOffset);
    // show current player avatar and name, when not in hub
    if (!bInHub){
        var nameBg = div({parent:s, id: "nameBg", x:0, y:0, w:screenW, h:60});
        $(nameBg).css("z-index", 300);
        addBackgroundImage($(nameBg), "dark-gray-pattern.png");
        $(nameBg).css("border-bottom","1px solid #353535");
        $(nameBg).css("box-shadow", "0px 3px 30px 1px #333333");
        label({parent:nameBg, id:"name", x:65, y:21, w:gFullWidth-65-45, h: 35, string:FPGetPersonName(), size:17});

        if (!(args&&args.noClose)){
            button({parent:nameBg, id:"close", x:270+screenXOffset*2, y:15, w:30, h:30, src:gImagePath+"close-x", idleover:"same"});
            s.on_close = function(){
                s.close();
            };
        }
        nameBg.buttonParent = s;
    }


    s.refresh  = function()
    {
        var people = FPGetAccountActivePeople();
        var data = [];
        data.push({t:"text", id:"who", string: i18n('_WHO_ARE_YOU')});
        for (var i= 0, len = people.length; i<len; i++) {
            var person = people[i];
            data.push(cascade({t:"player", id: person.person_id, role: FPIsParentByPersonData(person)?"parent":"family"}, person));
        }
        data.push({t:"player", id:"addplayer", avatar:"addplayer", name:i18n("_ADD_PLAYER"), role:"addPlayer"});
        FPSmartList.update(list, data);

        if (!bInHub){
            s.label["name"].text.innerText = FPGetPersonName();
            $(s.image["icon"]).remove();
            var role = FPIsParent()?"parent":"family";
            drawAvatar(s.div["nameBg"], FPGetPersonAvatar(), role, "icon", 45, 10, 5, false);
        }

    };

    s.refresh();

    s.on_choose = function (data)
    {
        if (!list.bScrolling){
            function next()
            {
                selectPerson2(data);
            }
            if (data.role === "addPlayer"){
                s.div["addPlayerPanel"].show();
            }else{
                if (FPIsParentByPersonData(data)) {
                    DoParentGate(next);
                } else {
                    next();
                }
            }
        }

    }

    function selectPerson2(data)
    {
        var selectedName = data.name;

        var people = FPGetAccountActivePeople();

        var person = FPGetPerson();

        for (var i=0; i<people.length; i++) {
            if (people[i].name == selectedName) {
                person = people[i];
                break;
            }
        }

        console.log("logging in: " + person.name);
        FPPersonLogin(person);

        if (bInHub){
            FPWebView.eval("hub", "refreshHubPanel()");
        }
        if (!person.avatar || person.avatar === "" || person.avatar === "null"){
            if (bInHub){
                $(nameBg).remove();
                if (FPIsOffline()) {
                    $(s).trigger("updateHubPanel", ["hub_home"]);
                } else {
                    $(s).trigger("updateHubPanel", ["hub_change_avatar"]);
                }
            }else{
                if (gbAndroid)
                {
                    // TODO Maybe find another way for Android to not show these elements on top of the pick_avatar screen?
                    // Not sure how it is working on iOS. Here is how to see this bug, if you comment out these calls
                    // to remove(): On game list screen, select change player, then add a new player and tap player to select avatar.
                    // See that carousel and other elements did not get hidden by pick_avatar screen.

                }

                if (FPIsOffline()) {
                    next();
                } else {
                    runScreen(gRoot, "pick_avatar", "down",  {noBack:true}, next);
                }
            }
        }else{
            next();
        }

        function next(){
            FPWebView.eval("multiplayer", "refreshGames()");
            FPWebView.eval("hub", "refreshHub()", next2);
        }
        function next2(){
            if (bInHub){
                $(s).trigger("updateHubPanel", ["hub_home"]);
            }else if (args && args.flow && args.flow !== "bPartnerNewAcc"){
                // in registration flow
                runScreenCloser(s, "right");
                runScreen(gRoot, "hub_sell", "left");
            }else{
                s.close();
            }
        }
    }



    s.on_addPerson = function (name)
    {
        FPAddNewPerson(name, onAccountPerson);
        function onAccountPerson(){
            FPWebView.eval("hub", "refreshHub()", next);
        }
        function next(){
            s.refresh();
        }
    }

};

//----------------------------------------------------------------------------------------------------------------------
// add player panel

function FPCreateAddPlayerPanel(s, sibling, screenH, screenXOffset)
{
    var eventName = window["FPNative"]?"touchstart":"click";
    var addPlayerPanel;
    var name = "";
    var bShowing = false;
    addPlayerPanel = div({parent:s, id: "addPlayerPanel", x:0+screenXOffset, y: screenH, w:320, h:140});

    label({parent: addPlayerPanel, x: 0, y: 0, w: 320, h: 30, size: 16, color: "#ffffff", center: true, string: i18n('_PULL_THE_LEVER')});

    var nameGenBox = div({parent:addPlayerPanel, id: "addName", x:0, y:20, w:283, h:63});
    image({parent: nameGenBox, src: gImagePath+"name-generator-box", x:40, y:11, w:240, h:40});
    var nameLabel = label({parent:nameGenBox, id:"nameLabel", string:name, x:55, y:22, w:240, h:40, size:16, color:"#4e4e4e"});
    var leverImage =image({parent: nameGenBox, src: gImagePath+"lever1", x:261, y:0, w:20, h:63});
    leverImage.id = "anim";
    $(nameGenBox).bind(eventName, function(){
        changeName();
    });

    function changeName()
    {
        lever.init();
        lever.startAnimation();
        FPRejectAndGenerateName(name, onName);
        function onName(n) {
            name = n;
            nameLabel.text.innerText = name;
        }
    }
    var lever = new SpriteAnim({
        numOfImages: 3,
        backgroundImage: "lever",
        elementId : "anim"
    });
    $("#anim").bind(eventName, function(){
        changeName();
    });
    button({parent: addPlayerPanel, id:"cancel", src: gImagePath+"graybutton_half", idleover:"same", x:39, y:75, w:100, h:40, string: i18n('_CANCEL'), size: 13});
    button({parent: addPlayerPanel, id:"add", src: gImagePath+"greenbutton_half", idleover:"same", x:180, y:75, w:100, h:40, string: i18n('_GO'), size: 13});

    addPlayerPanel.on_cancel = function(){
        hideAddPlayer();
    };

    addPlayerPanel.on_add = function(){
        var newName = name;
        name = ""; // keeping the name
        hideAddPlayer();
        s.on_addPerson(newName);
    };

    function hideAddPlayer()
    {
        if (bShowing) {
            if (name != "") {
                FPRejectName(name);
            }
            bShowing = false;
            var top = parseInt(sibling.style.top);
            var addPlayerH = parseInt(s.div["addPlayerPanel"].style.height);
            $(sibling).animate({"top": top+addPlayerH}, "fast", null);
            $(s.div["addPlayerPanel"]).animate({"top": screenH*gScaleY}, "fast", null);
        }
    }

    function showAddPlayer()
    {
        if (!bShowing) {
            bShowing = true;
            changeName();
            var top = parseInt(sibling.style.top);
            var addPlayerH = parseInt(s.div["addPlayerPanel"].style.height);
            $(sibling).animate({"top": top - addPlayerH}, "fast", null);
            $(s.div["addPlayerPanel"]).animate({"top": (screenH*gScaleY-addPlayerH)}, "fast", null);
        }
    }

    addPlayerPanel.show = showAddPlayer;
    addPlayerPanel.hide = hideAddPlayer;
    return addPlayerPanel;
}

FPLaunchScreen(o);