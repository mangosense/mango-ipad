//
//  Copyright 2011, 2012 Fingerprint Digital, Inc. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------------------
//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

/*
 example data:

 {
 src: "example.png",	// source url of image
 w: 160,				// natural width of image
 h: 120,				// natural height of image
 left: 40,			// size of fixed left edge
 top: 40,			// size of fixed top edge
 right: 40,			// size of fixed right edge
 bottom: 40			// size of fixed bottom edge
 };

 arguments:

 parentElement - where to add on the page
 data - see example above
 w - desired width of rendered image
 h - desired height of rendered image
 */
/**
 * @file
 * Utility functions needed for the image class.
 * This file contains anything that is not related directly to image class.
 */
/** Create patch of image to generate new image fits the desired width and height.
 *  @fn Object Create9Patch( Object parentElement, Object data, String w, String h)
 *  @tparam Object parentElement the parent element for the image element.
 *  @tparam Object data including the settings for the image element, such as src,
 *  w, h, left, top, right, and bottom.
 *  @tparam String w desired width of rendered image.
 *  @tparam String h desired height of rendered image.
 *  @treturn Object a new image div.
 */
function Create9Patch(parentElement, data, w, h)
{
    // create div to hold the patches
    var result = document.createElement('div');

    // compute fixed size of edges (not in the middle)
    var fixedX = data.left + data.right;
    var fixedY = data.top + data.bottom;

    // keep track of offset into source image
    var top = 0;
    var left = 0;

    // function for each row of the 9-patch image
    function CreateRow(srcH, dstH)
    {
        // each row starts with left source offset at 0
        left = 0;

        // scale of this row
        var yScale = dstH/srcH;

        // function to create patch image
        function CreatePatch(srcW, dstW, f)
        {

            // scale of this column
            var	xScale = dstW/srcW;

            // create div to clip the scaled image
            var e = document.createElement('div');
            e.setAttribute('style', "position: relative; overflow: hidden; float: " + f + "; width: " + dstW + "px; height: " + dstH + "px;");
            result.appendChild(e);

            // create scaled/offset image
            var i = document.createElement('img');
            i.src = GetImageInfo(data.src).src;
            i.setAttribute('style', "position: absolute; left: " + -left*xScale + "px; top: " + -top*yScale + "px; width: " + data.w*xScale + "px; height: " + data.h*yScale + "px;");
            e.appendChild(i);

            // increment left source offset by source width
            left += srcW;
        }

        // 3-patch image is made up of 3 columns of patch images
        CreatePatch(data.left, data.left, "left");			// left
        CreatePatch(data.w - fixedX, w - fixedX, "left");	// middle
        CreatePatch(data.right, data.right, undefined);		// right

        // increment top source offset by source height
        top += srcH;
    }

    // 9-patch images made up of 3 rows of 3-patch images
    CreateRow(data.top, data.top);			// top
    CreateRow(data.h - fixedY, h - fixedY);	// middle
    CreateRow(data.bottom, data.bottom);	// bottom

    // add div to parent and return result
    parentElement.appendChild(result);
    return result;
}

/** Add 9 patches image elements for the given image div. Calculate image width
 *  and height using loaded images dictionary.
 *  @fn Object CreatePatchImage2( Object d, Object readyImages)
 *  @tparam Object d the image div element.
 *  @tparam Object readyImages images dictionary.
 *  @treturn Object a image div.
 */
function CreatePatchImage2(d, readyImages)
{
    var i = readyImages[d.data.src];

    var data = {
        src: d.data.src,
        w: GetImageWidth(i),
        h: GetImageHeight(i),
        left: d.data.left?d.data.left:0,
        right: d.data.right?d.data.right:0,
        top: 0,
        bottom: 0
    };
    // allow patch image to use natural w, h of image, if w, h not specified
    var w = d.data.w ? d.data.w : GetImageWidth(i);
    var h = d.data.h ? d.data.h : GetImageHeight(i);
    Create9Patch(d, data, w, h);
    return d;
}
/** Return a new image div. If image width, height, rightCap, and leftCap is given,
 *  call Create9Patch to get the image div, otherwise call LoadImages to load all images.
 *  After finished loading call CreatePatchImage2 to create image div.
 *  @fn Object CreatePatchImage( Json data)
 *  @tparam Json data including the settings for the image div element.
 *  @see Create9Patch
 *  @see CreatePatchImage2
 *  @treturn Object a image div.
 */
