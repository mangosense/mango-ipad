//
//  Copyright 2013 Fingerprint Digital, Inc. All rights reserved.
//

/**
 Name space for functions that require native implementation support.
 */
var FPAudio = {};

/**
 * play audio - optionally loops the sound

 @param {String} url of the sound to play (can be a local fpcontent URL)
 @param {Boolean} whether to loop the sound
 @param {Function} onStartStop callback - function(soundId, event) - called on event "start" and "stop"
 @return {Void}
*/
FPAudio.play = function(url, bLoop, onStartStop)
{
    if (window["FPNative"])
    {
        var sdk_version = FPGetAppValue("sdk_version");
        if (sdk_version >= 6) {
            function callback(o)
            {
                if (onStartStop) {
                    onStartStop(o.soundId, o.event);
                }
            }
            FPNativeCall("FPNativeAudioPlayer", "play:loop:", [url, bLoop], callback);
        }
    }
    else
    {
        // TODO
        console.log("warning: webHub FPAudio.play not implemented");
    }
};

/**
 * stop audio

 @param {Integer} soundId of the sound to stop (returned by FPAudio.play) or -1 to stop all sounds
 @return {Void}
 */
FPAudio.stop = function(soundId)
{
    if (window["FPNative"])
    {
        var sdk_version = FPGetAppValue("sdk_version");
        if (sdk_version >= 6) {
            FPNativeCall("FPNativeAudioPlayer", "stop:", [soundId], null);
        }
    }
    else
    {
        // TODO
        console.log("warning: webHub FPAudio.stop not implemented");
    }
};
