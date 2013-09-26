//
//  Copyright 2011, 2012 Fingerprint Digital, Inc. All rights reserved.
//
/**
 * @file
 * Utility functions needed for the font class.
 * This file contains anything that is not related directly to font class.
 */
//----------------------------------------------------------------------------------------------------------------------
// deal with using fonts on iPhone
/** Flag for tracking if font have been added to IOS devices or not.
 *  @var gbAddedIosFont
 *  @type Boolean
 */
var gbAddedIosFont = false;
/** Dictionary for all added fonts
 *  @var gbAddedFonts
 *  @type Object
 */
// dictionary for added fonts
var gbAddedFonts = {
    "light font": {name:"light font", fileName: "Va Ground Light", "added": false},
    "bold font": {name:"bold font", fileName: "Va Ground Bold", "added": false},
    // TODO: these 2 fonts are for Alphabetinis only and could get moved to hub_custom for that game
    "stud": {"name": "Stud", fileName:"Stud", "added": false}
};

/** Add one font of the given fontName to devices.
 *  @fn addFont(String data)
 *  @tparam String fontName the new font Name.
 */
function addFont(fontName)
{
    var appSettings = getAppSetting();
    var pathAddon = appSettings.addOnPath;
    if (pathAddon){
        gbAddedFonts = appSettings.fonts;
    }
    if (!gbAddedFonts[fontName.toLowerCase()] || gbAddedFonts[fontName.toLowerCase()].added) {
        return;
    }
    var font = gbAddedFonts[fontName.toLowerCase()];
    font.added = true;
    var fontName = font.name;
    var fontFile = font.fileName;
    var head = document.getElementsByTagName('head')[0],
        style = document.createElement('style');

    if (gOnDevice) {
        // all the existing font is in fonts folder
        rules = document.createTextNode("@font-face { font-family: '"+ fontName +"-ios'; src: url('../hub/fonts"+ pathAddon +"/"+ fontFile +".ttf') format('truetype'); }");
    } else {
        rules = document.createTextNode("@font-face { font-family: '"+ fontName +"-ios'; src: url('hub/fonts"+ pathAddon +"/"+ fontFile +".TTF') format('truetype'); }");
    }

    style.type = 'text/css';
    if (style.styleSheet) {
        style.styleSheet.cssText = rules.nodeValue;
    } else {
        style.appendChild(rules);
    }
    head.appendChild(style);
}
/** Add new font with the given font name and append "-ios" to
 *  the font name and return the new name.R
 *  @fn String fixFontFamily( String font)
 *  @tparam String font font name.
 *  @treturn String modified font name.
 */
function fixFontFamily(font)
{
//	if (gOnDevice) {
//		return font;
//	}

	var result = font;

    addFont(font);
	result += "-ios";

	return result;
}