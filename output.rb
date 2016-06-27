require 'curses'

module Output
	class View
		def initialize(x1, y1, width, height)
			@window = Curses::Window.new(height, width, y1, x1)
		end
		
		def draw(x, y, string, colour)
			@window.setpos(y, x) #reversed order isn't error, library is retarded
			@window.attrset(Curses.color_pair(colour))
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
				draw(x, y, item, Output::Colours::WHITE)
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
		Output::Colours.init_color_pairs
	end
	
	def self.close_console
		Curses.close_screen
	end
	
	module Colours
		#all of them are on black
		WHITE = 1
		BLUE = 2
		RED = 3
		YELLOW = 4
		BLACK = 5
		CYAN = 6
		GREEN = 7
		
		def self.init_color_pairs
			Curses.init_pair(1, Curses::COLOR_WHITE, Curses::COLOR_BLACK)
			Curses.init_pair(2, Curses::COLOR_BLUE, Curses::COLOR_BLACK)
			Curses.init_pair(3, Curses::COLOR_RED, Curses::COLOR_BLACK)
			Curses.init_pair(4, Curses::COLOR_YELLOW, Curses::COLOR_BLACK)
			Curses.init_pair(5, Curses::COLOR_BLACK, Curses::COLOR_BLACK)
			Curses.init_pair(6, Curses::COLOR_CYAN, Curses::COLOR_BLACK)
			Curses.init_pair(7, Curses::COLOR_GREEN, Curses::COLOR_BLACK)
		end
	end
end
