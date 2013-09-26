//
//  Copyright 2011, 2012 Fingerprint Digital, Inc. All rights reserved.
//
/**
 * @file
 * Utility functions needed for the button class.
 * This file contains anything that is not related directly to button class.
 */
/** A global variable that trace which button is pressed.
 *  @var gMouseDown
 *  @type Object
 */

var gMouseDown = null;
/** A global variable that trace Last Button Event.
 *  @var gLastButtonEvent
 *  @type Number
 */
var gLastButtonEvent = 0; // TODO remove this workaround

/** Clear button state if gMouseDown true.
 *  It will be called when document mouseup event is triggered
 *  @fn ClearButton
 *  @see ShowButtonState
 */
function ClearButton()
{
	if (gMouseDown) {
		gMouseDown.bIn = false;
		ShowButtonState(gMouseDown, false);
		gMouseDown = null;
	}
}

$(document).mouseup(function(){
	ClearButton();
});

/** Return a new button div, and initialize
 *  the button and then load the assets needed to create the button, then call
 *  CreateButton2 when finished loading images
 *  @fn Object CreateButton( Json data)
 *  @tparam Json data including the settings for the button element.
 *  @treturn Object a button div.
 */
function CreateButton(data)
{
	data = cascade(_DefaultFont, data);

    var fragment = document.createDocumentFragment();
	var b = CreateDiv(fragment, 0, 0, 1, 1);
    b.fragment = fragment;
	b.bOn = false;
	b.bEnabled = true;
	b.data = data;
	b.bMouseDown = false;
    b.bHighlighted = false;

	// can't proceed with button until we have the images loaded so we know their natural width, height
	var images = [data.idle, data.over];
	if (data.image && data.image.src) {
		images.push(data.image.src);
	}
	if (data.imageBtn && data.imageBtn.src) {
		images.push(data.imageBtn.src);
	}
    if (data.noImage !== true)
    {
        LoadImagesSync(images, CreateButton2, b);
    }
    else
    {
        // css button without image
        CreateButton2(b);
    }
	// return the button
	return b;
}

/** Set the visibility of button b’s label, image and stateChangeFunc.
 *  @fn ShowButtonState(Object b, Boolean bOver)
 *  @tparam Object b a button div object.
 *  @tparam Boolean bOver.
 */
function ShowButtonState(b, bOver)
{
	function setVisible(o, bVisible)
	{
		if (bVisible) {
			$(o).show();
		} else {
			$(o).hide();
		}
	}

	setVisible(b.d1, !bOver);
	setVisible(b.d2, bOver);

    var tags = $(b).children("div");
    if (tags.length){
        var tag = tags[0];
        var transform = tag.style.webkitTransform;
        var translate = [" translate(-", 2*gScaleX,"px, ", 0*gScaleX,"px)"].join("");
        var scale = "scale(1.25)";
        if (bOver){
            transform = transform.replace(scale, "");
            transform = transform.replace(translate, "");
            transform += scale;
            transform += translate;
        }else{
            transform = transform.replace(scale, "");
            transform = transform.replace(translate, "");
        }
        tag.style.webkitTransform = transform;
    }

	if (b.l2) {
		setVisible(b.l1, !bOver);
		setVisible(b.l2, bOver);
	}

	if (b.stateChangeFunc) {
		b.stateChangeFunc(bOver);
	}
}

/** Called after image assets is loaded for the button.
 *  Add the mouse event handle, create labels and images, and in the meanwhile
 *  append the div to the parent element. if button
 *  size isn't specified, use the natural size of idle image.
 *  @fn Object CreateButton2(Object b, Array readyImages)
 *  @tparam Object b a button div.
 *  @tparam Array readyImages images used for creating the button.
 *  @treturn Object a new button element with the input css settings.
 */
