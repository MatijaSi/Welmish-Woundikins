require_relative "output.rb"
require_relative "input.rb"
require_relative "combat.rb"

module Ai
	module SimpleRoutines
		def self.random_move(actor, map, monsters)
			dirs = [-1, 0, 1]
			
			dir_x = dirs.sample
			dir_y = dirs.sample
			
			new_x = actor.x + dir_x
			new_y = actor.y + dir_y
			
			there_monster = false
			
			monsters.each {|monster|
				if monster.x == new_x && monster.y == new_y && monster != actor
					there_monster = monster
				end}
			
			if there_monster
				Combat.attack(actor, there_monster)
			elsif not (((new_x) > (map.tiles.size - 1)) || ((new_x) < 0) || ((new_y) > (map.tiles[0].size - 1)) || ((new_y) < 0))
				if not map.tiles[new_x][new_y].blocked
					actor.move(dir_x, dir_y)
				end
			end
		end
		
		def self.target_in_fov(actor, monsters)
			target = false
			monsters.each {|monster|
				target = monster if actor.in_fov?(monster) && monster != actor}
			return target
		end
		
		def self.seek_target(actor, target, map, monsters)
			dir_x = ((target.x - actor.x) / (target.x - actor.x).abs) unless target.x == actor.x
			dir_x = 0 if target.x == actor.x
				
			dir_y = ((target.y - actor.y) / (target.y - actor.y).abs) unless target.y == actor.y
			dir_y = 0 if target.y == actor.y
			
			new_x = actor.x + dir_x
			new_y = actor.y + dir_y
			
			there_monster = false
			
			monsters.each {|monster|
				if monster.x == new_x && monster.y == new_y && monster != actor
					there_monster = monster
				end}
			
			if there_monster
				Combat.attack(actor, there_monster)
			elsif not map.tiles[new_x][new_y].blocked
				actor.move(dir_x, dir_y)
			end
		end
		
		def self.run_away_from_target(actor, target, map, monsters)
			dir_x = ((target.x - actor.x) / (target.x - actor.x).abs) unless target.x == actor.x
			dir_x = 0 if target.x == actor.x
				
			dir_y = ((target.y - actor.y) / (target.y - actor.y).abs) unless target.y == actor.y
			dir_y = 0 if target.y == actor.y
			
			dir_x = - dir_x
			dir_y = - dir_y
			
			new_x = actor.x + dir_x
			new_y = actor.y + dir_y
			
			there_monster = false
			
			monsters.each {|monster|
				if monster.x == new_x && monster.y == new_y && monster != actor
					there_monster = monster
				end}
			
			if there_monster
				Combat.attack(actor, there_monster)
			elsif not map.tiles[new_x][new_y].blocked
				actor.move(dir_x, dir_y)
			end
		end
	end
	
	module Player
		def self.control_player(actor, key, map, monsters) #items)
			case key
			when "k", "j", "h", "l", "z", "y", "b", "n", "u"
				Ai::Player.movement(actor, key, map, monsters)
			when "?", "Q"
				Ai::Player.misc(key)
			end
		end
		
		def self.movement(actor, key, map, monsters)
			dir_x = 0
			dir_y = 0
			
			case key 
			#movement (and combat)
			when 'k' #up
				dir_y = -1
			when 'j' #down
				dir_y = 1
			when 'h' #left
				dir_x = -1
			when 'l' #right
				dir_x = 1
			when 'y' , 'z' #up-left
				dir_x = -1
				dir_y = -1
			when 'u' #up-right
				dir_x = 1
				dir_y = -1
			when 'b' #down-left
				dir_x = -1
				dir_y = 1
			when 'n' #down-right
				dir_x = 1
				dir_y = 1
			end
			
			new_x = actor.x + dir_x
			new_y = actor.y + dir_y
			there_monster = false
			
			monsters.each {|monster|
				if monster.x == new_x && monster.y == new_y
					there_monster = monster
				end}
			
			if there_monster
				Combat.attack(actor, there_monster)
			elsif not map.tiles[new_x][new_y].blocked
				actor.move(dir_x, dir_y)
			end
		end
		
		def self.item_manipulation(actor, key, items)
		end
		
		def self.misc(key)
			case key
			when '?' #help
				$status_view.add_to_buffer("Nethack keys to move/attack")
				$status_view.add_to_buffer("'Q' to quit, '?' for help.")
				$status_view.draw_buffer
			when 'Q' #quit
				Output.close_console
				exit
			end
		end
	end
end
