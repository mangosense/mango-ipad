orientation("vertical");
end();

//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

o = function(s, args) {

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    var info = div({parent: s, id:"hubFrame", x: 10, y: 40, w: 300, h:gHubHeight-65, color: "#f0f0f0"}); // actually needed to make white background
    button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "back", string: i18n('_BACK')});

    var device_id = FPGetAppValue("device_id");

    function onQAEnabled(r)
    {
        function setServer(server)
        {
            function next(bOK)
            {
                if (bOK) {
                    FPSetAppValue("server", server);
                    FPWebView.eval("login", "FPResume()");
                }
            }
            DoAlert(i18n("_SET_SERVER"), i18n("_RESTART_V2") + server, next, true);
        }

        if (r.bEnabled) {
            var _bt = cascade(_GreenButton, {parent: s, x: 210, w: 100, h: 40, size: 18});

            button(_bt, {id: "qa", string: i18n('_QA'), y: 40+gHubHeight-65-140});
            s.on_qa = function()
            {
                setServer("https://sdk2-qa.fingerprintplay.com");
            }
            button(_bt, {id: "prod", string: i18n('_PROD'), y: 40+gHubHeight-65-90});
            s.on_prod = function()
            {
                setServer("https://sdk2-prod.fingerprintplay.com");
            }
            button(_bt, {id: "custom", string: i18n('_CUSTOM'), y: 40+gHubHeight-65-40});
            s.on_custom = function()
            {
                runScreen(s, "enter_custom_server", "left", setServer);
            }

            button(_CheckBoxButton, {parent: s,id: "agree", x: 15, y:260, w:25, h:25});
            label({parent:s, x:50, y:265, w:160, h:25, string:"Show metric event IDs", size:12, color:"#4e4e4e"});
            SetToggle(s.button["agree"], FPGetAppValue("bShowMetric"));
            s.on_agree = function(){
                var bOn = s.button["agree"].bOn;
                FPSetAppValue("bShowMetric", !!bOn);
            }

        }
    }
    // direct request - not an FPWebRequest
    FPRequest("GetUpdates", {command:"isQAEnabled", device_id: FPGetDeviceId()}, onQAEnabled);

    var server = FPGetAppValue("server");
    var sdk_version = FPGetAppValue("sdk_version");
    var versions = JSON.parse(FPGetAppValue("versions"));
    var versionsStr = JSON.stringify(versions, null, 4); // re-stringify so it's pretty printed
    versionsStr = versionsStr.replace(/ /g, '&nbsp;'); // make spaces work in HTML
    versionsStr = versionsStr.replace(/\n/g, '<br />'); // make line feeds work in HTML

    info.innerHTML = "<code>" + "server: " + server + "<br><br>sdk_version: " + sdk_version + "<br>hub_custom: " + FPCustomGetName() + "<br><br>assets:<br>" + versionsStr + "</code>";
    $(info).css('fontSize',  10*gScaleX); // make font small enough to display a lot of text

    p.on_back = function()
    {
        s.close();
    }

};

FPLaunchScreen(o);