function CreateButton2(b, readyImages)
{
	var data = b.data;


    // added to create gray css buttons
    if (data.noImage === true)
    {
        $(b).css("background", data.background);
        $(b).css("border", data.border);
        $(b).css("border-radius", "10px");


        // add hover effect for css buttons

        $(b).hover(function(){
            $(this).css("-webkit-transform", "scale(1.1)");
            $(this).css("-webkit-transition-timing-function", "ease-out");
            $(this).css("-webkit-transition-duration", "500ms");
            $(this).css("cursor", "pointer");
        }, function(){
            $(this).css("-webkit-transform", "scale(1.0)");
            $(this).css("-webkit-transition-timing-function", "ease-out");
            $(this).css("-webkit-transition-duration", "500ms");
            $(this).css("cursor", "pointer");
        });


    }

	// id defaults to string ida
	if (data.id == "") {
		data.id = data.string;
	}

	// id gets broken down into name and tag (name.tag), if . present
	b.stateChangeFunc = data.stateChangeFunc;
	b.name = data.id;
    b.metricName = data.metricName ? data.metricName : data.id;
	b.tag = null;
	var i = b.name.indexOf(".");
	if (i != -1) {
		b.tag = b.name.substring(i+1);
		b.name = b.name.substring(0, i);
	}

	// get cap sizes
	var leftCap = 0;
	var rightCap = 0;
	if (data.leftCap) {
		leftCap = data.leftCap;
	}
	if (data.rightCap) {
		rightCap = data.rightCap;
	}

	// get the images
    if (data.noImage !== true)
    {
	    var idle = readyImages[data.idle];
        var over = readyImages[data.over];
    }


	if (data.idleover == "same") {
		if (!data.idleoverRatio) {
			data.idleoverRatio = 0.85;
		}
	}

	// if button size isn't specified, it can be the natural size
	if (data.w  == null) {
		data.w = GetImageWidth(idle);
		if (data.idleover == "same") {
			data.w *= data.idleoverRatio;
		}
	}
	if (data.h  == null) {
		data.h = GetImageHeight(idle);
		if (data.idleover == "same") {
			data.h *= data.idleoverRatio;
	}
	}

	// the 2 button images don't have to be the same size
	// we will align their center points
	// outer button div must be able to contain the larger one

	// determine idle size
	var idleW = data.w;
	var idleH = data.h;
	if (idleW == null) {
		idleW = GetImageWidth(idle);
	}
	if (idleH == null) {
		idleH = GetImageHeight(idle);
	}

	// determine over size
    if (data.noImage !== true)
    {
        var scaleW = idleW/GetImageWidth(idle);
        var scaleH = idleH/GetImageHeight(idle);
        var overW = GetImageWidth(over) * scaleW;
        var overH = GetImageHeight(over) * scaleH;
    }
    else
    {
        // no scale for css buttons

        var scaleW = 1;
        var scaleH = 1;
        var overW = idleW;
        var overH = idleH;
    }

	if (data.idleover == "same") {
		overW = idleW / data.idleoverRatio;
		overH = idleH / data.idleoverRatio;
	}

	// if over size is bigger than idle size (typical), we need to use that as outer button
	// div size, but over-set to keep center aligned with idle state
	var dx = overW - idleW;
	if (dx > 0) {
		data.x -= dx/2;
		data.w += dx;
	}
	var dy = overH - idleH;
	if (dy > 0) {
		data.y -= dy/2;
		data.h += dy;
	}

    $(b).css("width", data.w);
   	$(b).css("height", data.h);
   	$(b).css("left", data.x);
   	$(b).css("top", data.y);

    var createImageFunc = (leftCap || rightCap) ? CreatePatchImage : CreateImage;
    if (typeof data.idle !== "undefined")
    {
        b.d1 = createImageFunc({parent: b, src: data.idle, x:(dx>0)?dx/2:0, y:(dy>0)?dy/2:0, w:idleW, h:idleH, leftCap:leftCap, rightCap:rightCap});
    }

    if (typeof data.over !== "undefined")
    {
        b.d2 = createImageFunc({parent: b, src: data.over, x:(dx<0)?-dx/2:0, y:(dy<0)?-dy/2:0, w:overW, h:overH, leftCap:leftCap, rightCap:rightCap});
    }

	if (data.imageBtn) {

        CreateTag(cascade({parent:b}, data.imageBtn));
	}

	$(b.d2).hide();

    if (b.bHighlighted) {
        HighlightButton(b, true);
    }

	b.bIn = false;
	b.bToggle = data.toggle;
	if (data.bOn) {
		b.bOn = true;
	}

	var ox = 0, oy = 0;
	if (data.ox != undefined) {
		ox = data.ox;
	}
    if (data.oy != undefined) {
        oy = data.oy;
    }
	if (data.string) {
		var textData = CopyObject(data);
		if (data.center == undefined) {
			textData.center = true;
		}
		textData.vCenter = true;
		textData.x = ox+((dx>0)?dx/2:0) +3;
        textData.y = oy+((dy>0)?dy/2:0) +3;
        textData.w = data.w*data.idleoverRatio-6-ox;
        textData.h = data.h*data.idleoverRatio-6-oy;
		textData.parent = b;
		b.l1 = CreateLabel(textData);

        // always use a second label so we can adjust text offset and font size
        if (!data.stringOn) {
            data.stringOn = data.string;
        }
	}

	if (data.stringOn) {
		var textData = CopyObject(data);
		if (data.center == undefined) {
			textData.center = true;
		}
		textData.vCenter = true;
        var tScale = overH / idleH;
        textData.size *= tScale;
        textData.x = ox * tScale+3;
        textData.y = oy * tScale+3;
        textData.w = data.w - 6 - ox * tScale;
        textData.h = data.h - 6 - oy * tScale;
		textData.parent = b;
		textData.string = textData.stringOn;
		if (data.colorOn) {
			textData.colorOn = data.colorOn;
		}
		b.l2 = CreateLabel(textData);
		$(b.l2).hide();
	}

	b.onmousedown = function(evt)
	{
		if (!this.bEnabled) {
			return;
		}

		b.bHighlightStage = null;

		ClearButton();
		gMouseDown = b;
		gMouseDown.xPos = evt.clientX;
		gMouseDown.yPos = evt.clientY;
        gMouseDown.time = evt.timeStamp;
		if (!evt) evt=window.event;
		this.bIn = true;
		if (!this.bHighlighted) {
			ShowButtonState(b, true);
		}
		return true;
	};

	b.onmouseup = function(evt)
	{
		// doesn't count if didn't click on it
		if (gMouseDown != b) {
			return;
		}
		if (this.data.timeSensitive)
		{
		    if (gbAndroid)
			{
			    if (evt.timeStamp - gMouseDown.time > 900)
		        {
        			return;
		        }
            }
            else if (evt.timeStamp - gMouseDown.time > 300)
            {
                // iOS code
                return;
            }
		}
		if (this.data["mouseXSensitivity"]) {
			var currXPos = evt.clientX;
			var mouseXDiff = Math.abs(gMouseDown.xPos - currXPos);
			if (mouseXDiff > this.data.mouseXSensitivity) {
				return;
			}
		}
		if (this.data["mouseYSensitivity"]) {
			var currYPos = evt.clientY;
			var mouseYDiff = Math.abs(gMouseDown.yPos - currYPos);
			if (mouseYDiff > this.data.mouseYSensitivity) {
				return;
			}
		}

		gMouseDown = null;

		if (!evt) evt=window.event;
		if (this.bIn) {

			if (this.bToggle) {
				// reverse states on click -before calling click handler, so bOn value will be correct
				this.bOn = !this.bOn;
				var swap = this.d1;
				this.d1 = this.d2;
				this.d2 = swap;
				var swap = this.l1;
				this.l1 = this.l2;
				this.l2 = swap;
			}

			var func = this.data.parent["on_" + this.name];
            if (!func && this.data.parent.buttonParent) {
                func = this.data.parent.buttonParent["on_" + this.name];
            }
            var now = (new Date()).getTime();

            /*
            var elapsed = now - gLastButtonEvent;
            if (elapsed < 1000) {
                func = null;
            }
            */
            
			if (func) {

				if (window["FPMetrics"]) {
					var extra = {};
					if (this.tag) {
						extra = {tag: this.tag};
					}

					var path = this.data.parent.path;
                    if (path === undefined && this.data.parent.buttonParent) {
                        path = this.data.parent.buttonParent.path;
                    }
					if (path == undefined) {
						if (gScreen) {
							path = gScreen.path;
						}
					}
                    var eventName = FPGetEventToken(path, this.metricName);
                    if (FPGetAppValue("bShowMetric")){
                        showMetricName(this, eventName);
                    }
					FPMetrics.metric(eventName, extra);
				}
                // if show metric set time out on button action in order to display eventName on top of screen
                var that = this;
                if (FPGetAppValue("bShowMetric")){
                    setTimeout(next, 2500);
                }else{
                    next();
                }
                function next(){
                    if (window["DoHubFieldWorkaroundButtonHandler"]) {
                        DoHubFieldWorkaroundButtonHandler(func, that.tag);
                    } else {
                        func(that.tag);
                    }

                    if (window.gTestHarness) {
                        window.gTestHarness.controller.pushButton(that.name+"."+that.tag);
                    }

                    gLastButtonEvent = now;
                }

			} else {
				console.log("screen does not have a " + this.name + " handler.");
			}
		}

		this.bIn = false;
		if (!this.bHighlighted) {
			ShowButtonState(this, false);
		}
	};

	b.onmousemove = function(evt)
	{
		if (!this.bEnabled) {
			return;
		}

		if (!evt) {
			evt=CopyObject(window.event);
			var offset = $(b).offset();
			evt.clientX -= offset.left;
			evt.clientY -= offset.top;

			var buttonWidth = $(b).width();
			var buttonHeight = $(b).height();

			this.bIn = (evt.clientX > 0 && evt.clientX < buttonWidth && evt.clientY > 0 && evt.clientY < buttonHeight);
		} else {
			var r = this.getBoundingClientRect();
			this.bIn = (evt.clientX > r.left && evt.clientX < (r.left + r.width) && evt.clientY > r.top && evt.clientY < (r.top + r.height));
		}

		if (gMouseDown == b && !this.bHighlighted) {
			ShowButtonState(b, this.bIn);
		}
	};

	b.onmouseover = function(evt)
	{
		this.onmousemove(evt);
	};

	b.onmouseout = function(evt)
	{
		this.onmousemove(evt);
	};

	if (b.bOn) {
		b.bOn = false;
		SetToggle(b, true);
	}

	if (data.image && data.image.src) {
		CreateImage(cascade({parent: b}, data.image));
	}

    if (window.gTestHarness) {
        function doAct()
        {
            gMouseDown = b;
            b.bIn = true;
            b.onmouseup({timeStamp:(new Date()).getMilliseconds(), clientX: 10, clientY: 10});
        }
        var useP = b.data.parent.buttonParent;
        if (!useP) {
            if (b.data.parent.path) {
                useP = b.data.parent;
            }
        }
        if (!useP) {
            useP = gScreen;
        }
        window.gTestHarness.controller.addButton(b.name+"."+ b.tag, useP, doAct);
    }

    b.data.parent.appendChild(b.fragment);
    b.fragment = undefined;

	return b;
}

