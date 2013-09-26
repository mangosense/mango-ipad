var FPCalculator = {};

FPCalculator.Calculator = function(p, w, size, initStr, bMultiply, onSuccess, onWrong){
    var frag = document.createDocumentFragment();
    var q = FPCalculator.getQuestion(bMultiply);
    var bt_w = size/0.85, ratio = size/52;
    var q_l, l;
    if (bMultiply){
        image({parent: frag, x: 100, y: 29, w: 55, h:25, src: gImagePath+"textbox" });
        q_l = label({parent: frag, x: 0, y: 30, w: 110, h: 25, size:18, string: "", center: true, vCenter: true, color: "#000000"});
        l = label({parent: frag, id:"answer", x: 106, y: 30, w: 40, h:25, center:true, vCenter: true, string: "", color: "#000000", size: 18});
    }else{
        if (initStr){
            label({parent: frag, x: 0, y: 2, w: w, h:25*ratio, center:true, vCenter: true, string: i18n('_ENTER_THE_NUMBERS'), color: "#000000", size: 12*ratio, font:"light font"});
        }
        image({parent: frag, x: (w-73*ratio)/2, y: 38*ratio, w: 73*ratio, h:25*ratio, src: gImagePath+"textbox" });
        q_l = label({parent: frag, x: 0, y: 12, w: w, h: 25*ratio, size: 14*ratio, string: "", center: true, color: "#000000"});
        l = label({parent: frag, id:"answer", x: (w-73*ratio)/2, y: 38*ratio, w: 73*ratio, h:25*ratio, center:true, vCenter: true, string: "", color: "#000000", size: 18});
    }
    q_l.text.id = "qText";
    l.text.id = "ansText";
    var numberPanel = div({parent: frag, x: 0, y: 72*ratio, w: w, h:170});
    var d = div({parent: frag, x: 0, y: 72*ratio, w: 0, h:170});
    d.id = "numberPanelShield";

    for (var i = 0; i < 9; i++){
        var b = button({parent:numberPanel, id:"number."+i, src: gImagePath+"greenbutton_half", idleover:"same", string:i+1, w:size, h:size*0.64, size:16*ratio});
        b.className = "numberBt";
        b.buttonParent = numberPanel;
    }
    var b = button({parent:numberPanel, id:"number."+i, src: gImagePath+"greenbutton_half", idleover:"same", string: i18n('_0'), w:size, h:size*0.64, size:16*ratio});
    b.className = "numberBt";
    b.buttonParent = numberPanel;
    p.appendChild(frag);

    FPCalculator.initQuestion(bMultiply, q, initStr);

    $(".numberBt").css({
        position: "relative",
        display: "inline-block"
    });
    $(".numberBt:last-child").css({
        position: "relative",
        display: "inline-block",
        margin: ["0px ", bt_w*gScaleX, "px"].join("")
    });
    numberPanel.on_number = function(i){
        var answer = q[q.length-1].toString();
        var num = parseInt(i)+1;
        if (i==="9"){
            num = 0;
        }
        var input =  $("#ansText").text();
        input = input+num;
        $("#ansText").text(input);
        if(input.length === answer.length ){
            $("#numberPanelShield").css("width", w*gScaleX+"px");

            if (input===answer){
                // correct answer
                if (onSuccess){
                    onSuccess();
                }
            }else{
                // wrong answer, block and bounce, and generate new question
                if (onWrong){
                    onWrong();
                }
                // change question
                q = FPCalculator.getQuestion(bMultiply);
                FPCalculator.initQuestion(bMultiply, q, initStr);
            }
        }

    }

}

FPCalculator.getQuestion = function(bMultiply){
    // random numbers
    var nums =[];
    // number to words
    var words = ["Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"];
    var len = bMultiply?2:3;
    var answer =  bMultiply?1:"";
    for (var i = 0; i < len; i++){
        var ran = parseInt(Math.random()*9);
        nums[i] = bMultiply?ran:words[ran];
        answer = bMultiply?answer*ran:answer+ran;
    }
    // save answer
    nums.push(answer);
    return nums;
}
FPCalculator.initQuestion = function(bMultiply, q, initStr){
    var len = q.length-1;
    $("#ansText").text("");
    var qText = q.slice(0, len).join(bMultiply?" X ":"&nbsp;&nbsp;&nbsp;");
    qText += bMultiply?" = ":"";
    qText = initStr?initStr:qText;
    $("#qText").html(qText);
    $("#numberPanelShield").css("width", "0px");
}