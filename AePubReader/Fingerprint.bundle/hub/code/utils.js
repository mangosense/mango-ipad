//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//
function validateEmail(email)
{
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
}

function validatePhoneNumber(p) {
  var phoneRe = /^[2-9]\d{2}[2-9]\d{2}\d{4}$/;
  var digits = p.replace(/\D/g, "");
  return (digits.match(phoneRe) !== null);
}

function validateKeyName(name)
{
    var bFailed = false;
    if (typeof(name) == "string") {
        // not a valid key name if it
        // contains $
        bFailed |= (name.indexOf("$") != -1);
        // contains .
        bFailed |= (name.indexOf(".") != -1);
        // is the empty string
        bFailed |= (name.length == 0);
    }

    if (bFailed) {
        // alert the developer to force the issue and get the key name changed
        var message = "ILLEGAL KEY NAME: " + name;
        console.log(message);
        DoAlert("error", message);
    }
}

function validateAllKeyNames(o)
{
    // note that an Array will also act as on Object
    if (typeof(o) == "object") {
        for (name in o) {
            validateKeyName(name);
            validateAllKeyNames(o[name]);
        }
    }
}

// validate that Facebook token is still valid
function validateFacebookToken(callback){
    FPWebRequest("ConfirmFacebook", {command: "confirm"}, function(r) {
        if (r.result) {
            FPSetAccountValue("facebook_id", null);
            DoAlert("Connect to Facebook", "Your facebook connection is expired. Do you want to reconnect?", next, true);
            function next(bReconnect){
                function onFacebookResult(facebook_token){
                    FPLinkFacebook(facebook_token, callback);
                }
                if (bReconnect){
                    FPHelper.facebookConnect(onFacebookResult);
                }
            }
        }else if (r.notAuthorized){
            // use have remove fingerprint app from facebook
            // clean stored facebook_id, show UI for connecting to facebook
            FPSetAccountValue("facebook_id", null);

            callback();
        }else{
            callback();
        }
    });
}

var gCaller;
var gEvalCallbackCount = 0;
var gEvalCallbacks = {};

function DoEvalCallback(caller, n, data)
{
    var dataStr = JSON.stringify(data);
    FPWebView.eval(caller, "DoEvalCallbackReturn(" + n + ", " + dataStr + ")", null);
}

function DoEvalCallbackReturn(n, data)
{
    var callback = gEvalCallbacks[n];
    delete gEvalCallbacks[n];
    if (callback) {
        callback(data);
    }
}

function RegisterEvalCallback(callback)
{
    gEvalCallbackCount++;
    var n = gEvalCallbackCount;
    gEvalCallbacks[n] = callback;
    return n;
}

function FPIsSid()
{
    var bSid = (FPGetGameId() === "sid");

    bSid |= (FPGetGameId() === "shrinkykid"); // also for Shrinky Kid - the other Mindshapes game

    return bSid;
}

function FPDeferredRegistrationMode()
{
//    var bResult = (FPGetAppValue("bDeferredRegistration") == "true");
    var bResult = false; // deprecated except for Sid
    bResult |= FPIsSid(); // always enabled for Sid
    return bResult;
}

function FPInDelayedRegistrationMode()
{
    if (FPDeferredRegistrationMode() && FPGetAccountToken() === "guest") {
        return true;
    } else {
        return false;
    }
}

function DoNativeParentGate(details)
{
    function onResult(bIsParent)
    {
        FPHelper.callAPIDelegate("onParentGateInternal:details:", [bIsParent, details]);
    }

    var settings = FPGetAccountSettings();
    if (settings&&settings.noParentGate) {
        onResult(true);
    } else {
        var args = { callback: RegisterEvalCallback(onResult) };
        FPWebView.eval("alert", "ShowParentGate(" + JSON.stringify(args) + ")", null);
    }
}

function DoParentGate(callbackOnlyIfParent, args)
{
    var settings = FPGetAccountSettings();
    if (settings&&settings.noParentGate) {
        callbackOnlyIfParent();
        return;
    }

    function onResponse(bParent)
    {
        if (bParent) {
            if (bMultiply){
                settings.noParentGate = true;
                FPSetAccountSettings(settings);
            }
            callbackOnlyIfParent();
        }else if (bMultiply){
            // response for failures as well
            callbackOnlyIfParent();
        }
    }
    var args = cascade(args, { callback: RegisterEvalCallback(onResponse) });
    var bMultiply = args && args.bMultiply;
    args.noCheckBox = args.noCheckBox||false;
    FPWebView.eval("alert", "ShowParentGate(" + JSON.stringify(args) + ")", null);
}

function DoAlert(title, message, callback, doCancel)
{
    var args = {
        title: title,
        msg: message,
        ok: i18n("_OK"),
        callback: RegisterEvalCallback(callback)
    }
    if (doCancel){
        args.cancel = i18n("_CANCEL");
    }
    FPWebView.eval("alert", "ShowAlert(" + JSON.stringify(args) + ")", null);
}

