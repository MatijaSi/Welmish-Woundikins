require_relative "mapping.rb"

module Items
	class Item < Mapping::Tile
		def initialize(x, y, char, name)
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
			@slot = "finger"
		end
		
		attr_accessor :dmg_bonus, :hp_bonus, :slot
		
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
	
	class Armour < Wearable
		def initialize(x, y, char, name, dmg, hp)
			super
			@slot = "torso"
		end
	end
	
	class Weapon < Wearable
		def initialize(x, y, char, name, dmg, hp)
			super
			@slot = "arm"
		end
	end
	
	class Shield < Wearable
		def initialize(x, y, char, name, dmg, hp)
			super
			@slot = "arm"
		end
	end
	
	class Helmet < Wearable
		def initialize(x, y, char, name, dmg, hp)
			super
			@slot = "head"
		end
	end
	
	class Scroll < Item
		def read(player)
			$status_view.add_to_buffer("You read #{@name}!")
			$status_view.add_to_buffer("It burns up in front of your eyes")
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
	
	class HealingPotion < Potion
		def quaff(player)
			super
			if player.hp + 10 > player.max_hp
				player.hp = player.max_hp
			else
				player.hp += 10
			end
			
			$status_view.add_to_buffer("It was a potion of healing")
			$status_view.draw_buffer
			$status_view.refresh
		end
	end
	
	class PoisonPotion < Potion
		def quaff(player)
			super
			player.hp -= 10
			
			$status_view.add_to_buffer("It was a potion of poison")
			$status_view.draw_buffer
			$status_view.refresh
		end
	end
	
	class TeleportScroll < Scroll
		def read(player)
			super
			tile = false
			until tile
				ntile = $map.tiles.sample
				tile = ntile unless ntile.blocked
			end
			
			player.x = tile.x
			player.y = tile.y
			
			$status_view.add_to_buffer("You are drawn into strange flux.")
			$status_view.draw_buffer
			$status_view.refresh
		end
	end
end
