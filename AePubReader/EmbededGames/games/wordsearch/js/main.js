var MangoGame = {
	init: function(options) {
		var winSound = new buzz.sound("./wordsearch/sounds/magic.mp3");

		$('#overlay').live('click', function() {
			$('#overlay').hide();
			$('#congrat').hide();
		});

		var str = '{';
		$(options.words).each(function(key) {
			if (key < (options.words.length - 1)) {
				str = str + '"' + options.words[key] + '":"",';
			} else {
				str = str + '"' + options.words[key] + '":""';
			}

		});
		str = str + '}';

		var fwords = $.parseJSON(str);

		// render the game
		var soup = new Soup({
			fontSize: 25,
			fontFamily: "Comic Sans MS",
			color: "black", // font color
			selectColor: "#2941c4", // line color
			size: 10, // initial grid size
			wordsNum: 10, // initial number of words
			clock: "clock", // where display time? (element id)
			points: "points", // where display points? (element id)
			layout: "{points}", // how display points?
			startPoint: 1000, // initial points
			every: 10000, // every n miliseconds
			words: fwords,
			winSound: winSound,
			//deduct: 10, // deduct n points

			/*== Events ==*/
			onHint: function() {
				this.score.down(50);
			},

			// you get the final score and time in hh:mm:ss format
			onFinish: function(time, score) {
				// do anything
			}
		});
	}


}