orientation("vertical");
var appSettings = getAppSetting();
background(appSettings.background, true);
end();

//logic.js
o = function(s, args) {

    // attempt an auto-login
    function onAutoLogin(r)
    {
        s.close();
        if (!r.bSuccess)
        {
            // auto-login NOT successful - go to login screen
            FPSetEventScope2("Login");
            runScreen(gRoot, "registration_login", "none");
        }

        FPHelper.platformResumed();
    }

    FPAutoLogin(onAutoLogin);
};

FPLaunchScreen(o);