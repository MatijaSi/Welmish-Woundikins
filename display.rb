require_relative "BearLibTerminal.rb"

module Display
	#modify the coords to fit on view
	def self.snap_to_view(coords, view) # coords is [x, y] view is [x1, y1, x2, y2]
		result = [coords[0] - view[0], coords[1] - view[1]]
		
		if (view[0] < result[0]) && (result[0] < view[2]) && (view[1] < result[1]) && (result[1] < view[3])
			return result
		else
			return false
		end
	end
	
	#modify the coords to fit on player camera
	def self.snap_to_camera(coords, player, view)
		min_x = player.x - (view[2] - view[0]) / 2
		max_x = player.x + (view[2] - view[0]) / 2
		min_y = player.y - (view[3] - view[1]) / 2
		max_y = player.y + (view[3] - view[1]) / 2
		
		result = [coords[0] - min_x, coords[1] - min_y]
		
		return result
	end
	
	def self.message_draw(view, x, y, msg, color) #for statuses, messages, etc
		dx = x + view[0]
		dy = y + view[1]
		
		Terminal.color(color)
		Terminal.print(dx, dy, msg)
	end
	
	def self.draw(tile, player, view, color) #for map
		coords = [tile.x, tile.y]
		coords = snap_to_camera(coords, player, view)
		coords = snap_to_view(coords, view)
		
		if coords
			x = coords[0]
			y = coords[1]
	
			Terminal.color(color)
			Terminal.print(x, y, tile.char)
		end
	end
	
	def self.print_status(status_buffer) #draw messages from buffer
		lines = $status_view[3] - $status_view[1] - 1 #for use
		i = -1
		until lines == 0
			if status_buffer[i] != nil
				msg = status_buffer[i]
			else
				msg = " "
			end
			message_draw($status_view, 0, lines, msg, "light grey")
			lines -= 1
			i -= 1
		end
	end
end
