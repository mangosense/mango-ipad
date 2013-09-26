// index.js
orientation("vertical");
end();

// logic.js
o = function(s, args) {

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    var people = FPGetAccountActivePeople();
    var list;
    init();
    function init()
    {
        var d = div({parent:p, x:0, y:0, w:320, h:40});
        addBackgroundImage($(d), "gray-pattern.png");
        if (FPIsGuest()){
            $(d).css("height", gHubHeight*gScaleY);
            if (FPIsLandscape()){
                image({parent:p, src: gImagePath+"horizontal_images", x:0, y:30, w:320, h:140});
            }else{
                image({parent:p, src: gImagePath+"register-screenshots", x:0, y:0, w:320, h:165});
            }
            label({parent:p, string: i18n('_REGISTER_TO_UNLOCK'), center:true, x: 20, y:180, w: 280, h: 70, size:14, font: "light font", color:"#4e4e4e"});
            button({parent:p, src:gImagePath+"greenbutton_full", idleover:"same", id: "register", x: 40, y:260, w:240, h:30, string: i18n('_COUNT_ME_IN'), size: 16});
            p.on_register = function()
            {
                if (FPIsOffline()) {
                    runScreen(s, "offline", "left", {what: "create your family account"});
                } else {
                    function next()
                    {
                        FPWebView.eval("login", "FPCreateAccountDialog()", null);
                    }
                    DoParentGate(next);
                }
            }
        }else{
            label({parent:p, x:0, y:10, w:320, h:35, center:true, string: i18n('_YOUR_FAMILY'), size:16, color:"#4e4e4e"});

            if (people.length>1){
                list = FPSmartList.create(p, s, 0, 40, 320, gHubHeight-40, [FPListItem, FPChildOverview]);

                // creating show games section, refresh the page when go new games

                var data = [];
                for (var i = 0; i < people.length; i++)
                {
                    var person = people[i];
                    if (person.person_id!==FPGetPersonId())
                    {
                        if (FPIsParent()) {
                            data.push({t: "childOverview", id: person.person_id, person: person, buttonIndex: i, bAvatarButton: true, bShowName:true});
                        } else {
                            s.actionText = i18n("_VISIT");
                            var o = JSON.parse(JSON.stringify(person));
                            o.t = "friend";
                            o.id = o.person_id;
                            data.push(o);
                        }
                    }
                }

                FPSmartList.update(list, data);
            }else{
                image({parent:p, src: gImagePath+"empty_family", x: 75, y: 60, w: 160});
                var accCounts = FPGetAccountPeople().length;
                if (accCounts < 2){
                    label({parent:p, string: i18n('_DID_YOU_KNOW'), x:40, y:170, w:240, h:40, center:true, size:12, color:"#a6a6a6"});
                }
                button({parent:p, id:"addFamily", src:gImagePath+"greenbutton_full", idleover:"same", string: i18n('_ADD_FAMILY_NOW'), x:80, y:210, w:160, h:40, size:14});

            }
            p.buttonParent = s;
            s.on_child = function(i)
            {
                runScreen(s, "hub_child_profile","left", {person:people[i], personIndex:i});
            }
            s.on_friend = function(person){
                runScreen(s, "hub_child_profile","left", {person:person});
            };
            s.on_addFamily = function(){
                var parent = s.parent;
                s.parent = null;
                runScreenCloser(s, "left");
                runScreen(parent, "usersetup_children", "right", {flow:"AddFamily"});
            }

            s.onAddRealName = function(index){
                if (!list || !list.bScrolling){
                    var parent = s.parent;
                    s.parent = null; // TODO: fix this screen bug workaround
                    runScreenCloser(s, "right");
                    runScreen(parent, "edit_real_name", "left", {personIndex:index, bFamily:true, showTutorial:true});

                }

            }
        }


    }
    // on new msg refresh the page; on new games refresh the page

};

FPLaunchScreen(o);



