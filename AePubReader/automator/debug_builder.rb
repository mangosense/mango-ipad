require 'xcoder/rake_task'
require 'net/http'
require 'open-uri'

@story_id = ARGV[0]


url = URI "http://api.mangoreader.com/api/v2/livestories/#{@story_id}/info?platform=ios_automation"
@story_info = JSON.parse Net::HTTP.get url

source_dir = Dir.pwd.gsub '/automator', ''

#building the source with the new story info
project = Xcode.project(source_dir+'/MangoReader.xcodeproj')

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
	info.display_name = @story_info['title']
	#info.identifier = "com.mangostory.#{@story_info['id']}" #uniqe story id at last
	info.identifier = "com.mangosense.MangoStory.#{@story_id}"
end


builder = config.builder
builder.profile = 'Story_App_Dev_Profile.mobileprovision' # this is downloaded by casper profile creation
builder.identity = 'iPhone Developer: Jagdish Repaswal (FKU6U57CR3)'
builder.clean
builder.build :sdk => :iphoneos
builder.package
