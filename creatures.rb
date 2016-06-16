require_relative "mapping.rb"
require_relative "utilities.rb"
require_relative "combat.rb"

module Creatures
	class GenericCreature < Mapping::Tile
		def initialize(x, y)
			super
			@char = 'C'
			@blocked = nil
			@seen = false
			@color_in_pov = "light red"
			@color_not_pov = "darker red"
			@hp = 20
			@dmg = 5
		end
		
		def draw(player)
			super
			@seen = false
		end
		
		def move(to_x, to_y)
			@x += to_x
			@y += to_y
		end
		
		attr_accessor :hp, :dmg
	end
	
	class Goblin < GenericCreature
		def initialize(x, y)
			super
			@char = 'G'
			@hp = 5
			@dmg = 3
		end
		
		def act(player)
			x = [-1, 0, 1].sample
			y = [-1, 0, 1].sample
			
			if (@x + x) == player.x && (@y + y) == player.y
				Combat.attack(self, player)
			elsif not Utilities.is_blocked?($map.tiles, @x + x, @y + y)
				move(x, y)
			end
		end
	end
	
	class Player < GenericCreature
		def initialize(x, y)
			super
			@fov = 6
			@char = '@'
			@color = "amber"
			@hp = 30
			@dmg = 7
			@name = "Jerrold"
		end
		
		def draw
			Display.draw(self, self, $map_view, @color)
		end
		
		def state
			Display.message_draw($player_view, 0, 0, "Name: #{@name}", "light grey")
			Display.message_draw($player_view, 0, 1, "x: #{@x}", "light grey")
			Display.message_draw($player_view, 0, 2, "y: #{@y}", "light grey")
			Display.message_draw($player_view, 0, 3, "hp: #{@hp}", "light grey")
			Display.message_draw($player_view, 0, 4, "dmg: #{@dmg}", "light grey")
		end
		
		attr_reader :fov
	end
end
