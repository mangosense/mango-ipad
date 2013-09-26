var screenW = gFullWidth;//320
var screenH = gFullHeight;//480
var bVertical = !FPIsLandscape();
var screenXOffset = (screenW - 320)/2;
var screenYOffset = (FPIsLandscape())?10:0;
// index.js
orientation("vertical");
var appSettings = getAppSetting();
background(appSettings.background, true);

//header bg and logo on center
logo();

button({src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 8, size: 12, id: "back", string: i18n('_BACK')});
end();

var FPLoginListItem = {};
FPLoginListItem.guestFamily = function(d, data, w, s)
{
    $(d).css("margin-left", 10*gScaleX);
    $(d).css("margin-right", 10*gScaleX);
    var row = d;
    $(d).css("height", 70*gScaleY);
    var t_name = {size: 16, x: 75, w:200, h:40, color:appSettings.txtColor};
    var t_button = {src:gImagePath+"greenbutton_half", idleover:"same", w:60, h:30, x: 240, string:s.actionText, size: 14};
    var name = data.name;
    row.buttonParent = d;
    drawAvatar(row, data.avatar, data.role, null, 55, 10, 5, false);
    label(t_name, {parent: row, y:data.addText?13:27, string: name});
    button(t_button, {parent: row, idleover:"same", id: "Name", y:20});
    if (data.addText){
        label({parent: row, size: 12, x:75, w:120, h:35, y: 33, string: data.addText, font:"light font", color:appSettings.txtColor});
    }

    d.on_Name = function()
    {
        s.on_choose(data);
    }
}

o = function(s, args) {
    centerLogo(s);
    var people = FPGetAccountPeople();
    init();
    function init(){
        label({parent:s, x:0, y:75-screenYOffset, w:320+screenXOffset*2, h:25, string: i18n('_WHO_IS_THE'), size:22, id:"question", center:true, color:appSettings.txtColor});
        if (people.length > 1){
            s.actionText = i18n("_ACTION_CHOOSE");
            image({parent:s, src:gImagePath+"dog", x:gFullWidth - 65, y: 50, w:96, h:81});
            var list = FPSmartList.create(s, s, 0+screenXOffset, 140-screenYOffset*4, 320, gFullHeight-100, [FPLoginListItem]);
            $(list).css("background", "transparent");
            var data = [];
            for (var i=0; i<people.length; i++) {
                data.push(cascade({t:"guestFamily", id: people[i].person_id, role: "family"}, people[i]));
            }
            data.push({t:"guestFamily", id:"addplayer", avatar:"addplayer", name:"None of These", role:"addPlayer", addText:i18n("_CREATE_PARENT")});
            FPSmartList.update(list, data);
        }else{
            s.label["question"].text.innerText = FPGetPersonName()+ ",";
            label({parent:s, x:0, y:100-screenYOffset, w:320+screenXOffset*2, h:30, string: i18n('_ARE_YOU_THE'), size:24, center:true, color:appSettings.txtColor});
            drawAvatar(s, people[0].avatar, "family", null, 90, 115+screenXOffset, 150-screenYOffset, false);
            label({parent:s, x:0, y:260-screenYOffset, w:320+screenXOffset*2, h:25, string:people[0].name, size:16, center:true, color:appSettings.txtColor});
            button({parent:s, src:gImagePath+"greenbutton_half", idleover:"same", id: "no", x: 165+screenXOffset, y:280-screenYOffset, w:120, h:40, string: i18n('_NO'), size: 18});
            button({parent:s, src:gImagePath+"graybutton_half", idleover:"same", id: "yes", x: 38+screenXOffset, y:280-screenYOffset, w:120, h:40, string: i18n('_YES'), size: 18});
        }

    }

    s.on_choose = function(data){
        if (data.role === "addPlayer"){
            addParent(false);
        }else{
            FPPersonLogin(data);
            // after enter email go to game directly
            changeToParent(data, false);
        }
    }
    s.on_yes = function(){
        // set bAddMore = true, so that after enter email go to usersetup_children page to add more player
        changeToParent(people[0], true);
    }
    s.on_no = function(){
        addParent(true);
    }
    function addParent(bAddMore){
        runScreenCloser(s, "right");
        var flow = "GuestsAddParent";
        if (bAddMore){
            flow = "GuestAddParent";
        }
        runScreen(gRoot, "pick_avatar", "left", {flow:flow});
    }
    function changeToParent(parent, bAddMore){
        runScreenCloser(s, "right");
        var flow = "GuestsToParent";
        if (bAddMore){
            flow = "GuestToParent";
        }
        runScreen(gRoot, "registration_create", "left", {flow:flow, person:parent});
    }
    s.on_back = function()
    {
        // todo: need go back to hub with the same page it starts the registration
        s.close();
    };
};

FPLaunchScreen(o);