/** Set bEnabled for b. If bOn is true, change the opacity
 *  of b from 0.85 to 1.0. If bOn is false, change it back to 0.85.
 *  @fn SetEnabled(Object b, Boolean bOn)
 *  @tparam Object b a button div.
 *  @tparam Boolean bOn.
 */
function SetEnabled(b, bOn)
{
	b.bEnabled = bOn;
	$(b).css("opacity", bOn ? 1.0 : 0.85);
}

/** Change button's bHighlighted property.
 *  @fn HighlightButton(Object b, Boolean bDown)
 *  @tparam Object b a button div.
 *  @tparam Boolean bDown.
 */
function HighlightButton(b, bDown)
{
    b.bHighlighted = bDown;
	ShowButtonState(b, bDown);
}
/** Show highlight animation of the input button.
 *  @fn FlashButton(Object b)
 *  @tparam Object b the given button div.
 */
function FlashButton(b)
{
	if (b == null) {
		return;
	}

	b.bHighlightStage = 0;
	show(b, true);
	function show(b, bDown) {
		ShowButtonState(b, bDown);
	}

	function next()
	{
		if (b.bHighlightStage != null) {
			b.bHighlightStage++;
			if (b.bHighlightStage < 7) {
				show(b, ((b.bHighlightStage % 2) == 1));
				setTimeout(next, 120);
			}
		}
	}
	setTimeout(next, 120);
}
/** Show highlight animation among the input buttons.
 *  @fn FlashButtons(Array btns)
 *  @tparam Array btns an array of button divs.
 */
