// index.js
orientation("vertical");

end();

// logic.js
//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

o = function(s, args) {

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    init();
    function init()
    {
        var d = div({parent:p, x:0, y:0, w:320, h:40});
        addBackgroundImage($(d), "gray-pattern.png");
        label({parent:p, id: "title", string: i18n('_HIDE_PLAYERS'), center: true, x: 80, y: 0, w: 160, h: 40, vCenter:true, size:15, color:"#4e4e4e"});
        button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "back", string: i18n('_BACK')});
        var people = FPGetAccountPeople();

        var oy = 0;
        var listBox = div({parent:p, x:0, y:40, w:320, h:212});
        listBox.id = "renameList";
        var list =  div({parent:listBox, x:0, y:0, w:320, h:people.length*70+2});
        for (var i = 0; i< people.length; i++)
        {
            if (!FPIsParentByPersonData(people[i])){
                var line = div({parent:list, x: 5, y: oy, w: 310, h: 70, id:"line."+i});
                $(line).css("border-bottom", "1px solid #efefed");
                var role = "family";
                var img = drawAvatar(line, people[i].avatar, role, "avatar."+i, 55, 5, 5, false);
                label({parent:line, x: 70, y: 25, w: 130, h: 30, size: 15, id: "Name."+i, string: people[i].name, color:"#4e4e4e"});
                // checkbox
                button(_CheckBoxButton, {parent:line, id: "remove."+i, x: 200, y:20, w:25, h:25});
                label({parent:line, x: 230, y: 25, w: 50, h: 30, size: 15, string: i18n('_HIDE'), font:"light font", color:"#4e4e4e"});
                oy += 70;
                if (people[i].bRemoved){
                    SetToggle(s.button["remove."+i], true);
                    $(s.image["avatar."+i]).css("opacity", "0.2");
                    $(s.label["Name."+i]).css("opacity", "0.2");
                }

                line.on_remove = function(i)
                {
                    var opacity = s.button["remove."+i].bOn?"0.2":"1.0";
                    SetToggle(s.button["remove."+i], s.button["remove."+i].bOn);
                    $(s.image["avatar."+i]).css("opacity", opacity);
                    $(s.label["Name."+i]).css("opacity", opacity);
                }
            }
        }
        new iScroll("renameList", {hScroll: true, bounce: false});

        button({parent:p, src:gImagePath+"greenbutton_full", idleover:"same", id: "save", x: 40, y:270, w:240, h:40, string: i18n('_SAVE'), size: 18});


        p.on_back = function()
        {
            s.close();
        };
        p.on_save = function()
        {
            var count = 0, response = 0;
            var people = FPGetAccountPeople();
            for (var i=0; i<people.length; i++) {
                if (!FPIsParentByPersonData(people[i])){
                    if (s.button["remove."+i].bOn !== people[i].bRemoved) {
                        FPChangeRemoveStatus(people[i], next);
                        count++;
                    }
                }
            }
            if (count === 0){
                s.close();
            }
            function next(){
                response++;
                if (count===response){
                    s.close();
                }
            }
        };
    }
};

FPLaunchScreen(o);



