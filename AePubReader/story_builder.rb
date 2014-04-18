require 'clockwork'
require 'xcoder/rake_task'
require 'net/http'
require 'open-uri'
require 'mini_magick'

#module Clockwork
#	handler do |job|
   
  		def create_image(size)
			image = MiniMagick::Image.open 'cover.png'
			image.resize  size
			image.quality  100
			image.format 'png'
			image.write "mangoreader-app-icon-#{size}.png"
			# gloss_image = MiniMagick::Image.open "gloss-images/gloss-#{size.split('x').first}.png"
			# image = image.composite(gloss_image) do |c|
			# 	c.compose 'over'
			# 	c.geometry "+20+20"
			# end
			# image.write "mangoreader-app-icon-#{size}.png"
		end

	    puts "Starting story builder"

	    #checking for stories available for ios export
		
		# url = URI.parse 'http://api.mangoreader.com/api/v2/livestories/pending?platform=ios'	
		# res = Net::HTTP.start(url.host, url.port) {|http|
		# 	req = Net::HTTP::Get.new url
		# 	http.request req
		# }
		# story_ids = JSON.parse res.body

		story_ids = ['52d0263869702d0905990000']

		story_ids.each do |story_id|
		
			puts "Story ID : #{story_id}" 

			#get the story info
			url = URI "http://api.mangoreader.com/api/v2/livestories/#{story_id}/info"
			story_info = JSON.parse Net::HTTP.get url

			puts "Story title : #{story_info['title']}"


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


			
		    #building the source with the new story info

			project = Xcode.project('MangoReader')

			#get the target object from the project
			target = project.target(:MangoReader)

			source_file = 'MangoStory.zip'

			#get the config object of the selected target
			config = target.config(:Debug)
			config.product_name = "MangoReader" #or title of the story
			config.iphoneos_deployment_target = '7.0'

			# #set the app info here
			config.info_plist do |info|
				info.version = 1.0
				info.display_name = story_info['title']
				info.identifier = "com.mangosense.MangoStory.#{story_info['id']}" #uniqe story id at last
			end

			# #download the cover
			cover_url = "http://mangoreader.com/#{story_info['cover']}"


			File.open("cover.png", "wb") do |saved_file|
			  # the following "open" is provided by open-uri
			  open(cover_url, "rb") do |read_file|
			    saved_file.write(read_file.read)
			  end
			end

			#create a cover image with 1024x1024 resolution to be used while uploading
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


			#TODO copy the game screen shots as well




  			#create app icons using the cover image
			['57x57','76x76','114x114','120x120','144x144','152x152'].each {|x| create_image x}


			builder = config.builder
			builder.clean
			builder.build
			builder.package


			#load the json config for creating new app
			story_config = JSON.load File.open 'story.json'
			story_config['language'] = story_info['info']['language']

			story_config['name'] = story_info['title'] + ' By MangoReader'
			story_config['sku'] = story_id
			story_config['bundle_id_suffix'] = story_id
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
			File.write 'story.json',story_config.to_json

			# Create the new app entry in iTunes connect using the ghost
			system('casperjs ghost.js')

			break

			#TODO
			#1-Upload the app to app store using phantom
			#2-Update the story app status to live
		end


	

	#end

#  every(10.minutes, 'story.job')
#
#end