function FlashButtons(btns)
{
	if (btns == null) {
		return;
	}
	if (btns.length == 1) {
		FlashButton(btns[0]);
		return;
	}

	btns.bHighlightStage = 0;
	for (var i = 0; i < btns.length; i++) {
		show(btns[i], true);
	}
	function show(b, bDown) {
		ShowButtonState(b, bDown);
	}

	function next()
	{
		if (btns.bHighlightStage != null) {
			btns.bHighlightStage++;
			if (btns.bHighlightStage < 7) {
				for (var i = 0; i < btns.length; i++) {
					show(btns[i], ((btns.bHighlightStage % 2) == 1));
				}
				setTimeout(next, 120);
			}
		}
	}
	setTimeout(next, 120);
}

/** Swap button b’s two labels and two images if b.bOn and bOn is not matching.
 *  @fn SetToggle(Object b, Boolean bOn)
 *  @tparam Object b a button div.
 *  @tparam Boolean bOn.
 */
function SetToggle(b, bOn)
{
	if (bOn == undefined) {
		bOn = false;
	}

	if (b.bOn != bOn) {
		b.bOn = !b.bOn;
		var swap = b.d1;
		b.d1 = b.d2;
		b.d2 = swap;
		var swap = b.l1;
		b.l1 = b.l2;
		b.l2 = swap;
		ShowButtonState(b, false);
	}
}
/** Add /remove glow to image button
 *  @fn SetGlow(Object b, String color)
 *  @tparam Object b a button div.
 *  @tparam String color if color is null remove the glow otherwise add glow the #RGB color eg: "#4e4e4e".
 */
