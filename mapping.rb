require_relative "output.rb"

module Mapping
	class Tile
		def initialize(x, y)
			@x = x
			@y = y
			@char = 'X'
			@blocked = nil
			@colour = Output::Colours::WHITE
			@colour_not_fov = Output::Colours::BLUE
			@seen = false
			@type = :tile
		end
		
		def draw(view)
			x = @x - $player.x
			x += MAIN_SIZE[0] / 2
			y = @y - $player.y
			y += MAIN_SIZE[1] / 2
						
			unless x > MAIN_SIZE[0] || x < 0 || y > MAIN_SIZE[1] || y < 0
				#see red if near death
				if $player.hp < ($player.max_hp / 4)
					colour = Output::Colours::RED
				else
					colour = @colour
				end
			
				#make rogue see monsters fovs
				in_monster = false
				if $player.is_a?(Creatures::Rogue)
					$monsters.each {|monster|
						if monster.in_fov?($player) && in_fov?(monster) 
							colour = monster.colour
							in_monster = true
							break
						end}
				end
			
				#players and monsters always have same colour
				if @type == :player || @type == :monster || @type == :item
					colour = @colour
				end
			
				if in_fov?($player)
					view.draw(x, y, @char, colour)
					@seen = true
				elsif $player.class == "Rogue" && in_monster && @seen
					view.draw(x, y, @char, colour)
				elsif @seen && self.type != :monster
					view.draw(x, y, @char, @colour_not_fov)
				end
			end
		end
		
		def in_fov?(player)
			if self == player
				return true
			elsif Mapping.exists(player.fov_tiles, @x, @y)
				return true
			else
				return false
			end
		end
		
		attr_reader :blocked, :colour, :colour_not_fov, :type
		attr_accessor :x, :y
	end
	
	def self.recalc_fov(player)
		working_array = $items + $monsters + $map.tiles
		working_array.push($player) if player != $player
		player.fov_tiles = []
		#center coords
		px = player.x
		py = player.y
		
		#radius
		fov = player.fov
		
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
			while j < fov
				x += ax
				y += ay
				
				tile = false
				tile = Mapping.exists(working_array, x.round, y.round)
				if (not tile) || tile.blocked
					player.fov_tiles.push(tile)
					break
				else
					player.fov_tiles.push(tile)
				end
				j += step
			end
			i += step
		end
		
	end
	
	class Ground < Tile
		def initialize(x, y)
			super
			@char = '.'
			@blocked = false
		end
	end
	
	class Wall < Tile
		def initialize(x, y)
			super
			@char = '#'
			@blocked = true
		end
	end		
	
	class Map #map composed of more maps
		def initialize(min_x, min_y, max_x, max_y)
			@begin = [min_x, min_y]
			@size = [max_x, max_y]
			@tiles = []
		end
		
		def populate
			puts "Generating map, please wait."
			#cut the map in half
			cut_x = @size[0] / 2 
			cut_y = @size[1] / 2
			
			#create two maps, they should only generate ground tiles
			map1 = DrunkardWalkMap.new(0, 0, cut_x, cut_y)
			map1.populate
			puts "Caverns generated"
			
			map2 = DungeonMap.new(cut_x, 0, @size[0], cut_y)
			map2.populate
			puts "Dungeons generated"
			
			map3 = MazeMap.new(0, cut_y, cut_x, @size[1])
			map3.populate
			puts "Mazes generated"
			
			map4 = DrunkardWalkMap.new(cut_x, cut_y, @size[0], @size[1])
			map4.populate
			puts "More caverns generated"
			
			#connect maps with corridors
			tile1 = map1.tiles.sample
			tile2 = map2.tiles.sample
			tile3 = map3.tiles.sample
			tile4 = map4.tiles.sample
	
			puts "Connecting parts of map together"
	
			corridors = Mapping.connect_with_corridors(tile1, tile2) + Mapping.connect_with_corridors(tile2, tile3) + Mapping.connect_with_corridors(tile3, tile4) + Mapping.connect_with_corridors(tile4, tile1)
			
			corridor_tiles = []
			corridors.each {|cor| corridor_tiles += cor.tiles}
			
			#combine them into map
			@tiles = map1.tiles + map2.tiles + map3.tiles + map4.tiles + corridor_tiles
			
			ptile = @tiles.sample
			pcoords = [ptile.x, ptile.y]
			
			puts "Generating walls"
			#sorround ground tiles with walls
			@tiles.each do |tile|
				x = tile.x
				y = tile.y
				walls = []
				neighbours = [[x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1], [x + 1, y + 1], [x - 1, y - 1], [x + 1, y - 1], [x - 1, y + 1]]
				neighbours.each do |coords|
					unless Mapping.exists(@tiles, coords[0], coords[1])
						walls.push(Wall.new(coords[0], coords[1]))
					end
				end
				@tiles += walls
			end
			
			return pcoords
		end
		
		def draw(view)
			@tiles.each {|tile|
				tile.draw(view)}
		end
		
		attr_reader :tiles
	end
	
	def self.exists(map, x, y) #returns true if tile with coords in is map
		map.each {|tile|
			if tile.x == x && tile.y == y
				return tile
			end}
		false
	end
	
