// index.js
orientation("vertical");

end();

// logic.js
//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

o = function(s, args) {
    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    var person;
    init();
    function init()
    {
        var people = FPGetAccountActivePeople();
        if (args && args.personIndex!==undefined){
            person = people[args.personIndex];
        }
        var d = div({parent:p, x:0, y:0, w:320, h:40});
        addBackgroundImage($(d), "gray-pattern.png");
        label({parent:p, id: "title", string: i18n('_PLAYER_REAL_NAMES'), center: true, x: 80, y: 0, w: 160, h: 40, vCenter:true, size:15, color:"#4e4e4e"});
        button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "back", string: i18n('_BACK')});
        var oy = 10;
        var listBox = div({parent:p, x:0, y:40, w:320, h:gHubHeight-40});
        listBox.id = "realNamesList";
        var list =  div({parent:listBox, x:0, y:0, w:320, h:people.length*70+150});
        oy = tutorialOnRealName(list, oy);

        for (var i = 0; i< people.length; i++)
        {
            if (!FPIsParentByPersonData(people[i])){
                var line = div({parent:list, x: 5, y: oy, w: 310, h: 70, id:"line."+i});
                $(line).css("border-bottom", "1px solid #efefed");
                label({parent:line, x: 20, y: 15, w: 130, h: 30, size: 16, id: "Name."+i, string: people[i].name, color:"#4e4e4e"});
                label({parent:line, x: 20, y: 35, w: 130, h: 30, size: 14, id: "Name."+i, string: people[i].real_name||"", color:"#a6a6a6", font:"light font"});
                button({parent:line, id: "edit."+i, x: 230, y:15, w:60, h:30, string: i18n('_EDIT'), src:gImagePath+"greenbutton_half", idleover:"same", size:14});
                oy += 70;
                line.on_edit = function(i){
                    var parent = s.parent;
                    s.parent = null; // TODO: fix this screen bug workaround
                    runScreenCloser(s, "right");
                    runScreen(parent,"edit_real_name", "left", {personIndex:i});
                };
            }
        }
        new iScroll("realNamesList", {hScroll: true, bounce: false,
            onBeforeScrollStart: function (e) {
                var target = e.target.nodeName.toLowerCase();
                if ( "input" != target && "select" != target) {
                    e.preventDefault();
                }else {
                    return;
                }
            }
        });

        p.on_back = function()
        {
            s.close("left");
        };
    }
};

FPLaunchScreen(o);



