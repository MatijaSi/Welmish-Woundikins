require_relative "BearLibTerminal.rb"

module Mapping
	class Tile
		def initialize(x, y)
			@x = x
			@y = y
			@char = 'X'
			@blocked = nil
			@chasm = false
			@seen = false
			@to_draw = false
			@color_in_pov = "lighter yellow"
			@color_not_pov = "dark grey"
		end

=begin #Not needed since such tiles in current populate aren't made
		def out_of_view?(map) #return true if tile has 8 walls for neighbour
			i = 0
			x = @x
			y = @y
			map.each {|tile|
				if (tile.blocked && (tile.x == x || tile.x == (x + 1) || tile.x == (x - 1)) && (tile.y == y || tile.y == (y - 1) || tile.y == (y + 1)))
					i += 1
				end}
			if i >= 9
				return true
			else
				return false
			end
		end
=end		
		def in_pov?(player) #return true if tile is in pov
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
		
		def draw(player)
			if in_pov?(player)
				Display.draw(self, player, $map_view, @color_in_pov)
				@seen = true
			elsif @seen
				Display.draw(self, player, $map_view, @color_not_pov)
			end
		end
		
		attr_reader :x, :y, :seen, :blocked, :char, :chasm
		attr_accessor :to_draw
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
	
	class WoodenWall < Wall
		def initialize(x, y)
			super
			@color_in_pov = "light amber"
			@color_not_pov = "dark amber"
		end
	end
	
	class Chasm < Tile
		def initialize(x, y)
			super
			@char = '-'
			@color_in_pov = "darker violet"
			@color_not_pov = "darkest violet"
			@blocked = true
			@chasm = true
		end
	end
	
	class Map
		def initialize(floor_number)
			@floors = floor_number
			@tiles = []
		end
		
		def analyse #change to_draw properties of tiles
			@tiles.each {|tile|
				unless tile.out_of_view?(@tiles)
					tile.to_draw = true
				end}
		end
		
		def compact #remove entirely sorroundered tiles
			@tiles.each {|tile|
				if tile.to_draw == false
					@tiles.delete(tile)
				end}
		end
		
		def populate
			#starting coords
			x = 500
			y = 500
			dirs = [-1, 0, 1]
			i = 0
			
			#drunkard walk
			until i == @floors
				if Utilities.get_i_from_coords(@tiles, x, y) == false
					@tiles.push(Ground.new(x, y))
					i += 1
				end
				x += dirs.sample
				y += dirs.sample
			end
			
			#insert chasm
			x = 500
			y = 500
			i = 0
			
			until i >= 500
				index = Utilities.get_i_from_coords(@tiles, x, y)
				if index && @tiles[index].chasm != true
					@tiles.delete_at(index)
					@tiles[index] = Chasm.new(x, y)
					i += 1
				else
					@tiles.push(Chasm.new(x, y))
					i += 1
				end
				x += dirs.sample
				y += dirs.sample
			end
			
			#sorround tiles with walls
			@tiles.each do |tile|
				x = tile.x
				y = tile.y
				walls = []
				neighbours = [[x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1], [x + 1, y + 1], [x - 1, y - 1], [x + 1, y - 1], [x - 1, y + 1]]
				neighbours.each do |coords|
					if Utilities.get_i_from_coords(@tiles, coords[0], coords[1]) == false
						walls.push(Wall.new(coords[0], coords[1]))
					end
				end
				@tiles += walls
			end
		end
		
		def draw(player)
			@tiles.each {|tile|
				tile.draw(player)}
		end
		
		attr_reader :tiles
	end
	
	class Room
		def initialize(x, y, w, h)
			@x1 = x
			@y1 = y
			@x2 = x + w
			@y2 = x + h
			@tiles = []
		end
		
		def populate
			x = @x1
			y = @y1
			tiles = []
			until x > @x2
				until y > @y2
					tiles.push(Ground.new(x, y))
					y += 1
				end
				y = @y1
				x += 1
			end
			
			@tiles = tiles
		end
		
		def size
			return (@x2 - @x1) * (@y2 - @y1)
		end
		
		attr_reader :x1, :x2, :y1, :y2, :tiles
	end
	
	class HorizontalCorridor < Room
		def initialize(x, y, w)
			@x1 = x
			@y1 = y
			@x2 = @x1 + w
			@y2 = @y1
		end
		
		def size
			return @x2 - @x1
		end
	end
	
	class VerticalCorridor < Room
		def initialize(x, y, h)
			@x1 = x
			@y1 = y
			@x2 = @x1
			@y2 = @y1 + h
		end
		
		def size
			return @y2 - @y1
		end
	end
	
	class Dwelling
		def initialize(x, y, w, h)
			@x1 = x
			@y1 = y
			@x2 = x + w
			@y2 = y + h
			@tiles = []
		end
		
		def populate
			x = @x1
			y = @y1
			
			while x < @x2
				@tiles.push(WoodenWall.new(x, y))
				x += 1
			end
			
			x = @x1
			y = @y2
			
			while x < @x2
				@tiles.push(WoodenWall.new(x, y))
				x += 1
			end
			
			x = @x1
			y = @y1
			
			while y < @y2
				@tiles.push(WoodenWall.new(x, y))
				y += 1
			end
			
			x = @x2
			y = @y1
			
			while y < @y2
				@tiles.push(WoodenWall.new(x, y))
				y += 1
			end
			
			@tiles.shuffle.pop
		end
		
		attr_reader :x1, :x2, :y1, :y2, :tiles
	end
	
	class MapSector
		def initialize(x1, y1, x2, y2)
			@x1 = x1
			@x2 = x2
			@y1 = y1
			@y2 = y2
		end
		
		def split
			if rand(1..6) > 3 #horizontal split
				x = rand((@x1 + 5)..(@x2 - 5))
				@x2 = x
				new_sector = MapSector.new(x, @y1, @x2, @y2)
			else
				y = rand((@y1 + 5)..(@y2 - 5))
				@y2 = y
				new_sector = MapSector.new(@x1, y, @x2, @y2)
			end
			
			return new_sector
		end
		
		attr_reader :x1, :x2, :y1, :y2
	end
	
	def merge_sectors(sector1, sector2)
		x1 = sector1.x1
		x2 = sector2.x2
		y1 = sector1.y1
		y2 = sector2.y2
		
		new_sector = MapSector.new(x1, y1, x2, y2)
		return new_sector
	end
	
end
