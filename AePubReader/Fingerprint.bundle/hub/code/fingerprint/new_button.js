/** A global variable that trace which button is pressed.
 *  @var gMouseDown
 *  @type Object
 */

var gMouseDown = null;

/** Clear button state if gMouseDown true.
 *  It will be called when document mouseup event is triggered
 *  @fn ClearButton
 *  @see ShowButtonState
 */
function ClearButton()
{
    if (gMouseDown) {
        //gMouseDown.bIn = false;
        //ShowButtonState(gMouseDown, false);
        gMouseDown = null;
    }
}

$(document).mouseup(function(){
    ClearButton();
});

function buttonEvent(elem, data){
    $(elem).bind("mousedown touchstart", OnTouchStart);
    $(elem).bind("mouseleave touchleave", function(e){OnTouchLeave(e, data, this)});
    $(elem).bind("mouseup touchend", function(e){OnTouchEnd(e, data, this)});
}

function OnTouchStart(e){
    var target = e.target,
        className = target.className,
        w = parseInt(target.style.width),
        h = parseInt(target.style.height),
        x = parseInt(target.style.left),
        y = parseInt(target.style.top),
        bg = target.style.background,
        bOn = target.style.backgroundSize === "100%, 0%",
        re = /rgb\([0-9,\s]+\)/g;

    if (className.indexOf("toggle")>-1){
        SetToggle(target, bOn);
    } else if (className.indexOf("imageBt")>-1 || className.indexOf("imageBtText")>-1){
        if (className.indexOf("imageBtText")>-1)
        {
            var obj = {target: $(target).parent()[0]};
            OnTouchStart(obj);
        }else{
            target.style.display = "none";
            target.style.width= w*1.1 + "px";
            target.style.height= h*1.1 + "px";
            target.style.top = (y - h*0.05) + "px";
            target.style.left = x - w*0.05 + "px";

            if (className.indexOf("text")>-1){
                var child = $(target).children(),
                    size = parseInt(child.css("fontSize")),
                    str_top = parseInt(child.css("top")),
                    str_left = parseInt(child.css("left"));
                child.css("display", "none");
                child.css("fontSize",  size*1.1 + "px");
                child.css("left",   w*0.05 + str_left + "px");
                child.css("top",   h*0.05 + str_top +"px");
                child.css("display", "inline-block");
            }
            target.style.display = "inline-block";
        }

    }else if (className === "textBt"){
        var colors = bg.match(re);
        if (colors && colors.length > 1){
            target.style.background = ["-webkit-gradient(linear, left top, left bottom, color-stop(0.05, ", colors[1],"), color-stop(1, ", colors[0],"))"].join("");
        }
    }
    className = null;

}
function OnTouchLeave(e, data, that){
    var target = e.target;
    if (!data.bgColor){
        that.style.display = "none";
        that.style.width= data.w + "px";
        that.style.height= data.h + "px";
        that.style.top = data.y + "px";
        that.style.left = data.x + "px";
        if (data.string){
            var child = $(that).children();
            child.css("fontSize",  data.size + "px");
            child.css("left",   (data.ox?data.ox:0)+ "px");
            child.css("top",   (data.h-data.size-4)/2 + (data.oy?data.oy:0) +"px");
        }
        that.style.display = "inline-block";
    }else {
        target.style.background = ["-webkit-gradient(linear, left top, left bottom, color-stop(0.05, ", shadeColor(data.bgColor, 7),"), color-stop(1, ", shadeColor(data.bgColor, -7),"))"].join("");
    }
}
function OnTouchEnd(e, data, that){
    OnTouchLeave(e, data, that);

    var name = data.id.split("."),
        btName = name[0],
        tag = name[1];
    var func = data.parent["on_" + btName];
    if (!func && data.parent.buttonParent) {
        func = data.parent.buttonParent["on_" + btName];
    }
    if (func) {

        if (window["FPMetrics"]) {
            var extra = {};
            if (tag) {
                extra = {tag: tag};
            }

            var path = data.parent.path;
            if (path === undefined && data.parent.buttonParent) {
                path = data.parent.buttonParent.path;
            }
            if (path == undefined) {
                if (gScreen) {
                    path = gScreen.path;
                }
            }
            FPMetrics.metric("screen_" + path + ":button_" + btName, extra);
        }

        if (window["DoHubFieldWorkaroundButtonHandler"]) {
            DoHubFieldWorkaroundButtonHandler(func, tag);
        } else {
            func(tag);
        }
        if (window.gTestHarness) {
            window.gTestHarness.controller.pushButton(data.id);
        }

    } else {
        console.log("screen does not have a " + btName + " handler.");
    }

}
// create buttons
function CreateNewButton(data){
    var b;
    if (data.toggle !== undefined && data.idle == null){
        var src = data.src.replace(".png", "");
        data.over = GetImageInfo([src, "_over", ".png"].join("")).src;
        data.src = GetImageInfo([src, "_idle", ".png"].join("")).src;
        data.idle = data.src;
    }
    var image = new Image();
    if (data.src)
    {
        image.src = data.src;
    }
    if (data.idle)
    {
        image.src = data.idle;
    }
    if (data.over)
    {
        image.over = data.over;
    }
    if (data.src){
        var color = getColorByName(data.src);
        if (color === ""){
            b = CreateImageButton(data);
        }else {
            data.bgColor = color;
            b = CreateTextButton(data);
        }
    }else{
        b = CreateImageButton(data);
    }

    data.parent.appendChild(b);
    b.className.replace("hidden", "shown");
    b.bOn = false;
    buttonEvent(b, data);

    if (window.gTestHarness) {
        function doAct()
        {
            gMouseDown = b;
            $(b).mouseup();
        }
        var useP = data.parent.buttonParent;
        if (!useP) {
            if (data.parent.path) {
                useP = data.parent;
            }
        }
        if (!useP) {
            useP = gScreen;
        }
        window.gTestHarness.controller.addButton(data.id, useP, doAct);
    }


    return b;
}

