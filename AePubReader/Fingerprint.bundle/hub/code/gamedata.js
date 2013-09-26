//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

// ---------------------------------------------------------------------------------------------------------------------
// Support for Game Data (Fingerprint API saveData/loadData - per person with server synchronization)

function FPGameDataGetKey(data_id)
{
    var key = "game/" + FPGetPersonId() + "/" + data_id;
    return key;
}

function FPSaveServerData(o)
{
    FPHelper.saveServerData(FPGameDataGetKey(o.key), o);
}

function FPGameDataSend(data_id, o)
{
    var data = {
        command: "save",
        key: data_id,
        version: o.client_version ? o.client_version : 0,
        value:o.client_value,
        account_token: FPGetAccountToken(),
        person_id: FPGetPersonId(),
        game_id: FPGetGameId()
    };
    FPQueueRequest("GameData", data);
}