function DoSubstitutions(s, data)
{
    var orderedKeys = [];
    for (var key in data) {
        orderedKeys.push(key);
    }
	orderedKeys.sort(function(a,b) {
        return b.length - a.length;
    });

    for (var i = 0; i < orderedKeys.length; i++)
    {
        var d = orderedKeys[i];
        var dAlt = d;
        var orig;
        do {
            orig = s;

            s = s.replace("$"+dAlt, data[d]);

			if (s == orig) {
				// also see if we can find it all lowercase - workaround, as naming was inconsistent
				dAlt = dAlt.toLowerCase();
				s = s.replace("$"+dAlt, data[d]);
			}
        } while (orig != s);
    }
    return s;
}

function FPDoCallbackChain()
{
    var keep = arguments;
    var len = keep.length;
    var i = 0;
    function next()
    {
        if (i<len) {
            var func = keep[i];
            i++;
            func(next);
        }
    }
    next();
}

function GUID()
{
    var S4 = function ()
    {
        return Math.floor(
                Math.random() * 0x10000 /* 65536 */
            ).toString(16);
    };

    return (
            S4() + S4() + "-" +
            S4() + "-" +
            S4() + "-" +
            S4() + "-" +
            S4() + S4() + S4()
        );
}

// UI utils
/** Create opponents for selecting avatar.
 *  @fn createAvatarSelector( Object p)
 *  @tparam Object s specify the parent screen.
 *  @tparam Number oy specify the offset of these opponents to parent screen.
 *  @tparam String avatar_selected specify the name of avatar selected.
 *  @tparam String bParent force render as for parent .
 *  @treturn Object a avatar picker
 */
function createAvatarSelector(p, pHeight, oy, title, avatar_selected, bVertical, bParent)
{
    var avatar_large;
    var role = FPIsParent()||bParent?"parent":"family";
    var initialAvatar = FPGetPersonAvatar()?FPGetPersonAvatar():"";
    var selectedAvatarSize = 70,
        titleHeight = 40,
        space = 5,
        buttonHeight = 40;

    var fragment = document.createDocumentFragment();
    var avatar_large_Y = bVertical?oy+45:titleHeight+ space + 16;
    avatar_large = drawAvatar(fragment, initialAvatar, role, "avatar_selected", selectedAvatarSize, bVertical?100:270, avatar_large_Y, false);

    var title = label({parent:fragment, string: title, x:0, y:0, w:275, size:14, h:titleHeight, center:true, vCenter:true, color:"#4e4e4e"});
    $(title).css({width:"100%"});

    var wrapper = div({parent: fragment, x: 10, y: bVertical?(oy+130):45, w: 275, h: 212});
    var avatarScrollBox = div({parent: wrapper, x: 0, y: 0, w: 275, h: 212});
    div({parent:avatarScrollBox});


    role = FPIsParent()||bParent?"parentNoLabel":"family";
    var avatarButtonSize = (pHeight - titleHeight - selectedAvatarSize -2*space)/3;
    avatarButtonSize = avatarButtonSize>45?45:avatarButtonSize;
    for (var i = 0; i< gAvatarNum; i++){
        var avatar_button = drawAvatar(avatarScrollBox, "avatar" + (i+1), role, "avatar." + (i+1), avatarButtonSize, 65*(i%4)+5, (avatarButtonSize+17)*Math.floor(i/4)+5, true);
    }
    avatarScrollBox.id = "avatarScrollBox";
    p.appendChild(fragment);
    var iscroll = new iScroll("avatarScrollBox");

    return avatarScrollBox;
}

/** Generate the image path for avatar.
 *  @fn generateAvatarImagePath( String avatarId)
 *  @tparam String avatarId specify the avatar id of avatar selected.
 *  @treturn String path to the avatar image .
 */
function generateAvatarImagePath(avatarId)
{
    var result;
    if (avatarId && avatarId != "null" && avatarId != ""){
        result = gImagePath+avatarId+".png";
    }else if (avatarId === "addplayer"){
        result = gImagePath+"addplayer.png";
    }else{
        result = gImagePath+"randomavatar.png";
    }
    return result;

}
/** draw avatar with different bgColor for different role.
 *  @fn drawAvatar(String parent, String avatarId, String role, Number radius, Number x, Number y, String borderColor)
 *  @tparam String parent specify the parent of contain avatar image.
 *  @tparam String avatarId specify the avatar id of avatar selected.
 *  @tparam String role specify the avatar role.
 *  @tparam String id specify id of the element.
 *  @tparam Number dia specify the size.
 *  @tparam Number x specify the x position.
 *  @tparam Number y specify the y position.
 *  @tparam String borderColor specify the border color.
 *  @treturn Object a image or button element contain the avatar image .
 */
