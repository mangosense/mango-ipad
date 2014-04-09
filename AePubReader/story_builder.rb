require 'clockwork'
require 'xcoder/rake_task'
require 'net/http'


module Clockwork
  handler do |job|
   
    puts "Starting story builder"

    #checking for stories available for ios export


    #download the zip file 


    #rename to MangoStory.zip and place it in the base directory

    #building the source with the new story info

	project = Xcode.project('MangoReader')

	#get the target object from the project
	target = project.target(:MangoReader)

	#get the config object of the selected target
	config = target.config(:Debug)
	config.product_name = "Mango Story App" #or title of the story
	config.iphoneos_deployment_target = '7.0'

	#set the app info here
	config.info_plist do |info|
		info.version = info.version.to_i + 1
		info.display_name = ENV['title']
		info.identifier = "com.mangosense.storyapp.#{ENV['app_id']}" #uniqe story id at last
	end

	builder = config.builder
	builder.clean
	builder.build



  end

  every(10.minutes, 'story.job')

end