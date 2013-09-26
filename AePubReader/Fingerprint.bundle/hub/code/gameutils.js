//
//  Copyright 2011-2012 Fingerprint Digital, Inc. All rights reserved.
//

var gInstalledGames = {};

function GetGameLogo(appId)
{
	var s = "../../catalog/logo/" + appId + ".png";
	return s;
}

function GetGameIcons(appId)
{
	return {src: "../../catalog/button/" + appId + "_over.png", idleover: "same"};
}

function GetInstalledGames(callback)
{
    if (!(gInstalledGames&&gInstalledGames.length>0)){
        var games = GetGameList();
        function onResult(r)
        {
            gInstalledGames = r;
            callback();
        }
        FPHelper.areGamesInstalled(games, onResult);
    }else{
        callback();
    }

}

function GetNewGames()
{
	var allGames = GetAllGamesData();

	var newGames = [];
	for (var i = 0, len = allGames.length; i < len; i++) {

        // TODO: clean up gbIPad
		if (!gInstalledGames[allGames[i].appId]
				&& !(GetGameStage(allGames[i]) == "nopromote")
				&& !(allGames[i].appId == "drmlite" && gInstalledGames["drm"])
				&& !(allGames[i].device == "ipad" && !window["gbIPad"])
				&& !(allGames[i].device == "iphone" && window["gbIPad"])) {
			newGames.push(allGames[i]);
		}
	}

	function compare(a,b)
	{
		var a_val = (GetGameStage(a) == "new") ? 1 : ((GetGameStage(a) == "live") ? 2 : 3);
		var b_val = (GetGameStage(b) == "new") ? 1 : ((GetGameStage(b) == "live") ? 2 : 3);
		return (a_val < b_val) ? -1 : ((a_val > b_val) ? 1 : 0);
	}
	newGames.sort(compare);

	return newGames;
}

// logo is optional
// firstTimePlay is optional
// dir is only needed if the dir name is not the same as the appId (will be moving forward)

function GetAllGamesData()
{
	var allGames = [];
	var count = gGameInfo.length;
	for (var i=0; i<count; i++) {
		var o = CopyObject(gGameInfo[i]);
		o.id = o.appId;
		allGames.push(o);
	}
	return allGames;
}

function GetAllGamesDataJSON()
{
    return JSON.stringify(GetAllGamesData());
}

function GetGameInfoJSONByAppId(appId)
{
    return JSON.stringify(GetGameInfoByAppId(appId));
}

function GetMayLikeData()
{
    var result = null;

    try {
        var slotLookup = {};
        var order = null;

        var sdktest = GetGameInfoByAppId("sdktest");
        var maylike = sdktest.maylike;
        var slots = maylike.slots.all;
        var len = slots.length;
        for (var i=0; i<len; i++) {
            var gameObject = slots[i];
            slotLookup[gameObject.appId] = gameObject.n;
        }

        if (gbAndroid) {
            order = maylike.android;
        } else {
            var model = FPGetAppValue("model");
            if (model && model.toLowerCase) {
                model = model.toLowerCase();
            }

            if (model && model.indexOf("ipad") != -1) {
                order = maylike.ipad;
            } else {
                order = maylike.iphone;
            }
        }


        if (order && order.length) {
            result = {};
            result.promoteIds = order;
            result.promoteImages = [];
            len = order.length;
            for (var i=0; i<len; i++) {
                result.promoteImages.push("../../catalog/maylike/" + slotLookup[result.promoteIds[i]] + ".png");
            }
        }
    } catch (e) {
    }

    return result;
}

function GetGameStage(game)
{
    var stage = "nopromote";
    if (game) {
        var d;
        if (gbAndroid) {
            d = game.stageAndroid;
        } else {
            d = game.stage;
        }
        // only use if it's a valid value
        if (d !== null && d !== undefined) {
            stage = d;
        }
    }
    return stage;
}

