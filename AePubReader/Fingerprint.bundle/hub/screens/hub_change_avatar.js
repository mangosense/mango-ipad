// index.js
orientation("vertical");


end();


var gAvatarNum = 12;

o = function(s, args) {

    var p = div({parent: s, id:"hubFrame", x: 0, y: 0, w: 320, h:gHubHeight, color: "#ffffff"}); // actually needed to make white background
    var avatarId = -1;

    if (FPIsOffline()) {
        runScreen(s, "offline", "left", {what: "change your avatar", bNoBack: true});
    } else {
        init();
    }

    function init()
    {
        var name = FPGetPersonName();
        //title
        //label({parent:s, string: (name?name+", ":"")+i18n("_PICK_YOUR_PICTURE"), x:0, y:11, w:320, size:16, center:true, color:"#4e4e4e"});

        var frame = div({parent:p, x:20, y: 0, w:280, h:325});
        var avatarScrollBox = createAvatarSelector(frame,325, 0, (name?name+", ":"")+i18n("_PICK_YOUR_PICTURE"), FPGetPersonAvatar(), true);


        avatarScrollBox.on_avatar = function(i)
        {
            avatarId = i;
            FlashButton(s.button["avatar."+i]);
            // change image src and reload
            var img = generateAvatarImagePath("avatar"+avatarId);
            img = GetImageInfo("images/" + img).src;
            img = img.replace("images/../","");
            $(s.image["avatar_selected"]).attr('src',img);
            // TODO: need a way to set avatar that doesn't require synchronous server response
            FPChangeAvatar(FPGetPerson(), "avatar"+avatarId, null);
        }
    }


};

FPLaunchScreen(o);




