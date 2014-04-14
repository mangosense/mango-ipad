

var GhostUploader = (function(){
	return {
		url_to_go : '',
		casper:'',
		story_config:null,
		init: function() {
			casper = require('casper').create({
				 clientScripts:  [
			        'js/jquery.min.js',      
			        'js/underscore-min.js'   
			    ]
			});

			// print out all the messages in the headless browser context
			casper.on('remote.message', function(msg) {
			    this.echo('remote message caught: ' + msg);
			  
			});

			casper.userAgent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36');
			
			this.loadConfig()
			this.start()

		},
		loadConfig: function() {
			var fs = require('fs')
			var data = fs.read('story.json')
			this.story_config = JSON.parse(data)
			//casper.echo(story_config['new app']['name'])
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

				self.url_to_go = this.evaluate(function() {
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
				self.handleManageApps()
			})
		},

		handleManageApps: function() {
			self=this;
			casper.thenOpen('https://itunesconnect.apple.com'+this.url_to_go,function() {
				self.url_to_go = this.evaluate(function(oops) {
					console.log('url to go :' + oops.url_to_go)
					console.log("Page url " + window.location.href);
					console.log($('.upload-app-button a').attr('href'));
					return $('.upload-app-button a').attr('href')
				},self)
				
				self.fill_1st_step()
				
			})
		},

		fill_1st_step: function() {
			self=this;
			casper.thenOpen('https://itunesconnect.apple.com'+this.url_to_go,function() {
				this.evaluate(function(config) {
					console.log("Page url " + window.location.href);

					// fill the language

					lang_found = $('#default-language-popup option').filter(function() {
						return ($(this).text() == config['language'])
					})
					if lang_found
						lang_found.prop('selected',true)
					else
						$('#default-language-popup option').filter(function() {
							return ($(this).text() == 'English')
						}).prop('selected',true)

					// fill the app name

					$('#appNameUpdateContainerId input[type="text"]').val(config['name'])

					//fill the SKU number

					$('#sKUNumberTooltipId').parent().find('input[type="text"]').val(config['sku'])

					// fill the bundle id

					bundle_found = $('primary-popup option').filter(function() {
						return ($(this).text() == config['bundle_id'])
					})

					if bundle_found
						bundle_found.prop('selected',true);
					else
						//Break the app

					// fill the bundle id suffix if available
					if ($('.bundleIdWildcard').is(':visible')){
						if (config['bundle_id_suffix'])
							$('#wildcardSuffix').val(config['bundle_id_suffix'])
						else
							//break the app
					}

					// goto next step by clicking continue button

					$('.continueActionButton').click()

				},self.story_config)

				self.fill_2nd_step();
			})
		},

		fill_2nd_step: function() {

		}

	}	

})().init()









