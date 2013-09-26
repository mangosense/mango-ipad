//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

function YourTurnHeader(s, n)
{
    var b = div({parent: s, x: 0, y: 0, w: 320, h: gFullHeight, color: "#c0c0ff"});
    var d = div({parent: b, x: 5, y: 5, w: 310, h: gFullHeight-10, color: "#ffffff"});
    var b = div({parent: d, x: 0, y: 0, w: 310, h: 36, color: "#d0d0ff"});
    label({parent: d, x: 5, y: 5, w: 300, center: true, size: 18, string: n, color: "#000000"});
    return d;
}