function drawAvatar(parent, avatarId, role, id, dia, x, y, bBt, borderColor)
{
    var bgColor;
    var appSettings = getAppSetting();
    switch (role){
        case "parent": bgColor = appSettings.parentAvatarColor;
            break;
        case "parentNoLabel": bgColor = appSettings.parentAvatarColor;
            break;
        case "family": bgColor = appSettings.friendAvatarColor;
            break;
        case "friend": bgColor = appSettings.friendAvatarColor;
            break;
        case "addPlayer": bgColor = appSettings.addAvatarColor;
            break;
        default: bgColor = "#07793b";
            break;
    }
    var avatar = generateAvatarImagePath(avatarId);
    var borderNum = parseInt(0.05*gScaleX*dia);
    borderNum = borderNum>3?borderNum:3;
    var border = borderNum+"px solid " + (borderColor?borderColor:"white");
    var avatarElem;
    if (bBt){
        avatarElem = button({parent: parent, id:id?id:"avatarIcon", src: avatar, x:x, y:y, w:dia, h: dia, idleover:"same"});
        SetToggle(avatarElem, true);
    }else{
        avatarElem = image({parent: parent, id:id?id:"avatarIcon", src: avatar, x:x, y:y, w:dia, h: dia});
    }
    LoadImages(["hub/"+avatar], applyStyle, null);
    function applyStyle(){
        $(avatarElem).css("border-radius", 100*gScaleX);
        $(avatarElem).css("border", border);
        $(avatarElem).css("box-shadow", appSettings.avatarBoxShadow);
        $(avatarElem).css("background-color", bgColor);
    }
    if (role==="parent"){
        var radius = dia/2;
        var boxR = radius+(borderNum/gScaleX);
        var d = div({parent:parent, x:x, y:y+(borderNum/gScaleY)+dia*0.8-2, w:boxR*2, h: dia*0.2+(borderNum/gScaleX)});
        $(d).css({textAlign:"center", overflow:"visible"});
        d.className = "ParentTag";
        var tag = div({parent:d});
        tag.innerText = i18n('_PARENT');
        $(tag).css({padding: 4*gScaleX,
            color:appSettings.parentTagColor,
            backgroundColor:"white",
            borderRadius: 3*gScaleX,
            display:"inline-block",
            textAlign:"left",
            fontSize:parseInt(20*boxR/60)*gScaleX,
            fontFamily:fixFontFamily("bold font"),
            boxShadow: appSettings.avatarBoxShadow});

    }
    return avatarElem;

}

/* Return a list of text for creating messages
 *  @fn getDefaultText( )
 *  @treturn Array a array of text strings.
 */
function getDefaultText()
{
    var defaultTextArray = new Array(
            i18n("_HOWS_IT_GOING"),
            i18n("_WHATS_UP"),
            i18n("_HI_THERE"),
            i18n("_YOU_MAKE_ME_SMILE"),
            i18n("_YOU_ROCK"),
            i18n("_WILL_YOU_BE_MY_FRIEND"),
            i18n("_BOO"),
            i18n("_HELLOOOOOO")
    );
    return defaultTextArray;
}
/* Return a button text for different type of messages
 *  @fn getMessageActionText( )
 *  @tpatem String i search string
 *  @treturn String a text string.
 */
function getMessageActionText(i)
{
    var key = i.toLowerCase();

    var defaultTextDict = {
        makefriend:"Make Friend",
        get:"Get It Now",
        reply:"Reply",
        view:"View",
        ok:i18n("_OK"),
        play:"Play",
        progress:"Progress"

    };
    return defaultTextDict[key]?defaultTextDict[key]:"OK";
}

/** Draw a svg pie chart.
 *  @fn drawArcs(Object paper, Array pieData, Array colorArr)
 *  @tparam Object paper place to draw this pie chart.
 *  @tparam Array pieData data.
 *  @tparam Array colorArr colors for drawing.
 */
