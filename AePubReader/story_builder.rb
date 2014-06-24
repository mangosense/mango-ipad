require 'clockwork'
require 'xcoder/rake_task'
require 'net/http'
require 'open-uri'
require 'mini_magick'
require 'nokogiri'
require 'digest/md5'
require 'FileUtils'
#module Clockwork
#	handler do |job|
   
   		user_name = ARGV[0]
   		password = ARGV[1]
   		app_creation = ARGV[2] || 'no'
   		app_upload = ARGV[3] || 'no'
   		just_distribute = ARGV[4] || no
   		story_id = nil
   		story_config = nil
  		
  		def create_image(size)
			image = MiniMagick::Image.open 'cover.png'
			image.resize  size
			image.quality  100
			image.format 'png'
			image.write "Store Images/mangoreader-app-icon-#{size.gsub('!','')}.png"
			sleep 2
			#MangoIcon watermarking
			water_mark = MiniMagick::Image.open 'appicon.png'
			['57x57!=>30x30!','76x76!=>41x41!','114x114!=>44x44!','120x120!=>52x52!','144x144!=>52x52!','152x152!=>62x62!'].each do |icon_map|
				actual,icon = icon_map.split '=>'
				if (actual==size)
					unless File.exists? "appicon-#{icon.split('x').first}.png"
					 	water_mark.resize icon
					 	water_mark.quality 100
					 	water_mark.format 'png'
						water_mark.write "appicon-#{icon.split('x').first}.png"
						sleep 2
					end 
					main_image = MiniMagick::Image.open "Store Images/mangoreader-app-icon-#{size.gsub('!','')}.png"
				 	main_image.combine_options do |c|
						c.gravity 'SouthWest'
						c.draw 'image Over -1,0 0,-2 "appicon-'+icon.split('x').first+'.png"'
					end
					main_image.write "Store Images/mangoreader-app-icon-#{size.gsub('!','')}.png"
				end
			end
		end


		def create_json

			puts "Story ID : #{story_id}" 

			#get the story info
			url = URI "http://api.mangoreader.com/api/v2/livestories/#{story_id}/info"
			story_info = JSON.parse Net::HTTP.get url

			puts "Story title : #{story_info['title']}"


			#load the json config for creating new app
			story_config = JSON.load File.open 'story.json'
			story_config['language'] = story_info['info']['language']

			story_config['name'] = "#{story_info['title']} - Interactive Story"
			story_config['title'] = "#{story_info['title']}"
			story_config['sku'] =  "Mango_#{story_id}"
			story_config['bundle_id'] = "com.mangostory.#{story_id}"
			story_config['app_rating_all'] = 0
			require 'date'
			story_config['availability_date'] = Date.today.strftime('%b %d %Y')
			story_config['description'] = story_info['synopsis']
			keywords = []
			keywords << story_info['info']['language']
			keywords << story_info['info']['categories']
			keywords << story_info['info']['tags']
			keywords << story_info['info']['subjects']
			keywords << story_info['info']['publisher']
			story_config['keywords'] = keywords.select {|x| x!=''}.flatten.compact
			temp_keys = story_config['keywords'].join(',')[0..99]
			temp_splitted = temp_keys.split(',')
			#check if the integrity of the last keyword after taking the 100 characters by checking it against the keyword list
			unless keywords.include? temp_splitted.last
				#If its not there, assume the last keyword is partial. And remove it
				temp_splitted.pop
			end
			story_config['keywords'] = temp_splitted
			story_config['user_name'] = user_name
			story_config['password'] = password
			story_config['id_type'] = 'explicit'
			File.write 'story.json',story_config.to_json
			story_config
		end

		def download_story
			#download the zip file by login using admin account
			url = URI.parse  'http://api.mangoreader.com/api/v2/sign_in'  
			res = Net::HTTP.post_form(url, 'email' => 'rameshvel@gmail.com', 'password' => 'mango@123') 
			auth_out = JSON.parse res.body
			auth_token = auth_out['auth_token']

			puts "Auth token : #{auth_token}"


			#download

			File.open("MangoStory.zip", "wb") do |saved_file|
			  # the following "open" is provided by open-uri
			  open("http://api.mangoreader.com/api/v2/livestories/#{story_id}/zipped?auth_token=#{auth_token}&email=rameshvel@gmail.com", "rb") do |read_file|
			    saved_file.write(read_file.read)
			  end
			end

		end

		def make_images
			#download the cover
			cover_url = "http://mangoreader.com/#{story_info['cover']}"


			File.open("cover.png", "wb") do |saved_file|
			  # the following "open" is provided by open-uri
			  open(cover_url, "rb") do |read_file|
			    saved_file.write(read_file.read)
			  end
			end

			#create a cover image with 1024x1024 resolution to be used while uploading
			FileUtils.mkdir_p "images/screenshots"
			image = MiniMagick::Image.open 'cover.png'
			image.resize  '1024x1024!'
			image.quality  100
			image.format 'png'
			image.write "images/large_icon.png"


			image = MiniMagick::Image.open 'cover.png'
			image.resize  '1024x768!'
			image.quality 100
			image.format 'png'
			image.write "images/screenshots/1.png"

			#copy 3 images to images/en folder. These will be treated as iPad screen shots whe upload
			require 'zip'
			img_count = 2
			Zip::File.open('MangoStory.zip') do |zip_file|
				zip_file.each do |entry|
					if img_count <= 3
						if entry.name.start_with?('res') && (entry.name != 'res') && (entry.name.end_with?('.png') || entry.name.end_with?('.jpg'))
							# puts "Image found #{entry.game}"
							extn = entry.name.split('.').last
							File.delete "images/screenshots/#{img_count}.#{extn}" if File.exists? "images/screenshots/#{img_count}.#{extn}"
							image = MiniMagick::Image.read entry.get_input_stream.read
							image.resize  '1024x768!'
							image.quality 100
							image.format 'png'
							image.write "images/screenshots/#{img_count}.png"
							#entry.extract "images/screenshots/#{img_count}.#{extn}"
							img_count=img_count+1
						end
					end
				end
			end

  			#create app icons using the cover image
			['57x57!','76x76!','114x114!','120x120!','144x144!','152x152!'].each {|x| create_image x}

		end

		def build_app
			#building the source with the new story info
			project = Xcode.project('MangoReader')

			#get the target object from the project
			target = project.target(:MangoReader)

			source_file = 'MangoStory.zip'

			#get the config object of the selected target
			config = target.config(:Release)
			config.product_name = "MangoReader" #or title of the story
			config.iphoneos_deployment_target = '7.1'

			# #set the app info here
			config.info_plist do |info|
				info.version = 1.0
				info.display_name = story_info['title']
				#info.identifier = "com.mangostory.#{story_info['id']}" #uniqe story id at last
				info.identifier = "com.mangostory.#{story_id}"
			end


			builder = config.builder
			builder.profile = 'MangoStory.mobileprovision' # this is downloaded by casper profile creation
			builder.identity = 'iPhone Distribution: Jagdish Repaswal (LNHPT8X9T3)'
			builder.clean
			builder.build :sdk => :iphoneos
			builder.package



		end

		def verify_and_distribute
			# Create the app 
			if app_creation == 'yes'
				system('casperjs ghost.js --mode=app')
			end

			if app_upload == 'yes'
				iTMSTransporter = '/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/MacOS/itms/bin/iTMSTransporter'
				# call to get the vendor meta data xml
				system("'#{iTMSTransporter}' -u #{user_name} -p #{password} -v off -m  lookupMetadata -vendor_id #{story_id}  -destination /tmp/#{story_id} ")
				
				# Get the apple id of the newly created app 
				apple_id =`cat /tmp/#{story_id}/#{story_id}.itmsp/metadata.xml | grep apple-id | cut -d '>' -f2 | cut -d '<' -f1`.strip


				# copy the release ipa to app uploads folder
				ipa_file = 'MangoReader-Release-1.0.ipa'
				File.cp("Build/Products/Release-iphoneos/#{ipa_file}","/tmp/#{story_id}/#{story_id}.itmsp")

				# verify the app
				system("'#{iTMSTransporter}' -m verify -f /tmp/#{story_id}/ -u #{user_name} -p #{password}")


			
				ipa_size = File.size "/tmp/#{story_id}/#{ipa_file}"
				ipa_checksum = Digest::MD5.file("/tmp/#{story_id}/#{ipa_file}").hexdigest

				asset_config = " <software_assets>
					            <asset type='bundle'>
					                <data_file>
					                    <size>
					                        #{ipa_size}
					                    </size>
					                    <file_name>
					                        #{ipa_file}
					                    </file_name>
					                    <checksum type='md5'>
					                        #{ipa_checksum}
					                    </checksum>
					                </data_file>
					            </asset>
					        </software_assets>"

				doc=Nokogiri::XML(open("/tmp/#{story_id}/#{story_id}.itmsp/metadata.xml"))
				software_section = doc.at_css "software_metadata"
				asset_node=Nokogiri::XML::Node.new asset_config,doc
				software_section << asset_node

				FileUtils.mkdir_p "/tmp/#{story_id}/#{story_id}.itmsp"
				File.write("/tmp/#{story_id}/#{story_id}.itmsp/metadata.xml",doc.to_xml)

				# Create success & failue & log folders
				FileUtils.mkdir_p "/tmp/#{story_id}/success"
				FileUtils.mkdir_p "/tmp/#{story_id}/failure"
				FileUtils.mkdir_p "/tmp/#{story_id}/log/errors"

				# Upload the ipa

				system("'#{iTMSTransporter}' -u #{user_name} -p #{password} -m upload -v critical -f /tmp/#{story_id} -success /tmp/#{story_id}/success -failure /tmp/#{story_id}/failure -errorLogs /tmp/#{story_id}/log/errors -loghistory /tmp/#{story_id}/log/itms.log")


			end
		end

	    puts "Starting story builder"

	    #checking for stories available for ios export
		
		# url = URI.parse 'http://api.mangoreader.com/api/v2/livestories/pending?platform=ios'	
		# res = Net::HTTP.start(url.host, url.port) {|http|
		# 	req = Net::HTTP::Get.new url
		# 	http.request req
		# }
		# story_ids = JSON.parse res.body

		story_ids = ['53846d1569702d472b030000']

		story_ids.each do |storyid|

			story_id = storyid

			if just_distribute
				verify_and_distribute
			else
				story_config = create_json story_id
				download_story story_id

				# Create the profile & download provisioing profile to be used in xcode build
				if app_creation == 'yes'
					 system('casperjs ghost.js --mode=profile')
				end
			    
				make_images
				
				#TODO copy the game screen shots as well

				build_app

				verify_and_distribute
			end
		
			

			break

		end


	

	#end

#  every(10.minutes, 'story.job')
#
#end