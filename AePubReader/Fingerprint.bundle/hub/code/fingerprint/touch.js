//
//  Copyright 2011, 2012 Fingerprint Digital, Inc. All rights reserved.
//
/**
 * @file
 * Utility functions to handle touch events.
 */
/** Touch event Handler. Mapping touch event with mouse events on iPhone.
 *  @fn touchHandler( Event event)
 *  @tparam Event event.
 */
//----------------------------------------------------------------------------------------------------------------------
// deal with simulating mouse events on iPhone
function touchHandler(event)
{
	// on iPad iOS5, if we process clicks on text areas this way, then
	// then fail to get focus
	if (event.target.nodeName == "TEXTAREA" ||
		event.target.nodeName == "INPUT")
	{
		return;
	}

	var touches = event.changedTouches,
			first = touches[0],
			type = "";
	switch(event.type)
	{
		case "touchstart": type = "mousedown"; break;
		case "touchmove":  type="mousemove"; break;
		case "touchend":   type="mouseup"; break;
		default: return;
	}

	var simulatedEvent = document.createEvent("MouseEvent");
    var button = gbAndroid ? 2:0;
	simulatedEvent.initMouseEvent(type, true, true, window, 1,
			first.screenX, first.screenY,
			first.clientX, first.clientY, false,
			false, false, false, button, null);

	first.target.dispatchEvent(simulatedEvent);
	event.preventDefault();
}
/** Initialize touch event with event handler, touchHandler,
 *  and the events includes touchstart, touchmove, touchend and touchcancel.
 *  @fn initTouchEvents
 */
function initTouchEvents()
{
	document.addEventListener("touchstart", touchHandler, true);
	document.addEventListener("touchmove", touchHandler, true);
	document.addEventListener("touchend", touchHandler, true);
    document.addEventListener("touchcancel", touchHandler, true);

    // Android sometimes generates both a touchstart AND a mousedown
    // in that case, we end up with two mousedown events and can end up with stray button pushes of buttons that get exposed
    // on Android, we tag our desired, simulated event as coming from mouse button 2, so we can filter out events not from
    // the correct button
    if (gbAndroid) {
        function mouseHandler(event)
        {
        	lastTouchPosition = event.screenY;

            if (event.button != 2) {
                if (event.stopImmediatePropagation) {
                    event.stopImmediatePropagation();
                }
                return;
            }
        }

        document.addEventListener("mousedown", mouseHandler, true);
        document.addEventListener("mouseup", mouseHandler, true);
    }
}