function drawArcs(paper, pieData, colorArr){
    var arc;
    var sectorAngleArr = [];
    var total = 0;
    var startAngle = 0;
    var endAngle = 0;
    var x1,x2,y1,y2 = 0;
    paper.append("<svg>");
    //CALCULATE THE TOTAL
    for(var k=0; k < pieData.length; k++){
        total += pieData[k];
    }
    //CALCULATE THE ANGLES THAT EACH SECTOR SWIPES AND STORE IN AN ARRAY
    for(var i=0; i < pieData.length; i++){
        var angle = Math.ceil(360 * pieData[i]/total);
        sectorAngleArr.push(angle);
    }
    for(var i=0; i <sectorAngleArr.length; i++){
        startAngle = endAngle;
        endAngle = startAngle + sectorAngleArr[i];

        x1 = parseInt(200 + 180*Math.cos(Math.PI*startAngle/180));
        y1 = parseInt(200 + 180*Math.sin(Math.PI*startAngle/180));

        x2 = parseInt(200 + 180*Math.cos(Math.PI*endAngle/180));
        y2 = parseInt(200 + 180*Math.sin(Math.PI*endAngle/180));

        var d = "M200,200  L" + x1 + "," + y1 + "  A180,180 0 0,1 " + x2 + "," + y2 + " z"; //1 means clockwise
        arc = paper.next("svg").append("<path d='"+ d +"' fill='red' stroke='black' stroke-width='2' stroke-linejoin='round' />");
        arc.attr("fill",colorArr[i]);
    }

}
function donutChart(data, outerR, innerR, color, ox, oy) {
    if (typeof outerR == "undefined") { outerR = 100; }
    if (typeof innerR == "undefined") { innerR = 30; }

    var	width = outerR*2+(ox?ox:0), // canvas size
        height = outerR*2+(oy?oy:0),
        cx = outerR + (ox?ox:0), // centre of the pie chart
        cy = outerR + (oy?oy:0),
        sb = '<svg width="'+width+'" height="'+height+'" id="chart"> ',
        laf = 0, /* Long/Short Arc */
        deg = 0,
        jung = 0,
        sum = 0,
        countOfSlice = 0,
        oldangle = 0;

    for (var i=0; i< data.length; i++) {
        var key = Object.keys(data[i])[0];
        sum += data[i][key]; /* DEPTH */
        countOfSlice += 1;
    };

    if (countOfSlice>1)
    {
        deg = sum/360;
        jung = sum/2;


        var	other = 0;
        var k = 0;
        for (var i=0; i< data.length; i++) {
            var	id = i;
            key = Object.keys(data[i])[0];
            var val = data[i][key];

            /* Special Case, group other games if there are more than 3  */
            if (k > 2) {
                other += val;
                continue;
            }
            else
            {
                makePath(val,id, color[k]);
            }

            k +=1;
        }
        if(k>2)
        {
            makePath(other,"Others", color[3]);
        }
    }
    else
    {
        // draw circle

        sb += '<circle cx="'+ cx +'" cy="'+ cy +'" r="'+ outerR +'" stroke="none" stroke-width="3" fill="'+ color[0]+'" />';
        sb += '<circle cx="'+ cx +'" cy="'+ cy +'" r="'+ innerR +'" stroke="none" stroke-width="3" fill="white" />';
    }


    function makePath(_int,_id,_fill) {

        var angle = oldangle + _int/deg; // cumulative angle

        if (_int > jung) {
            // arc spans more than 180 degrees
            laf = 1;
        } else {
            laf = 0;
        }

        var x1 = cx + (Math.cos(-(oldangle/360)*(2*Math.PI))) * outerR;
        var x2 = cx + (Math.cos(-(angle/360)*(2*Math.PI))) * outerR;
        var y1 = cy + (Math.sin(-(oldangle/360)*(2*Math.PI))) * outerR;
        var y2 = cy + (Math.sin(-(angle/360)*(2*Math.PI))) * outerR;
        var xx1 = cx + (Math.cos(-(oldangle/360)*(2*Math.PI))) * innerR;
        var xx2 = cx + (Math.cos(-(angle/360)*(2*Math.PI))) * innerR;
        var yy1 = cy + (Math.sin(-(oldangle/360)*(2*Math.PI))) * innerR;
        var yy2 = cy + (Math.sin(-(angle/360)*(2*Math.PI))) * innerR;

        sb += '<path id="'+_id+'" data-color="'+_fill+'" data-count="'+_int;
        sb += '" d="M '+cx+','+cy+' ';
        sb += ' L '+x1+','+y1+' ';
        sb += ' A '+outerR+','+outerR+', 0 '+laf+', 0 '+x2+','+y2+' ';
        sb += ' L '+xx2+','+yy2+' ';
        sb += ' A '+innerR+','+innerR+', 0 '+laf+', 1 '+xx1+','+yy1+' ';
        sb += ' z" '; // z = close path
        sb += ' fill="'+_fill+'" stroke="none" ';
        sb += ' fill-opacity="1" stroke-linejoin="round" />';

        oldangle = angle;

    }

    sb += '</svg>';

    return sb;

}

function createTag(p, data, colors)
{
    var k = 0;
    for (var i=0; i< data.length; i++) {
        var key = Object.keys(data[i])[0];
        var d = div({parent:p, x:130, y:37+k*20, w:10, h:10});
        $(d).css("background-color", colors[k]);

        var gameInfo = GetGameInfoByAppId(key);
        if (gameInfo) {
            var gameName = gameInfo.shortname;
            if (gameName === "" || !gameName) {
                gameName = gameInfo.name;
            }
        } else {
            gameName = "";
        }
        label({parent:p, x:145, y:35+k*20, w:180, h:25, string:gameName, size: 12, color:"#4e4e4e"});
        k +=1;
    };
}

