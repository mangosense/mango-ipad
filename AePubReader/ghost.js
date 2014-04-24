

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
			mode  = casper.cli.options['mode']
			if (mode=="app"){
				this.createApp()
			}else if (mode=="profile"){
				this.createProfile();
			}
			

		},
		loadConfig: function() {
			var fs = require('fs')
			var data = fs.read('story.json')
			this.story_config = JSON.parse(data)
			//casper.echo(story_config['']['name'])
		},
		createProfile: function() {
			self=this;
			casper.echo('I am in profile')
			casper.start('https://developer.apple.com/account',function() {
				 this.echo(this.getCurrentUrl());
				 this.evaluate(function() {
				 	console.log(decodeURIComponent(window.location.href));
				 })

				 this.fill('form[name="appleConnectForm"]',
						{
							'theAccountName':self.story_config['user_name'],
							'theAccountPW':self.story_config['password']
						},true);
				 self.changeProfile()
			})
			casper.run()
		},
		createApp: function() {
			self = this;
			casper.start('https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa', function() {
			    this.echo(this.getTitle());
			    this.fill('form[name="appleConnectForm"]',
						{
							'theAccountName':self.story_config['user_name'],
							'theAccountPW':self.story_config['password']
						},true);
			    self.clickManageApps()
			});
			casper.run();
		},

		createAppIdentifier: function() {
			self=this;
			casper.thenOpen('https://developer.apple.com/account/ios/identifiers/bundle/bundleCreate.action',function() {
				this.waitUntilVisible('input[name="appIdName"]',function() {
					this.echo('name is visible')
					form_fields = {}
					form_fields['appIdName'] = 'MangoStory ' + self.story_config['story_id']
					form_fields['prefix'] = self.story_config['teamId']
					form_fields['type'] = self.story_config['id_type']
					form_fields[((self.story_config['id_type'] == "explicit") ? 'explicitIdentifier' :  'wildcardIdentifier' )] =  self.story_config['bundle_id']
					this.fill('form[name="bundleSave"]',form_fields,true)

					this.waitForSelector('form[name="bundleSubmit"]',function() {
						this.click('.bottom-buttons .submit');
					})

				})
			})
		},

		changeProfile: function() {
			self.this;
			casper.thenOpen('https://developer.apple.com/account/ios/profile/profileList.action?type=production',function() {
				this.evaluate(function(config) {
					console.log('changing profile')

					// Find our profile row
					grid_row  = window.jQuery('#gbox_grid-table tr').filter(function() {
						return (window.jQuery(this).find('td').filter(function() {
							return (window.jQuery(this).text() == "Mango Story As An App")
						}).length > 0)
					})

					// Expand it
					grid_row.click();

					// Click edit
					grid_row.next().find('.validButtons .edit-button').click()

					
				},self.story_config)

				self.changeAppId()
				
			})
		},

		changeAppId: function() {
			self=this;
			casper.waitUntilVisible('form[name="profileEdit"]',function() {
				this.echo('Inside profile edit')
				this.evaluate(function(config) {
					window.jQuery('select[name="appIdId"] option').filter(function() {
						return (window.jQuery(this).text().indexOf(config['bundle_id']) > -1)
					}).attr('selected',true);

					window.jQuery('.bottom-buttons .submit').click()
				},self.story_config)
				
				self.downloadProfile()

			},function() {
				this.capture('edit_timeout.png')
			},40000)

		},

		downloadProfile: function() {
			casper.waitForSelector('.downloadForm',function() {
				console.log('Inside download form')
				download_url  = 'https://developer.apple.com' + this.evaluate(function() {
					return window.jQuery('.downloadForm .button.blue').attr('href');
				})
				this.download(download_url,'MangoStory.mobileprovision');

			},function() {
				this.capture('download_timeout.png')
			},40000)
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

					window.jQuery('#sKUNumberTooltipId').parent().find('input[type="text"]').val(config['sku']);


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
			},null,40000)
		},

		upload_images: function() {
			self = this;

			casper.waitForSelector('#versionInitForm',function() {


				this.echo('Image path : ' + self.story_config['image_path'])

				this.fill('form[name="FileUploadForm_largeAppIcon"]',{
						'filedata' : self.story_config['image_path']+'/large_icon.png'
				});

				this.waitForSelector('.lcUploaderImage.LargeApplicationIcon',function() {
					self.image_count = 0
					self.handle_upload_screenshot()
				},null,40000)


			},null,40000);

		},

		handle_upload_screenshot: function() {
			self=this
			casper.waitFor(function() {
				return this.evaluate(function(image_count) {
					main_spinner = window.jQuery('#iPadScreenshots .lcUploadSpinner')
					//console.log('Main spinner exists : ' + main_spinner.length)
					// console.log('Main spinner is '+ (!main_spinner.is(':visible') ? 'not' : '') +' visible');
					current_spinner = window.jQuery('#iPadScreenshots .lcUploaderImage:eq('+(image_count)+') .lcUploaderImageWellSpinner');
					// console.log('Current spinner exists : ' + current_spinner.length)
					// console.log('Current spinner is '+ (!current_spinner.is(':visible') ? 'not' : '') +' visible')
					if (!main_spinner.is(':visible') && (!current_spinner.is(':visible') || current_spinner.length == 0)){
						return true;
					}
					else{
						return false;
					}
				},self.image_count)
			}, function() {
				if (self.image_count < 3) {
					self.story_config['screenshots_count'] = self.story_config['screenshots_count']-1;
					self.image_count++;
					this.echo('Screen shot upload count : '+self.image_count)
					this.capture(self.image_count+'screen.png')
					
					this.fill('form[name="FileUploadForm_iPadScreenshots"]',{
						'filedata' : self.story_config['image_path']+'/screenshots/'+self.image_count+'.png'
					});
					self.handle_upload_screenshot();
				}

			},null,60000)

			casper.then(function() {
				if (self.story_config['screenshots_count'] == 0){
					this.echo('Going to fill last form')
					this.wait(10000,function() {
						self.fill_last_form()
					})
				}
			})
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

				if (config['app_rating_all']==null){
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
							case 'medical_treatment_info' : 
								window.jQuery('input[name="11"]').eq(rating).attr('checked',true);
								window.updateRating();
								break;
						}
					})
				}else {
					// Update all app ratings field with same option (Ex: For kids app)
					window.jQuery('.add-rating tr').each(function() {
						window.jQuery(this).find('td.mapping').eq(config['app_rating_all']+1).find('input').click()
						window.updateRating();
					})
				}

				

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
				self.url_to_go =  this.evaluate(function() {
					//window.jQuery('#lcBoxWrapperFooterUpdateContainer .wrapper-right-button img').click()
					return window.jQuery('.app-icon.ios').find('.blue-btn').attr('href')
				})

				self.set_app_ready_state();


			},function() {
					this.echo('Timed out now')
					this.capture('timed_out.png')
			},40000);


		},

		set_app_ready_state: function() {
			self=this;
			
			casper.thenOpen('https://itunesconnect.apple.com'+this.url_to_go,function() {

				this.capture('set_app_ready_state.png')
			
				this.evaluate(function() {
					// Click Ready to upload binary
					window.jQuery('#lcBoxWrapperFooterUpdateContainer .wrapper-right-button input').click()
				})

				self.fill_compliance_form();

			});
		},
		
		fill_compliance_form: function() {
			self=this;
			casper.waitForSelector('.export-comp-wrapper', function() {
				self.current_url = this.getCurrentUrl();
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

				self.endAppCreation()

			},function() {
					this.echo('Timed out now')
					this.capture('timed_out.png')
			},40000)
		},

		endAppCreation: function() {
			self=this;
			casper.waitFor(function() {
				return this.evaluate(function(current_url) {
					return (decodeURIComponent(window.location.href) != current_url)
				},self.current_url)
			},function() {
				this.exit()
			})
		}



	}	

})().init()









