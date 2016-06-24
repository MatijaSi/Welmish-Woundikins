require 'curses'

module Output
	class View
		def initialize(x1, y1, width, height)
			@window = Curses::Window.new(height, width, y1, x1)
		end
		
		def draw(x, y, string)
			@window.setpos(y, x) #reversed order isn't error, library is retarded
			@window.addstr(string)
		end
		
		def clear
			@window.clear
		end
		
		def refresh
			@window.refresh
		end
		
		attr_reader :window
	end

	class StatusView < View
		def initialize(x1, y1, width, height)
			super
			@buffer = []
		end
		
		def draw_buffer
			self.clear
			x = 0
			y = 0
			if @buffer.count >= STATUS_SIZE[1]
				to_display = @buffer.reverse.first(STATUS_SIZE[1]).reverse
			else
				to_display = @buffer
			end
			
			to_display.each {|item|
				draw(x, y, item)
				y += 1}		
			self.refresh
		end
		
		def add_to_buffer(string)
			@buffer.push(string)
		end
		
		attr_reader :buffer
	end
	
	def self.setup_console
		Curses.init_screen
		Curses.start_color
		Curses.noecho
		Curses.cbreak
		Curses.nonl
		Curses.curs_set(0)
	end
	
	def self.close_console
		Curses.close_screen
	end
end
