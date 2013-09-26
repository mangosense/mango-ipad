//
//  Copyright 2011, 2012 Fingerprint Digital, Inc. All rights reserved.
//
/**
 * @file
 * Utility functions needed for the field class.
 * This file contains anything that is not related directly to field class.
 */
/** Return true if the navigator appName is Microsoft Internet Explorer.
 *  @fn IsInternetExplorer
 */
function IsInternetExplorer()
{
	return (navigator.appName == 'Microsoft Internet Explorer');
}

function SetPasswordMode(f, bPasswordOn)
{
    if (bPasswordOn) {
        if (gbAndroid) {
            $(f).css("-webkit-text-security", "disc");
        } else {
            f.type = "password";
        }
    } else {
        if (gbAndroid) {
            $(f).css("-webkit-text-security", "none");
        } else {
            f.type = "text";
        }
    }
}

/** Return a new input field div. If it is viewing in IE, handle password input
 * field specially before calling CreateFieldCore.
 *  @fn Object CreateField( Json data)
 *  @tparam Json data including the settings for the field element.
 *  @treturn Object a field div.
 *  @see CreateFieldCore
 */
function CreateField(data)
{
	if (IsInternetExplorer() && data.password) {
		// for Password field in IE, we need special logic for placeholder text
		var data1 = CopyObject(data);
		data1.placeholder = null;
		var result = CreateFieldCore(data1);
		result.tabIndex = -1;

		var data2 = CopyObject(data);
		delete data2["password"];
		data2.x = 0;
		data2.y = 0;
		data2.parentDiv = result.parentDiv;
		var placeholder = CreateFieldCore(data2);

		result.paired1 = placeholder;
		placeholder.paired2 = result;
		result.onblur();
	} else {
		return CreateFieldCore(data);
	}

	return result;
}
/** Create basic components of a new input field element
 *  @fn Object CreateFieldCore( Json data)
 *  @tparam Json data including the settings for the field element.
 *  @treturn Object a field div.
 */
