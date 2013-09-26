//
//  Copyright 2011, 2012 Fingerprint Digital, Inc. All rights reserved.
//
/**
 * @file
 * Utility functions needed for the label class.
 * This file contains anything that is not related directly to label class.
 */
/** Create a new outer div as a container of a new label by calling CreateDiv,
 *  get the text div by calling CreateText and then add it to outer.text,
 *  set the css for the label element, and return the div.
 *  @fn Object CreateLabel( Json data)
 *  @tparam Json data including the settings for the label element.
 *  @treturn Object a label div.
 *  @see CreateDiv
 *  @see CreateText
 */
function CreateLabel(data)
{
    data = cascade(_DefaultFont, data);

	var useW = data.w;
	if (data.w == null) {
		useW = 1024;
	}

	var outer = CreateDiv(data.parent, data.x, data.y, useW, data.h, null);
	if (data.h == null) {
		$(outer).css("overflow", "visible");
	}

	if (data.shadow) {
        var shadowOuter = CreateDiv(outer, 0, 0, useW, data.h, null);
		var shadowData = CopyObject(data);
		shadowData.x = 1;
		shadowData.y = 1;
		shadowData.color = data.shadow;
		shadowData.parent = shadowOuter;
		outer.shadow = CreateText(shadowData);
	}
	var textData = CopyObject(data);
	textData.x = 0;
	textData.y = 0;
	textData.parent = outer;

	outer.text = CreateText(textData);
	if (data.link) {
		var a = outer.text.firstChild;
		a.style.pointerEvents = "all";
		a.style.textDecoration = "none";
		a.style.color = data.color;
	}

	if (data.w == null) {
		$(outer).css("width", $(outer.text).width()+4);
	}
	if (data.h == null) {
		$(outer).css("height", $(outer.text).height()+4);
	}

	return outer;
}