

var GhostUploader = (function(){
	return {
		url_to_go : '',
		casper:'',
		story_config:null,
		init: function() {
			casper = require('casper').create({
				 clientScripts:  [
			        'js/underscore-min.js'   
			    ]
			});

			// print out all the messages in the headless browser context
			casper.on('remote.message', function(msg) {
			    this.echo(msg);
			});



			casper.userAgent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36');
			
			this.loadConfig()
			this.start()

		},
		loadConfig: function() {
			var fs = require('fs')
			var data = fs.read('story.json')
			this.story_config = JSON.parse(data)
			//casper.echo(story_config['']['name'])
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
					var sins = window.jQuery('.singlewide')
					console.log(sins.length)
					var manage_apps_elem  = _.select(sins,function(elem) {
						img_elem  = window.jQuery(elem).find('img')[0]
						//console.log('image src : ' +  window.jQuery(img_elem).parent().attr('href'))
						if (window.jQuery(img_elem).attr('src').indexOf('manageapps.png') > -1)
							return true;
						else
							return false;
					}).first()

					url_to_go = window.jQuery(manage_apps_elem).find('a').first().attr('href')
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
					console.log(window.jQuery('.upload-app-button a').attr('href'));
					return window.jQuery('.upload-app-button a').attr('href')
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

					lang_found = window.jQuery('#default-language-popup option').filter(function() {
						return (window.jQuery(this).text() == config['language']);
					});

					if (lang_found)
						lang_found.attr('selected',true);
					else {
						window.jQuery('#default-language-popup option').filter(function() {
							return (window.jQuery(this).text() == 'English')
						}).attr('selected',true);
					}

					// fill the app name

					window.jQuery('#appNameUpdateContainerId input[type="text"]').val(config['name']);

					//fill the SKU number

					window.jQuery('#sKUNumberTooltipId').parent().find('input[type="text"]').val(config['bundle_id_suffix']);


					// Logging all bundle ids
					console.log('Available Bundle Ids are :');
					console.log('==========================');
					window.jQuery('#primary-popup option').each(function() {
						if (window.jQuery(this).text()!='Select')
							console.log(window.jQuery(this).text());
					})
					console.log('==========================')
					// fill the bundle id

					bundle_found = window.jQuery('#primary-popup option').filter(function() {
						return (window.jQuery(this).text() == config['bundle_id']);
					});


					if (bundle_found){
						bundle_found.attr('selected',true);
						if (config['bundle_id_suffix']){
							window.jQuery('.bundleIdWildcard').show()
							window.bundleWildcardChange();
						}


					}
					// else
					// 	break;
						//Break the app
					// fill the bundle id suffix if available
					if (config['bundle_id_suffix']){
						window.jQuery('#wildcardSuffix').val(config['bundle_id_suffix']);
						window.bundleWildcardChange()
					}
						// else
						// 	break;
						//break the app


					// goto next step by clicking continue button

					window.jQuery('#lcBoxWrapperFooterUpdateContainer .wrapper-right-button input').click()

				},self.story_config);

				this.wait(5000,function() {
					this.capture('1st_step.png')
				})


				self.fill_2nd_step();
			})
		},

		fill_2nd_step: function() {
			self=this;
			casper.waitForSelector('.priceTier',function() {
				
				this.evaluate(function(config) {
					console.log("Page url " + window.location.href);
					console.log('App title :' + window.jQuery.trim(window.jQuery('#lcBoxWrapperHeaderUpdateContainer').text()))
					date_parts = config['availability_date'].split(' ');


					console.log('Month is : ', window.jQuery('.date-select-month select').val())
					
					// - Date select start
					window.jQuery('.date-select-month select option').filter(function() {
							month_parts = window.jQuery(this).text().split('/')
							return (month_parts[1] == date_parts[0])
					}).attr('selected',true);

					window.jQuery('.date-select-day select option').filter(function() {
							return (parseInt(window.jQuery(this).text()) == parseInt(date_parts[1]))
					}).attr('selected',true);

					window.jQuery('.date-select-year select option').filter(function() {
							return (parseInt(window.jQuery(this).text()) == parseInt(date_parts[2]))
					}).attr('selected',true);

					// - Date select end

					// setting up price tier

					window.jQuery('#pricingTierUpdateContainer select').find('option[value="0"]').attr('selected',true);

					// uncheck the discount boc since our app is free
					window.jQuery('#education-checkbox').attr('checked',false)



					window.jQuery('#lcBoxWrapperFooterUpdateContainer .wrapper-right-button input').click()

				},self.story_config);

				this.wait(5000,function() {
					this.capture('2nd_step.png')
				})

				self.upload_images();
			},null,20000)
		},

		upload_images: function() {
			self = this;

			casper.waitForSelector('#versionInitForm',function() {


				this.echo('Image path : ' + self.story_config['image_path'])

				this.fill('form[name="FileUploadForm_largeAppIcon"]',{
						'filedata' : self.story_config['image_path']+'/large_icon.png'
				});

				this.waitForSelector('.lcUploaderImage.LargeApplicationIcon',function() {
					//Upload screen shots
					while (self.story_config['screenshots_count']!=0){
						this.fill('form[name="FileUploadForm_iPadScreenshots"]',{
							'filedata' : self.story_config['image_path']+'/screenshots/'+self.story_config['screenshots_count']+'.png'
						});

						this.echo('Screen shot upload count : '+self.story_config['screenshots_count'])
						this.wait(5000,function() {
								this.capture(self.story_config['screenshots_count']+'screen.png')
							})
						this.waitWhileVisible('#iPadScreenshots .lcUploadSpinner',function() {
							if (self.story_config['screenshots_count']==1)
								self.fill_last_form()
						},function() {
							this.wait(5000,function() {
								this.capture('image_timed_out.png')
							})
						},40000)

						self.story_config['screenshots_count'] = self.story_config['screenshots_count']-1
					}
				},null,20000)


			},null,20000);

		},


		fill_last_form: function(self) {
			self = this;
			casper.evaluate(function(config) {

				console.log("Page url " + window.location.href);
				console.log('App title :' + window.jQuery.trim(window.jQuery('#lcBoxWrapperHeaderUpdateContainer').text()))

				// -- Version info

				// Set the version number
				window.jQuery('#versionNumberTooltipId').siblings('input').val('1.0');

				//Set the copyright text
				window.jQuery('#copyrightTooltipId').siblings('input').val(config['copyright']);

				// -- Category info

				// Set the primary category
				window.jQuery('#primaryCategoryTooltipId').siblings('select').find('option').filter(function() {
					return (window.jQuery(this).text() == config['primary_category'])
				}).attr('selected',true)

				// Set the secondary category
				window.jQuery('#secondaryCategoryOptionalTooltipId').siblings('select').find('option').filter(function() {
					return (window.jQuery(this).text() == config['secondary_category'])
				}).attr('selected',true)

				// -- Ratings info

				// Set the ratings
				// Apple rating element values are totally fucked up. For some elemenets it is 1,2,3, for some 1,2,3 or 1,3,5
				// Instead of relying on the rating value to find the correct element, we ll use the physcial order the elements arranged
				// So in input config file, the rating values against each field is just order
				// 0 - None, 1 - Infrequent/Mild,  2  - Frequent/Intense
				_.each(config['app_rating'],function(rating,field) {
					switch(field){
						case 'cartoon' :
							// name="1" is actual apple reference for the rating field name
							// Its hard coded, there is no way to do it except this
							// eq is to find the element at index
							window.jQuery('input[name="1"]').eq(rating).attr('checked',true);
							break;
						case 'realistic_violence' :
							window.jQuery('input[name="2"]').eq(rating).attr('checked',true);
							window.updateRating();
							break;
						case 'sadistic_realistic_violence' :
							window.jQuery('input[name="9"]').eq(rating).attr('checked',true);
							window.updateRating();
							break;
						case 'profanity_crude_humor' :
							window.jQuery('input[name="4"]').eq(rating).attr('checked',true);
							window.updateRating();
							break;
						case 'mature_themes' :
							window.jQuery('input[name="6"]').eq(rating).attr('checked',true);
							window.updateRating();
							break;
						case 'horror_themes' :
							window.jQuery('input[name="8"]').eq(rating).attr('checked',true);
							window.updateRating();
							break;
						case 'alchocol_drug_ref' :
							window.jQuery('input[name="5"]').eq(rating).attr('checked',true);
							window.updateRating();
							break;
						case 'simulated_gambling' :
							window.jQuery('input[name="7"]').eq(rating).attr('checked',true);
							window.updateRating();
							break;
						case 'sexual_content_nudity' :
							window.jQuery('input[name="3"]').eq(rating).attr('checked',true);
							window.updateRating();
							break;
						case 'graphic_sexual_content_nudity' :
							window.jQuery('input[name="10"]').eq(rating).attr('checked',true);
							window.updateRating();
							break;
					}
				})

				

				// Set kids app
				if (config['kids_app']){
					window.jQuery('#designed-for-kids-checkbox').attr('checked',true);
					window.jQuery('#designed-for-kids-select option').filter(function() {
						return (window.jQuery(this).val() == config['kids_app']['age_group'])
					}).attr('selected',true)

					window.updateRating();
					window.updateAgeBandSelectVisibility();
				}

				// -- Metadata info

				// Set description
				window.jQuery('#descriptionUpdateSpinnerId').siblings('textarea').text(config['description'])

				// Set keywords
				window.jQuery('#keywordsTooltipId').siblings('input').val(config['keywords'].join(','))

				// Set support url
				window.jQuery('#supportURLTooltipId').siblings('input').val(config['support_url'])

				// Set marketting url
				window.jQuery('#marketingURLOptionalTooltipId').siblings('input').val(config['marketing_url'])

				// Set privacy policy url
				window.jQuery('#privacyPolicyURLTooltipId').siblings('input').val(config['privacy_policy_url'])

				// -- Contact info

				// Since there is no  class or id fields associated with this seciton
				// we need to use the  indexes of .field-section under parent container to find each section

				// Find the fields in contact section
				contact_inputs = window.jQuery('#reviewInfoUpdateContainer .field-section').eq(0).find('input')

				// Fill the contact info

				// Set first name
				contact_inputs.eq(0).val(config['first_name']);

				// Set the last name
				contact_inputs.eq(1).val(config['last_name']);

				// Set email id
				contact_inputs.eq(2).val(config['email']);

				// Set phone number
				contact_inputs.eq(3).val(config['phone']);

				// Set review notes
				if (config['review_notes']){
					review_note = window.jQuery('#reviewInfoUpdateContainer .field-section').eq(1).find('input')
					review_note.text(config['review_notes'])
				}

				// Set demo account details
				if(config['demo_account'] && config['demo_account']['user_name'] && config['password']){
					demo_fields = window.jQuery('#reviewInfoUpdateContainer .field-section').eq(2).find('input')

					// Set user name
					demo_fields.eq(0).val(config['demo_account']['user_name'])

					// Set password
					demo_fields.eq(0).val(config['demo_account']['password'])

				}

				// Set custom EULA
				if (config['EULA'] && config['EULA']['text']){
					// Expand the EULA section
					window.jQuery('.version-eula-text a').eq(0).click()

					// Set EULA text
					window.jQuery('#eulaData textarea').text(config['EULA']['text'])

					//Set EULA country
					if (config['EULA']['countries'] == 'All'){
						window.jQuery('.country-check-all a').eq(0).click()
					}else {
						window.jQuery('.eula-country-wrapper .country-name').each(function() {
							all_countries = config['EULA']['countries'].split(',')
							current_country_elem = window.jQuery(this)
							country_exists = _.find(all_countries,function(country) {
								return (current_country_elem.text()  == country);
							})
							if (country_exists){
								current_country_elem.siblings('.country-check-box').find('input').attr('checked',true)
							}

						})
					}
				}


				//window.jQuery('#lcBoxWrapperFooterUpdateContainer .wrapper-right-button img').click()
				window.jQuery('#versionInitForm').submit()

			},self.story_config)

			casper.wait(5000,function() {
				this.capture('3rd.png')
			})

			self.complete_setup();
		},

		complete_setup: function() {
			self=this;
			casper.waitForSelector('#appInfoLightboxUpdate',function() {

				this.wait(5000,function() {
					this.capture('complete_setup.png')
				})

				this.echo('Got in')
 				this.echo(this.getTitle());
				this.evaluate(function() {
					//window.jQuery('#lcBoxWrapperFooterUpdateContainer .wrapper-right-button img').click()
					window.jQuery('.app-icon.ios').find('a').click();
				})

				self.set_app_ready_state();


			},function() {
					this.echo('Timed out now')
					this.capture('timed_out.png')
			},40000);


		},

		set_app_ready_state: function() {
			self=this;
			
			casper.waitForSelector('#versionInfoLightboxUpdate', function() {

				this.wait(5000,function() {
					this.capture('set_app_ready_state.png')
				})
			
				this.evaluate(function() {
					// Click Ready to upload binary
					window.jQuery('#lcBoxWrapperFooterUpdateContainer .wrapper-right-button input').click()
				})

				self.fill_compliance_form();

			});
		},
		
		fill_compliance_form: function() {
			casper.waitForSelector('.export-comp-wrapper', function() {

				this.wait(5000,function() {
					this.capture('fill_compliance_form.png')
				})

				this.evaluate(function() {
					// Set the export compliance (Does you app designed to use Cryptography? Nope)
					window.jQuery('.export-comp-wrapper #second-set .export-comp-question-group:visible').each(function() {
						window.jQuery(this).find('input[value="false"]').click()
					})

					// Set Content rights
					window.jQuery('#thirdpartyQuestion .export-comp-radio:visible').each(function() {
							window.jQuery(this).find('input[value="false"]').click()
					})

					// Set Advertising Identifier
					window.jQuery('#idfa-radio').parents('.export-comp-radio').find('input[value="false"]').click()

					// Click save
					window.jQuery('#lcBoxWrapperFooterUpdateContainer .wrapper-right-button input').click()
				})
			})
		}



	}	

})().init()









