# encoding UTF-8

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
	
	def self.item_generator(x, y) #generate one item
		n = rand(1..51)
		
		case n
		when 1, 28, 29, 30, 31
			item = Items::Weapon.new(x, y, '|', "Sword", 3, 0)
		when 2, 32, 33
			item = Items::Weapon.new(x, y, '|', "Hatchet", 4, 0)
		when 3, 34
			item = Items::Weapon.new(x, y, '|', "Mace", 5, 0)
		when 4, 27
			item = Items::Armour.new(x, y, '[', "Heavy armour", 0, 20)
		when 5, 41
			item = Items::Helmet.new(x, y, '[', "Helmet", 0, 7)
		when 6, 42, 43, 44, 45
			item = Items::Shield.new(x, y, ']', "Buckler", 0, 5)
		when 7, 8, 49, 50
			item = Items::HealingPotion.new(x, y, '!', "Potion")
		when 9, 10, 51
			item = Items::PoisonPotion.new(x, y, '!', "Potion")
		when 11, 12
			item = Items::TeleportScroll.new(x, y, '?', "Scroll")
		when 13, 21, 22, 23, 24
			item = Items::Armour.new(x, y, '[', "Light armour", 0, 10)
		when 14, 25, 26
			item = Items::Armour.new(x, y, '[', "Scale mail", 0, 15)
		when 15, 46, 47
			item = Items::Shield.new(x, y, ']', "Shield", 0, 8)
		when 16, 48
			item = Items::Shield.new(x, y, ']', "Tower shield", 0, 17)
		when 17, 39, 40
			item = Items::Helmet.new(x, y, '[', "Cap", 0, 5)
		when 18, 35, 36, 37, 38
			item = Items::Helmet.new(x, y, '[', "Mask", 0, 2)
		when 19
			item = Items::Weapon.new(x, y, '[', "Sting", 8, 0)
		when 20
			item = Items::Helmet.new(x, y, '[', "Ithilus Mask", 0, 20)
		else
			item = Items::Shield.new(x, y, 'æ', "Shield of Wonders", 7, 20)
		end
		
		return item
	end
	
	def self.items_generator(number, map) #generates number items
		i = 0
		items = []
		until i >= number
			tile = false
			until tile
				ntile = map.tiles.sample
				tile = ntile unless ntile.blocked || Mapping.exists(items, ntile.x, ntile.y) || ($player.x == ntile.x && $player.y == ntile.y)
			end
			
			items.push(Items.item_generator(tile.x, tile.y))
			
			i += 1
		end
		
		return items
	end
end