function GetAllGamesDataForDevice()
{
    var newGames = [];
    var bIpad = false;
    var otherDevice = "ipad";
    var model = FPGetAppValue("model");
    if (model && model.indexOf("iPad") != -1){
        bIpad = true;
        otherDevice = "iphone";
    }

    // on Android, there's never a need to exclude "other device" games
    if (gbAndroid) {
        otherDevice = "";
    }

    var promoteApps = [];

    // newer versions of catalog game-data.js provide an override for this - use it if available
    var altData = GetGameInfoByAppId("sdktest");
    var altTag = bIpad ? "promoOrder_ipad" : "promoOrder_iphone";
    if (gbAndroid) {
        altTag = "promoOrder_android";
    }
    if (altData && altData[altTag]) {
        var candidates = altData[altTag];
        promoteApps = [];
        for (var i=0; i<candidates.length; i++) {
            if (GetGameStage(GetGameInfoByAppId(candidates[i])) !== "nopromote") {
                promoteApps.push(candidates[i]);
            }
        }
    }

    for (var i = 0; i< gGameInfo.length; i++)
    {
        var game = gGameInfo[i];
        if (bIpad && game.device !== otherDevice && GetGameStage(game) !== "nopromote")
        {
            if (promoteApps.indexOf(game.appId) < 0){
                // show all games in Ipad
                newGames.push(CopyObject(game));
            }
        }
        else if (game.device !== otherDevice && GetGameStage(game) !== "nopromote")
        {
                if (promoteApps.indexOf(game.appId) < 0){
                    // show all games in Iphone
                    newGames.push(CopyObject(game));
                }

        }
    }
    for (var i = promoteApps.length-1; i>=0; i--)
    {
        var promoteApp = GetGameInfoByAppId(promoteApps[i]);
        newGames.push(CopyObject(promoteApp));
    }


    for (var i = 0; i< newGames.length; i++)
    {
        if (bIpad && newGames[i].device === otherDevice)
        {
            newGames.splice(i, 1);
        }
        else if (newGames[i].device === otherDevice)
        {
                newGames.splice(i, 1);

        }
    }


    return newGames;
}
// promote game for parent home, not including games already installed, not including game which not available in app store or nopromote
function GetPromoteGameNotInstalled(parent, callback){
    var diff = [];
    if (gInstalledGames){
        next();
    }else{
        GetInstalledGames(next);
    }
    function next(){
        var allGames = GetAllGamesDataForDevice();
        var i = allGames.length;
        while(i--){
            var game = allGames[i];
            var id = game.appId;
            if ( !gInstalledGames[id] && // it's not in installed games
                GetGameStage(game) !== "comingsoon" && // not show games not in app store
                GetGameStage(game) !== "nopromote") // not show games that not promoting
            {
                diff.push(game);
            }
        }

        callback(parent, diff);
    }
}
function GetGameList()
{
	var list = [];
	var count = gGameInfo.length;
	for (var i=0; i<count; i++) {
		if (gGameInfo[i].appId != "sdktest") { // exclude test App
			list.push(gGameInfo[i].appId);
		}
	}
	return list;
}

function GetAppDirName(appId)
{
	var info = GetGameInfoByAppId(appId);
	if (info.dir) {
		// some early games had directory names different than their Id
		return info.dir;
	} else {
		return appId;
	}
}

function GetFirstTimePlay()
{
	var appId = GetAppId();
	var info = GetGameInfoByAppId(appId);
	return info.firstTimePlay;
}

function GetLarryOMode()
{
    var appId = GetAppId();
    var info = GetGameInfoByAppId(appId);
    return info.larryoMode;
}

function GetGameInfoByAppId(appId)
{
	var count = gGameInfo.length;
	for (var i=0; i<count; i++) {
		if (gGameInfo[i].appId == appId) {
			return gGameInfo[i];
		}
	}
	return null;
}

function GetGameInfo(bundleId)
{
	var count = gGameInfo.length;
	for (var i=0; i<count; i++) {
		var bundleIds = gGameInfo[i].bundleIds;
		if (bundleIds) {
			var len = bundleIds.length;
			for (var j=0; j<len; j++) {
				if (bundleIds[j] == bundleId) {
					return gGameInfo[i];
				}
			}
		}
	}

	// if we couldn't find the game, use sdktest
	return GetGameInfoByAppId("sdktest");
}

var gGameBundleId;

function GetGameNameByAppId(appId)
{
	var info = GetGameInfoByAppId(appId);
    return info.name;
}

function NewSetBundleId(bundleId)
{
    gGameBundleId = bundleId;
    var info = GetGameInfo(gGameBundleId);
    return JSON.stringify(info);
}

function GetAppId()
{
	var info = GetGameInfo(gGameBundleId);
	return info.appId;
}

function GetGameName()
{
    var info = GetGameInfo(gGameBundleId);
    return info.name;
}

function IsGameMultiplayer()
{
    var v = FPGetAppValue("bMultiplayer");
    var bMultiplayer = (v == "true");
    console.log("bMultiplayer: " + bMultiplayer);
    if (!window["FPNative"])
    {
        return true;
    }else
    {
        return bMultiplayer;
    }
}

function FPGetGameName()
{
    var game_id = FPGetGameId();
    var count = gGameInfo.length;
   	for (var i=0; i<count; i++) {
   		if (game_id == gGameInfo[i].appId) {
               return gGameInfo[i].name;
       }
   	}

   	// if we couldn't find the game, use sdktest
   	return "_GAME_";
}
