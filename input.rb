require 'curses'

module Input
	def self.get_key(window)
		return window.getch
	end

	def self.get_string
		return Curses.getstr
	end
	
	module SpecialKeys	
	end
end
