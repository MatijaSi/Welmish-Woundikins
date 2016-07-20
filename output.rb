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
				draw(x, y, item, Output::Colours::GRAY)
				y += 1}		
		end
		
		def add_to_buffer(string)
			@buffer.push(string)
			self.draw_buffer
		end
		
		attr_reader :buffer
	end
	
	def self.setup_console
		Curses.init_screen
		Curses.start_color
		Output::Colours.init_color_pairs
		Curses.noecho
		Curses.cbreak
		Curses.nonl
		Curses.curs_set(0)
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
		
		BROWN = 11
		WARMBROWN = 12
		GOLD = 13
		GRAY = 14
		PURPLE = 15
		
		def self.init_color_pairs
			Curses.init_pair(1, Curses::COLOR_WHITE, Curses::COLOR_BLACK)
			Curses.init_pair(2, Curses::COLOR_BLUE, Curses::COLOR_BLACK)
			Curses.init_pair(3, Curses::COLOR_RED, Curses::COLOR_BLACK)
			Curses.init_pair(4, Curses::COLOR_YELLOW, Curses::COLOR_BLACK)
			Curses.init_pair(5, Curses::COLOR_BLACK, Curses::COLOR_BLACK)
			Curses.init_pair(6, Curses::COLOR_CYAN, Curses::COLOR_BLACK)
			Curses.init_pair(7, Curses::COLOR_GREEN, Curses::COLOR_BLACK)
			
			Curses.init_pair(BROWN, 94, Curses::COLOR_BLACK)
			Curses.init_pair(WARMBROWN, 172, Curses::COLOR_BLACK)
			Curses.init_pair(GOLD, 220, Curses::COLOR_BLACK)
			Curses.init_pair(GRAY, 248, Curses::COLOR_BLACK)
			Curses.init_pair(PURPLE, 128, Curses::COLOR_BLACK)
		end
	end
	
	def self.draw_gui_decorations(player)
		row = "═" * (MAIN_SIZE[0] - 1)
		column = Array.new((MAIN_SIZE[1] - 1), "║" )
		column_cont = Array.new((STATUS_SIZE[1]), "║")
		box1 = "╔══╣"
		box2 = "║  ║"
		box3 = "║  ║"
		box4 = "╩══╣"
	
		border_colour = Output::Colours::GRAY
		emblem_okay = Output::Colours::GOLD
		emblem_wounded = Output::Colours::RED
		
		$main_view.draw(0, (MAIN_SIZE[1] - 1), row, border_colour)
		
		i = 0
		column.each {|char|
			$main_view.draw((MAIN_SIZE[0] - 1), i, char, border_colour)
			i += 1}
		i = 0
		column_cont.each {|char|
			$status_view.draw((STATUS_SIZE[0] - 1), i, char, border_colour)
			i += 1}
	
		$main_view.draw((MAIN_SIZE[0] - 4), (MAIN_SIZE[1] - 4), box1, border_colour)
		$main_view.draw((MAIN_SIZE[0] - 4), (MAIN_SIZE[1] - 3), box2, border_colour)
		$main_view.draw((MAIN_SIZE[0] - 4), (MAIN_SIZE[1] - 2), box3, border_colour)
		$main_view.draw((MAIN_SIZE[0] - 4), (MAIN_SIZE[1] - 1), box4, border_colour)
		
		#emblem
		if player.hp < (player.max_hp / 4)
			emblem_colour = emblem_wounded
		else
			emblem_colour = emblem_okay
		end
	
		$main_view.draw((MAIN_SIZE[0] - 3), (MAIN_SIZE[1] - 3), "##", emblem_colour)
		$main_view.draw((MAIN_SIZE[0] - 3), (MAIN_SIZE[1] - 2), "##", emblem_colour)
	end
end
