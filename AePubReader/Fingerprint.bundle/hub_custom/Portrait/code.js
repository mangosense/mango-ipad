function FPCustomGetName()
{
    return "generic";
}
var AssetsPosition = {
	"list":{
        "button-coins.png":{x: 200, y: 14, w: 60, h: 32, size:14},
        "button-nudged.png":{x: 140, y: 14, w: 60, h: 32, size:14},
		"button-newgame1.png":{x: 10, y: 36, w: 280, h: 44, oy:3, size:20},
		"button-newgame2.png":{x: 10, y: 36, w: 280, h: 44, oy:3, size:20},
		"button-newgame3.png":{x: 10, y: 80, w:280, h:55, size:20},
        "change-player-button2":{x: 235, y: 23, w: 65, h:26},
		"finishedgames-bottom.png":{x: 10, y: 0, w: 280, h: 2},
		"finishedgames-mid.png":{x:10, y:0, w:280, h:45},
		"finishedgames-top.png":{x:10, y:0, w:280, h:33},
        "FINISHED GAMES":{x:25, y:7, w:280, h:30, color:"#e6e2d5", size:18},
        "game_header.png":{x: 320- gFullWidth, y: 0, w: gFullWidth, h:40},
        "name":{x:75, y:28, w:200, h: 35},
        "newgame3":{x:15, y:80, w:280, h:30, color:"#148242", size:20},
        "smallbutton.png":{x: 140, y: 14, w: 60, h: 32, size:14},
        "view":{color: "#148242"},
        "waitingfor-top.png":{x:10, y:0, w:280, h:33},
        "WAITING FOR":{x:25, y:7, w:287, h:30, color:"#d1d9e2", size:18},
		"yourturn-mid.png":{x:10, y:0, w:280, h:44},
		"yourturn-top.png":{x:10, y:30, w:280, h:33},
        "TAKE A TURN TO EARN COINS!":{x:25, y:37, w:287, h:30, color:"#ccded4", size:18}
	},
	"create":{
        "button-back.png":{x: 40, y: 367+(gFullHeight-440), w: 110, h:35, string:"Back"},
        "button-findfriends.png":{x: 170, y: 367+(gFullHeight-440), h: 35, w: 110, string:"Find Friends"},
        "button-practice-round.png":{x: 20, w: 240, h:40, y: 20, color:"#178643", size:18},
        "challenge-someone.png":{x: 20, y: 80, w: 280, h:50},
        "challenge-someone-text":{x: 20, y: 97, w: 280, h:60, size:20},
        "friendBox":{x: 20, y: 132, w: 280, h:220+(gFullHeight-440)},
        "game_logo.png":{ x: 15, y: 18, w: 290, h: 64},
        "randomAvatarAnimation":{h:50},
        "smallbutton.png":{x: 200, y: 14, w: 60, h: 30, size:14},
        "yourturn-mid.png":{x: 20, y: 130, w: 280, h: 280+(gFullHeight-440)},
        "yourturn-bottom.png":{x: 20, y: 410+(gFullHeight-440), w: 280, h: 2}
	},
	"game_pause":{
		"button-keepplaying.png":{x:35, y:145, w:250, h:45, size: 14},
		"button-mainmenu.png":{x:35, y:215, w:250, h:45, size: 14}
	}
};
function FPCustomAssetsPosition(screenName, name)
{
    return cascade(AssetsPosition[screenName][name], {src:FPCustomAssetsPath(name)});
}
function FPCustomGetFontName()
{
    return "bold font";
}
function FPCustomListAddOn(parent, status)
{
}
function FPCustomCreateAddOn(parent, status)
{
}
function FPCustomPauseAddOn(parent, status)
{
    if (status === "front"){
        image({parent:parent, src: gImagePath+"button_play", x: 224, y: 160, w:10});
    }
}

function onContinueGame(){
 runScreen(gRoot,  "yourturn/list", "none");
}