// generate animation for levers
function SpriteAnim (options) {
    var timerId, i=1, j= 1, repeated=false,
        element = document.getElementById(options.elementId);
    var img = GetImageInfo("hub/"+gImagePath+options.backgroundImage+i+".png").src;
    $(element).attr("src", img);
    this.init = function(){
        clearInterval(timerId);
        i= j= 1;
        repeated=false;
    };
    this.stopAnimation = function () {
        clearInterval(timerId);
    };
    this.startAnimation = function () {
        timerId = setInterval(function () {
            if (i == 1 && repeated) {
                clearInterval(timerId);
                i = 1;
            }else if(i >= options.numOfImages){
                j = -1;
                repeated = true;
                i += j;
            }else{
                i += j;
            }

            var img = GetImageInfo("hub/"+gImagePath+options.backgroundImage+i+".png").src;
            $(element).attr("src", img);
        }, 50);
    };
}
// generation animation though webkit animation,
// css animation is fast and good at hover effect but not in click and other events
function cssAnimation(rulesText){
    var head = document.getElementsByTagName('head')[0],
        style = document.createElement('style'),
        rules = document.createTextNode(rulesText);
    style.type = 'text/css';
    if (style.styleSheet) {
        style.styleSheet.cssText = rules.nodeValue;
    } else {
        style.appendChild(rules);
    }
    head.appendChild(style);
}
// open native friend picker for contact list
function openNativeFriendPicker(bFacebook, callback)
{
    function onFriend(d)
    {
        if (d){
            var connect_info = d.email;
            // Link to player to each others friend circle
            FPLinkAccount(connect_info, onLinkAccount);
            function onLinkAccount(response){
                if (response.bSuccess){
                    var friendName = response.newFriend?response.newFriend:d.name;

                    DoAlert(i18n("_CONNECT"), i18n("_YOU_HAVE_CONNECTED", {friendName: friendName}) + ".");

                }else{
                    if (d.name == "" && d.name == ""){
                        DoAlert(i18n("_CONNECT"), i18n("_FINGERPRINT_DOES_NOT_HAVE"));
                    }else{
			var bValid = validateEmail(connect_info);
			if (!bValid) {
			    DoAlert(i18n("_CONNECT"), i18n("_INVALID_EMAIL_FORMAT"));
			} else {
			    FPWebRequest("Message", {command: "inviteEmail", email: connect_info});
			    DoAlert(i18n("_CONNECT"), i18n("_YOU_HAVE_SENT") + d.name + ".");
			}
                    }
                }
                if (callback){
                    callback();
                }
            }
        }else{
            if (callback){
                callback();
            }
        }
    }
    FPHelper.friendPicker(FPGetAccountToken(), bFacebook, "Select Friend to Invite", onFriend);
}

function FinishLegalText(legalScrollBox, legalLabel)
{
    // handle links natively so that we don't browse to sites in the hub, and also handle mailto:
    var unqiue = GUID();
    var uniqueName = "legalLabel_" + unqiue;
    legalLabel.id = uniqueName;
    $("#" + uniqueName + " a").click(function() {
        var url = this.href;
        if (url.indexOf("mailto:") == 0) {
            FPHelper.mailTo(url.substring(7), "", "");
        } else {
            FPHelper.openURL(this.href);
        }
        return false; // prevent default behavior
    });

    // to avoid Fingerprint.js from overriding and suppressing the link
    legalLabel.text.style.pointerEvents = null;

    // iScroll needs unique ID to be sure no 2 iScrolls have same Id at the same time (e.g. when transitioning
    // between TOU and PP)
    legalScrollBox.id = "legalScrollBox" + GUID();
    legalScrollBox.iscroll = new iScroll(legalScrollBox.id);
}

function FPCustomAssetsImageInfoPath()
{
    return "../../hub_custom/image-info.js?" + FPGetAppValue("game_id");
}

function FPCustomAssetsPath(asset)
{
    // in device, fpcache configuration, the query argument gets ignored and the files
    // are always directly in ../hub_custom
    // in web/development configuration, the query argument gets used to find the files
    // in ../hub_custom/game_id or ../hub_custom/generic if the game doesn't have a folder
    var pathAddOn = (FPIsLandscape()?"Landscape/":"Portrait/");
    return "../../hub_custom/" + pathAddOn + asset + "?" + FPGetAppValue("game_id");
}
// show tutorial what is real name and where it will be shown
function tutorialOnRealName(parent, oy){
    label({parent:parent, x: 20, y: oy, w:280, h:50, size: 14, string: i18n('_ADD_REAL_NAMES'), font:"light font", color:"#a6a6a6"});
    oy += 50;
    image({parent:parent, x:0, y:oy, w:320, h:97, src:gImagePath+"real_name"});
    oy += 117;
    return oy;
}

