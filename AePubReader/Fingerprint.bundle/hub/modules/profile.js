//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

// common header for hub_child_profile and hub_friend_profile

function FPCreateProfileScreen(s, backName, person, tabNames, bShowRealName)
{
    var currentTab = 0;
    var appSettings = getAppSetting();
    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    p.buttonParent = s;
    var barImg = gImagePath + ((tabNames.length == 3) ? "profile-orange-bar" : "profile-orange-bar-2");
    var yPos = 110;

    button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 27, w: 80, y: 5, size: 12, id: "back", string: backName});
    button({parent: p, src:gImagePath+"greenbutton_half", idleover:"same", x: 210, h: 27, w: 100, y: 5, size: 12, id: "send", string: i18n('_SEND_NOTE')});
    label({parent: p, x:100, y:37, w:200, h: 35, string:person.name, size:20, color:"#4e4e4e"});
    if (bShowRealName){
        var real_name = person.real_name;
        if (real_name === undefined || real_name === "undefined") {
            real_name = "";
        }
        label({parent: p, x:100, y:60, w:200, h: 35, string:real_name, size:12, color:"#4e4e4e", font:"light font"})
    }
    var role = FPIsParentInCurrAcc(person.person_id)?"parent":"family";
    var yContent = yPos + 3;
    var boxWidth = window["gWebGame"] ? 340 : 320;
    s.contentBoxArea = div({parent: p, x: 0, y: yContent, w: boxWidth, h: gHubHeight - yContent, color: "#ffffff"});

    function positionTab(n)
    {
        var words = tabNames.slice(0,n+1).join("");
        var left = n?80+220*(words.length/totalCount)-220*(tabNames[n].length/totalCount)/2:220*(tabNames[n].length/totalCount)/2+80;
        $("#profileTab").css({left: left*gScaleX, zIndex:10});
    }
    positionTab(0);

    var ox = 90;
    var totalCount = tabNames.join("").length;
    for (var i=0; i<tabNames.length; i++) {

        var w = 220*(tabNames[i].length/totalCount);
        var l;
        if (i===0){
            l = div({parent: p, x:10, y:75, w: 80+w, h: 35});
            label({parent: l, x:80, y:0, w: w, h: 35, string:tabNames[i], size:12, center: true, vCenter:true});

        }else{
            l = label({parent: p, x:i?ox:10, y:75, w: (i?0:80)+w, h: 35, string:tabNames[i], size:12, center: true, vCenter:true});

        }
        $(l).css({outline:"none", overflow:"visible"});
        l.className = "tabBar";


        ox += w;
        l.tabIndex = i;
        l.onmousedown = function()
        {
            positionTab(this.tabIndex);
            if (currentTab != this.tabIndex) {
                currentTab = this.tabIndex;
                // re-create content area - don't just empty it because possible that old tab is loading asynchronously
                $(s.contentBoxArea).remove();
                s.contentBoxArea = div({parent: p, x: 0, y: yContent, w: boxWidth, h: gHubHeight - yContent});
                s.on_tab(this.tabIndex);
            }
        }
    }
    $(".tabBar").css(appSettings.tabBar);
    drawAvatar(p, person.avatar, role, "icon", 60, 12, 35, false);

    var profileTab = div({parent:p, x:220*(tabNames[0].length/totalCount)/2+80, y: 110.5, id: "tab"});
    div({parent:profileTab, x:-9, y: -10.5, id: "tab"});
    profileTab.id = "profileTab";
    $("#profileTab > div").css(appSettings.profileTabDiv);
    $("#profileTab").css(appSettings.profileTab);
}
