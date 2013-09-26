//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

var FPChildOverview = {};

FPChildOverview.childOverview = function(d, data, w, s)
{
    var parentDiv = d;
    var person = data.person;
    var buttonIndex = data.buttonIndex;
    var bAvatarButton = data.bAvatarButton;
    var bShowName = data.bShowName;
    var eventName = window["FPNative"]?"touchend":"click";
    var radius = gScaleX;
    var colorArr = getAppSetting().pieColor;
    var gameData = FPGetAccountGamePlay();

    function getPersonGameData(gameData, id)
    {
        var result = [];
        if (gameData.hasOwnProperty(id) )
        {
            result = gameData[id];
        }
        return result;
    }

    var pieData = getPersonGameData(gameData, person.person_id);
    person.gameData = pieData;

    var section = div({parent:parentDiv, x:3, w:314, h:160});
    section.buttonParent = s;
    $(section).css("position", "relative");
    $(section).css("border-bottom", "1px solid #e7e3e2");
    var chartBox = div({parent:section, x:5, y:34, w:111, h:111});
    chartBox.id = buttonIndex;
    var chart = div({parent:chartBox, x:4, y:4, w:100, h:100});
    var chartBg = div({parent:chartBox, x:1, y:1, w:107, h:107});
    $(chartBg).css("border-radius", 100*gScaleX);
    $(chartBg).css("box-shadow", "1px 1px 3px #999999");
    if (!$.isEmptyObject(pieData))
    {
        chart.innerHTML=(donutChart(pieData, 50*radius, 27*radius,colorArr));

        var sum = 0;
        for (var j=0; j< pieData.length; j++) {
            var key = Object.keys(pieData[j])[0];
            sum += pieData[j][key];
        }
        label({parent:chartBox, string: i18n('_SESSIONS_THIS_WEEK'), x:35, y:50, w:40, h:44, size: 8, center:true, font: "light font", color:"#4e4e4e"});
        label({parent:chartBox, string:sum, x:30, y:35, w:50, h:44, size: 12, center:true, color:"#4e4e4e"});
        createTag(section, pieData, colorArr);
    }
    else
    {
        var str = i18n("_NOT_PLAY", {name:person.name});
        label({parent:chartBox, string:str, x:10, y:40, w:70 + 10*2, h:44, size: 10, center:true, color:"#4e4e4e"});

        var data = {empty0:5, empty1:3, empty2:6, empty3:4, empty4:2};
        chart.innerHTML=(donutChart(data, 50*radius, 27*radius,["#d8d8d8", "#bababa", "#d8d8d8", "#d0d0d0", "#d8d8d8"]));
    }

    if (bAvatarButton) {
        var img = drawAvatar(section, person.avatar, "family", "child."+buttonIndex, 32, 5, 15, true);
    }
    if (bShowName){
        var addString;
        var bAdd = false;
        if (person.real_name && (person.real_name !== "undefined")) {
            addString = " ("+person.real_name+")";
        } else {
            addString = "&nbsp;&nbsp; "+i18n("_ADD_A_REAL_NAME");
            bAdd = true;
        }
        var nameStr = label({parent:section, string:person.name + addString, x:45, y:15, w:270, h:44, size: 14, multiColorFunc:getColor});
        function getColor(i, words){
            if (!bAdd){
                var realNames = person.real_name.split(" ");
                realNames[0] = "(" + realNames[0];
                realNames[realNames.length-1] += ")";
                var nameMatch = words[i] === realNames[0];
                for (var j = 1; j<realNames.length; j++){
                    nameMatch = nameMatch || words[i] === realNames[j];
                }
            }
            if (!bAdd && nameMatch ) {
                return "#a6a6a6";
            } else if ( (words[i] === "Add") || words[i] === "Real" || words[i] === "a" || words[i] === "Name" || words[i] === ">"){
                return getAppSetting().linkColor;
            }else{
                return "#4e4e4e";
            }
        }
        if (bAdd){
            bindEvent(nameStr, eventName, "text_addRealName", function(){
                s.onAddRealName(buttonIndex);
            });
        }
    }

    GetPromoteGameNotInstalled(section, addGamePromote);
    function addGamePromote(p, gameList){
        var allGames = gameList;
        if (allGames.length){
            var gameIndex = buttonIndex<allGames.length-1?buttonIndex:allGames.length-1;
            var yPos = 35 + (pieData?pieData.length*25:0);
            var gameDiv = div({parent:p, x:130, y:yPos, w:180});
            $(gameDiv).css("border-radius", 8*gScaleX);
            $(gameDiv).css("background-color", getAppSetting().gameRecomColor);
            button({parent:gameDiv, src:GetGameIcons(allGames[gameIndex].appId).src, idleover:"same", id:"gameIcon", x:5, y:5, w:45, h:45});
            gameDiv.on_gameIcon = function()
            {
                $(s).trigger("updateHubPanel", ["hub_games_main", allGames[gameIndex].appId]);
            }
            var l1 = label({parent:gameDiv, x:55, y:5, w:120, string: i18n('_RECOMMENDED_GAME_FOR') + person.name, color:"#4e4e4e", size:12});
            var l2 = label({parent:gameDiv, x:55, w:120, string: GetGameNameByAppId(allGames[gameIndex].appId), color:"#3a3a3a", size:13});
            $(l1).css("position", "relative");
            $(l2).css("position", "relative");
            $(gameDiv).css("position", "relative");
            var h1 = parseInt($(gameDiv).css("height"))+parseInt($(gameDiv).css("top")) + 10*gScaleY;
            h1 = h1 < 155*gScaleY? 155*gScaleY : h1;
            $(p).css("height", h1);
        }
    }


    if (bAvatarButton) {
        function onClickOnChartBox(){
            runScreen(s, "hub_child_profile","left", {person:person, personIndex:buttonIndex});
        }
        bindEvent(chartBox, eventName, "image_chartBox", onClickOnChartBox);
    }
}
