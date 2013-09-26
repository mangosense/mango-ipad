//
//  notification.js
//
//  Copyright (c) 2011-2012 Fingerprint Digital, Inc. All rights reserved.
//

// -----------------------------------------------------------------------------------------
// XMPP Push Notification Mechansim

var SERVER = "xmpp.fingerprintplay.com";
var BOSH_SERVICE = 'http://' + SERVER + ':5280/http-bind';
var gConnection = null;
var gXmppUsername = null;
var gXmppPassword = null;
var gNotificationCallback;

var gRetryInterval = 3;

function onConnect(status)
{
	if (status == Strophe.Status.ERROR) {
		console.log('Strophe encountered an error.');
		XmppReconnect();		
	} else if (status == Strophe.Status.CONNECTING) {
		console.log('Strophe is connecting.');
	} else if (status == Strophe.Status.CONNFAIL) {
		console.log('Strophe failed to connect.');
		XmppReconnect();
	} else if (status == Strophe.Status.DISCONNECTING) {
		console.log('Strophe is disconnecting.');
	} else if (status == Strophe.Status.DISCONNECTED) {
	    console.log('Strophe is disconnected.');
		XmppReconnect();
	} else if (status == Strophe.Status.CONNECTED) {
		gRetryInterval = 3; // success, so reset retry interval
		console.log('Strophe is connected.');
		gConnection.addHandler(onMessage, null, 'message', null, null,  null);   	
		gConnection.send($pres().tree());    	
		// trigger the callback on connect, as there was a window in the interim where messages could've arrived
		if (gNotificationCallback) {
			gNotificationCallback();
		}		
	}
}

function onMessage(msg) {
	var type = msg.getAttribute('type');
	var elems = msg.getElementsByTagName('body');
	if (type == "chat" && elems.length > 0) {
		var body = elems[0];
		if (gNotificationCallback) {
			gNotificationCallback(Strophe.getText(body));
		}
	}
	return true; // we must return true to keep the handler alive.  
}

function initNotifications(id, callback)
{
    if (gConnection) {
        XmppDisconnect();
    }

	gNotificationCallback = callback;
	gXmppUsername = id + "@xmpp.fingerprintplay.com";
	gXmppPassword = id;
	XmppConnect();
}

function XmppDisconnect()
{
    gConnection.disconnect();
    gConnection = null;
}

function XmppReconnect()
{
	gConnection.disconnect();
	gConnection = null;
	
	console.log("Xmpp Attempt Reconnect in " + gRetryInterval + " seconds.");
	var useInterval = gRetryInterval;
	gRetryInterval *= 2; // if we fail again before we succeed, double the interval, up to max 1 minute
	if (gRetryInterval > 60) {
		gRetryInterval = 60;
	}
	setTimeout(XmppConnect, useInterval*1000);
}

function XmppConnect()
{
	console.log("XmppConnect started");
	gConnection = new Strophe.Connection(BOSH_SERVICE);
	gConnection.connect(gXmppUsername, gXmppPassword, onConnect);
}
