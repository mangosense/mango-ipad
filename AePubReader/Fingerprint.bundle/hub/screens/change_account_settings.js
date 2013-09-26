// index.js
orientation("vertical");

end();

// logic.js
//
//  Copyright 2012 Fingerprint Digital, Inc. All rights reserved.
//

o = function(s, args) {

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    var bPwd = args.toChange ==="email"?false:true;
    init();
    function init()
    {
        var d = div({parent:p, x:0, y:0, w:320, h:40});
        addBackgroundImage($(d), "gray-pattern.png");
        var title, l1, l2, i1, i2, oy, fieldType;
        if (bPwd){
            title = i18n("_CHANGE_PASSWORD");
            l1 = i18n("_OLD_PASSWORD");
            l2 = i18n("_NEW_PASSWORD");
            i1 = i2 = "icon_password";
            oy = 85;
            fieldType = {password:true};
        }else
        {
            title = i18n("_CHANGE_EMAIL");
            l1 = i18n("_ENTER_PASSWORD");
            l2 = i18n("_NEW_EMAIL");
            i1 = "icon_password";
            i2 = "icon_email";
            oy = 70;
            fieldType = {email:true};
        }
        label({parent:p, id: "title", string: title, center: true, x: 0, y: 10, w: 320, h: 55, size:15, color:"#4e4e4e"});
        button({parent: p, src:gImagePath+"gray-leftpoint-button", idleover:"same", x: 10, h: 30, w: 60, y: 5, size: 12, id: "back", string: i18n('_BACK')});

        label({parent:p, x: 40, y: oy, w: 240, h: 30, string:l1,  size:12, font: "light font", color:"#4e4e4e"});
        field({parent:p, x: 40, y: 110, w: 240, h: 30, size: 15, id: "field.0", placeholder: "", password: true,
            field: "gray-box.png", icon:{src: gImagePath+i1, w:14, h:12, y:8 }, setTransparent: true, ox: 40});
        label({parent:p, x: 40, y: 160, w: 240, h: 30, string:l2,  size:12, font: "light font", color:"#4e4e4e"});
        field({parent:p, x: 40, y: 185, w: 240, h: 30, size: 15, id: "field.1", placeholder: "",
            field: "gray-box.png", icon:{src: gImagePath+i2, w:14, h:12, y:8 }, setTransparent: true, ox: 40}, fieldType);

        var t = { src:gImagePath+"switch", x: 205, w: 75, h:35, size: 12, string: ""};
        var b = button(t, {parent:p, id:"show.0", y: 105});
        addTextOnSwitch(b, 75, 35);

        if (bPwd)
        {
            var b = button(t, {parent:p, id:"show.1", y: 180, w: 75, h:35});
            addTextOnSwitch(b, 75, 35);

        }
        function addTextOnSwitch(b, w, h){
            var l1= label({parent:b, x: 0, y: 0, w: w/2, h:h, size: 14, center: true, vCenter:true, string:""});
            l1.text.innerHTML="&lowast;&lowast;&lowast;"
            label({parent:b, x: w/2, y: 0, w: w/2, h:h, size: 10, center: true, vCenter:true, string:i18n('_ABC')});
        }

        button({parent:p, src:gImagePath+"greenbutton_full", idleover:"same", id: "save", x: 40, y:240, w:240, h:40, string: i18n('_SAVE'), size: 18});


        p.on_back = function()
        {
            s.close();
        };
        p.on_show = function(i)
        {
            var bOn = s.button["show."+i].bOn;
            SetToggle(s.button["show."+i], !bOn);
            SetPasswordMode(s.field["field."+i], bOn);
        };
        p.on_save = function()
        {
          $("*:focus").blur();
          if (bPwd)
          {
              var pwdLength = s.field["field.1"].value.length;
              // validate password
              if (pwdLength < 5 || pwdLength > 16) {
                  DoAlert(i18n("_INVALID_PASSWORD"), i18n("_PASSWORD_MUST_BE"));
                  return;
              } else
              {
                  validatePassword(next1);
                  function next1(r)
                  {
                      if ( !r.bSuccess )
                      {
                          DoAlert(i18n("_INVALID_PASSWORD"), i18n("_PLEASE_ENTER_CORRECT_PASSWORD"));
                      }
                      else
                      {
                          FPChangePassword(s.field["field.1"].value, next);
                      }
                  }
              }

          }else
          {
              // validate email address
              if (!validateEmail(s.field["field.1"].value)) {
                  DoAlert(i18n("_INVALID_EMAIL"), i18n("_INVALID_EMAIL_FORMAT"));
                  return;
              }else
              {
                  validatePassword(next2);
              }

              function next2(r)
              {
                  if ( !r.bSuccess )
                  {
                      DoAlert(i18n("_INVALID_PASSWORD"), i18n("_PLEASE_ENTER_CORRECT_PASSWORD"));
                  }
                  else
                  {
                      function onEmailChange(bSuccess)
                      {
                          if (!bSuccess) {
                              DoAlert(i18n("_INVALID_EMAIL"), i18n("_EMAIL_ALEADY_REGISTERED"), next);
                          }else{
                              next();
                          }
                      }
                      FPChangeEmail(s.field["field.1"].value, onEmailChange);
                  }
              }

          }
        };
        function validatePassword(callback)
        {
            var email = FPGetAccountValue("email");
            var password = s.field["field.0"].value;
            FPAccountLogin(email, password, callback, i18n("_UPDATING"));
        }

        function next(){
            s.close();
        }
    }


};

FPLaunchScreen(o);



