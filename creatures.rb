require_relative "mapping.rb"
require_relative "combat.rb"
require_relative "input.rb"

module Creatures
	class GenericCreature < Mapping::Tile
		def initialize(x, y)
			super
			@char = 'C'
			@blocked = nil
			@fov = 5
			@max_hp = 50
			@hp = @max_hp
			@dmg = 12
			@name = "Cthulhu"
			@colour = Output::Colours::RED
			@colour_not_fov = Output::Colours::BLACK
			@regen = 1
			@type = :monster
		end
		
		def regen #restore some of lost lives
			if @hp < @max_hp
				@hp += @regen
				@hp = @max_hp if @hp > @max_hp
			end
		end
		
		def death
			$status_view.add_to_buffer("#{@name} died.")
			$status_view.draw_buffer
			$monsters.delete(self)
		end
		
		def act
			dirs = [-1, 0, +1]
			xdir = dirs.sample
			ydir = dirs.sample
			move(xdir, ydir) unless not Mapping.exists($map.tiles, @x + xdir, @y + ydir) && Mapping.exists($map.tiles, @x + xdir, @y + ydir).blocked
		end
		
		def move(to_x, to_y)
			@x += to_x
			@y += to_y
		end
		
		attr_reader :fov, :dmg, :name, :max_hp
		attr_accessor :hp
	end
	
	class Player < GenericCreature
		def initialize(x, y, name, pclass)
			super(x, y)
			@char = '@'
			@name = name.capitalize
			@type = :player
			@kills = 0
			
			case pclass
			when 'b'
				@class = "Warrior"
			when 'a'
				@class = "Rogue"
			when 'c'
				@class = "Barbarian"
			end
			
			@fov = 4 if @class == "Warrior" || @class == "Barbarian"
			@fov = 6 if @class == "Rogue"
			
			@max_hp = 100
			@max_hp = 80 if @class == "Barbarian"
			@hp = @max_hp
			@dmg = 10 if @class == "Rogue"
			@dmg = 15 if @class == "Warrior" || @class == "Barbarian"
			
			@colour = Output::Colours::YELLOW
			@regen = 2
		end
		
		attr_reader :class
		attr_accessor :kills
		
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
			when '.' #wait
				dirx = 0
				diry = 0
				
			#misc
			when '?'
				$status_view.add_to_buffer("Nethack keys for movement and attacking,")
				$status_view.add_to_buffer("'?' for help, 'q' to quit, '.' to wait.")
				$status_view.add_to_buffer("Good luck.")
				$status_view.draw_buffer
				$status_view.refresh
				
				key = Input.get_key($main_view.window)
				$player.act(key)
			when 'q' #exit
				Output.close_console
				exit
			else
				$status_view.add_to_buffer("I don't know that key,")
				$status_view.add_to_buffer("Click '?' for help")
				$status_view.draw_buffer
				$status_view.refresh
				
				key = Input.get_key($main_view.window)
				$player.act(key)
			end
			
			#recalc damage
			if @hp <= @max_hp / 4 && @class == "Barbarian"
				@dmg = 20
			end
			
			monster = Mapping.exists($monsters, @x + dirx, @y + diry) 
			if monster
				Combat.attack(self, monster)
			else
				move(dirx, diry) unless Mapping.exists($map.tiles, @x + dirx, @y + diry).blocked
			end
			
			true
		end
		
		def state(view)
			colour = Output::Colours::WHITE
			view.draw(0, 0, "#{@name} the #{@class}", colour)
			view.draw(0, 1, "x: #{@x}", colour)
			view.draw(0, 2, "y: #{@y}", colour)
			view.draw(0, 4, "health: #{@hp}/#{@max_hp}", colour)
			view.draw(0, 5, "regen per turn: #{@regen}", colour)
			view.draw(0, 6, "damage: #{@dmg}", colour)
			view.draw(0, 8, "kills: #{@kills}", colour)
		end
	end
	
	class Goblin < GenericCreature
		def initialize(x, y)
			super
			@char = 'G'
			@dmg = 12
			@max_hp = 40
			@hp = @max_hp
			@name = "Goblin"
			@colour = Output::Colours::GREEN
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
	
	class GoblinWarlord < Goblin
		def initialize(x, y)
			super
			@char = 'G'
			@name = "Goblin Warlord"
			@colour = Output::Colours::RED
			@dmg = 15
			@max_hp = 50
			@hp = @max_hp
			@regen = 3
		end
		
		def act
			if $player.in_fov?(self) && rand(1..6) == 6
				$status_view.add_to_buffer("#{@name} summoned his followers!")
				$status_view.draw_buffer
				$status_view.refresh
				
				dirs = [-1, 0, 1]
				i = 0
				j = 0
				until i >= 2
					until j >= 2
						unless Mapping.exists($map.tiles, @x + dirs[i], @y + dirs[j]).blocked && i == j && i == 0 && Mapping.exists($monsters, @x + dirs[i], @y + dirs[j])
							if rand(1..6) == 6
								$monsters.push(GoblinWarlord.new(@x + dirs[i], @y + dirs[j]))
							else
								$monsters.push(Goblin.new(@x + dirs[i], @y + dirs[j]))
							end
						end
						
						j += 1
					end
						j = 0
						i += 1
				end
			else
				super
			end
		end
	end
	
	class Scoundrel < Goblin
		def initialize(x, y)
			super
			@char = 'S'
			@dmg = 10
			@name = "Scoundrel"
			@colour = Output::Colours::CYAN
		end
		
		def act
			if @hp < (@max_hp / 2) && $player.in_fov?(self) #run
				xdir = -(($player.x - @x) / ($player.x - @x).abs) unless $player.x == @x
				xdir = 0 if $player.x == @x
				
				ydir = -(($player.y - @y) / ($player.y - @y).abs) unless $player.y == @y
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
			@dmg = 15
			@max_hp = 75
			@hp = @max_hp
			@name = "Nazgul"
			@regen = 5
			@colour = Output::Colours::RED
			@fov = 8
		end
		
		def death
			$status_view.add_to_buffer("Congrats! You won by killing the dark one.")
			$status_view.add_to_buffer("Quit by pressing 'q'")
			$status_view.draw_buffer
		
			while 1
				if Input.get_key($main_view.window) == 'q'
					Output.close_console
					exit
				end
			end
		end
	end
	
	class Bomber < Goblin
		def initialize(x, y)
			super
			@char = 'B'
			@dmg = 1
			@max_hp = 5
			@hp = @max_hp
			@name = "Bomber"
			@regen = 0
			@colour = Output::Colours::RED
		end
		
		def act
			if ($player.x - @x).abs < 2 && ($player.y - @y).abs < 2
				self.death
			else
				super
			end
		end
		
		def death
			array = $monsters + [$player]
			array.each {|being|
				if (being.x - @x).abs < 3 && (being.y - @y).abs < 3
					being.hp -= 30
				end}
			
			$status_view.add_to_buffer("#{@name} exploded.")
			$status_view.draw_buffer
			$monsters.delete(self)
		end
	end
end
