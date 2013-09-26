// index.js
orientation("vertical");
//header bg
div({id:"headerBg", x:0, y:0, w:320, h:45});
label({id:"title", string: i18n('_CUSTOM_TEST_SERVER'), x:0, y:11, w:320, h:30, size:20, center:true, color:"#4e4e4e"});
field({id: "custom_server", x: 20, y:70, w:220, h:35, placeholder: "", setTransparent: true, size: 18, field: "../hub/images/textbox.png"});
button({src:gImagePath+"greenbutton_half", idleover:"same", x: 250, y:65, w:60, h:40, size: 18, id: "go", string: i18n('_OK')});
button({src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 8, size: 12, id: "back", string: i18n('_BACK')});
end();


o = function(s, onOK) {
    init();

    function init()
    {
        var custom_server = FPGetAppValue("custom_server");
        if (custom_server == null || custom_server.length == 0) {
            custom_server = "http://127.0.0.1:8080";
        }
        SetField(s.field["custom_server"], custom_server);

        $(s).css("background-color", "white");
        addBackgroundImage($(s.div["headerBg"]), "gray-pattern.png");
    }

    function close()
    {
        s.close();
    }

    s.on_go = function()
    {
        var custom_server = GetField(s.field["custom_server"]);
        FPSetAppValue("custom_server", custom_server);
        close();
        onOK(custom_server);
    }

    s.on_back = function()
    {
        close();
    }
};

FPLaunchScreen(o);