function SetGlow(b, color, color2, radius)
{
    var img = $(b).find("img");
    var r = radius?radius:40*gScaleY;
    var c = color?color:"#ffffff";
    var c2 = color2?color2:"#ffffff";
    if (!b.oldBg){
        b.oldBg = $(b).css("background");
    }
    if (color){
        $(b).css("background", "-webkit-radial-gradient(circle, "+c+", "+c2+")");
        $(b).css("border-radius", r);
        $(b).css("filter", "alpha(opacity=30)");
    }else{
        $(b).css("background", b.oldBg);
    }
}
// Create Tag on top of image buttons
function CreateTag(data){
    var data = data;
    var parent = data.parent;
    var pData = parent.data;
    var ratio = pData.idleoverRatio;
    var p_w = pData.w;
    if (!data.font){
        data.font = "bold font";
    }

    var outerStyle = {left:p_w*(1-ratio)/2, top:p_w*(1-ratio)/2, width:p_w*ratio-2.5*gScaleX, height:p_w*ratio-2.5*gScaleX, overflow:"hidden", position:"relative"};

    var innerStyle = {};
    innerStyle.height = 15*gScaleX;
    innerStyle.width = 53*gScaleX;
    innerStyle.left = (outerStyle.width - innerStyle.width);
    innerStyle.top = Math.floor(Math.sqrt(2)*((innerStyle.width)/2))-innerStyle.height;
    innerStyle.color = "white";
    innerStyle.textAlign = "center";
    innerStyle.valign = "middle";
    innerStyle.fontSize = data.string === i18n("_COMING")?8*gScaleX:10*gScaleX;
    innerStyle.lineHeight= (innerStyle.height-innerStyle.fontSize)/(3*gScaleX);
    innerStyle.webkitTransform = "rotate(45deg)";
    innerStyle.webkitTransformOrigin = "100% 100%";
    innerStyle.fontFamily = fixFontFamily(data.font);
    innerStyle.boxShadow = "1px 1px 2px #4e4e4e, -1px -1px 2px #4e4e4e";
    innerStyle.position = "relative";
    innerStyle.background = ["-webkit-gradient(linear, left bottom, right top, color-stop(0, ", data.colors[0],"), color-stop(0.5, ", data.colors[1],"), color-stop(1, ", data.colors[1],"))"].join("");

    var outer = document.createElement("div");
    var d = document.createElement("div");
    d.innerText = data.string;
    $(outer).css(outerStyle);
    $(d).css(innerStyle);
    outer.appendChild(d);
    $(parent).append(outer);
}

// change the text on button
function SetTxt(bt, newTxt){
    var l1 = bt.l1,
        l2 = bt.l2;
    l1.text.innerHTML = newTxt;
    l2.text.innerHTML = newTxt;

}