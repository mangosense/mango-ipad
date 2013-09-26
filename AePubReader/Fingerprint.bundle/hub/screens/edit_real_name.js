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
        label({parent:p, id: "title", string: i18n('_EDIT_REAL_NAME'), center: true, x: 0, y: 10, w: 320, h: 55, size:15, color:"#4e4e4e"});
        button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "back", string: i18n('_BACK')});
        var oy = 10;
        var listBox = div({parent:p, x:0, y:40, w:320, h:gHubHeight});
        listBox.id = "realNameList";
        $(listBox).css("overflow-y", "scroll");
        var list =  div({parent:listBox, x:0, y:0, w:320, h:480});
        if (args&&args.showTutorial)
        {
            oy = tutorialOnRealName(list, oy);
        }else{
            oy += 15;
        }
        label({parent:list, x: 40, y: oy, w:280, h:30, size: 14, string: i18n('_EDIT_REAL_NAME_FOR') + person.name, color:"#4e4e4e"});
        oy += 30;
        field({parent:list, x: 44, y: oy, w: 232, h: 35, size: 15, id: "Name", placeholder: person.real_name||"",
            field: "gray-box.png", setTransparent: true, capitalize: true});
        oy += 40;
        new iScroll("realNameList", {hScroll: true, bounce: false,
            onBeforeScrollStart: function (e) {
                var target = e.target.nodeName.toLowerCase();
                if ( "input" != target && "select" != target) {
                    e.preventDefault();
                }else {
                    return;
                }
            }
        });

        button({parent:list, src:gImagePath+"greenbutton_full", idleover:"same", id: "save", x: 40, y:oy+20, w:240, h:40, string: i18n('_SAVE'), size: 18});


        list.on_save = function()
        {
            var sKidName = GetField(s.field["Name"]);
            // Just allow alphanumeric
            sKidName = sKidName.replace(/[^a-z0-9]/gi,'');
            if (sKidName && sKidName.length > 12){
                DoAlert(i18n("_REAL_NAME"), i18n("_PLEASE_ENTER_NAME"));
            } else if (sKidName !== person.real_name && sKidName !== undefined) {
                FPChangeRealName(person, sKidName, next);
            }
            function next(r)
            {
                s.field["Name"].blur();
                back();
            }
        };
        p.on_back = function()
        {
           back();
        };

        function back(){
            var parent = s.parent;
            s.parent = null; // TODO: fix this screen bug workaround
            runScreenCloser(s, "left");
            if (args&&args.bFamily){
                runScreen(parent,"hub_parent_home", "right");
            }else{
                runScreen(parent,"player_real_names", "right");
            }
        }
    }
};

FPLaunchScreen(o);



