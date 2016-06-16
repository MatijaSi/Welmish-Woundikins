module Utilities
	def self.get_i_from_coords(map, x, y) #map must be array (you get @tiles i)
		i = 0
		map.each {|tile|
			return i if tile.x == x && tile.y == y
			i += 1}
		false
	end
	
	def self.is_blocked?(map, x, y)
		i = get_i_from_coords(map, x, y)
		tile = map[i]
		if tile == nil || tile.blocked
			return true
		else
			return false
		end
	end
	
	def self.is_chasm?(map, x, y)
		i = get_i_from_coords(map, x, y)
		tile = map[i]
		if tile == nil || tile.chasm
			return true
		else
			return false
		end
	end
	
	def self.find_free_coords(map, n) #returns nth free tile's x and y
		i = 0
		map.each {|tile|
			if not tile.blocked
				i += 1
			end
			
			if i == n
				return [tile.x, tile.y]
			end}
	end
	
	def self.is_occupied?(monsters, x, y) #return monster that occupies the tile, if tile is empty return false
		monsters.each {|monster|
			if monster.x == x && monster.y == y
				return monster
			end}
		false
	end
	
	def self.find_free_space(map, w, h) #return starting coords of empty place sized w * h
		x1 = 0
		y1 = 0
		
		free_tiles = [] #coords of all free tiles go here
		map.each {|tile|
			unless tile.blocked
				free_tiles.push([tile.x, tile.y])
			end}
		
		same_x_tiles = []
		start_x = free_tiles.sample[0]
		while true
			free_tiles.each {|tile|
				x = tile[0]
				if x == start_x
					same_x_tiles.push(tile)
				end}
			
			if same_x_tiles.count >= w
				x1 = start_x
				break
			end
			start_x = free_tiles.sample[0]
		end
		
		y = same_x_tiles.sample[1]
		same_x_tiles.each {|tile|
			if tile[1] < y
				y = tile[1]
				y1 = tile[1]
			end
		}
		
		return [x1, y1]
	end
end
