require_relative "mapping.rb"
require_relative "combat.rb"

module Creatures
	class GenericCreature < Mapping::Tile
		def initialize(x, y)
			super
			@char = 'C'
			@blocked = nil
			@fov = 5
			@hp = 20
			@dmg = 2
			@name = "Cthulhu"
			@colour = Output::Colours::RED
			@colour_not_fov = Output::Colours::BLACK
		end
		
		def act
			dirs = [-1, 0, +1]
			xdir = dirs.sample
			ydir = dirs.sample
			move(xdir, ydir) unless Mapping.exists($map.tiles, @x + xdir, @y + ydir).blocked
		end
		
		def move(to_x, to_y)
			@x += to_x
			@y += to_y
		end
		
		attr_reader :fov, :dmg, :name
		attr_accessor :hp
	end
	
	class Player < GenericCreature
		def initialize(x, y)
			super
			@char = '@'
			@name = "Jerrold"
			@fov = 6
			@hp = 40
			@dmg = 5
			@colour = Output::Colours::YELLOW
		end
		
		def check_if_dead
			if @hp <= 0
				$status_view.add_to_buffer("You died.")
				$status_view.add_to_buffer("Press q to quit.")
				$status_view.draw_buffer
				
				while 1
					if Input.get_key($main_view.window) == 'q'
						Output.close_console
						exit
					end
				end
			end
		end
		
		def act(key)
			#default movement values
			dirx = 0
			diry = 0
			
			case key 
			
			#movement (and combat)
			when 'k' #up
				diry = -1
			when 'j' #down
				diry = 1
			when 'h' #left
				dirx = -1
			when 'l' #right
				dirx = 1
			when 'y' , 'z' #up-left
				dirx = -1
				diry = -1
			when 'u' #up-right
				dirx = 1
				diry = -1
			when 'b' #down-left
				dirx = -1
				diry = 1
			when 'n' #down-right
				dirx = 1
				diry = 1
			end
			
			monster = Mapping.exists($monsters, @x + dirx, @y + diry) 
			if monster
				Combat.attack(self, monster)
			elsif $boss.x == @x + dirx && $boss.y == @y + diry
				Combat.attack(self, $boss)
			else
				move(dirx, diry) unless Mapping.exists($map.tiles, @x + dirx, @y + diry).blocked
			end
			
			true
		end
		
		def state(view)
			colour = Output::Colours::WHITE
			view.draw(0, 0, "#{@name}", colour)
			view.draw(0, 1, "x: #{@x}", colour)
			view.draw(0, 2, "y: #{@y}", colour)
			view.draw(0, 4, "health: #{@hp}", colour)
			view.draw(0, 5, "damage: #{@dmg}", colour)
		end
	end
	
	class Goblin < GenericCreature
		def initialize(x, y)
			super
			@char = 'G'
			@dmg = 3
			@hp = 10
			@name = "Goblin"
		end
		
		def act
			if (($player.x - @x) == 0 || ($player.x - @x).abs == 1) && (($player.y - @y) == 0 || ($player.y - @y).abs == 1)
				Combat.attack(self, $player)
			elsif $player.in_fov?(self)
				xdir = (($player.x - @x) / ($player.x - @x).abs) unless $player.x == @x
				xdir = 0 if $player.x == @x
				
				ydir = (($player.y - @y) / ($player.y - @y).abs) unless $player.y == @y
				ydir = 0 if $player.y == @y
				
				move(xdir, ydir) unless Mapping.exists($map.tiles, @x + xdir, @y + ydir).blocked || Mapping.exists($monsters, @x + xdir, @y + ydir) || (@x + xdir == $player.x && @y + ydir == $player.y)
			else
				super
			end
		end
	end
	
	class Nazgul < Goblin
		def initialize(x, y)
			super
			@char = 'N'
			@dmg = 7
			@hp = 20
			@name = "Nazgul"
		end
	end
end
