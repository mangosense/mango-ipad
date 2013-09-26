//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

function awardFingerprintPoints(points)
{
    var data = {
        coins: points,
        command: "add"
    };
    FPQueueRequest("Coins", data);
}

function reportProgress(progressId, state)
{
    validateAllKeyNames(state);

    var data = {
        progressId: progressId,
        state: state,
        command: "post"
    };
    FPQueueRequest("ProgressReport", data);
}

// TODO: consider metrics support in the various web views
function metric(metricID, data)
{
    validateAllKeyNames(data);

    FPMetrics.metric(metricID, data);
}

function metricScreen(screenID)
{
    FPMetrics.metricScreen(screenID);
}

function avatarDescription()
{
    var a = {};
    a.bGuest = FPIsGuest();
    a.name = FPGetPersonName();

    var avatar = FPGetPersonAvatar();

    var n = parseInt(avatar.substring(6));
    n--;
    var hair = ["red", "black", "brown", "blond", "black", "black", "red", "black", "black", "blond", "black", "brown"];
    var eyes = ["black", "black", "black", "blue", "black", "black", "black",  "black", "black", "black", "black", "black"];
    // safety
    if (isNaN(n) || n < 0 || n > 11) {
        n = 0;
    }
    a.hair = hair[n];
    a.eyes = eyes[n];

    if (n < 6) {
        a.id = "girl" + (n+1);
    } else {
        a.id = "boy" + (n+1-6);
    }

    a.friends = [];
    var friends = FPGetAccountValue("friends");
    var count = friends.length;
    for (var i=0; i<count; i++) {
        a.friends.push(friends[i].name);
    }

    a.language = FPGetAppValue("language");
    a.partner = FPGetAppValue("partner");

    if (FPPartnerMode())
    {
        a.bHasKidsOrFamily = FPGetAppValue("PartnerMode_bHasKidsOrFamily");
    }
    else if (a.partner === "astro") {
        var settings = FPGetAccountSettings();
        if (settings) {
            a.bHasKidsOrFamily = settings.bHasKidsOrFamily;
        }
        // avatar in astro platform, odd is boy and even is girl
        if (n%2 === 0){
            a.id = "boy" + (parseInt(n/2)+1);
        }else{
            a.id = "girl" + (parseInt(n/2)+1);
        }
    } else {
        a.bHasKidsOrFamily = false;
    }

    return JSON.stringify(a);
}

function sendMessage(messageID, data, bInteractive)
{
    // TODO: reconsider what to do with bInteractive
    // sendMessage from game goes to the parent - which is the primary account holder - person id is the account id
    FPSendMessage(FPGetAccountId(), messageID, data, null); // no callback so it gets queued to send when possible
}
