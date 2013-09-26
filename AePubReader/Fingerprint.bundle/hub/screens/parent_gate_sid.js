// index.js
orientation("vertical");
end();

// logic.js
o = function(s, args) {

    var o = GetImageInfo("images/parent_gate.png");
    image({parent: s, src: gImagePath+"parent_gate", x: (gFullWidth - o.w)/2, y: (gFullHeight - o.h)/2, w: o.w, h: o.h});
    var clickme = div({parent: s, x: 0, y: 0, w: gFullWidth, h: gFullHeight});
    var downtime;

    var bDone = false;
    var elapsedLabel;

    if (FPShowParentGateTimer()) {
        function update()
        {
            if (!bDone) {
                setTimeout(update, 100);
            }
            if (elapsedLabel) {
                $(elapsedLabel).remove();
            }

            var elapsed = (new Date()).getTime() - downtime;
            if (elapsed) {
                elapsed = Math.round(elapsed/100)/10;
            } else {
                elapsed = "(0)";
            }
            elapsedLabel = label({parent: s, x: 90, y: 106, w: gFullWidth, size: 9, color: "#202020", string: i18n('_TIMER')+elapsed});
        }
        setTimeout(update, 100);
    }

    clickme.onmousedown = function()
    {
        if (!downtime) { // protect against multitouch
            downtime = (new Date()).getTime();
        }
    }

    clickme.onmouseup = function()
    {
        if (downtime) {
            var elapsed = (new Date()).getTime() - downtime;
            args.callback(elapsed >= 5000);
            bDone = true;
            s.close();
        }
    }
};

FPLaunchScreen(o);