// draw header with current player's avatar, name and change player button, used in list screen and game pause screen
function drawHeaderWithChangePlayer(parent, screenName){
    // use the settings in list screen
    screenName = "list";
    var nameBg = div({parent:parent, x:-1, y:40, w:gFullWidth+2, h:30});
    addBackgroundImage($(nameBg), "dark-gray-pattern.png");
    $(nameBg).css("border", "1px solid #353535");
    $(nameBg).css("box-shadow", "0px 0px 20px 3px #444444");
    image(FPCustomAssetsPosition(screenName, "game_header.png"), {parent:parent, id:"icon"});
    label(FPCustomAssetsPosition(screenName, "name"), {parent:parent, id:"name", string:FPGetPersonName(), size:16, x:FPIsLandscape()?95:75, y:48, w:200, h: 35});
    var role = FPIsParent()?"parent":"family";
    drawAvatar(parent, FPGetPersonAvatar(), role, "icon", 50, FPIsLandscape()?35:15, 5, false);
    button({parent:parent, id:"changeButton", src:gImagePath+"button-2-change", idleover:"same", string: "", x: 235+(gFullWidth-320), y: 43.5, w: 24, h:26});
    var l = label({parent:parent, string: i18n("_CHANGE_PLAYER"), x: 264+(gFullWidth-320), y: 40, w: 40, h:30, size:10, vCenter:true});
    var eventName = window["FPNative"]?"touchstart":"click";
    bindEvent(l, eventName, "button_changeButton", parent.on_changeButton);

}

function messageSlideDown(p, str, width, oy, callback){
    var d = div({parent:p, x:0, y:oy-48, w:width, h:25});
    d.innerText = str;
    var fontSize = 500/str.length;
    fontSize = Math.min(16*width/320, fontSize);
    $(d).css({
        backgroundColor:"#fcf4c3",
        border:"1px solid #e1dab2",
        color:"#4e4e4e",
        padding: 5*gScaleX,
        fontSize:fontSize*gScaleX,
        fontFamily:fixFontFamily("bold font"),
        display: "table-cell",
        verticalAlign: "middle",
        textAlign:"center"
    });
    var rules = ["@-webkit-keyframes topMsgAnimation{0% {top:", (oy-48)*gScaleY, "px;} 25% {top:", oy*gScaleY, "px;} 75% {top:", oy*gScaleY, "px;} 100% {top:", (oy-48)*gScaleY, "px;} }"].join("");
    cssAnimation(rules);
    $(d).css("-webkit-animation", "topMsgAnimation 2s");
    setTimeout(removeMsg, 2500);
    function removeMsg(){
        if (callback){
            callback();
        }
        $(d).remove();
    }
}

var gAppSettingSave = null;

function getAppSetting(){
    if (!gAppSettingSave) {
        gAppSettingSave = getAppSettingCore();
    }
    return gAppSettingSave;
}

