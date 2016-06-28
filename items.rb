require_relative "mapping.rb"

module Items
	class Item < Mapping::Tile
		def initialize(x, y, char = '°', name = "Lamp of Green Djinni")
			super(x, y)
			@char = char
			@color = Output::Colours::YELLOW
			@blocked = nil
			@type = :item
			@name = name
		end
		
		attr_reader :name
		
		def pick_up(player)
			$items.delete(self)
			player.inventory.push(self)
			
			$status_view.add_to_buffer("You pick up #{@name}!")
			$status_view.draw_buffer
			$status_view.refresh
		end
		
		def drop(player)
			player.inventory.delete(self)
			@x = player.x
			@y = player.y
			$items.push(self)
			
			$status_view.add_to_buffer("You drop #{@name}!")
			$status_view.draw_buffer
			$status_view.refresh
		end
	end
	
	class Wearable < Item #weapons and armors
		def initialize(x, y, char, name, dmg, hp)
			super(x, y, char, name)
			@dmg_bonus = dmg
			@hp_bonus = hp
		end
		
		attr_accessor :dmg_bonus, :hp_bonus
		
		def wear(player)
			player.inventory.delete(self)
			player.equipment.push(self)
			
			$status_view.add_to_buffer("You wear/wield #{@name}!")
			$status_view.draw_buffer
			$status_view.refresh
			
			player.dmg += @dmg_bonus
			player.max_hp += @hp_bonus
		end
		
		def take_off(player)
			player.equipment.delete(self)
			player.inventory.push(self)
			
			$status_view.add_to_buffer("You take off #{@name}!")
			$status_view.draw_buffer
			$status_view.refresh
			
			player.dmg -= @dmg_bonus
			player.max_hp -= @dmg_bonus
		end
	end
	
	class Scroll < Item
		def read(player)
			$status_view.add_to_buffer("You read #{@name}!")
			$status_view.add_to_buffer("Nothing happens...")
			$status_view.draw_buffer
			$status_view.refresh
			
			player.inventory.delete(self)
		end
	end
	
	class Potion < Item
		def quaff(player)
			$status_view.add_to_buffer("You drank #{@name}!")
			$status_view.add_to_buffer("It tastes weird")
			$status_view.draw_buffer
			$status_view.refresh
			
			player.inventory.delete(self)
		end
	end
end
