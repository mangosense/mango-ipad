// index.js
orientation("vertical");
end();

// logic.js
var gbLoadedCoinocopiaImageInfo = false;
function LoadCoinocopiaImageInfo(callback)
{
    if (!gbLoadedCoinocopiaImageInfo) {
        gbLoadedCoinocopiaImageInfo = true;
        LoadScript("/coinocopia/image-info.js", callback);
    }
}

o = function(s, args) {
    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    var animationOrder = [2, 1, 0, 3, 4, 5, 6, 7, 8, 11, 9, 12, 10, 13, 14];
    var sound2multiplierRate = {// name of sound : [ multiplier number, rate to be selected, the sum of rates till that sound (calculate later) ],
    // the ratio of none be selected is 100, the base is 1344.35
        "Cow":[2, 10, 0], "Cat":[3, 1, 0], "KitchenCrash":[4, 0.1, 0], "Cymbals":[5, 0.05, 0],
        "Chicken":[2, 10, 0], "Firecracker":[3, 1, 0], "Glass":[4, 0.1, 0], "Submarine":[5, 0.05, 0],
        "Duck":[2, 10, 0], "OldCarHorn":[3, 1, 0],"Elephant":[4, 0.1, 0], "BowlingPins":[5, 0.05, 0],
        "Plates":[2, 10, 0], "OrchestraHits":[3, 1, 0] };
    var machine, bgDiv, animationLayer, coinsPanel;
    var audioPath = "/coinocopia/sounds/";// correct path to major/coinocopia/sounds/ in device
    var imagePath = "../../coinocopia/images/";
    var animIndex, preId = -1, currId = -1, bgSoundId = -1, coinTallyId = -1;
    var intervals = 1000;
    var bClose = false;
    var x_multi = 90, y_multi = 160, rate = 1;
    var pegMap = [];
    var coin_r = 17;
    var max_x = parseInt(220/coin_r), max_y = parseInt(115/coin_r);
    var coinsIn = FPGetPersonCoins(), coinsOut = FPGetPersonCoinsOut();
    init();
    function init(){
        machine = div({parent:p, x:0, y:0, w:320, h:991});
        bgDiv = div({parent:machine, x:0, y:0, w:320, h:991});
        image({parent:machine, x: 15, y: 25, w: 290, h: 60, src: gImagePath+"coinocopia-logo"});
        if (FPIsOffline()) {
            runScreen(s, "offline", "left", {what: "play Coin-o-Copia", bNoBack: true});
        } else {
            checkAvailability();
        }
    }
    // check is assets is downloaded if not download and then show machine from top to bottom
    function checkAvailability(){
        var versions = JSON.parse(FPGetAppValue("versions"));
        // see if we have coinocopia available
        var bHaveIt = false;
        if (window["gWebGame"]) {
            bHaveIt = true;
        } else {
            bHaveIt = (versions.seed && versions.seed.coinocopia) || (versions.major && versions.major.coinocopia && versions.major.coinocopia >= 5);
        }
        if (!bHaveIt && window["gRanCoinocopia"]) {
            bHaveIt = true;
        }
        if  (bHaveIt) {
            initialGame();
        }else{
            label({parent:bgDiv, x: 0, y: 140, w:320, h:40, center:true, string: i18n('_TAP_PLAY_TO'), id: "tap", font:"light font", color:"#a6a6a6", size:14});
            button({parent:bgDiv, x: 110, y: 170, w:94, h:95, id: "download", string: "", src: gImagePath+"play-button", idleover:"same"});
            bgDiv.on_download = function(){


                $(s.button["download"]).hide();

                var pd = div({parent: s, x: 0, y: 240, w: 320, h: 80});

                var timeText = label({parent:pd, x:10, y:30, w:300, h:170, string: i18n('_0_IS_FINISHED'), center:true, font:"light font", color:"#5e5e5e", size:12});
                image({parent: pd, x: 20, y: 0, w: 280, h: 20, src:gImagePath+"progress-bar-background"});
                image({parent: pd, x: 22, y: 2, w: 10, h: 16, src:gImagePath+"progressbar-beginning"});
                var mid = image({parent: pd, x: 32, y: 2, w: 0, h: 16, src:gImagePath+"progressbar-mid"});
                var end= image({parent: pd, x: 41, y: 2, w: 10, h: 16, src:gImagePath+"progressbar-end"});
                var w = 256*gScaleX;
                var perc = 0;
                setProgress(0);

                function setProgress(percent){
                    if (percent<0) {
                        percent = 0;
                    } else if (percent > 100) {
                        percent = 100;
                    }
                    $(mid).css("width", w*percent/100.0);
                    $(end).css("left", (w)*percent/100.0+(31)*gScaleX);
                    timeText.text.innerText = Math.round(percent) + "% finished.";
                }

                function onUpdateComplete(bSuccess)
                {
                    $(pd).hide();
                    if (bSuccess) {
                        initialGame();
                    }
                }

                // ask the server for URL of latest coinocopia
                var versions = {seed:{coinocopia:""}};
                function onVersions(r)
                {
                    FPProcessUpdate(r.updates, setProgress, onUpdateComplete);
                }
                FPWebRequest("GetUpdates", {command: "get", versions: versions}, onVersions);
            }
        }
    }

    function initialGame(){
        LoadCoinocopiaImageInfo(initialGame2);
    }

    function initialGame2(){

        window["gRanCoinocopia"] = true;

        label({parent:bgDiv, x: 0, y: 140, w:320, h:40, center:true, string: i18n('_LOADING'), color:"#a6a6a6", size:18});
        image({parent:bgDiv, x: 0, y: 0, w: 320, h: 320, src: imagePath+"coinocopia1.jpg"});
        image({parent:bgDiv, x: 0, y: 310, w: 320, h: 320, src: imagePath+"coinocopia2.jpg"});
        image({parent:bgDiv, x: 0, y: 620, w: 320, h: 320, src: imagePath+"coinocopia3.jpg"});
        image({parent:bgDiv, x: 0, y: 930, w: 320, h: 65, src: imagePath+"coinocopia4.jpg"});

        LoadImages([imagePath+"coinocopia1.jpg"], showTotalCoins, null);
        button({parent:machine, x: 240, y: 150, w:55, h:55.5, id: "play", string: "", src: gImagePath+"play-button", idleover:"same"});
        div({parent:machine, x:64, y:158, w:160, h:45, id:"InLabel"});
        image({parent:machine, x:83, y:148, w:150, h:58, src:imagePath+"topplate-shadow"});
        renderCoinsLabel(s.div["InLabel"], coinsIn, 50, 3, "#ffffff");
        div({parent:machine, x:15, y:880, w:280, h:45, id:"OutLabel"});
        image({parent:machine, x:37, y:877, w:245, h:48, src:imagePath+"plate-shadow"});
        animationLayer = div({parent:machine, x:0, y:190, w:320, h:801});
        addAnimationParts();

        var sum = 0;
        for ( var k in sound2multiplierRate){
            sum += sound2multiplierRate[k][1] * 100;
            sound2multiplierRate[k][2] = sum;
        }
        machine.on_play = function(){

            if (FPGetPersonCoins()>0){

                SetEnabled(s.button["play"], false);
                playCoinFlow();
                // play the bg music
                if (bgSoundId < 0 ){
                    FPAudio.play(audioPath + "MachineHum.aiff", true, onStartStopBgMusic);
                }
                renderCoinsLabel(s.div["InLabel"], 0, 50, 3, "#ffffff");
                // init animIndex
                animIndex = 0;
                renderCoinsLabel(s.div["OutLabel"], coinsOut, 35, 7, "#ffffff");
            }else{
                // show help
                runScreen(p, "hub_coins_help", "left");
            }
        };
    }
    function showTotalCoins(){
        label({parent:machine, x:20, y:107, w:150, h:30, string: i18n('_YOUR_TOTAL_COINS'), size:16, color:"#fbde57", font:"light font"});
        var total = div({parent:machine, x:153, y:100, w:150, h:30});
        $(total).css("background-color", "#4e4e4e");
        div({parent:machine, x:141, y:105, w:160, h:30, id:"totalLabel"});
        renderCoinsLabel(s.div["totalLabel"], coinsOut, 21, 7, "#ffffff", 17);
        image({parent:machine, x:153, y:100, w:150, h:30, src:imagePath+"plate-shadow"});
    }
    function renderCoinsLabel(parent, coinsVal, ox, maxLen, color, size){
        if ($(parent).children().length>0){
            $(parent).empty();
        }
        var numberStr = coinsVal.toString();
        if (numberStr.length > maxLen){
            var maxNumStr = "";
            for (var i = 0; i < maxLen; i++){
                maxNumStr += "9";
            }
            numberStr = maxNumStr;
        }
        var Numbers = numberStr.split("").reverse();
        var w_size = 38;
        if (size){
            w_size = size;
        }
        var t_label = {y:0, w:w_size+4, h: 45, size:w_size};
        var offset = 10+ox*(maxLen-1);
        for (var i = 0; i < Numbers.length; i++){
            label(t_label, {parent:parent, x:offset, string: Numbers[i]?Numbers[i]:"", color:color});
            offset -= ox;
        }
        $(parent).css("text-align", "right");
    }
    function addAnimationParts(){
        var oy = 190;
        var t_animat = [];
        t_animat[0] = {x:19, y:408-oy, w:125, h:110.5};
        t_animat[1] = {x:137, y:423.5-oy, w:100, h:63.5};
        t_animat[2] = {x:235.5, y:355.5-oy, w:63, h:136};
        t_animat[3] = {x:88.5, y:514-oy, w:33.5, h:50};
        t_animat[4] = {x:113, y:511-oy, w:60, h:60};
        t_animat[5] = {x:228, y:519-oy, w:37, h:30};
        t_animat[6] = {x:39, y:585.5-oy, w:30, h:58};
        t_animat[7] = {x:96, y:623-oy, w:119, h:89};
        t_animat[8] = {x:256, y:583-oy, w:48.5, h:60};
        t_animat[9] = {x:18.5, y:675.5-oy, w:52, h:103.5};
        t_animat[10] = {x:79, y:716-oy, w:121.5, h:50};
        t_animat[11] = {x:157, y:718-oy, w:57.5, h:34};
        t_animat[12] = {x:18.5, y:779-oy, w:58, h:71};
        t_animat[13] = {x:133.5, y:809.5-oy, w:40, h:42};
        t_animat[14] = {x:184, y:778.5-oy, w:117, h:77};
        for (var i = 0; i < animationOrder.length; i++){
            image(t_animat[animationOrder[i]], {parent:animationLayer, id:"anim."+animationOrder[i], src:gImagePath + "blank"});
        }
        image({parent:animationLayer, x: 90, y: 160, w: 0, h: 0, id: "multiplier", src: gImagePath + "blank" });
        $(animationLayer).hide();

        // add pegs for coin drop
        var t_box = {x: 60, y: 220, w: 246, h: 113};
        var pegsPanel = div(t_box, {parent:machine});
        coinsPanel = div(t_box, {parent:machine});
        image({parent:machine, x: 30, y: 214, w: 262, h: 127, src: imagePath + "coinbox"});
        for (var i = 0; i < max_x; i++){
            var tmpArr = [];
            for (var j = 0; j < max_y; j++){
                tmpArr.push(0);
            }
            pegMap.push(tmpArr);
        }
        for (var i = 0; i < max_x; i++){
            for (var j = 0; j < max_y-1; j++){
                if (j%2!==0){
                    if ( (j%4===3 && i%3===1) || (j%4===1 && i%3===0) ){
                        pegMap[i][j] = 1;
                        addPeg(pegsPanel, i, j);
                    }
                }
            }
        }
        j = max_y - 1;
        var k = Math.round(max_x/2);
        pegMap[k][j] = 1;
        addPeg(pegsPanel, k, j);

        function addPeg(parent, i, j){
            var img = image({parent:parent, x:i*coin_r, y:j*coin_r, w:15, h:18, id: "peg", src:imagePath+"peg" });
            $(img).addClass("peg");
        }
    }
    // play coin animation
    function playCoinFlow(){
        $(machine).animate({"top": -(991-gHubHeight)*gScaleY}, 15000);
        $(animationLayer).show();
        FPAudio.play(audioPath + "CoinDropSmall.mp3", false, null);
        rate = 1;
        // add coins
        var num_coinDropOnce = 5;
        var num_coinShow = 15;
        var dx = 176/(num_coinDropOnce);
        // add coins
        for (var i = 0; i < num_coinShow; i++){
            var coinImg = image({parent:coinsPanel, x: dx*(i%num_coinDropOnce)+(Math.random()*10-5), y: -coin_r, w: 20, h: 20, id: "coin."+i, src: imagePath+"coin" });
            $(coinImg).addClass("coin");
        }
        // init setting for coin drop
        var coinDropSpeed = 50;
        var count = 0;
        calcuCoinsPos();
        function calcuCoinsPos(){
            if (count < 25 + num_coinShow/num_coinDropOnce){
                for (var i = 0; i < Math.min(num_coinDropOnce*(count/3+1), num_coinShow); i++){
                    var pos = {};
                    pos.x =  parseInt($(s.image["coin."+i]).css("left"));
                    pos.y =  parseInt($(s.image["coin."+i]).css("top"));
                    pos = getCoinPos(pos, i);
                    $(s.image["coin."+i]).css("left", pos.x);
                    $(s.image["coin."+i]).css("top", pos.y);
                }
                count++;
                setTimeout(calcuCoinsPos, coinDropSpeed);
            }else{
                // play the flow
                showAnimationFlow();
                $(coinsPanel).empty();
            }
        }
        function getCoinPos(old_pos, animIndex){
            var new_pos = {};
            var ddy = 5*gScaleY;
            // check if coin hit a peg
            new_pos.y = old_pos.y + ddy+Math.random()*5;
            new_pos.x = old_pos.x;
            var ny = Math.ceil(new_pos.y/gScaleY/coin_r);
            var nx = Math.ceil(new_pos.x/gScaleX/coin_r);
            nx = nx<0?1:nx;
            nx = nx>max_x-1?max_x-1:nx;
            if (pegMap[nx][ny]>0){
                // randomly pick left and right
                var random = Math.random()*2>1?1:-1;
                // if coin in the left edge make it move to the right
                if (nx < 1){
                    random = 1;
                }
                // move to left
                if (nx > max_x){
                    random = -1;
                }
                nx = nx + random;
                // check if the update position still have peg on
                // then change the direction to the opposite
                if (pegMap[nx][ny]>0){
                    random = -random;
                    nx += 2*random;
                }
            }
            new_pos.x = (nx)*coin_r*gScaleX+(Math.random()*10-5);

            // adjust for wall in bottom
            if (new_pos.y > 65*gScaleY && new_pos.x < 2*(new_pos.y - 65*gScaleX) ){
                new_pos.x = 2*(new_pos.y - 65*gScaleX);
            }
            if (new_pos.y > 70*gScaleY && new_pos.x > 175*gScaleX  - 2*(new_pos.y - 70*gScaleX) ){
                new_pos.x = 175*gScaleX - 2*(new_pos.y - 70*gScaleX);
            }

            return new_pos;
        }
    }


    function showAnimationFlow(){
        if (!bClose){
            var animPath = "../../coinocopia/animations/";
            var i = animationOrder[animIndex];
            s.image["anim."+i].src = animPath + i + "_animated_img.gif";
            // hide previous animation
            if (animIndex>0){
                var i2 = animationOrder[animIndex-1];
                $(s.image["anim."+i2]).hide();
            }
            addMultiplier();

            // cache the position for multiplier
            x_multi = parseInt($(s.image["anim."+i]).css("left"));
            y_multi = parseInt($(s.image["anim."+i]).css("top")) + 20;
            if (x_multi > (320 - 200)*gScaleX){
                x_multi = (320 - 200)*gScaleX;
            }
            FPAudio.play(audioPath + i + "_audio.mp3", true, onStartStopInLoop);
            animIndex++;
            if (animIndex < animationOrder.length){
                // in the same period show next animation
                setTimeout(showAnimationFlow, intervals);
            }else{
                cleanAnimationAndSound();
            }
        }
    }

    function muteLastSound(){
        if (preId > -1){
            FPAudio.stop(preId);
        }
    }
    function addMultiplier(){
        // animation multiplier on the previous animation pieces
        var keys = Object.keys(sound2multiplierRate);
        var lastkey = keys[keys.length-1];
        var random = Math.random()*(sound2multiplierRate[lastkey][2]+10000);
        if (random < sound2multiplierRate[lastkey][2]){
            var keyIndex = 0;
            var key = keys[keyIndex];
            while (random > sound2multiplierRate[key][2]){
                keyIndex++;
                key = keys[keyIndex];
            }
            rate *= sound2multiplierRate[key][0];
            s.image["multiplier"].src = "../../coinocopia/multipliers/" + sound2multiplierRate[key][0] + "_multiplier.png";

            // add zoom in and out for multiplier
            $(s.image["multiplier"]).animate({
                height: 128*gScaleX,
                width: 116*gScaleY
            }, 200, function(){
                //"finish scale up"
                setTimeout(function(){
                    //pause for a while
                    $(s.image["multiplier"]).animate({
                        height: 0,
                        width: 0
                    }, 200, function(){
                        //finished scale done
                        $(s.image["multiplier"]).css("left", x_multi);
                        $(s.image["multiplier"]).css("top", y_multi);
                        // finished moving
                    });
                }, 600);
            });
            FPAudio.play(audioPath + key + ".mp3", false, null);
        }
    }
    function cleanAnimationAndSound(){
        // finish the last sound with the last animation
        setTimeout(muteLastSound, intervals);
        $(s.image["multiplier"]).hide();
        // render the number
        var result = coinsIn*rate;
        var l_plus = label({parent:machine, x:0, y:840, w:320, h:40, string: i18n('_')+result, center:true, size:40, color:"#fbde57"});
        $(l_plus).animate({
            opacity: 0,
            top: 720*gScaleX
        }, intervals*4, function() {
            var sum = result + coinsOut;
            var addby = Math.max(parseInt(result/100), 10);
            FPSetCoinsOut(sum, null);
            FPSetCoinsIn(0, null);
            coinsAddUp(s.div["OutLabel"], coinsOut, sum, addby, 17, goToTop);
            // start the coin sound, loop
            if (coinTallyId <0){
                FPAudio.play(audioPath + "CoinTally.mp3", true, onCoinsAddUp);
            }
        });

    }
    function onCoinsAddUp(soundId, event){
        coinTallyId = soundId;
    }
    function goToTop(){
        FPAudio.stop(coinTallyId);
        FPAudio.stop(bgSoundId);
        setTimeout(function(){
            $(machine).animate({"top": 0}, intervals);
            renderCoinsLabel(s.div["totalLabel"], FPGetPersonCoinsOut(), 21, 7, "#ffffff", 17);
            SetEnabled(s.button["play"], true);
        }, intervals*3);
    }
    // show add up animation
    function coinsAddUp(parent, oldVal, newVal, addby, intervals, callback){
        if (oldVal < newVal){
            setTimeout(function(){
                coinsAddUp(parent, oldVal+addby, newVal, addby, intervals, callback);
            }, intervals);
        }else{
            oldVal = newVal;
            callback();
        }
        renderCoinsLabel(s.div["OutLabel"], oldVal, 35, 7, "#ffffff");
    }
    function onStartStopInLoop(soundId, event){
        muteLastSound();
        if (!bClose){
            preId = parseInt(soundId);
        }else{
            currId = parseInt(soundId);
        }
        if (event == "stop") {
            if (onComplete) {
                onComplete();
            }
        }
    }
    function onStartStopBgMusic(soundId, event){
        bgSoundId = soundId;
    }

    // if coins update, refresh the page
    s.registerForNotification("coins");
    s.onNotification_coins = function(){
        if (!s.div["InLabel"]) {
            div({parent:machine, x:63, y:133, w:180, h:45});
        }
        renderCoinsLabel(s.div["InLabel"], FPGetPersonCoins(), 50, 3, "#ffffff");
    }

    s.onScreenClose = function(){
        bClose = true;
        FPAudio.stop(bgSoundId);
        FPAudio.stop(currId);
        FPAudio.stop(coinTallyId);
        muteLastSound();
    }
};

FPLaunchScreen(o);