// get custom bg and header for different app
function getAppSettingCore(){
    var appId = FPGetGameId();
    var setting = {
        partner: "fingerprint",
        partnerName: "Fingerprint",
        landing: "select_play_options",
        addOnPath:"",
        background:gImagePath+"registration_bg_pattern.png",
        headerBg:gImagePath+"bg_header.png",
        logoImg:gImagePath+"logo",
        boxRGBA:"rgba(255, 255, 255, 1)",
        boxFrameRGBA:"rgba(194, 190, 190, 1)",
        friendAvatarColor:"#07793b",
        parentAvatarColor:"#f18b29",
        addAvatarColor:"#366ca8",
        avatarBoxShadow: "1px 1px 3px #999999",
        linkColor: "#148241",
        parentTagColor: "#f37e45",
        txtColor:"#ffffff",
        welcBubbleColor: "#ebebb8",
        friendMayKnowBg: "#a8cce6",
        invitationBg:"#fcf3c5",
        pieColor:["#fbde4f","#f9ee93","#8ac248","#1b9248"],
        gameRecomColor: "#afd1ea",
        alertHeader: "#d9472f",
        alertBorder: "#bb3e28",
        hubBtColor:"#e7571c",
        hubBtSize: 50,
        tabOnHubOpen: "hub_home",
        hubTabColor1: "#181f22",
        hubTabColor2:"transparent",
        hubSelected: function (bt){
            var barColor = bt.barColor;
            var style = {background: ["-webkit-linear-gradient(", FPIsLandscape()?"right":"top", ", ",  barColor, " 0px, ",  barColor, " ", 2*gScaleX, "px, ",  this.hubTabColor1, " ", 3*gScaleX, "px, ",  this.hubTabColor2, " 95%)"].join("")};
            $(bt).css(style);
            $(bt).find(".buttonName").css("color", "#fff");
        },
        hubUnSelected: function (bt){
            var style = {background:"none", borderBottom: "none"};
            $(bt).css(style);
            $(bt).find(".buttonName").css("color", "#aaa");
        },
        hubTxt: function(){
            var style = {};
            var shadow = "0 0 4px #181f22", k = 6;
            while (k--){
                shadow += ", 0 0 4px #181f22";
            }
            style.textShadow = shadow;
            style.overflow = "visible";
            return style;
        },
        hubTxtColor:"#aaa",
        bgPatternStyle:{
            "background-image": "url('hub/"+gImagePath+"bg_pattern.png')"},
        hubTabPos:{
            LandscapeShort:[13,0,0,70,80,65,false],
            Landscape: [22,0,0,70,132,55,true],
            Portrait: [0,3,72,0,72,50, false]
        },
        fonts:{
            "light font": {name:"light font", fileName: "Va Ground Light", "added": false},
            "bold font": {name:"bold font", fileName: "Va Ground Bold", "added": false},
            // TODO: these 2 fonts are for Alphabetinis only and could get moved to hub_custom for that game
            "stud": {"name": "Stud", fileName:"Stud", "added": false}
        },
        signInStr: "",
        signInHelp:"",
        signInSpaceH:0,
        signInCancel:true,
        signEmailPlaceholder: "_EMAIL_ADDRESS",
        signAlert:i18n("_PLEASE_ENTER_EMAIL"),
        str4Pwd: {
            bCenter: false,
            string:  '_FORGOT_PASSWORD',
            id: "forgot",
            size: 14,
            color:"#148241",
            font: "bold font"
        },
        bAccountSetting:true,
        wall: "_WALL",
        bPowerBy: false,
        tabBar:{
            backgroundColor:"#d44d23",
            boxShadow: ["inset ", 1*gScaleX, "px ", 1*gScaleX, "px ", 2*gScaleX, "px #ea9a78"].join(""),
            border:[1*gScaleX,"px solid #c2451f"].join("")
        },
        profileTab:{
            width: 0,
            height: 0,
            borderLeft: 10*gScaleX+"px solid transparent",
            borderRight: 10*gScaleX+"px solid transparent",
            borderTop: 10*gScaleX+"px solid #c2451f",
            overflow:"visible"
        },
        profileTabDiv:{
            width: 0,
            height: 0,
            borderLeft: 9*gScaleX+"px solid transparent",
            borderRight: 9*gScaleX+"px solid transparent",
            borderTop: 9*gScaleX+"px solid #d44d23"
        },
        welMsgColor: "#eaa94d",
        exampleEmail: "abc@fingerprintplay.com",
        examplePhone: " 123-456-7890",
        bLangSelect:false,
        langSelectorBt1:"graybutton_full",
        langSelectorBt1Color:"white"

    };
    if (FPIsSid()){
        setting.background = gImagePath+"sid-pattern.png";
        setting.headerBg = gImagePath+"sid-header.png";
    }
    var partner = FPGetAppValue("partner");
    switch (partner)
    {
        case "astro":
            setting.partner = partner,
                setting.partnerName = "Astro Play",
                setting.landing =  "astro_startup",
                setting.addOnPath = "_"+partner,
                setting.boxRGBA = "rgba(200, 54, 54, 0)",
                setting.boxFrameRGBA = "rgba(225, 225, 225, 0)",
                setting.friendAvatarColor = "#F9B000",
                setting.parentAvatarColor = "#009DB5",
                setting.addAvatarColor = "#366ca8",
                setting.avatarBoxShadow = "0px 2px #D1D1D1",
                setting.linkColor =  "#79B828",
                setting.parentTagColor = "#009DB5",
                setting.txtColor = "#535353",
                setting.welcBubbleColor = "#EFE4F0",
                setting.friendMayKnowBg = "#D9F2FF",
                setting.invitationBg = "#FEF3D9",
                setting.pieColor = ["#A351A6", "#00A7DA", "#54CAFF", "#64C306"],
                setting.gameRecomColor = "#D9F2FF",
                setting.alertHeader = "#64C306",
                setting.alertBorder = "#929292",
                setting.hubBtColor = "#64c323",
                setting.hubSelected = function (bt){
                    var style = {background:"#a8a8a8"};
                    $(bt).css(style);
                    $(bt).find(".buttonName").css("color", "#ffffff");
                },
                setting.hubUnSelected = function (bt){
                    var style = {background:"none", borderBottom: "none"};
                    $(bt).css(style);
                    $(bt).find(".buttonName").css("color", "#535353");
                },
                setting.hubTxt = function(){
                    return "";
                },
                setting.hubTxtColor = "#3e3e3e",
                setting.hubBtSize = 49,
                setting.tabOnHubOpen = "hub_games_main",
                setting.hubTabColor1 = "grey",
                setting.hubTabColor2 = "grey",
                setting.bgPatternStyle = {
                    backgroundImage: "url('hub/"+gImagePath+"bg_pattern.png')",
                    backgroundRepeat: "repeat-x",
                    backgroundSize: "10px 100%"},
                setting.hubTabPos = {
                    LandscapeShort:[13,0,0,70,80,65,false],
                    Landscape: [22,0,0,70,135,55,true],
                    Portrait: [0,5,72,0,72,50, false]
                },
                setting.fonts = {
                    "light font": {name:"light font", fileName: "Arial", "added": false},
                    "bold font": {name:"bold font", fileName: "Arial Bold", "added": false},
                    // TODO: these 2 fonts are for Alphabetinis only and could get moved to hub_custom for that game
                    "stud": {"name": "Stud", fileName:"Stud", "added": false}
                },
                setting.signInStr = "_SIGN_IN_USING_YOUR_ASTRO",
                setting.signInHelp = i18n("_ASTRO_ID"),
                setting.signInSpaceH = 5,
                setting.signInCancel = false;
                setting.signEmailPlaceholder = "_ASTRO_ID",
                setting.signAlert = i18n("_PLEASE_ENTER_ASTRO", {partner:setting.partnerName}),
                setting.str4Pwd =  {
                    bCenter: true,
                    string:  '_PLEASE_VISIT_THE_ASTRO',
                    id: "visit",
                    size: 10,
                    color:"#ffffff",
                    font: "light font",
                    moreCSS: {backgroundColor:"#dadada", borderRadius:3*gScaleX+"px", paddingLeft: 5*gScaleX+"px", paddingRight: 5*gScaleX+"px", paddingTop: 2*gScaleX+"px", paddingBottom: 2*gScaleX+"px"}
                },
                setting.bAccountSetting = false,
                setting.wall = "_MESSAGES_2",
                setting.bPowerBy = true,
                setting.tabBar = {
                    backgroundColor:"#F9B000",
                    //boxShadow: ["inset ", 1*gScaleX, "px ", 1*gScaleX, "px ", 2*gScaleX, "px #ea9a78"].join(""),
                    borderRadius:[3*gScaleX,"px"].join(""),
                    borderBottom:[3*gScaleX,"px solid #eb9925"].join("")
                },
                setting.profileTab = {
                    width: 0,
                    height: 0,
                    borderLeft: 10*gScaleX+"px solid transparent",
                    borderRight: 10*gScaleX+"px solid transparent",
                    borderTop: 10*gScaleX+"px solid #eb9925",
                    overflow:"visible"
                },
                setting.profileTabDiv = {
                    width: 0,
                    height: 0,
                    borderLeft: 8*gScaleX+"px solid transparent",
                    borderRight: 8*gScaleX+"px solid transparent",
                    borderTop: 8*gScaleX+"px solid #F9B000"
                },
                setting.welMsgColor = "#954B97",
                setting.exampleEmail = "abcdfg@example.com",
                setting.examplePhone = "1-300-12-3456";
                setting.get_pp = function(callback){
                    callback("This is the Astro Privacy Policy.");
                };
                setting.get_tos = function(callback){
                        callback("This is the Astro Terms of Use.");
                };
                setting.bLangSelect = true;
                setting.langSelectorBt1 = "button-white";
                setting.langSelectorBt1Color = "#79B828";

            break;
        default:
            // partner name not seen in the list
            // correct partner name to be fingerprint
            FPSetAppValue("partner", "fingerprint");
            break;

    }

    // value need to fix after setting
    _CheckBoxButton.src = gImagePath+"checkbox";

    return setting;
}

