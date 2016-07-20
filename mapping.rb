require_relative "output.rb"

module Mapping
	class Tile
		def initialize(x, y)
			@x = x
			@y = y
			@char = 'X'
			@blocked = nil
			@colour_in_fov = Output::Colours::WARMBROWN
			@colour_not_fov = Output::Colours::BROWN
			@seen = false
			@type = :tile
		end
		
		def draw(player)
			x = @x - player.x
			x += MAIN_SIZE[0] / 2
			y = @y - player.y
			y += MAIN_SIZE[1] / 2
			
			unless x > MAIN_SIZE[0] || x < 0 || y > MAIN_SIZE[1] || y < 0
				if player.in_fov?(self)
					$main_view.draw(x, y, @char, @colour_in_fov)
					@seen = true
				elsif @seen
					$main_view.draw(x, y, @char, @colour_not_fov)
				end
			end
		end
		
		attr_reader :x, :y, :blocked, :seen, :type
	end
	
	class Ground < Tile
		def initialize(x, y)
			super
			@char = '.'
			@blocked = false
			@type = :ground
		end
	end
	
	class Wall < Tile
		def initialize(x, y)
			super
			@char = '#'
			@blocked = true
			@type = :wall
		end
	end
	
	class Mirror < Tile
		def initialize(x, y)
			super
			@char = 'Ω'
			@colour_in_fov = Output::Colours::CYAN
			@blocked = false
			@type = :mirror
		end
		
		def teleport(player)
			if player.x == @x && player.y == @y
				Mapping.level_generator(MAP_SIZE[0], MAP_SIZE[1], rand(MONSTER_NUMBER[0]..MONSTER_NUMBER[1]), player)
				player.mirrors_passed += 1
				$status_view.add_to_buffer("You pass through a mirror")
				$status_view.draw_buffer
			end	
		end
	end
	
	class GenericMap
		def initialize(size_x, size_y)
			@tiles = Array.new(size_x) {Array.new(size_y, 0)}
			@size_x = size_x
			@size_y = size_y
			@mirrors = []
			
			self.populate
			
			self.place_mirrors
		end
		
		def populate
		end
		
		def place_mirrors
			num = rand(5..15)
			i = 0
			while i < num
				coords = false
				until coords
					new_coords = @tiles.sample.sample
					coords = new_coords if not new_coords.blocked
				end
				
				mirror = Mirror.new(coords.x, coords.y)
				@tiles[coords.x][coords.y] = mirror
				@mirrors.push(mirror)
				
				i += 1
			end
		end
		
		def fill_border_with_walls
			@tiles.each {|row| row.each {|tile|
				x = tile.x
				y = tile.y
				if x == 0 || y == 0 || x == (@size_x - 1) || y == (@size_y - 1) 
					@tiles[tile.x][tile.y] = Wall.new(tile.x, tile.y)
				end}}
		end
		
		def cellular_automata(born, stay, repeat) #wall borning, born and stay must be [min, max] arrays.
			i = 0
			while i < repeat
				@tiles.each {|row| row.each {|tile|
					if Mapping.has_neighbours?(tile, @tiles, :wall, born[0], born[1]) && tile.type == :ground
						@tiles[tile.x][tile.y] = Wall.new(tile.x, tile.y)
					end
					if (not Mapping.has_neighbours?(tile, @tiles, :wall, stay[0], stay[1])) && tile.type == :wall
						@tiles[tile.x][tile.y] = Ground.new(tile.x, tile.y)
					end}}
				i += 1
			end
		end
		
		def random_fill(walls) #in percents
			current_x = 0
			current_y = 0
			until current_x >= @size_x
				until current_y >= @size_y
					if rand(1..100) <= walls
						@tiles[current_x][current_y] = Wall.new(current_x, current_y)
					else
						@tiles[current_x][current_y] = Ground.new(current_x, current_y)
					end
					current_y += 1
				end
				current_x += 1
				current_y = 0
			end
		end
		
		def draw(player)
			@tiles.each {|tiles|
			 tiles.each {|tile|
			  tile.draw(player)}}
		end
		
		attr_reader :tiles, :mirrors
	end
	
	class DrunkardWalkMap < GenericMap #creates nice caves
		def populate
			#filling the map
			self.random_fill(100) #100% of the map is walls
		
			#drunkard walk
			current_x = @size_x / 2
			current_y = @size_y / 2
			dirs = [-1, 0, 1]
			ground_num = 0
			target_ground_num = (@size_x * @size_y) / 4
			until ground_num >= target_ground_num
				if current_x > 0 && current_x < @size_x && current_y > 0 && current_y < @size_y
					if @tiles[current_x][current_y].blocked
						@tiles[current_x][current_y] = Ground.new(current_x, current_y)
						ground_num += 1
					end
				end
				
				move_x = dirs.sample
				move_y = dirs.sample
				
				if current_x < 5
					move_x = 1
				end
				if current_x > (@size_x - 5)
					move_x = -1
				end
				if current_y < 5
					move_y = 1
				end
				if current_y > (@size_y - 5)
					move_y = -1
				end
				
				current_x += move_x
				current_y += move_y
			end
			
			self.fill_border_with_walls
		end
	end
	
	class MazeMap < GenericMap #creates mazes using automata
		def populate
			#filling the map array randomly
			self.random_fill(50) #50% walls
			
			#cellular automata with B3/S01234 rule
			self.cellular_automata([3, 3], [0, 3], 10)
			self.cellular_automata([0, 0], [0, 3], 1)
			
			#fill the border with walls
			self.fill_border_with_walls 
		end
	end
	
	class CavernMap < GenericMap #creates caverns using automata
		def populate
			#filling the map array randomly
			self.random_fill(50) #50% walls
			
			#cellular automata with B015+/S015+ rule
			self.cellular_automata([5, 9], [4, 9], 3)

			
			#fill the border with walls
			self.fill_border_with_walls
		end
	end
	
	def self.has_neighbours?(tile, tiles, type, min, max) #returns true if tile has in tiles at least min type neighbours and at most max
		tx = tile.x
		ty = tile.y
		neighbours = []
		num = 0
		
		#populate neighbours with all tiles that neighbour tile
		dirs = [-1, 0, +1]
		dirs.each {|x|
			dirs.each {|y|
				if not (((tx + x) > (tiles.size - 1)) || ((tx + x) < 0) || ((ty + y) > (tiles[0].size - 1)) || ((ty + y) < 0))
					neighbours.push(tiles[tx + x][ty + y])
				end}}
		neighbours.delete(tiles[tx][ty])
		
		#count them
		neighbours.each {|neigh|
			if neigh != nil && neigh.type == type
				num += 1
			end}
		
		#return
		if num >= min && num <= max
			return true
		else
			return false
		end
	end
	
	def self.level_generator(size_x, size_y, monster_number, player)
		#gen a new map
		which_map = rand(1..3)
		
		case which_map
		when 1
			map = DrunkardWalkMap.new(size_x, size_y)
		when 2
			map = MazeMap.new(size_x, size_y)
		when 3
			map = CavernMap.new(size_x, size_y)
		end
				
		#place player
		coords = false
		until coords
			new_coords = map.tiles.sample.sample
			coords = new_coords if not new_coords.blocked
		end
				
		player.x = coords.x
		player.y = coords.y
				
		$map = map
				
		#gen monsters
		$monsters = [player]
		Creatures.creature_spawner($map, $monsters, monster_number)
		$monsters.each {|monster| monster.recalc_fov($map)}
	end
end
