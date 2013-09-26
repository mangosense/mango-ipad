//
//  Copyright 2011, 2012 Fingerprint Digital, Inc. All rights reserved.
//
/**
 * @file
 * Utility functions needed to support retina display.
 */
/** Global flag for retina display. The default is true.
 *  @var gbHiResEnabled
 *  @type Boolean
 */
var gbHiResEnabled = true;
/** Flag for if current devices support retina display. It is true
 *  when window.devicePixelRatio is equal to 2, otherwise false;
 *  @var gbRetina
 *  @type Boolean
 */
var gbRetina = (window.devicePixelRatio === 2);

/** Return false if it is retina display ipad.
 *  @fn Boolean FPUse3d
 *  @note 3d translate is hardware accelerated, but breaks our up-res scheme
 *  @treturn Boolean.
 */
// NOTE: 3d translate is hardware accelerated, but breaks our up-res scheme
function FPUse3d()
{
	if (gbHiResEnabled) {
		if (window["gbIPad"]) {
			return false;
		}
	}

	// non-retina and retina iPhone work fine with 3d translate, so leave it on
	return true;
}
/** Return false to use 3d translate for iScroll if it is retina display ipad
 *  @fn Boolean FPIScrollUse3d
 *  @see FPUse3d
 *  @treturn Boolean.
 */
function FPIScrollUse3d()
{
	return FPUse3d();
}

/** Return the original image’s width from the scaled image input,
 *  by dividing the input’s width with the scale.
 *  @fn Number GetImageWidth( Object i)
 *  @tparam Object i the image div element.
 *  @treturn Number.
 */
//----------------------------------------------------------------------------------------------------------------------
// Hi-Res support: Bottleneck functions for setting an Image source, w, h / getting an Image w, h

function GetImageWidth(i)
{
	var w = i.width;
	if (i.src.indexOf("@2x") != -1) w /= 2;
	if (i.src.indexOf("@4x") != -1) w /= 4;
	return w;
}
/** Return the natural image’s height from the scaled image input,
 *  by dividing the input’s height with the scale.
 *  @fn Number GetImageHeight( Object i)
 *  @tparam Object i the image div element.
 *  @treturn Number.
 */
function GetImageHeight(i)
{
	var h = i.height;
	if (i.src.indexOf("@2x") != -1) h /= 2;
	if (i.src.indexOf("@4x") != -1) h /= 4;
	return h;
}
/** Get the imageInfo by calling GetImageInfo and set the source,
 *  width and height of the image.
 *  @fn SetImage( Object image, String src, String w, String h)
 *  @tparam Object image the image div.
 *  @tparam String src the url for the image.
 *  @tparam String w width for the image element.
 *  @tparam String h height for the image element.
 *  @see GetImageInfo
 */
function SetImage(image, src, w, h)
{
	var imageInfo = GetImageInfo(src);

	// if using image natural size (and it might not be loaded yet), we
	// get the 1x natural size from the image info
	if (imageInfo && w == "auto" && h == "auto") {
		w = imageInfo.w;
		h = imageInfo.h;
	}

	// src may have been mapped to a @2x or @4x asset
	image.src = imageInfo.src;
	if (w) {
		$(image).css("width", w);
	}
	if (h) {
		$(image).css("height", h);
	}
}
/** Remove dot in the path and then return the modified one.
 *  @fn String RemoveDotDot( String resPath)
 *  @tparam String resPath path need be modified.
 *  @treturn String modified path.
 */
function RemoveDotDot(resPath)
{
	while (true) {
		var i = resPath.indexOf("/../");
		if (i == -1) {
			break;
		}
		var j = i-1;
		while (resPath.charAt(j) != '/' && j>0) {
			j--;
		}
		var pre = resPath.substring(0, j);
		var post = resPath.substring(i+3);
		resPath = pre+post;
	}
	resPath = resPath.substring(1);
	return resPath;
}
/** Check if the image resource is exist or not. And for
 *  Retina iPad - use “@4x” (image scaled by 4) if available,
 *  if not then “@2x”(use image scaled by 2) if available,
 *  otherwise user “@2x” for iPhone and regular iPad.
 *  Return the imageInfo with updated source url.
 *  @fn Object GetImageInfo( String src)
 *  @tparam String src image path.
 *  @treturn Object.
 */
function GetImageInfo(src)
{
	// get the canonical version of the asset path to look up in the image info
	var resPath = RemoveDotDot("/hub/" + src);

	// if it's a dynamically loaded online hub asset, trim server
	var i = resPath.indexOf("/onlinehub/");
	if (i != -1) {
		resPath = resPath.substring(i+1);
	}

    // if it's a hub_custom asset, trim the game_id query string when looking up
    i = resPath.indexOf("?");
    if (i != -1) {
        resPath = resPath.substring(0,i);
    }

	// if not found, want empty object, not null
	var imageInfo = {};

	// look up in image info
	var bFound = false;
	for (var n in gImageInfo) {
		var candidate = gImageInfo[n][resPath];
		if (candidate) {
			bFound = true;
			imageInfo = candidate;
			break;
		}
	}

	if (!bFound) {
        console.log("GetImageInfo: not found: " + src);
    }

    src = PickrResolution(imageInfo, src);

	// return result
    if (gUNIQUE) {
        src += "?" + gUNIQUE;
    }

	imageInfo.src = src;
	return imageInfo;
}

function PickrResolution(imageInfo, src)
{
    // pick appropriate resolution
    var res = null;
    if (gbHiResEnabled) {

        if (gbRetina)
        {
            if (gScaleX < 1.5) {
                res = imageInfo.b2x?"@2x":"";// iphone retina
            } else {
                res = imageInfo.b4x?"@4x":(imageInfo.b2x?"@2x":"");// ipad retina
            }
        }
        else
        {
            if (gScaleX < 1.5) {
                res = "";// iphone no retina
            } else if (imageInfo.b2x){
                res = "@2x";// ipad no retina
            }
        }
    }

    // update src URL as needed
    if (res) {
        var i = src.lastIndexOf(".");
        if (i == -1) {
            src += res;
        } else {
            src = src.substring(0, i) + res + src.substring(i);
        }
    }
    return src;
}

function GetCatalogURL(src)
{
    // TODO: consider whether @4x images are too big for dynamic download
 	// pick appropriate resolution
	var res = "";
	if (gbHiResEnabled)
    {
        if (gbRetina)
        {
            if (gScaleX < 1.5) {
                res = "@2x";// iphone retina
            } else {
                res = "@4x";// ipad retina
            }
        }
        else
        {
            if (gScaleX < 1.5) {
                res = "";// iphone no retina
            } else {
                res = "@2x";// ipad no retina
            }
        }
	}

    var i = src.lastIndexOf(".");
    if (i != -1) {
        src = src.substring(0, i) + res + src.substring(i);
    }

    console.log("CATALOG URL: " + src);

	return src;
}