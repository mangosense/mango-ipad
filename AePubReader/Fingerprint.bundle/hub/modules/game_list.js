//
//  Copyright 2012, 2013 Fingerprint Digital, Inc. All rights reserved.
//

function FPCreateGameList(person_id, callback, callbackObj)
{
    function onData(r)
    {
        function next(gamesInstalled)
        {
            var len = r.games.length;
            for (var i=0; i<len; i++) {
                r.games[i].bInstalled = gamesInstalled[r.games[i].game_id];
            }
            callback(r, callbackObj);
        }
        if (r && r.bSuccess && r.games) {
            var games = [];
            var len = r.games.length;
            for (var i=0; i<len; i++) {
                games.push(r.games[i].game_id);
            }
            FPHelper.areGamesInstalled(games, next);
        } else {
            callback(null, callbackObj);
        }
    }

    FPWebRequestWithCache(
        "GamePlayed",
        {command: "getPlayed", friend_id: person_id},
        onData, null,
        "gamesPlayed_" + person_id, "account");
}


