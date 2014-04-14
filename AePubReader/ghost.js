

var GhostUploader = (function(){
	return {
		url_to_go : '',
		casper:'',
		init: function() {
			casper = require('casper').create({
				 clientScripts:  [
			        'js/jquery.min.js',      /
			        'js/underscore-min.js'   
			    ]
			});

			// print out all the messages in the headless browser context
			casper.on('remote.message', function(msg) {
			    this.echo('remote message caught: ' + msg);
			  
			});

			casper.userAgent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36');
			
			this.start()

		},
		start: function() {
			self = this;
			casper.start('https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa', function() {
			    this.echo(this.getTitle());
			    this.fill('form[name="appleConnectForm"]',
						{
							'theAccountName':'apple@edesii.com',
							'theAccountPW':'Mango1234'
						},true);
			    self.clickManageApps()
			});
			casper.run();
		},
		clickManageApps: function() {
			self=this;
			casper.then(function() {

				url_to_go = this.evaluate(function() {
					console.log("Page url " + window.location.href);
					var sins = $('.singlewide')
					console.log(sins.length)
					var manage_apps_elem  = _.select(sins,function(elem) {
						img_elem  = $(elem).find('img')[0]
						//console.log('image src : ' +  $(img_elem).parent().attr('href'))
						if ($(img_elem).attr('src').indexOf('manageapps.png') > -1)
							return true;
						else
							return false;
					}).first()

					url_to_go = $(manage_apps_elem).find('a').first().attr('href')
					console.log(url_to_go)
					return url_to_go;
				})
				self.handleManageApps(0)
			})
		},

		handleManageApps: function() {
			self=this;
			casper.thenOpen('https://itunesconnect.apple.com'+url_to_go,function() {
				url_to_go = this.evaluate(function() {
					console.log("Page url " + window.location.href);
					console.log($('.upload-app-button a').attr('href'));
					return $('.upload-app-button a').attr('href')
				})
				
				self.fill_1st_step()
				
			})
		},

		fill_1st_step: function() {
			self=this;
			casper.thenOpen('https://itunesconnect.apple.com'+url_to_go,function() {
				this.evaluate(function() {
					console.log("Page url " + window.location.href);
					// $('#default-language-popup option').filter(function() {
					// 	if ($(this).text() == )
					// })
				})
			})
		}
	}	

})().init()






// function clickManageApps() {
	
// }

    
// function handleManageApps() {
// 	this.thenOpen('https://itunesconnect.apple.com'+url_to_go,function() {
// 		url_to_go = this.evaluate(function() {
// 			console.log("Page url " + window.location.href);
// 			console.log($('.upload-app-button a').attr('href'));
// 			return $('.upload-app-button a').attr('href')
// 		})
		
// 		fill_1st_step.call(this)
		
// 	})


// }

// function fill_1st_step() {
// 	this.thenOpen('https://itunesconnect.apple.com'+url_to_go,function() {
// 		this.evaluate(function() {
// 			console.log("Page url " + window.location.href);
// 			// $('#default-language-popup option').filter(function() {
// 			// 	if ($(this).text() == )
// 			// })
// 		})
// 	})
	
// }





