require 'mini_magick'
def create_image(size)
			image = MiniMagick::Image.open 'cover.jpg'
			image.resize  size
			image.quality  100
			image.format 'png'
			image.write "mangoreader-app-icon-#{size.gsub('!','')}.png"
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
					main_image = MiniMagick::Image.open "mangoreader-app-icon-#{size.gsub('!','')}.png"
				 	main_image.combine_options do |c|
						c.gravity 'SouthWest'
						c.draw 'image Over -1,0 0,-2 "appicon-'+icon.split('x').first+'.png"'
					end
					main_image.write "mangoreader-app-icon-#{size.gsub('!','')}.png"
				end
			end
end