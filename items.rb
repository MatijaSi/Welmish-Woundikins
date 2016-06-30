# encoding: UTF-8

require_relative "mapping.rb"

module Items
	class Item < Mapping::Tile
		def initialize(x, y, char, name, realname, description)
			super(x, y)
			@char = char
			@color = Output::Colours::YELLOW
			@blocked = nil
			@type = :item
			@name = name
			@realname = name
			@desc = description
		end
		
		attr_accessor :name
		attr_reader :realname, :desc
		
		def pick_up(player)
			$items.delete(self)
			player.inventory.push(self)
			
			$status_view.add_to_buffer("You now have #{@name}!")
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
		def initialize(x, y, char, name, realname, description, dmg, hp, res)
			super(x, y, char, name, realname, description)
			@dmg_bonus = dmg
			@hp_bonus = hp
			@slot = "finger"
			@res_bonus = res
		end
		
		attr_accessor :dmg_bonus, :hp_bonus, :slot, :res_bonus
		
		def wear(player)
			player.inventory.delete(self)
			player.equipment.push(self)
			
			verb = "don"
			verb = "wear" if self.is_a?(Armour) || self.is_a?(Helmet)
			verb = "wield" if self.is_a?(Weapon)
			verb = "strap on" if self.is_a?(Shield)
			$status_view.add_to_buffer("You #{verb} #{@name}.")
			$status_view.draw_buffer
			$status_view.refresh
			
			player.dmg[0] += @dmg_bonus[0]
			player.dmg[1] += @dmg_bonus[1]
			player.dmg[2] += @dmg_bonus[2]
			player.dmg[3] += @dmg_bonus[3]
			
			player.res[0] += @res_bonus[0]
			player.res[1] += @res_bonus[1]
			player.res[2] += @res_bonus[2]
			player.res[3] += @res_bonus[3]
			
			player.max_hp += @hp_bonus
		end
		
		def take_off(player)
			player.equipment.delete(self)
			player.inventory.push(self)
			
			$status_view.add_to_buffer("You take off #{@name}!")
			$status_view.draw_buffer
			$status_view.refresh
			
			player.dmg[0] -= @dmg_bonus[0]
			player.dmg[1] -= @dmg_bonus[1]
			player.dmg[2] -= @dmg_bonus[2]
			player.dmg[3] -= @dmg_bonus[3]
			
			player.res[0] -= @res_bonus[0]
			player.res[1] -= @res_bonus[1]
			player.res[2] -= @res_bonus[2]
			player.res[3] -= @res_bonus[3]
			
			player.max_hp -= @hp_bonus
		end
	end
	
	class Armour < Wearable
		def initialize(x, y, char, name, realname, description, dmg, hp, res)
			super
			@slot = "torso"
		end
	end
	
	class Weapon < Wearable
		def initialize(x, y, char, name, realname, description, dmg, hp, res)
			super
			@slot = "arm"
		end
	end
	
	class Shield < Wearable
		def initialize(x, y, char, name, realname, description, dmg, hp, res)
			super
			@slot = "arm"
		end
	end
	
	class Helmet < Wearable
		def initialize(x, y, char, name, realname, description, dmg, hp, res)
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
		n = rand(1..6)
		
		case n
		when 1
			item = Items::HealingPotion.new(x, y, "!", "Potion", "Potion of Healing", "Swirling red liquid")
		when 2
			item = Items::PoisonPotion.new(x, y, "!", "Potion", "Poison", "Burbling green liquid")
		when 3
			item = Items::TeleportScroll.new(x, y, "?", "Scroll", "Teleport Scroll", "Scroll full of ancient runes")
		else
			n = rand(1..7)
			case n
			when 1
				mod = "of Fire"
			when 2
				mod = "of Ice"
			when 3
				mod = "of Poison"
			when 4
				mod = "of Light"
			when 5
				mod = "of Hope"
			when 6
				mod = "of Sadness"
			when 7
				mod = "of Averages"
			end
			
			n = rand(1..6)
			case n
			when 1
				fdmg = 5
				idmg = 5
				pdmg = 5
				ldmg = 5
				
				case mod
				when "of Fire"
					fdmg += 3
				when "of Ice"
					idmg += 3
				when "of Poison"
					pdmg += 3
				when "of Light"
					ldmg += 3
				when "of Hope"
					fdmg += 3
					ldmg += 3
				when "of Sadness"
					idmg += 3
					pdmg += 3
				end
				
				item = Items::Weapon.new(x, y, '|', "Sword", "Sword #{mod}", "One handed blade.", [fdmg, idmg, pdmg, ldmg], 0, [0, 0, 0, 0])
			when 2
				fres = 10
				ires = 10
				pres = 10
				lres = 10
				
				case mod
				when "of Fire"
					fres += 5
				when "of Ice"
					ires += 5
				when "of Poison"
					pres += 5
				when "of Light"
					lres += 5
				when "of Hope"
					fres += 5
					lres += 5
				when "of Sadness"
					ires += 5
					pres += 5
				end
				
				item = Items::Shield.new(x, y, ']', "Shield", "Shield #{mod}", "Forged under the earth.", [0, 0, 0, 0], 0, [fres, ires, pres, lres])
			when 3
				fres = 5
				ires = 5
				pres = 5
				lres = 5
				
				case mod
				when "of Fire"
					fres += 4
				when "of Ice"
					ires += 4
				when "of Poison"
					pres += 4
				when "of Light"
					lres += 4
				when "of Hope"
					fres += 3
					lres += 3
				when "of Sadness"
					ires += 3
					pres += 3
				end
				
				item = Items::Armour.new(x, y, '[', "Light Armour", "Light Armour of #{mod}", "Leather and metal scales.", [0, 0, 0, 0], 15, [fres, ires, pres, lres])
			when 4
				fres = 3
				ires = 3
				pres = 3
				lres = 3
				
				case mod
				when "of Fire"
					fres += 2
				when "of Ice"
					ires += 2
				when "of Poison"
					pres += 2
				when "of Light"
					lres += 2
				when "of Hope"
					fres += 1
					lres += 1
				when "of Sadness"
					ires += 1
					pres += 1
				end
				
				item = Items::Helmet.new(x, y, '[', "Mask", "Mask #{mod}", "Hides your tears.", [0, 0, 0, 0], 5, [fres, ires, pres, lres])
			when 5
				item = Items::Weapon.new(x, y, '|', "Short Sword", "Sting", "Likes Blood, glows softly.", [15, 10, 0, 10], 0, [0, 0, 20, 0])
			when 6
				item = Items::Helmet.new(x, y, '[', "Rotting mask", "Mask of Ithilus", "It was used to hide the faces of sacrifices.", [0, 5, 15, 0], -15, [30, 15, 15, 30])
			else
				item = Items::Shield.new(x, y, 'æ', "Silver Shield", "Shield of Wonders", "Pyramid is engraved on it." [20, 20, 20, 20], 20, [80, 80, 80, 80])
			end
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