=begin
	class RandomMap < Map #map randomly filled with tiles, only for tests, since it also gens walls
		def populate
			#starting coords
			x = @begin[0]
			y = @begin[1]
			until x >= @size[0]
				until y >= @size[1]
					if rand(1..6) > 3
						@tiles.push(Ground.new(x, y))
					else
						@tiles.push(Wall.new(x, y))
					end
					y += 1
				end
					x += 1
					y = 0
			end
		end
	end
=end
	
	class GroundMap < Map #map full of ground tiles
		def populate
			#starting coords
			x = @begin[0]
			y = @begin[1]
			until x >= @size[0]
				until y >= @size[1]
					@tiles.push(Ground.new(x, y))
					y += 1
				end
					x += 1
					y = 0
			end
		end
	end
	
	class Room < GroundMap
		def draw
			nil
		end
	end
	
	class VerticalCorridor < Room
		def populate
			if @begin[1] < @size[1]
				y = @begin[1]
				until y >= @size[1]
					@tiles.push(Ground.new(@begin[0], y))
					y += 1
				end
			else
				y = @size[1]
				until y >= @begin[1]
					@tiles.push(Ground.new(@begin[0], y))
					y += 1
				end
			end
		end
	end

	class HorizontalCorridor < Room
		def populate
			if @begin[0] < @size[0]
				x = @begin[0]
				until x >= @size[0]
					@tiles.push(Ground.new(x, @begin[1]))
					x += 1
				end
			else
				x = @size[0]
				until x >= @begin[0]
					@tiles.push(Ground.new(x, @begin[1]))
					x += 1
				end
			end
		end
	end
	
	def self.connect_with_corridors(tile1, tile2)
		x1 = tile1.x
		y1 = tile1.y
		x2 = tile2.x
		y2 = tile2.y
			
		if rand(1..6) > 3 #create horizontal corridor first
			h_corridor = HorizontalCorridor.new(x1, y1, x2, y1)
			v_corridor = VerticalCorridor.new(x2, y1, x2, y2)
		else #vertical first
			v_corridor = VerticalCorridor.new(x1, y1, x1, y2)
			h_corridor = HorizontalCorridor.new(x1, y2, x2, y2)
		end
		
		h_corridor.populate
		v_corridor.populate
			
		return [h_corridor, v_corridor]
	end
	
	class DrunkardWalkMap < Map #map generated with drunkard walk alghoritm
		def populate
			borders = [@begin[0], @begin[1], @size[0], @size[1]]
			dirs = [-1, 0, 0, 1]
			
			x = ((borders[2] - borders[0]) / 2) + borders[0] #center of the map
			y = ((borders[3] - borders[1]) / 2) + borders[1] #center of the map
			
			until x >= borders[2] || x <= borders[0] || y >= borders[3] || y <= borders[1] #generate ground till border of map is reached
				@tiles.push(Ground.new(x, y))
				x += dirs.sample
				y += dirs.sample
			end
		end
	end
	
	class DungeonMap < Map #map of corridors and rooms
		def populate
			borders = [@begin[0], @begin[1], @size[0], @size[1]]
			x = rand(borders[0]..(borders[2] - 30))
			y = rand(borders[1]..(borders[3] - 30))
			
			rooms = []
			corridors = []
			rooms.push(Room.new(x, y, x + 5, y + 5))
			
			i = 0
			until i > 10
				x = rand(borders[0]..(borders[2] - 30))
				y = rand(borders[1]..(borders[3] - 30))
				
				rooms.push(Room.new(x, y, x + rand(5..8), y + rand(3..4)))
				i += 1
			end
			
			rooms.each {|room| room.populate}
				
			i = 1
			while i < rooms.size
				tile1 = rooms[i - 1].tiles.sample
				tile2 = rooms[i].tiles.sample
				ncorridors = Mapping.connect_with_corridors(tile1, tile2)
				corridors.push(ncorridors[0])
				corridors.push(ncorridors[1])
				i += 1
			end
			
			corridors.each {|corridor| corridor.populate}
			
			rooms.each {|room| @tiles += room.tiles}
			corridors.each {|corridor| @tiles += corridor.tiles}
		end
	end
	
	class AutomataMap < Map #map generated using cellular automata	
	end
	
	class MazeMap < Map
		def populate
			borders = [@begin[0], @begin[1], @size[0], @size[1]]
			
			#first generate a room in center of the map
			x = ((borders[2] - borders[0]) / 2) + borders[0] #center of the map
			y = ((borders[3] - borders[1]) / 2) + borders[1] #center of the map
			
			room = Room.new(x, y, x + rand(3..7), y + rand(3..7))
			room.populate
			@tiles += room.tiles
			
			#generate corridors
			i = 0
			until i == 10
				start_tile = @tiles.sample
				if rand(1..6) > 3
					corridor = VerticalCorridor.new(start_tile.x, start_tile.y, start_tile.x, start_tile.y + rand(5..7))
				else
					corridor = HorizontalCorridor.new(start_tile.x, start_tile.y, start_tile.x + rand(5..7), start_tile.y)
				end
				
				corridor.populate
				@tiles += corridor.tiles
				
				i += 1
			end
		end
	end
end