function CreatePatchImage(data)
{
	data = cascade(data);

	var d = CreateDiv(data.parent, data.x, data.y, data.w, data.h);
	d.data = {
        src: data.src,
        w: data.w,
        h: data.h,
        left: data.leftCap,
        right: data.rightCap,
        top: 0,
        bottom: 0
    };


	if (data.w && data.h && data.rightCap == 0 && data.leftCap == 0) {
		var i2 = Create9Patch(d, d.data, data.w, data.h);
	} else {
	// must be sure the image is loaded because we need its natural width, height
	var images = [data.src];
	LoadImages(images, CreatePatchImage2, d);
	}

	// return the div that will have the images after loaded
	return d;
}
/** Create image div with the same ratio as the loaded images. If the width and height settings of div
 *  is not equal to the images', remove the width and height setting of the div.
 *  @fn CreateImageKeepRatio( Json data)
 *  @tparam Json data including the settings for the image div element.
 */
//----------------------------------------------------------------------------------------------------------------------
// NOTE: does not synchronously return the image like CreateImage does
function CreateImageKeepRatio(data)
{
	FixImagePath(data);


	function KeepRatioFunction(ignoreContext, readyImages)
	{

		var data2 = CopyObject(data);
		var i = readyImages[data.src];

		var ratio_w_h = GetImageWidth(i) / GetImageHeight(i);
		var t_width = data.w;
		var t_height = t_width / ratio_w_h;

		if (t_height > data.h) {
			t_height = data.h;
			t_width = t_height * ratio_w_h;
			data2.w = null;
		} else {
			data2.h = null;
		}

		CreateImage(data2);
	}

	// must be sure the image is loaded because we need its natural width, height
	var ratioimages = [data.src];
	LoadImages(ratioimages, KeepRatioFunction);
}
/** Get a new image element, set the styles for a new image element,
 *  load the image, and return the image element. If the image should be cropped,
 *  create the parent div as a container for the new image, and return the parent div instead.
 *  @fn Object CreateImage( Json data)
 *  @tparam Json data including the settings for the image div element.
 *  @treturn Object a image div.
 */
function CreateImage(data)
{
	data = cascade(data);

//    console.log("CreateImage");
//    console.log(data);


	if (data.w == null) {
		data.w = "auto";
	}
	if (data.h == null) {
		data.h = "auto";
	}

	var p = data.parent;
	if (data.cropW && data.cropH) {
		p = CreateDiv(data.parent, data.x, data.y, data.cropW, data.cropH);
		data.x = 0;
		data.y = 0;
	}

	var e = new Image();

	if (!data.center) {
		$(e).css("position", "absolute");
		$(e).css("border", "0px");
		$(e).css("left", data.x);
		$(e).css("top", data.y);
	} else {
		$(e).css("display", "block");
		$(e).css("margin-left", "auto");
		$(e).css("margin-right", "auto");
	}

	if (data.marginLeft) {
		$(e).css("margin-left", data.marginLeft);
	}

	if (data.ox) {
		e.style.left = -data.ox + "px";
	}
	if (data.oy) {
		e.style.top = -data.oy + "px";
	}

	if (data.src) {
		if (!data.loadspin) {
			SetImage(e, data.src, data.w, data.h);
		} else {
			var bTempLoading = true;
			e.onload = function() {
				bTempLoading = false;
				$(e).show();
				$(temp).hide();
				div_temp.removeChild(temp);
				data.loadcallback();
			}
			SetImage(e, data.src, data.w, data.h);
			$(e).hide();

			var div_temp = div({parent:p, x:data.x, y:data.y, w:data.w, h:data.h, color:null});
			var temp = new Image();
			var t_size = 30;
			temp.src = "/hub/images/loading.png";
			$(temp).css("position", "absolute");
			var center_y = ($(div_temp).height()-t_size) * 0.5;
			$(temp).css("top", center_y);
			var center_x = ($(div_temp).width()-t_size) * 0.5;
			$(temp).css("left", center_x);
			$(temp).css("width", t_size);
			$(temp).css("height", t_size);
			div_temp.appendChild(temp);

			setTimeout(animateTemp, 100);
			function animateTemp() {
				if (!bTempLoading) {
					return;
				}
				setTimeout(animateTemp, 100);

				var x = (new Date()).getTime();
				x = x % 3000;
				var deg = 360*x/3000;
				deg = deg % 360;
				deg = parseInt(deg/30)*30;

				var r = "rotate(" + deg + "deg)";
				temp.style.webkitTransform = r;
			}
		}
	}

	p.appendChild(e);
	if (p != data.parent) {
		return p;
	} else {
		return e;
	}
}
/** A global variable of the image path.
 *  @var gImagePath
 *  @type String
 */
var gImagePath = ["../images", FPGetAppValue("partner")&&FPGetAppValue("partner")!=="fingerprint"?"_"+FPGetAppValue("partner"):"","/"].join("");


