$(window).load(function() {
	
	
	var f1, f2, f3,f4,f5,f6,f7,f8;
	var x1=0;x2=0;x3=0;x4=0;x5=0;x6=0;x7=0;x8=0;
	
	var h1=0;h2=0;h3=0;
	var g1=0;g2=0;g3=0;

	$(".itm").draggable({
		revert : 'invalid'
	});
	$('.handle').droppable();

	$('#e2').droppable({
		accept : '#d2',
		drop : function(event, ui) {
			$("#loose").addClass("actv");
			var draggableId = ui.draggable.attr("id");
			
			

			if (draggableId == "d5" || draggableId == "d6" || draggableId == "d7") {
				f2 = 1;
				$("#a2 .r").addClass("active");
			} else {
				f2 = 0;
				$("#a2 .w").addClass("active");
			}
			h1=1;
			//alert(f2);
			x2=1;
			
		}
	});
	$('#e3').droppable({
		accept : '#d3',
		drop : function(event, ui) {
			$("#loose").addClass("actv");
			var draggableId = ui.draggable.attr("id");

			if (draggableId == "d3") {
				f3 = 1;
				$("#a3 .r").addClass("active");
			} else {
				f3 = 0;
				$("#a3 .w").addClass("active");
			}
			
			h2=1;
			//alert(f3);
			x3=1;
			displayButton();
		}
	});
	$('#e4').droppable({
		accept : '#d4',
		drop : function(event, ui) {
			$("#loose").addClass("actv");
			var draggableId = ui.draggable.attr("id");

			if (draggableId == "d5" || draggableId == "d6" || draggableId == "d7") {
				f4 = 1;
				$("#a4 .r").addClass("active");
			} else {
				f4 = 0;
				$("#a4 .w").addClass("active");
			}
			//alert(f3);
			h3=1;
			x4=1;
			
		}
	});
	
	$('#e5').droppable({
		accept : '#d2',
		drop : function(event, ui) {
			$("#loose").addClass("actv");
			var draggableId = ui.draggable.attr("id");

			if (draggableId == "d1") {
				f5 = 1;
				$("#a5 .r").addClass("active");
			} else {
				f5 = 0;
				$("#a5 .w").addClass("active");
			}
			g1=1;
			//alert(f3);
			x5=1;
			displayButton();
		}
	});
	
	$('#e6').droppable({
		accept : '#d3',
		drop : function(event, ui) {
			$("#loose").addClass("actv");
			var draggableId = ui.draggable.attr("id");

			if (draggableId == "d8") {
				f6 = 1;
				$("#a6 .r").addClass("active");
			} else {
				f6 = 0;
				$("#a6 .w").addClass("active");
			}
			//alert(f3);
			g2=1;
			x6=1;
		}
	});
	
	$('#e7').droppable({
		accept : '#d4',
		drop : function(event, ui) {
			$("#loose").addClass("actv");
			var draggableId = ui.draggable.attr("id");

			if (draggableId == "d4") {
				f7 = 1;
				$("#a7 .r").addClass("active");
			} else {
				f7 = 0;
				$("#a7 .w").addClass("active");
			}
			//alert(f3);
			g3=1;
			x7=1;
		}
	});
	
	
	function itemInSpot(drag_item, spot) {
		var item = $('<img />');
		// create new img element
		item.attr({// copy attributes
			src : drag_item.attr('src'),
		}).attr('class', drag_item.attr('class')).appendTo(spot).draggable({
			revert : 'invalid'
		});
		// add to spot + make draggable
		drag_item.remove();
		// remove the old object
	}


	$('.handle').bind('drop', function(ev, ui) {
		itemInSpot(ui.draggable, this);
	});

	function checkAnswer() {
		
		$('#check').delay(1000).fadeOut();
		$('#retry').delay(1250).fadeIn();
		
		if(g1 === 1 && g2 == 1 && g3 == 1 )
		{
			$('#right').show();
			$(".active").fadeIn(600);
			$("#win").fadeIn(600);
			//	alert("hurray");
		}
		else
		{
		$('#wrong').show();
		$(".active").fadeIn(600);
			$(".actv").fadeIn(600);
		//	alert("poop");
		}
	
		/*
		if (f1 === 1 && f2 == 1 && f3 == 1 && f4 == 1 && f5 == 1 && f6 == 1 && f7 == 1 && f8 == 1 ) {
			$(".active").fadeIn(600);
			$("#win").fadeIn(600);
			
			
		} else {
			$(".active").fadeIn(600);
			$(".actv").fadeIn(600);
		
		}*/
	}
	


	$("#check").click(function() {
		checkAnswer();

	});

	$("#retry").click(function() {

		location.reload();
	});

}); 