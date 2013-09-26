// index.js
orientation("vertical");
var appSettings = getAppSetting();
background(appSettings.background, true);

//header bg
image({id:"headerBg", src: appSettings.headerBg, x:0, y:0, w:gFullWidth, h:45});


label({id:"title",size: 18, x: 0, y: 10, w: gFullWidth, center:true, string: i18n('_THANKS_FOR_REGISTERING')});
end();



o = function(s, args) {
    var nameLabel = [];
    var lever = [];
    var existChildren = FPGetAccountPeople()?FPGetAccountPeople():[];
    init();

    function init()
    {
        var bInHub = false;
        if (args&&args.flow==="AddFamily"){
            bInHub = true;
            $(s).empty();
            existChildren = [];
            var p = div({parent:s, x:0, y:0, w:320, h:gHubHeight, color: "#ffffff"});
            var d = div({parent:p, x:0, y:0, w:320, h:40});
            addBackgroundImage($(d), "gray-pattern.png");
            label({parent:p, x:0, y:10, w:320, h:35, center:true, string: i18n('_ADD_FAMILY_MEMBERS'), size:16, color:"#4e4e4e"});
        }
        var contentPanel = div({parent:(bInHub)?p:s, x:0, y:45, w:gFullWidth, h:(bInHub)?gHubHeight-40:gFullHeight-45});
        var layout = getThreeGroupTemplate(contentPanel, 252, 260, (bInHub)?0:75, (bInHub)?260:228, (bInHub)?0:50);
        var top =  layout.topPanel, bottom = layout.bottomPanel, middle = layout.middlePanel, center = layout.center;

        if (bInHub){
            top = div({parent: middle, x:0, w: 320, h: 40});
        }
        var childScrollBox = div({parent: middle, x:10, w: 300, h: (bInHub)?170:260});
        if (!bInHub){
            $(center).css("background", appSettings.boxRGBA);
            $(center).css("border", "1px solid " + appSettings.boxFrameRGBA);
            var avatarDiv = div({parent: top, x:0, y:0, w: 75, h: 75});
            drawAvatar(avatarDiv, FPGetPersonAvatar(), "parent", null, 65, 0, 0, false);
            var l = label({parent: top, size: 14, id: "now", x: 5, y: 10, string: i18n('_ENTER_NAMES_OF'), font: "light font", color:"#4e4e4e"});
        }else{
            label({parent:top, x:0, y:10, w:260, h:35, center:true, string: i18n('_HI')+FPGetPersonName()+"! Add your children below by creating a nickname for them.", size:12, color:"#4e4e4e"});
            bottom = div({parent: middle, x:0, w: 320, h: 50});
            setPositionRelative(top);
            setPositionRelative(middle);
            setPositionRelative(bottom);
        }

        button({parent:bottom, src:gImagePath+"graybutton_half", idleover:"same", id: "clear", w:110, h:40, string: i18n('_CLEAR_ALL'), size: 18});
        button({parent:bottom, src:gImagePath+"greenbutton_half", idleover:"same", id: "go", w:110, h:40, string: i18n('_DONE'), size: 18});

        if (FPIsLandscape()&&!bInHub){
            $(l).css("width", "90%");
            $(l).css("top", "0");
            setPositionRelative(bottom);
            setChildrenXCenter(bottom);
            setPositionRelative(top);
            setChildrenXCenter(top);
        }else{
            $(l).css("width", parseInt($(top).css("width"))-75*gScaleX);
            setLineHorizontally(bottom, (bInHub)?130:140);
            setLineHorizontally(top, 75);
        }

        var lastone;

        var offset = 0;
        for (var i=0; i<existChildren.length; i++) {
            var person = existChildren[i];
            if (person.name !== FPGetPersonName()){
                lastone = div({parent:childScrollBox, x:0, y:offset*57, w:283, h:57});
                image({parent: lastone, src: gImagePath+"name-generator-box", x:0, y:10, w:240, h:35});
                label({parent:lastone, id:"existNameLabel."+i, string:existChildren[i].name, x:15, y:22, w:240, h:35, size:16, color:"#4e4e4e"});
                offset++;
            }
        }
        var totalLever = bInHub?3:4;
        for (var i=0; i<totalLever-offset; i++) {
            lastone = div({parent:childScrollBox, x:0, y:(i+offset)*57, w:283, h:57});
            $(lastone).addClass("nameLabel");
            image({parent: lastone, src: gImagePath+"name-generator-box", x:0, y:10, w:240, h:35});
            nameLabel[i] = label({parent:lastone, id:"nameLabel."+i, string: "", x:15, y:22, w:240, h:35, size:16, color:"#4e4e4e"});
            var levelImage = image({parent: lastone, id:"lever."+i, src: gImagePath+"lever1", idleover:"same", x:223, y:0, w:18, h:57});
            levelImage.id = "anim"+i;
            $(levelImage).addClass("anim");
            lever[i] = new SpriteAnim({
                numOfImages: 3,
                backgroundImage: "lever",
                elementId : "anim"+i
            });
        }
        var eventName = window["FPNative"]?"touchstart":"click";
        $(".nameLabel").bind(eventName, function(){
            changeName($(".nameLabel").index(this));
        });
        function changeName(i){
            lever[i].init();
            lever[i].startAnimation();
            FPRejectAndGenerateName(nameLabel[i].text.innerText, onName);
            function onName(n) {
                nameLabel[i].text.innerText = n;
            }
        }
        bottom.buttonParent = s;
    }


    s.on_go = function()
    {
        // disable all the button while waiting response from server
        $( s ).attr({ disabled: true });

        save();

    };

    function save()
    {
        // complete the saving and go to next page
        FPWebBatchStart();
        for (var i=0; i<nameLabel.length; i++) {
            if (nameLabel[i].text.innerText.match(/\S/) ) {
                FPAddNewPerson(nameLabel[i].text.innerText, null);
            }
        }
        FPWebBatchSend(finishedSave);
    }
    function finishedSave(){
        runScreenCloser(s, "right");
        if (args && (args.flow === "FamilyPlay"||args.flow === "bPartnerNewAcc")){
            runScreen(gRoot, "change_player", "left", {noClose:true, flow:args.flow});
        }else if (args && args.flow === "AddFamily"){
            var parent = s.parent;
            s.parent = null;
            runScreenCloser(s, "left");
            runScreen(parent, "hub_parent_home", "right");
        }else {
            runScreen(gRoot, "registration_congratulations", "left");
        }
    }

    s.on_clear = function(){
        for (var i=0; i<nameLabel.length; i++){
            nameLabel[i].text.innerText = "";
        }
    };
};

FPLaunchScreen(o);



