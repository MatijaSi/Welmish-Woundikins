require_relative "BearLibTerminal.rb"
require_relative "combat.rb"
require_relative "utilities.rb"
require_relative "display.rb"

module Input
	def self.handle_keys(player, status)
		key = Terminal.read()
		
		case key
		#movement
		when Terminal::TK_K #up
			monster_present = Utilities.is_occupied?($monsters, player.x, player.y - 1)
			
			if monster_present
				Combat.attack(player, monster_present)
			elsif Utilities.is_chasm?($map.tiles, player.x, player.y - 1)
				player.hp = 0
				$status.push("You died.")
				Display.print_status($status)
			elsif not Utilities.is_blocked?($map.tiles, player.x, player.y - 1)
				player.move(0, -1) 
			end
			
		when Terminal::TK_J #down
			monster_present = Utilities.is_occupied?($monsters, player.x, player.y + 1)
			
			if monster_present
				Combat.attack(player, monster_present)
			elsif Utilities.is_chasm?($map.tiles, player.x, player.y + 1)
				player.hp = 0
				$status.push("You died.")
				Display.print_status($status)
			elsif not Utilities.is_blocked?($map.tiles, player.x, player.y + 1)
				player.move(0, 1) 
			end
			
		when Terminal::TK_H #left
			monster_present = Utilities.is_occupied?($monsters, player.x - 1, player.y)
			
			if monster_present
				Combat.attack(player, monster_present)
			elsif Utilities.is_chasm?($map.tiles, player.x - 1, player.y)
				player.hp = 0
				$status.push("You died.")
				Display.print_status($status)
			elsif not Utilities.is_blocked?($map.tiles, player.x - 1, player.y)
				player.move(-1, 0) 
			end
			
		when Terminal::TK_L #right
			monster_present = Utilities.is_occupied?($monsters, player.x + 1, player.y)
			
			if monster_present
				Combat.attack(player, monster_present)
			elsif Utilities.is_chasm?($map.tiles, player.x + 1, player.y)
				player.hp = 0
				$status.push("You died.")
				Display.print_status($status)
			elsif not Utilities.is_blocked?($map.tiles, player.x + 1, player.y)
				player.move(1, 0) 
			end
			
		when Terminal::TK_Y , Terminal::TK_Z #up-left
			monster_present = Utilities.is_occupied?($monsters, player.x - 1, player.y - 1)
			
			if monster_present
				Combat.attack(player, monster_present)
			elsif Utilities.is_chasm?($map.tiles, player.x - 1, player.y - 1)
				player.hp = 0
				$status.push("You died.")
				Display.print_status($status)
			elsif not Utilities.is_blocked?($map.tiles, player.x - 1, player.y - 1)
				player.move(-1, -1) 
			end
			
		when Terminal::TK_U #up-right
			monster_present = Utilities.is_occupied?($monsters, player.x + 1, player.y - 1)
			
			if monster_present
				Combat.attack(player, monster_present)
			elsif Utilities.is_chasm?($map.tiles, player.x + 1, player.y - 1)
				player.hp = 0
				$status.push("You died.")
				Display.print_status($status)
			elsif not Utilities.is_blocked?($map.tiles, player.x + 1, player.y - 1)
				player.move(1, -1) 
			end
			
		when Terminal::TK_B #down-left
			monster_present = Utilities.is_occupied?($monsters, player.x - 1, player.y + 1)
			
			if monster_present
				Combat.attack(player, monster_present)
			elsif Utilities.is_chasm?($map.tiles, player.x - 1, player.y + 1)
				player.hp = 0
				$status.push("You died.")
				Display.print_status($status)
			elsif not Utilities.is_blocked?($map.tiles, player.x - 1, player.y + 1)
				player.move(-1, 1) 
			end
			
		when Terminal::TK_N #down-right
			monster_present = Utilities.is_occupied?($monsters, player.x + 1, player.y + 1)
			
			if monster_present
				Combat.attack(player, monster_present)
			elsif Utilities.is_chasm?($map.tiles, player.x + 1, player.y + 1)
				player.hp = 0
				$status.push("You died.")
				Display.print_status($status)
			elsif not Utilities.is_blocked?($map.tiles, player.x + 1, player.y + 1)
				player.move(1, 1) 
			end
		else
			0
		end
	end
end
