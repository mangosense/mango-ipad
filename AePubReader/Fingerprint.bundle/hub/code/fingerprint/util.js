//
//  Copyright 2011, 2012 Fingerprint Digital, Inc. All rights reserved.
//
/** Return a deep copy of the input object.
 *  @fn Object CopyObject( Object o)
 *  @tparam Object o.
 *  @treturn Object.
 */
//----------------------------------------------------------------------------------------------------------------------
function CopyObject(o)
{
	var result = {};
	for (var i in o) {
		result[i] = o[i];
	}
	return result;
}
//----------------------------------------------------------------------------------------------------------------------
// protect against browsers without console defined
if (!window["console"]) {
	window.console = {};
	window.console.log = function(s)
	{
	}
}
/** Print the errors to console.
 *  Example:
 *  LogError({err: "can only load 1 screen at a time"});
 *  @fn Object LogError( Object err)
 *  @tparam Object err.
 */
function LogError(err)
{
	console.log("ERROR:");
	for (var i in err) {
		console.log(i + ": " + err[i]);
	}
}

