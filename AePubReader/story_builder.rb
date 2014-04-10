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
		
		url = URI.parse 'http://api.mangoreader.com/api/v2/livestories/pending?platform=ios'	
		res = Net::HTTP.start(url.host, url.port) {|http|
			req = Net::HTTP::Get.new url
			http.request req
		}
		story_ids = JSON.parse res.body

		story_ids = [story_ids.sample]

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
			config.product_name = "Mango Story App" #or title of the story
			config.iphoneos_deployment_target = '7.0'

			#set the app info here
			config.info_plist do |info|
				info.version = 1.0
				info.display_name = story_info['title']
				info.identifier = "com.mangosense.MangoStory.#{story_info['id']}" #uniqe story id at last
			end

			#download the cover
			cover_url = "http://mangoreader.com/#{story_info['cover']}"


			File.open("cover.png", "wb") do |saved_file|
			  # the following "open" is provided by open-uri
			  open(cover_url, "rb") do |read_file|
			    saved_file.write(read_file.read)
			  end
			end

  			#create app icons using the cover image
			['57x57','76x76','114x114','120x120','144x144','152x152'].each {|x| create_image x}


			builder = config.builder
			builder.clean
			builder.build
			break

			#TODO
			#1-Upload the app to app store using phantom
			#2-Update the story app status to live
		end


	

	#end

#  every(10.minutes, 'story.job')
#
#end