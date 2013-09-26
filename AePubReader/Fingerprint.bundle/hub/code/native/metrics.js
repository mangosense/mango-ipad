//
//  Copyright 2011, 2012 Fingerprint Digital, Inc. All rights reserved.
//

/**
 Name space for functions that require native implementation support.
 */
var FPMetrics = {};

/**
 * metrics event

 @param {String} metric_id id of event
 @param {Object} data key/value pairs data for event
 @return {void}
 */
FPMetrics.metric = function(metric_id, data)
{
    if (window["FPNative"])
    {
        FPNativeCall("Helper", "metric:data:", [metric_id, data]);
    }
    else
    {
        // TODO
        console.log("warning: webHub FPMetrics.metric not implemented");
    }
};

/**
 * metrics screen event

 @param {String} screen_id id of event
 @return {void}
 */
FPMetrics.metricScreen = function(screen_id)
{
    if (window["FPNative"])
    {
        FPNativeCall("Helper", "metricScreen:", [screen_id]);
    }
    else
    {
        // TODO
        console.log("warning: webHub FPMetrics.metricScreen not implemented");
    }
};
