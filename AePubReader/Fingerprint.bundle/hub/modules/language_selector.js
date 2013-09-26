function FPLanguageSelector(p, p_w, p_h, d_w, oy, langLookUp, code, offScreen, bTitle, onClose){
    var appSettings = getAppSetting();
    var oldPos = {};
    var d = div({parent:p, x:offScreen?p_w:0, y:oy, w:d_w, h:p_h});
    d.id = "languageSelector";
    $(d).css({backgroundColor:"#dadada"});
    var d_inner = div({parent:d, x:0, y:0, w:d_w, h:p_h});
    var lang_codes = Object.keys(gStringTable);

    var len = lang_codes.length;
    var oy = 5;

    if (bTitle){
        $(d_inner).css({height:(oy+len*45)*gScaleY});
        label({parent:d_inner, string:i18n("_CHOOSE_YOUR_LANGUAGE"), size: 16, color:appSettings.txtColor, x: 3, y:0, w:d_w-6, h:45, center:true, vCenter:true});
        oy = 45;
    }
    var j = 0, i = 0;;
    while(i<len){
        var lang = langLookUp[lang_codes[i]];
        if (lang){
            var btImg = code===lang_codes[i]?"greenbutton_half":appSettings.langSelectorBt1;
            var btColor = code===lang_codes[i]?"#ffffff":appSettings.langSelectorBt1Color;
            button({parent:d_inner, id:"langCode."+i, src:gImagePath+btImg, idleover:"same", string:lang, x: (d_w-170)/2, y:45*j + oy, w:170, h:40, size: 14, color:btColor, center:true});
            j++;
        }
        i++

    }

    new iScroll("languageSelector", {vScroll: true, bounce: false,
        onScrollStart:
            function(e){
                if (window["FPNative"]){
                    oldPos = {x:e.touches[0].clientX, y:e.touches[0].clientY};
                }else{
                    oldPos = {x:e.clientX, y:e.clientY};
                }
            },
        onScrollMove:
            function(e){
                var newPos;
                if (window["FPNative"]){
                    newPos = {x:e.touches[0].clientX, y:e.touches[0].clientY};
                }else{
                    newPos = {x:e.clientX, y:e.clientY};
                }
                if (Math.abs(newPos.x-oldPos.x)>5*gScaleX || Math.abs(newPos.y-oldPos.y)>5*gScaleY){
                    var i = lang_codes.length;
                    while (i--){
                        SetEnabled(d.button["langCode."+i], false);
                    }
                }
            }});

    d_inner.on_langCode = function(i){
        var i = parseInt(i);
        // set language
        FPSetAppValue("language", lang_codes[i]);

        // reload
        //FPUpdater.refresh();
        onClose();

    }

    return d;
}