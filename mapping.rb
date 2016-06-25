require_relative "output.rb"

module Mapping
	class Tile
		def initialize(x, y)
			@x = x
			@y = y
			@char = 'X'
			@blocked = nil
		end
		
		def draw(view)
			x = @x - $player.x
			x += MAIN_SIZE[0] / 2
			y = @y - $player.y
			y += MAIN_SIZE[1] / 2
			
			unless x > MAIN_SIZE[0] || x < 0 || y > MAIN_SIZE[1] || y < 0 || (not in_fov?($player))
				view.draw(x, y, @char)
			end
		end
		
		def in_fov?(player)
			px = player.x
			py = player.y
			tx = @x
			ty = @y
			fov = player.fov
			cond_distance = (((tx - px).abs * (tx - px).abs + (ty - py).abs * (ty - py).abs) <= (fov * fov))

			if cond_distance
				return true
			else
				return false
			end
		end
		
		attr_reader :x, :y, :blocked
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
			#cut the map in half
			cut_x = @size[0] / 2 
			
			#create two maps, they should only generate ground tiles
			map1 = MazeMap.new(0, 0, cut_x, @size[1])
			map1.populate
			
			map2 = DrunkardWalkMap.new(cut_x, 0, @size[0], @size[1])
			map2.populate
			
			#connect maps with corridors
			tile1 = map1.tiles.sample
			tile2 = map2.tiles.sample
			
			corridors = Mapping.connect_with_corridors(tile1, tile2)
			
			#combine them into map
			@tiles = map1.tiles + map2.tiles + corridors[0].tiles + corridors[1].tiles
			
			ptile = @tiles.sample
			pcoords = [ptile.x, ptile.y]
			
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
			dirs = [-1, 0, 1]
			
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
			puts "start room made"
			
			#generate corridors
			until x >= borders[2] || x <= borders[0] || y >= borders[3] || y <= borders[1] #generate corridors till border of map is reached
				start_tile = @tiles.sample
				if rand(1..6) > 3
					corridor = VerticalCorridor.new(start_tile.x, start_tile.y, start_tile.x, start_tile.y + rand(5..7))
				else
					corridor = HorizontalCorridor.new(start_tile.x, start_tile.y, start_tile.x + rand(5..7), start_tile.y)
				end
				
				corridor.populate
				@tiles += corridor.tiles
				
				x = start_tile.x
				y = start_tile.y
			end
		end
	end
end
