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
		clickToFocusCallback : callbackHandler,

	});

	$('#jigsaw.roundabout-in-focus').live('click', function() {
		window.location.href = 'gamecenter/jigsaw.html';
	});
	$('#draw.roundabout-in-focus').live('click', function() {
		window.location.href = 'gamecenter/draw.html';
	});
	$('#memorypuzzle.roundabout-in-focus').live('click', function() {
		window.location.href = 'gamecenter/memorypuzzle.html';
	});
	$('#wordsearch.roundabout-in-focus').live('click', function() {
		window.location.href = 'gamecenter/wordsearch.html';
	});
	$('#dragNdrop.roundabout-in-focus').live('click', function() {
		window.location.href = 'gamecenter/dragNdrop.html';
	});
	$('#arrange-the-letters.roundabout-in-focus').live('click', function() {
		window.location.href = 'gamecenter/arrange-the-letters.html';
	});
	$('#select-the-object.roundabout-in-focus').live('click', function() {
		window.location.href = 'gamecenter/select-the-object.html';
	});
	$('#identify-the-animal.roundabout-in-focus').live('click', function() {
		window.location.href = 'gamecenter/identify-the-animal.html';
	});

});
