//
//  Copyright 2013 Fingerprint Digital, Inc. All rights reserved.
//

gOnDevice = true;

function start(root)
{
    div({parent: root, x: 0, y: 0, w: 320, h: 640, color: "#d0ffd0"});

    label({parent: root, x: 10, y: 10, string: "Add this user's devices to QA devices", size: 18, color: "#000000"});
    var f = field({parent: root, placeholder: "Fingerprint Username", string: "", x: 10, y: 40, w: 300, h: 30});
    button(_GreenButton, {parent: root, string: "OK", x: 10, y: 80, w: 120, h: 30, id: "ok"});

    root.on_ok = function()
    {
        var name = GetField(f);
        function onDone(r)
        {
            alert("result: " + r.success);
        }
        FPRequest("GetUpdates", {command: "setQAEnabled", name: name}, onDone);
    }
}
