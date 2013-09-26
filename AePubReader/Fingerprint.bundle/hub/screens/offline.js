// index.js
orientation("vertical");
end();

// logic.js
o = function(s, args) {

    init();

    function init()
    {
        var x = "images/offline.png";

        var h = window.gHubHeight ? window.gHubHeight : window.gFullHeight;
        var w = (args&&args.w)?args.w:gFullWidth;
        var p = div({parent: s, x: 0, y: 0, w: w, h: h, color: "#ffffff"});
        p.buttonParent = s;

        var d = div({parent:p, x:0, y:0, w:w, h:40});
        $(d).css("background-image", "url('hub/"+gImagePath+"gray-pattern.png')");
        label({parent:p, id: "title", string: i18n('_NO_CONNECTION'), center: true, vCenter:true, x: 0, y: 0, w: w, h: 40, size:15, color:"#4e4e4e"});
        if (!(args && args.bNoBack)) {
            button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "back", string: i18n('_BACK')});
            s.on_back = function()
            {
                s.close();
            };
        }
        image({parent: p, src: gImagePath+"offline", x: (w-200)/2, y: 50, w: 200});

        var msg;
        if (args && args.what) {
            msg = "You can " + args.what + " when you are connected to the Internet.";
        } else {
            msg = "Please try again when you are connected to the Internet.";
        }

        var margin = 20;
        label({parent: p, x: margin, y: 240, w: w-margin*2, color: "#444444", center: true, size: 18, string: msg});
    }



};

FPLaunchScreen(o);