function FPOpenAppStore(assets, wantFade)
{
    // Check to see if we can open an embedded store page. Requires iOS 6 and also requires the app to link to the StoreKit.framework.
    var bHasEmbeddedStore = FPGetAppValue("bHasEmbeddedStore");

    // TODO: we found that on some Unity games, the embedded app store is failing - probably view controller issue, so ugly workaround
    var exceptions = ["chutesandroots", "getrockypaid"];
    var len = exceptions.length;
    for (var i=0; i<len; i++) {
        if (exceptions[i] == FPGetGameId()) { // game ID of the host game is what matters
            bHasEmbeddedStore = false;
        }
    }

    // TODO: further, we found that device rotation is really breaking with the embedded app store / probably all view controllers
    // TODO: so completely disabling this for now
    bHasEmbeddedStore = false;
    
    var sdk_version = FPGetAppValue("sdk_version");
    var stage = GetGameStage(assets);
    if (gbAndroid && (stage === "new" || stage === "live")){
        var packageName = assets.androidPackage;
        var link = "https://play.google.com/store/apps/details?id=" + packageName;
        FPHelper.openURL(link);
    }else
    if (sdk_version > 32 && bHasEmbeddedStore == "true")
    {
        FPHelper.presentAppStoreForID(assets.appStoreId, wantFade);
    }
    else
    {
        FPHelper.openURL(assets.link);
    }
}
