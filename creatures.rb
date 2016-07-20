require_relative "input.rb"
require_relative "output.rb"
require_relative "ai.rb"

module Creatures
	class Monster
		def initialize(x, y, id)
			@x = x
			@y = y
			@char = 'M'
			@colour_in_fov = Output::Colours::RED
			@name = "Monster"
			@id = id
			
			@kills = 0
			
			@fov_tiles = []
			@fov = 4
			
			@max_hp = 20
			@hp = 20
			@regen = 0.5
			
			@damages = {:fire => 0, :ice => 0, :light => 0, :dark => 0}
			@resistances = {:fire => 0, :ice => 0, :light => 0, :dark => 0}
			
			@inventory = []
			@equipment = {:head => nil, :left_hand => nil, :right_hand => nil, :left_finger => nil, :right_finger => nil, :body => nil, :feet => nil}
		end
		 
		def death
			if $player.in_fov?(self)
				$status_view.add_to_buffer("#{@name} entered a new cycle.")
			else
				$status_view.add_to_buffer("You hear a faint scream.")
			end
			$monsters.delete(self)
		end
		
		def regen
			if (@hp + @regen) < @max_hp
				@hp += @regen
			else
				@hp = @max_hp
			end
		end
				
		def draw(player)
			x = @x - player.x
			x += MAIN_SIZE[0] / 2
			y = @y - player.y
			y += MAIN_SIZE[1] / 2
			
			unless x > MAIN_SIZE[0] || x < 0 || y > MAIN_SIZE[1] || y < 0
				if player == self || player.in_fov?(self)
					$main_view.draw(x, y, @char, @colour_in_fov)
				end
			end
		end
		
		def move(dir_x, dir_y)
			@x += dir_x
			@y += dir_y
		end
		
		def act(map)
			Ai::SimpleRoutines.random_move(self, map, $monsters)
		end
		
		def recalc_fov(map)
			working_array = map.tiles
			@fov_tiles = []
			
			#center coords
			px = @x
			py = @y
		
			#limit and step
			limit = 135
			step = 3

			#ray tracing
			i = 0
			while i < limit
				x = px
				y = py
				ax = Math.sin(i)
				ay = Math.cos(i)
			
				j = 0
				while j < 2 * @fov
					x += ax
					y += ay
				
					tile = false
					tile = working_array[x.round][y.round] if not (((x) > (working_array.size - 1)) || ((x) < 0) || ((y) > (working_array[0].size - 1)) || ((y) < 0))
					if (not tile) || tile.blocked
						@fov_tiles.push(tile)
						break
					else
						@fov_tiles.push(tile)
					end
					j += step
				end
				i += step
			end
		end
		
		def in_fov?(tile)
			@fov_tiles.each {|fov_tile|
				if fov_tile && fov_tile.x == tile.x && fov_tile.y == tile.y
					return true
				end}
			false
		end
		
		attr_reader :blocked, :seen, :fov_tiles, :name, :id, :char, :colour_in_fov
		attr_accessor :hp, :max_hp, :damages, :resistances, :x, :y, :kills
	end
	
	class Goblin < Monster
		def initialize(x, y, id)
			super
			@char = 'G'
			@colour_in_fov = Output::Colours::GREEN
			@name = "Goblin"
			
			@fov = 5
			
			@damages = {:fire => 0, :ice => 5, :light => 0, :dark => 5}
			@resistances = {:fire => 5, :ice => 15, :light => 0, :dark => 20}
		end
		
		def act(map)
			target = false
			target = smart_target
			
			if target && @hp < (@max_hp / 4)
				Ai::SimpleRoutines.run_away_from_target(self, target, $map, $monsters)
			elsif target
				Ai::SimpleRoutines.seek_target(self, target, $map, $monsters)
			else
				Ai::SimpleRoutines.random_move(self, map, $monsters)
			end
		end
		
		def smart_target
			targets = []
			$monsters.each {|monster| targets.push(monster) if self.in_fov?(monster) && monster.name != @name}
			
			if targets.count == 0
				return false
			else
				return targets.sample
			end
		end
	end
	
	class Elf < Goblin
		def initialize(x, y, id)
			super
			@char = 'E'
			@name = "Elf"
			
			@damages = {:fire => 5, :ice => 0, :light => 5, :dark => 0}
			@resistances = {:fire => 15, :ice => 5, :light => 20, :dark => 0}
		end
	end
	
	class Player < Monster
		def initialize(x, y, id)
			super
			@char = '@'
			@colour_in_fov = Output::Colours::GOLD
			@name = "Player"
			@class = "Player"
			
			@mirrors_passed = 0
			
			@fov = 5
			
			@damages = {:fire => 8, :ice => 0, :light => 3, :dark => 0}
			@resistances = {:fire => 10, :ice => 5, :light => 15, :dark => 0}
		end
		
		attr_accessor :name, :class, :mirrors_passed
		
		def death
			$status_view.add_to_buffer("You died. Press 'Q' to quit.")
			Output.draw_gui_decorations(self)
			self.state
			$player_view.refresh
			$status_view.refresh
			key = false
			until key == 'Q'
				key = Input.get_key($main_view.window)
			end
			
			Output.close_console
			exit
		end
		
		def state
			colour = Output::Colours::GRAY
			$player_view.draw(0, 0, "#{@name} the #{@class}", colour)
			$player_view.draw(0, 1, "Kills: #{@kills}", colour)
			$player_view.draw(0, 2, "Mirrors passed: #{@mirrors_passed}", colour)
			
			$player_view.draw(0, 4, "health: #{@hp}/#{@max_hp}", colour)
			$player_view.draw(0, 5, "regen: #{@regen}", colour)
			
			$player_view.draw(0, 7, "Damage/Resistance:", colour)
			$player_view.draw(0, 8, "Fire: #{@damages[:fire]}/#{@resistances[:fire]}%", Output::Colours::RED)
			$player_view.draw(0, 9, "Ice: #{@damages[:ice]}/#{@resistances[:ice]}%", Output::Colours::CYAN)
			$player_view.draw(0, 10, "Light: #{@damages[:light]}/#{@resistances[:light]}%", Output::Colours::YELLOW)
			$player_view.draw(0, 11, "Dark: #{@damages[:dark]}/#{@resistances[:dark]}%", Output::Colours::PURPLE)
			
			$player_view.draw(0, 13, "Nearby:", colour)
			i = 14
			$monsters.each {|monster|
				if self.in_fov?(monster) && (not monster.is_a?(Creatures::Player))
					$player_view.draw(0, i, monster.name, colour)
					$player_view.draw(0, i, monster.char, monster.colour_in_fov)
					i += 1
				end}
					
		end
		
		def act(map)
			key = Input.get_key($main_view.window)
			Ai::Player.control_player(self, key, map, $monsters)
		end
	end
	
	def self.creature_spawner(map, monsters, number)
		i = 0
		until i > number
			coords = false
			until coords
				new_coords = $map.tiles.sample.sample
				coords = new_coords if not new_coords.blocked
			end
				if rand(1..6) > 3
					monsters.push(Creatures::Elf.new(coords.x, coords.y, i))
				else
					monsters.push(Creatures::Goblin.new(coords.x, coords.y, i))
				end
				i += 1
		end
	end
end
