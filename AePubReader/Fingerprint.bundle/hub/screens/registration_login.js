// index.js
orientation("vertical");
var appSettings = getAppSetting();
background(appSettings.background, true);

//header bg
image({id:"headerBg", src: appSettings.headerBg, x:0, y:0, w:gFullWidth, h:45});

if(appSettings.partner === "fingerprint"){
    label({id: "title", string: i18n('_SIGN_IN_FINGERPRINT', {partner: appSettings.partnerName}), center: true, x: 35+(gFullWidth - 320)/2, y: 10, w: 240, h: 55, size:20});
}else{
    logo();
}

end();

//logic.js
o = function(s, args) {

    centerLogo(s);
    var id2str = {};
    if (appSettings.bLangSelect){

        id2str["title"] = {key:"_SIGN_IN_FINGERPRINT", val: {partner: appSettings.partnerName}};
        var cur_code = FPGetAppValue("language");

        var lang = langLookUp[cur_code];
        button({parent:s, src:gImagePath+"graybutton_half", idleover:"same", id:"language", x:gFullWidth-130, y:5, w:120, h:35, size: 14, string:lang+"&nbsp;&#9658;"});


        var lang_panel = FPLanguageSelector(s.parent, gFullWidth, gFullHeight, 200, 0, langLookUp, cur_code, true, true, onSelected);


        function onSelected(){
            if (cur_code !== FPGetAppValue("language")){
               // change label button and field
                changeTxt4All("label", onChangeLabel);
                changeTxt4All("button", onChangeBt);
                changeTxt4All("field", onChangeField);

                // change cur-code
                cur_code = FPGetAppValue("language");

                var lang = langLookUp[cur_code];
                var str = lang+"&nbsp;&#9658;";
                SetTxt(s.button["language"], str);

                // close
                closeLangPannel();

                // clean lang_panel
                $(lang_panel).remove();
                lang_panel = FPLanguageSelector(s.parent, gFullWidth, gFullHeight, 200, 0, langLookUp, cur_code, true, true, onSelected);

            }
        }

        function changeTxt4All(type, onChange){
            var keys = Object.keys(s[type]);
            var i = keys.length;
            while (i--){
                var key = keys[i];
                var strObj = id2str[key];
                if (strObj){
                    var str = i18n(strObj.key, strObj.val);
                    var item = s[type][key];
                    onChange(item, str);

                }
            }
        }

        function onChangeBt(item, str){
            SetTxt(item, str);
        }

        function onChangeLabel(item, str){
            item.text.innerText = str;
        }
        function onChangeField(item,str){
            item.value = str;
        }
    }
    init();

    function init()
    {

        function getTopCenter(p, p_height){
            var top = p_height*0.15;
            var obj = {};
            if (p){
                obj = {parent:p};
            }
            var d = div(obj, { x: 0, y:top, w: 320, h: p_height - top});
            setXCenter(d);
            return d;
        }
        var d = getTopCenter(s, gFullHeight);
        d.buttonParent = s;
        if (appSettings.signInStr){
            label({parent:d, id:"signInStr", x:5, y: 0, w:310, h: 40, center:true, size:15, string:i18n(appSettings.signInStr), color:appSettings.txtColor});
            id2str["signInStr"] =  {key:appSettings.signInStr};
        }


        //label({parent:d, id:"signInHelp", x:5, y: 0, w:310, center:true, size:13, string:appSettings.signInHelp, color:appSettings.linkColor});
        // frame
        var frame = div({parent:d, id:"frame", x: 20, w: 280, h:212, color: appSettings.boxRGBA});
        frame.buttonParent = s;
        field({parent:frame, x: 20, y: 20, w: 240, h: 30, size: 15, id: "email", placeholder: i18n(appSettings.signEmailPlaceholder), email: true,
            field: "textbox.png", icon:{src: gImagePath+"icon_email", w:14, h:12, y:8 }, setTransparent: true, ox: 40});
        id2str["email"] = {key:appSettings.signEmailPlaceholder};
        field({parent:frame, x: 20, y: 63+appSettings.signInSpaceH, w: 240, h: 30, size: 15, id: "password", placeholder: i18n("_PASSWORD"), password:true, maxLength: 16,
            field: "textbox.png", icon:{src: gImagePath+"icon_password", w:14, h:12, y:8 }, setTransparent: true, ox: 40});
        id2str["password"] = {key:"_PASSWORD"};
        var t = { src: gImagePath+"password_hide", y: 65+appSettings.signInSpaceH, size: 12, font: "impact", string: "", stringOn: "", toggle: true};
        button(t, {parent:frame, id:"show", x: 196, w: 50, h:25});

        if (appSettings.signInCancel){
            button({parent:frame, src:gImagePath+"greenbutton_half", idleover:"same", id: "go", x: 145, y:115, w:120, h:40, string: i18n("_SIGN_IN"), size: 18});
            id2str["go"] = {key:"_SIGN_IN"};
            button({parent:frame, src:gImagePath+"graybutton_half", idleover:"same", id: "cancel", x: 18, y:115, w:120, h:40, string: i18n("_CANCEL"), size: 18});
            id2str["cancel"] = {key:"_CANCEL"};
            s.on_cancel = function()
            {
                runScreenCloser(s, "left");
                runScreen(gRoot, "select_play_options", "right");
            }
        }else{
            button({parent:frame, src:gImagePath+"greenbutton_full", idleover:"same", id: "go", x: 18, y:115, w:245, h:40, string: i18n("_SIGN_IN"), size: 18});
            id2str["go"] = {key:"_SIGN_IN"};
        }

        $(s.div["frame"]).css("border", "1px solid "+appSettings.boxFrameRGBA);

        var str4Pwd = appSettings.str4Pwd;
        var l = label({parent: frame, id:str4Pwd.id, size: str4Pwd.size, x: 18, y: 155+appSettings.signInSpaceH, w: 236, h: 45, center:str4Pwd.bCenter, vCenter: true, string: i18n(str4Pwd.string), color:str4Pwd.color, font:str4Pwd.font});
        id2str[str4Pwd.id] = {key:appSettings.str4Pwd.string};
        if (str4Pwd.moreCSS){
            $(l).css(str4Pwd.moreCSS);
        }

        if (appSettings.bPowerBy){

            var powBy = div({parent:d, x: 0, w: 320, h:25});
            var title = label({parent:powBy, id: "powerBy", x: 0, y: 0, w: 320, h: 25, size: 12, string: i18n("_POWERED_BY"), color: "#dadada"});
            id2str["powerBy"] = {key:"_POWERED_BY"};

            //logo
            var logo = image({parent:title, id:"logo", src: gImagePath+"fingerprintlogolight", x:3, y:0, h:14});
            $(title).css({textAlign:"center", position:"absolute"});
            $(title.text).css({display: "inline-table", width:"auto", position:"relative", fontSize:0.68*gScaleX+"em", marginTop: 50%-14*gScaleX/2, height:14*gScaleX });
            $(logo).css({display: "inline-table", position:"relative", marginTop: 50%-14*gScaleX/2});
        }



        setPositionRelative(d);

        if (s.label["forgot"]){
            s.label["forgot"].onmousedown = function()
            {
                runScreenCloser(s, "right");
                runScreen(gRoot, "registration_forgot_pwd", "left", {email:s.field["email"].value});

            }
        }

    };



    s.on_go = function()
    {
        $("*:focus").blur();// set blur, in case is offline, alert box shows up
        if (s.field["email"].bEmpty) {
            SetField(s.field["password"], "");
            DoAlert(i18n("_LOGIN"), appSettings.signAlert);
        } else if (appSettings.partner !== "astro" && !validateEmail(s.field["email"].value)){
            SetField(s.field["password"], "");
            DoAlert(i18n("_INVALID_EMAIL"), i18n("_INVALID_EMAIL_FORMAT"));
        } else if (s.field["password"].bEmpty) {
            DoAlert(i18n("_LOGIN"), i18n("_PLEASE_ENTER_PASSWORD"));
        } else {
            // make go button disable
            SetEnabled(s.button["go"], false);
            // disable all the button while waiting response from server
            $( s ).attr({ disabled: true });

            var email = s.field["email"].value;
            var password = s.field["password"].value;

            if (appSettings.partner === "astro"){
                FPAstroLogin(email, password, onAccountLogin);
            }else{
                FPAccountLogin(email, password, onAccountLogin);
            }

        }
        function onAccountLogin(r)
        {
            if (r.bSuccess === undefined)
            {
                SetField(s.field["password"], "");
                DoAlert(i18n("_ERROR"), i18n("_UNABLE_REACH_SERVER" , {partner: appSettings.partnerName}));
                SetEnabled(s.button["go"], true);
            }
            else if ( !r.bSuccess )
            {
                SetField(s.field["password"], "");
                DoAlert(i18n("_INVALID_LOGIN"), i18n("_EMAIL_PASSWORD_NOT_MATCH"));
                SetEnabled(s.button["go"], true);
            }
            else if (r.bNewAccount){
                if (appSettings.partner === "astro" && !r.bHasKidsOrFamily){
                    DoAlert(appSettings.partnerName, i18n("_PLEASE_SUBSCRIBE_TO"), nextPickAvatar);
                }else{
                    nextPickAvatar();
                }




            }else
            {
                if (appSettings.partner === "astro" && !r.bHasKidsOrFamily){
                    DoAlert(appSettings.partnerName, i18n("_PLEASE_SUBSCRIBE_TO"), nextClose);
                }else{
                    nextClose();
                }

            }
        }
        function nextPickAvatar(){
            // go to pick avatar and name generator
            runScreen(gRoot, "pick_avatar", "left", {flow:"bPartnerNewAcc",bGoName: true, bBack:false});
        }
        function nextClose(){
            s.close();
        }
    }

    s.on_show = function()
    {
        s.button["show"].checked = s.button["show"].checked !== true;
        SetPasswordMode(s.field["password"], s.button["show"].checked !== true);
    };

    s.onmouseup = function(){

        if (parseInt($(s).css("left")) < 0 && appSettings.bLangSelect){
            closeLangPannel();
        }
    }
    s.on_language = function(){
        $(s).css({left: -200*gScaleX, webkitTransition:"left 0.1s" });
        $(lang_panel).css({left: (gFullWidth-200)*gScaleX, webkitTransition:"left 0.1s" });


    };
    function closeLangPannel(){
        $(s).css({left: 0, webkitTransition:"left 0.1s" });
        $(lang_panel).css({left: (gFullWidth)*gScaleX, webkitTransition:"left 0.1s" });

    }
};
FPLaunchScreen(o);