function CreateFieldCore(data)
{
    data = cascade(_DefaultFont, data);


	var dx;
	var dw;
	var dy;
	var dh;
	var leftCap = 20*gScaleX;
	var rightCap = 20*gScaleX;
	if (data.field == null) {
		data.field = "images"+getAppSetting().addOnPath+"/textfield.png";
		if (!gOnDevice) {
			data.field = "/" + data.field;
		}
		dx = -17;
		dy = -9;
		dw = 30;
		dh = 14*gScaleX;
	} else {
        // correct path of field
        data.field = "images/" + gImagePath + data.field;

		leftCap = 3;
		if (data.leftCap) {
			leftCap = data.leftCap;
		}
		rightCap = 3;
		if (data.rightCap) {
			rightCap = data.rightCap;
		}
		dx = -leftCap;
		dw = leftCap + rightCap;
		dy = -9;
		dh = 14*gScaleY;
	}

	var d, t;
	if (data.parentDiv) {
		d = data.parentDiv;
	} else {
        if (data.multiline !== true)
        {
            CreatePatchImage({parent: data.parent, src: data.field, x:data.x+dx, y:data.y+dy, w:data.w+dw, h:data.h+dh, leftCap:leftCap, rightCap:rightCap});
            if (data.icon !== undefined && data.ox)
            {
                image({parent:data.parent, src:data.icon.src, x:(data.x+dx)/gScaleX+12, y:(data.y+dy)/gScaleX+data.icon.y+7, w: data.icon.w, h:data.icon.h});

            }
        }
		d = CreateDiv(data.parent, data.x+(data.ox?data.ox:0), data.y+dy, data.w+dx+dw-(data.ox?data.ox:0), data.h+dh);

        if (!gbAndroid) {
            // this logic is preventing keyboard from opening on Android - need to revisit intent, what it was fixing on iOS with Jo
            var clickArea = CreateDiv(data.parent, data.x+dx, data.y+dy, data.w+dw, data.h+dh);
            if (window["FPNative"]){
                clickArea.onmousedown = function()
                {
                    t.focus();
                }
            }else{
                clickArea.onclick = function()
                {
                    t.focus();
                }
            }
        }

    }

    if (data.multiline === true)
    {
        t = document.createElement('textarea');
    }else
    {
        t = document.createElement('input');
    }
    if (data.setTransparent === true)
    {
        $(t).css("backgroundColor","transparent");
    }
	t.parentDiv = d;

	// In Internet Explorer, an input field type can only be set once
	if (data.password) {
		if (gbAndroid) {
			// on Android, password fields are buggy, so we workaround it by using the -webkit-text-security style to show the dots
			t.type = "text";
		} else {
			t.type = "password";
		}
	} else if (data.email) {
		t.type = "email";
	} else if (data.date) {
		t.type = "date";

	} else {
		t.type = "text";
	}
	t.password = data.password;
	if (data.maxLength) {
		t.maxLength = data.maxLength;
	}
	if (data.readonly) {
		t.readOnly = true;
	}

	if (gOnDevice && !data.capitalize) {
        t.setAttribute("autocapitalize", "off");
	}

    t.setAttribute("autocorrect", "off");
    t.setAttribute("autocomplete", "off");

	t.emptyText = data.placeholder;
	t.bEmpty = false;
	t.id = data.id;
	t.name = data.id;
	t.style.position = "absolute";
	t.style.fontSize = data.size + "px";
	t.style.fontFamily = data.font?fixFontFamily(data.font):fixFontFamily("bold font");
    t.style.width = (data.w+dw+dx-(data.ox?data.ox:0)) + "px";
	t.style.height = data.h + "px";
    t.style.webkitTapHighlightColor = "rgba(0,0,0,0)";
    t.style.padding =  "0px";
    t.style.top = dh/2 + "px";
    t.style.webkitUserModify = "read-write-plaintext-only";
    if (data.multiline === true)
    {
        $(t).css("border","2px solid #eeeeee");
        $(t).css("border-radius","10px");
    }else
    {
        t.style.border = "0px";
        t.style.outline = "none";
    }



	t.onblur = function()
	{
        if (window["DoHubFieldWorkaroundBlur"]) {
            DoHubFieldWorkaroundBlur();
        }

		if (this.value.length == 0) {
			this.value = this.emptyText;
			this.style.color = "#c0c0c0";
			this.bEmpty = true;
			if (this.paired1) {
				$(this.paired1).show();
				$(this).hide();
			} else if (this.password) {
                SetPasswordMode(this, false);
			}
		}
	};

	t.onfocus = function()
	{
        if (window["DoHubFieldWorkaroundFocus"]) {
            DoHubFieldWorkaroundFocus();
        }

		if (this.bEmpty) {
			this.bEmpty = false;
			this.style.color = "#000000";
			this.value = "";
			if (this.paired2) {
				$(this).hide();
				$(this.paired2).show();
				$(this.paired2).focus();
            } else if (this.password) {
                SetPasswordMode(this, true);
            }
        }
    };

	if (data.string) {
		t.value = data.string;
		t.onfocus();
	}

	t.onblur();

	d.appendChild(t);

	return t;
}
/** Return user input value of the field. If the field is empty, return empty string.
 *  @fn String GetField( Object f)
 *  @tparam Object f the field element.
 *  @treturn String user input value of the field.
 */
function GetField(f)
{
	if (f.bEmpty) {
		return "";
	} else {
		return f.value;
	}
}
/** Set the text in the input field and change field's color and bEmpty properties.
 *  @fn SetField( Object data, String s)
 *  @tparam Object f the field element.
 *  @tparam String s.
 */
function SetField(f, s)
{
	if (s == null  || s == undefined) {
		s="";
	}

	f.value = s;

	if (f.value.length == 0) {
		f.value = f.emptyText;
		f.style.color = "#c0c0c0";
		f.bEmpty = true;
        if (gbAndroid) {
            $(f).css("-webkit-text-security", "none");
        } else {
            f.type = "text";
        }
	} else {
		f.bEmpty = false;
		f.style.color = "#000000";
	}
}