require 'mini_magick'
require 'net/http'
require 'open-uri'

@story_id = ARGV[0]
url = URI "http://api.mangoreader.com/api/v2/livestories/#{@story_id}/info"
@story_info = JSON.parse Net::HTTP.get url

cover_url = "http://mangoreader.com/#{@story_info['cover']}"

File.open("cover.png", "wb") do |saved_file|
  # the following "open" is provided by open-uri
  open(cover_url, "rb") do |read_file|
    saved_file.write(read_file.read)
  end
end


def create_image(size)
			image = MiniMagick::Image.open 'cover.png'
			image.resize  size
			image.quality  100
			image.format 'png'
			image.write "../Store Images/mangoreader-app-icon-#{size.gsub('!','')}.png"
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
					main_image = MiniMagick::Image.open "../Store Images/mangoreader-app-icon-#{size.gsub('!','')}.png"
				 	main_image.combine_options do |c|
						c.gravity 'SouthWest'
						left = -4
						if size == "72x72!" || size == "76x76!" || size == "80x80!" || size == "114x114!"
							left = -5
						elsif size == "120x120!" || size == "144x144!" || size == "152x152!"
							left = -7
						end
						c.draw 'image Over '+left.to_s+',0 0,-2 "appicon-'+icon.split('x').first+'.png"'
					end
					main_image.write "../Store Images/mangoreader-app-icon-#{size.gsub('!','')}.png"
				end
			end
end

#create app icons using the cover image
['57x57!','60x60!','72x72!','76x76!','80x80!','114x114!','120x120!','144x144!','152x152!'].each {|x| create_image x}