// button with src using scale for click effect
// button without src but have text using transparent mask to create all size for button
// and add text label
function CreateImageButton(data){
    data = cascade(_DefaultFont, data);
    var bt, bt_style,
        src = (data.src||data.idle);
    bt = document.createElement('div');
    if (data.string){
        var text_style =["position: absolute",
            "; color:",data.color ,
            "; font-family:",fixFontFamily(data.font) ,
            "; font-size:",data.size,"px " ,
            "; width:",  data.w, "px",
            "; height:", data.h, "px",
            "; left:", (data.ox?data.ox:0), "px",
            "; top:",(data.h-data.size-4)/2 + (data.oy?data.oy:0), "px ",
            "; text-align: center;"].join("");

        bt.innerHTML = ["<div class = 'imageBtText' style='",text_style, "'>",data.string, "</div>"].join("");
    }

    var background_image = ["url(", src, ")"].join(""),
        background_size = "100% 100%",
        background_position = "0% 0%";
    if (data.imageBtn){
        background_image = ["url(", data.imageBtn.src, "), ", background_image].join("");
        background_size = [100*data.imageBtn.w/data.w, "% ", 100*data.imageBtn.h/data.h, "%, ", background_size].join("");
        background_position = [100*data.imageBtn.x*2.2/data.w, "% ", 100*data.imageBtn.y/data.h, "%, ", background_position].join("");
    }else if (data.over && data.idleover !=="same"){
        background_image = [background_image, ", url(", data.over, ") " ].join("");
        background_size = [background_size,", 0% 0%"].join("");
        background_position = [background_position, ", 0% 0%"].join("");
    }
    bt_style = ["position: absolute",
        "; background-image:", background_image,
        "; background-size:",  background_size,
        "; background-position:", background_position,
        "; background-repeat: no-repeat, no-repeat",
        "; background-origin:content-box",
        "; width:",  data.w, "px",
        "; height:", data.h, "px",
        "; left:", data.x, "px",
        "; top:", data.y, "px"].join("");
    bt.style.cssText = bt_style;
    bt.className = "imageBt";
    if (data.toggle !== undefined){
        bt.className += " toggle";
    }
    if (data.string){
        bt.className += " text";
    }
    return bt;
}
function CreateTextButton(data){
    var color = data.bgColor;
    data = cascade(_DefaultFont, data);
    var bt = document.createElement('div');
    bt.innerText = data.string;
    var bt_style = ["box-shadow: inset 1px 1px 2px ",shadeColor(color, 20), ", inset 0 -1px 2px ",shadeColor(color, -10) ,
        "; background-color:",color ,
        "; background:-webkit-gradient(linear, left top, left bottom, color-stop(0.05, ", shadeColor(color, 7),"), color-stop(1, ", shadeColor(color, -7),"))",
        "; border:", 1.5*gScaleX, "px solid ",shadeColor(color, -15) ,
        "; display:inline-block" ,
        "; color:",data.color ,
        "; font-family:",fixFontFamily(data.font) ,
        "; font-size:",data.size,"px" ,
        "; left:",data.x + "px",
        "; top:",data.y + "px",
        "; position:absolute",
        "; padding: ", (data.h-data.size-4)/2+"px 0px",
        "; text-align: center",
        //"; text-shadow:1px 1px 5px #000000",
        "; width:", (data.w - 2), "px;"
    ].join("");
    bt.style.cssText = bt_style;
    bt.className = "textBt";
    return bt;
}
function shadeColor(color, percent) {
    var color = color?color:"#ffffff",
        percent = percent?percent:100,
        num = parseInt(color.slice(1),16),
        amt = Math.round(2.55 * percent),
        R = (num >> 16) + amt,
        B = (num >> 8 & 0x00FF) + amt,
        G = (num & 0x0000FF) + amt;
    return "#" + (0x1000000 + (R<255?R<1?0:R:255)*0x10000 + (B<255?B<1?0:B:255)*0x100 + (G<255?G<1?0:G:255)).toString(16).slice(1);
}
function SetToggle(elem, bOn){
    var background_size;
    if (bOn){
        background_size = bOn?"0% 0%, 100% 100%":"100% 100%, 0%";
        elem.bOn = bOn;
    }else{
        // switch background
        var oldbackground_size = elem.style.backgroundSize;
        if (oldbackground_size === "100% 100%, 0%"){
            background_size = "0% 0%, 100% 100%";
            elem.bOn = true;
        }else{
            background_size = "100% 100%, 0%";
            elem.bOn = false;
        }
    }

    elem.style.backgroundSize = background_size;
}
function GetBOn(){
    var background_size = this.style.backgroundSize;
    return background_size === "100% 100%, 0%"?true:false;
}
function SetEnabled(b, bOn)
{
    //b.bEnabled = bOn;
}
function ChangeImageSrc(elem, src){
    var srcData = {src:src};
    FixImagePath(srcData);
    elem.src = srcData.src;
}
function getColorByName(color){
    if (color.indexOf("green")>0 && color.indexOf("greenstreet")<0){
        return "#127d34";
    }else if (color.indexOf("blue")>0){
        return "#3883c2";
    }else if (color.indexOf("gray")>0 && color.indexOf("point")<0){
        return "#64646c";
    }else if (color.indexOf("red")>0){
        return "#d43d35";
    }else if (color.indexOf("orange")>0){
        return "#d2341d";
    }else{
        return "";
    }
}
function widthOfStr(str, font, size) {
    if (!gScreen.hiddenTextDiv){
        gScreen.hiddenTextDiv = $('<div>' + str + '</div>').css({
            'position': 'absolute',
            'float': 'left',
            'white-space': 'nowrap',
            'visibility': 'hidden',
            'font-family': font,
            'font-size':size + "px"

        }).appendTo($('body'));
    }else{
        gScreen.hiddenTextDiv.style.fontFamily = font;
        gScreen.hiddenTextDiv.style.fontSize = size + "px";
        gScreen.hiddenTextDiv.innerText = str;
    }
    return gScreen.hiddenTextDiv.style.width;
}

// todo: to support or change
function SetToggle(){

}
function FlashButton(){

}