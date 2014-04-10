require 'clockwork'
require 'xcoder/rake_task'
require 'net/http'
require 'open-uri'

module Clockwork
	handler do |job|
   
	    puts "Starting story builder"

	    #checking for stories available for ios export
		
		url = URI.parse 'http://api.mangoreader.com/api/v2/livestories/pending?platform=ios'	
		res = Net::HTTP.start(url.host, url.port) {|http|
			req = Net::HTTP::Get.new url
			http.request req
		}
		story_ids = JSON.parse res.body

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
				info.version = info.version.to_i + 1
				info.display_name = story_info['title']
				info.identifier = "com.mangosense.storyapp.#{story_info['id']}" #uniqe story id at last
			end

			builder = config.builder
			builder.clean
			builder.build


			#TODO
			#1-Upload the app to app store using phantom
			#2-Update the story app status to live
		end

	
	end

  every(10.minutes, 'story.job')

end