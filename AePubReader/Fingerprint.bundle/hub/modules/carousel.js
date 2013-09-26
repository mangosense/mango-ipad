//
//  Copyright 2013 Fingerprint Digital, Inc. All rights reserved.
//

function FPCreateCarousel(p, x, y, w, h, count, startIndex, createItemFunc)
{
    var bMouseDown = false;
    var bBrokeThreshold = false;
    var mouseDownX = null;
    var mouseDownP = null;
    var mouseDownC = null;
    var mouseDownIndex = null;
    var animationStart = null;

    var a = div({parent: p, x: x, y: y, w: w, h: h, color: null});
    var r = w/2*gScaleX;
    var spacing = Math.PI*r/5;
    var len = (count-1)*spacing;
    var p = -spacing*startIndex;
    var minP = -Math.PI*r/2;
    var maxP = -minP;
    var threshold = 20;

    var items = [];
    for (var i=0; i<count; i++) {
        var d = createItemFunc(a, i);
        items.push(d);
        d.index = i;
        d.w = $(d).width();
        d.h = $(d).height();
        d.onmousedown = function()
        {
            mouseDownIndex = this.index;
        }
    }

    function doCallback(event, index)
    {
        if (a[event]) {
            a[event](index);
        }
    }

    function clamp(v, minV, maxV)
    {
        if (v < minV) v = minV;
        if (v > maxV) v = maxV;
        return v;
    }

    function mouseXtoC(mouseX)
    {
        var x = mouseX/r-1;
        x = clamp(x, -1, 1);
        var theta = Math.acos(x);
        var c = Math.PI*r/2 - theta*r;
        return c;
    }

    function positionItems()
    {
        for (var i=0; i<count; i++) {
            var itemP = p + i*spacing;
            var item = items[i];

            if (itemP < minP || itemP > maxP) {
                item.style.visibility = "hidden";
            } else {
                var theta = Math.PI/2 - itemP/r;
                var x = (w/2)*gScaleX + r*Math.cos(theta);
                var s = Math.sin(theta);
                var scale = 0.5 + 0.5 * s * s;
                var zIndex = Math.round(scale*100);

                item.style.visibility = "visible";
                item.style.zIndex = zIndex;
                item.style.opacity = scale;

                // x,y location was being set using left, top, and I was seeing crazy intermittent behavior where
                // sometimes the location didn't work at the item was left at 0,0
                // seems to be a manifestation/reincarnation of this webkit bug:
                // http://code.google.com/p/chromium/issues/detail?id=85506
                // work-around in this case is using translate instead.  I believe we're seeing this in some other
                // instances right now, like on the home tab...
                item.style.webkitTransform = "translate(" + (x-item.w/2) + "px, " + ((h/2)*gScaleY - item.h/2) + "px) scale(" + scale + ", " + scale + ")";
            }
        }
    }

    function animateTo(index)
    {
        index = clamp(index, 0, count-1);

        var targetP = -index*spacing;
        var startP = p;
        var distance = targetP - p;

        if (distance != 0) {
            var transitionTime = Math.abs(distance/r * 300);

            function animate()
            {
                if (animationStart) {
                    var now = (new Date()).getTime();
                    var elapsed = now - animationStart;
                    if (elapsed >= transitionTime) {
                        elapsed = transitionTime;
                        animationStart = null;
                    }

                    p = startP + distance * elapsed / transitionTime;
                    positionItems();
                    setTimeout(animate, 1);
                }
            }

            animationStart = (new Date()).getTime();
            animate();
        }
    }

    // initial positioning
    positionItems();

    a.onmousedown = function(e)
    {
        animationStart = null; // stop any animation in progress
        bMouseDown = true;
        bBrokeThreshold = false;
        mouseDownX = e.clientX;
        mouseDownP = p;
        mouseDownC = mouseXtoC(mouseDownX);
    }

    a.onmousemove = function(e)
    {
        if (bMouseDown) {
            var mouseX = e.clientX;

            if (!bBrokeThreshold) {
                var dx = Math.abs(mouseX-mouseDownX);
                if (dx > threshold) {
                    bBrokeThreshold = true;
                }
            }

            if (bBrokeThreshold) {
                var c = mouseXtoC(mouseX);
                var dc = c-mouseDownC;
                p = mouseDownP + dc;
                p = clamp(p, -(count-1)*spacing, 0);
                positionItems();
            }
        }
    }

    a.onmouseup = function(e)
    {
        if (bMouseDown) {
            var frontIndex = Math.round(-p/spacing);
            if (bBrokeThreshold) {
                // we dragged it - snap to closest one
                doCallback("on_change", frontIndex);
                animateTo(frontIndex);
            } else {
                if (mouseDownIndex == frontIndex) {
                    // we didn't drag and we'd clicked on front most item
                    doCallback("on_select", mouseDownIndex);
                    mouseDownIndex = null;
                } else if (mouseDownIndex !== null) {
                    // we didn't drag and we'd clicked on an item we'd like to animate to the front
                    doCallback("on_change", mouseDownIndex);
                    animateTo(mouseDownIndex);
                }
            }
            bMouseDown = false;
        }
    }

    // be sure we don't miss a mouseup because it's outside of our div
    $(document).mouseup(function(){
        a.onmouseup();
    });

    // return
    return a;
}
