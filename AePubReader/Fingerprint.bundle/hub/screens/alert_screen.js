// index.js
orientation("vertical");
end();




// logic.js
// the input, title and msg is a must have, others are optional.
// {cancel: "cancel", ok: "ok", title: "Alert", msg: "Please select.", callback: fn }
o = function(s, args) {

    init();

    function init()
    {
        var appSettings = getAppSetting();
        var centerPanel = div({parent:s, x:0, y:0, w:300});
        setCenter(centerPanel, 250);

        var d = div({parent:centerPanel, id: "frame", x: 0, y:0, w: 298, h:200, color: "#ffffff"});
        $(d).css("border", "1px solid #c2bebe");
        d = div({parent:centerPanel, id:"alertFrame", x: 0, y: 0, w: 298, h:45, color: appSettings.alertHeader});
        $(d).css("border", "1px solid " + appSettings.alertBorder);


        label({parent: centerPanel, x: 0, y: 12, size: 16, w: 300, string: args.title, center: true });

        if (args.types === "field")
        {
            $(d).css("height", "200");

            field({parent: centerPanel, id: "msg", x: 20, y: 48, w: 260, h: 100, size: 16, multiline: true, placeholder: args.msg, maxLength: 100, font: "light font"});

        }
        else{
            label({parent: centerPanel, x: 20, y: 68, w: 260, h: 67, size: 16, string: args.msg, center: true, font: "light font", color: "#000000"});
        }



        if (args.cancel && args.ok) {
            button({parent: centerPanel, src:gImagePath+"graybutton_half", idleover:"same", id: "cancel", string: args.cancel, x: 24, y: 130, w:120, h:40, size: 16});
            button({parent: centerPanel, src:gImagePath+"greenbutton_half", idleover:"same", id: "ok", string: args.ok, x: 151, y: 130, w:120, h:40, size: 16});
            centerPanel.on_cancel = function()
            {
                if (s.field["msg"])
                {
                    console.log(GetField(s.field["msg"]));
                }
                s.close();
                if (args.callback) {
                    args.callback(false);
                }
            };

        } else {
            button({parent: centerPanel, src:gImagePath+"graybutton_half", idleover:"same",id: "ok", string: args.ok, x: 88, y: 130, w:120, h:40, size: 16});
        }
        centerPanel.on_ok = function()
        {
            s.on_ok();
        };


    }

    s.on_ok = function()
    {

        if (s.field["msg"])
        {

            console.log(GetField(s.field["msg"]));
        }
        s.close();
        if (args.callback) {
            args.callback(true);
        }
    };


};

FPLaunchScreen(o);



