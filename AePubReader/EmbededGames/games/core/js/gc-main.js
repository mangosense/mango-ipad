function callbackHandler(a, b, v) {
	var id = $(this).data('roundabout').childInFocus;
	$('.disc').fadeOut(400);
	$('#text' + (id + 1)).fadeIn(400);
}

$(document).ready(function() {
	$('.slide1').roundabout({
		minOpacity : 0.2,
		btnNext : ".next",
		btnPrev : ".previous",
		enableDrag : false,
		btnNextCallback : callbackHandler,
		btnPrevCallback : callbackHandler,
		clickToFocusCallback : callbackHandler
	});

	$('#jigsaw.roundabout-in-focus').live('click', function() {
		window.location.href = 'games/jigsaw.html';
	});
	$('#draw.roundabout-in-focus').live('click', function() {
		window.location.href = 'games/draw.html';
	});
	$('#memory.roundabout-in-focus').live('click', function() {
		window.location.href = 'games/memorypuzzle.html';
	});
	$('#wordsearch.roundabout-in-focus').live('click', function() {
		window.location.href = 'games/wordsearch.html';
	});

});
