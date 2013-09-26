//
//  Copyright 2011, 2012 Fingerprint Digital, Inc. All rights reserved.
//
/**
 * @file
 * Utility functions needed for the text class.
 * This file contains anything that is not related directly to text class.
 */
/** Create a new div as a container of a new text element by calling document.createElement,
 *  set the innerHTML to data.link, set the css for the text element, and return the div.
 *  @fn Object CreateText( Json data)
 *  @tparam Json data including the settings for the text element.
 *  @treturn Object a text div.
 */
function CreateText(data)
{
	data = cascade(data);

//    console.log("CreateText");
//    console.log(data);

	var p = document.createElement("div");
	$(p).css("position", "absolute");

	var text = data.string;
	if (data.multiColorFunc) {
        var end = text.match(/[.!?]/);
        text = text.replace(end, "");
		var words = text.split(" ");
		var colorText = "";
		for (var i= 0, len = words.length; i<len; i++) {
            words.style = null;
            var wordColor = data.multiColorFunc(i, words);
            var spacer = (i === len-1?"":" ");
            if (words.style) {
                colorText += "<span style=\"" + words.style + "\">";
            }
            if (wordColor){
                colorText += "<span style='color: " + wordColor + "'>" + words[i] + "</span>" + spacer;
            }else{
                colorText += words[i] + spacer;
            }

            if (words.style) {
                colorText += "</span>";
            }
		}
		text = colorText;

        if (end){
            text += end;
        }
	}
	if (data.link) {
		text = "<a href='" + data.link + "'>" + text + "</a>";
	}
	p.innerHTML = text;
    var fontFamily = data.font ? fixFontFamily(data.font) : fixFontFamily('bold font');
	$(p).css('fontFamily', fontFamily);
	$(p).css('fontSize', data.size);
	if (data.bNoWrapping) {
		$(p).css("visibility", "hidden");
		document.body.appendChild(p);
		var targetWidth = data.w - 16;
		var origHeight = p.clientHeight;
		var iWidth = p.clientWidth+1;
		var iSize = data.size;

		while (iWidth > targetWidth && iSize > 0) {
			iSize--;
			p.style.fontSize = iSize;
			iWidth = p.clientWidth+1;
		}

		data.y += (origHeight - p.clientHeight)/2;
		document.body.removeChild(p);
		$(p).css("visibility", "visible");
	}
	$(p).css("left", data.x);
	$(p).css("top", data.y);
	$(p).css("width", data.w);
	$(p).css("height", data.h);

	if (data.color) {
		$(p).css('color', data.color);
	}
	$(p).css('cursor', 'default');

	p.style.outline = "none";
	p.style.cursor = "default";
	p.style.pointerEvents = "none";

	if (data.center) {
		p.style.textAlign = "center";
	}
	if (data.rightJustify) {
		p.style.textAlign = "right";
	}
    if (data.left) {
        p.style.left = data.left;
    }
	if (data.vCenter) {
		p.style.verticalAlign = "middle";
        data.parent.style.display = "table";
        p.style.display = "table-cell";
        p.style.position = "relative";
        p.style.left = undefined;
        p.style.top = undefined;
	}
	if (data.bold) {
		p.style.fontWeight = "bold";
	}
	if (data.underline) {
		p.style.textDecoration = "underline";
	}
	if (data.italic) {
		p.style.fontStyle = "italic";
	}
	if (data.lineHeight) {
		p.style.lineHeight = data.lineHeight + "px";
	}
    if (data.ellipsis)
    {
        p.style.overflow = "hidden";
        p.style.textOverflow = "ellipsis";
    }else if (data.h){

        // not count html tab on string
        var regex = /(<([^>]+)>)/ig;
        
        // force to string, in case text was actually a number
        text = ""+text;

        var t1 = text.replace(regex, "");
        var count = t1.toString().length;
        // assume the letter height is larger than letter width in this font
        var newFont = Math.sqrt(data.w*data.h/(count));
        newFont = Math.max(newFont, 9);
        newFont = Math.min(newFont, data.size);
        $(p).css('font-size', newFont);


    }

	data.parent.appendChild(p);

	return p;
}



