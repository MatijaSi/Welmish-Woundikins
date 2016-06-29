require_relative "mapping.rb"
require_relative "combat.rb"
require_relative "ai.rb"
require_relative "items.rb"

module Creatures
	class GenericCreature < Mapping::Tile
		def initialize(x, y, name = "Cthulhu")
			super(x, y)
			@char = 'C'
			@blocked = nil
			@fov = 5
			@max_hp = 50
			@hp = @max_hp
			@dmg = 12
			@name = name
			@colour = Output::Colours::RED
			@colour_not_fov = Output::Colours::BLACK
			@regen = 1
			@type = :monster
			@player = false
			@class = "Abyssal one"
			@kills = 0
			
			@inventory = []
			@equipment = []
			
			#number of inventory slots
			@slots = {"arm" => 2, "head" => 1, "torso" => 1}
		end
		
		def regen #restore some of lost health
			if @hp < @max_hp
				@hp += @regen
				@hp = @max_hp if @hp > @max_hp
			end
		end
		
		def check_if_dead #only use with player controlled beings!
			if @hp <= 0 && @player == true
				$status_view.add_to_buffer("You died.")
				$status_view.add_to_buffer("Press q to quit.")
				$status_view.draw_buffer
				
				while 1
					if Input.get_key($main_view.window) == 'q'
						Output.close_console
						exit
					end
				end
			end
		end
		
		def death
			$status_view.add_to_buffer("#{@name} died.")
			$status_view.draw_buffer
			$monsters.delete(self)
			
			if rand(1..6) > 5 #drop an item
				$items.push(Items.item_generator(@x, @y))
				$status_view.add_to_buffer("#{@name} dropped something!.")
				$status_view.draw_buffer
			end
			
			#redraw screen
			$main_view.clear
			$map.draw($main_view)
			$items.each {|item| item.draw($main_view)}
			$player.draw($main_view)
			$monsters.each {|monster| monster.draw($main_view)}
			$main_view.refresh
		end
		
		def state(view)
			colour = Output::Colours::WHITE
			view.draw(0, 0, "#{@name} the #{@class}", colour)
			view.draw(0, 1, "x: #{@x}", colour)
			view.draw(0, 2, "y: #{@y}", colour)
			view.draw(0, 4, "health: #{@hp}/#{@max_hp}", colour)
			view.draw(0, 5, "regen per turn: #{@regen}", colour)
			view.draw(0, 6, "damage: #{@dmg}", colour)
			view.draw(0, 8, "kills: #{@kills}", colour)
			view.draw(0, 10, "Inventory:", colour)
			
			i = 11
			j = 0
			@inventory.each {|item|
				view.draw(0, i, "#{j}: #{item.name}", colour)
				i += 1
				j += 1}
			
			i += 1
			view.draw(0, i, "Equipment:", colour)
			
			i += 1
			j = 0
			@equipment.each {|item|
				view.draw(0, i, "#{j}: #{item.name}", colour)
				i += 1
				j += 1}
		end
		
		def act(key = false)
			if @player
				PlayerAI.act(key, self)
			else
				RandomAI.act(self)
			end
		end
		
		def move(to_x, to_y)
			@x += to_x
			@y += to_y
		end
		
		attr_reader :fov, :name, :class, :slots
		attr_accessor :hp, :dmg, :max_hp, :equipment, :inventory, :player, :kills
	end
	
	class Player < GenericCreature
		def initialize(x, y, name)
			super(x, y)
			@char = '@'
			@name = name.capitalize
			@type = :player
			@kills = 0
			@player = true
			
			@class = "Warrior"
			
			@fov = 4
			
			@max_hp = 100
			@hp = @max_hp
			@dmg = 15
			
			@colour = Output::Colours::YELLOW
			@regen = 2
		end
		
		def act(key)
			PlayerAI.act(key, self)
		end
	end
	
	class Rogue < Player
		def initialize(x, y, name)
			super

			@class = "Rogue"
			@fov = 6 if @class == "Rogue"
			
			@max_hp = 100
			@hp = @max_hp
			@dmg = 10 if @class == "Rogue"
		end
	end
	
	class Barbarian < Player
		def initialize(x, y, name)
			super
			@class = "Barbarian"
			
			@fov = 4
			@max_hp = 80
			@hp = @max_hp
			@dmg = 15
		end
	end
	
	class Goblin < GenericCreature
		def initialize(x, y, name = "Goblin")
			super
			@char = 'G'
			@dmg = 12
			@max_hp = 40
			@hp = @max_hp
			@name = name
			@colour = Output::Colours::GREEN
			@class = "Marauder"
		end
		
		def act(key = false)
			if @player
				PlayerAI.act(key, self)
			else
				if (($player.x - @x) == 0 || ($player.x - @x).abs == 1) && (($player.y - @y) == 0 || ($player.y - @y).abs == 1)
					Combat.attack(self, $player)
				elsif $player.in_fov?(self)
					SeekerAI.act(self)
				else
					RandomAI.act(self)
				end
			end
		end
	end
	
	class GoblinWarlord < Goblin
		def initialize(x, y, name = "Goblin Warlord")
			super
			@char = 'G'
			@name = name
			@colour = Output::Colours::RED
			@dmg = 15
			@max_hp = 50
			@hp = @max_hp
			@regen = 3
			@class = "War Leader"
		end
		
		def act(key = false)
			if @player
				PlayerAI.act(key, self)
			else
				if $player.in_fov?(self) && rand(1..6) == 6
					$status_view.add_to_buffer("#{@name} summoned his followers!")
					$status_view.draw_buffer
					$status_view.refresh
				
					dirs = [-1, 0, 1]
					i = 0
					j = 0
					num = 0
					until i > 2
						until j > 2
							unless (Mapping.exists($map.tiles, @x + dirs[i], @y + dirs[j]).blocked) || (i == j && i == 0) || (Mapping.exists($monsters, @x + dirs[i], @y + dirs[j])) || ($player.x == @x + dirs[i] && $player.y == @y + dirs[j])
								if rand(1..20) == 20
									$monsters.push(GoblinWarlord.new(@x + dirs[i], @y + dirs[j]))
								elsif rand(1..6) > 3
									$monsters.push(Goblin.new(@x + dirs[i], @y + dirs[j]))
									num += 1
									break if num > 3
								end
							end
						
							j += 1
						end
						j = 0	
						i += 1
					end
				else
					super
				end
			end
		end
	end
	
	class Scoundrel < Goblin
		def initialize(x, y, name = "Scoundrel")
			super
			@char = 'S'
			@dmg = 10
			@name = name
			@colour = Output::Colours::CYAN
			@class = "Bandit"
		end
		
		def act(key = false)
			if @player
				PlayerAI.act(key, self)
			else
				if @hp < (@max_hp / 2) && $player.in_fov?(self) #run
					RunnerAI.act(self)
				else
					super
				end
			end
		end	
	end
	
	class Nazgul < Goblin
		def initialize(x, y, name = "Nazgul")
			super
			@char = 'N'
			@dmg = 20
			@max_hp = 100
			@hp = @max_hp
			@name = name
			@regen = 1
			@colour = Output::Colours::RED
			@fov = 8
			@class = "Dark One"
		end
		
		def death
			$status_view.add_to_buffer("Congrats! You won by killing the dark one.")
			$status_view.add_to_buffer("Quit by pressing 'q'")
			$status_view.draw_buffer
		
			while 1
				if Input.get_key($main_view.window) == 'q'
					Output.close_console
					exit
				end
			end
		end
	end
	
	class Bomber < Goblin
		def initialize(x, y, name = "Bomber")
			super
			@char = 'B'
			@dmg = 1
			@max_hp = 5
			@hp = @max_hp
			@name = name
			@regen = 0
			@colour = Output::Colours::RED
			@class = "Hopeful"
		end
		
		def act(key = false)
			if @player
				PlayerAI.act(key, self)
			else
				if ($player.x - @x).abs < 2 && ($player.y - @y).abs < 2
					self.death
				else
					super
				end
			end
		end
		
		def death
			array = $monsters + [$player]
			array.each {|being|
				if (being.x - @x).abs < 3 && (being.y - @y).abs < 3
					being.hp -= 30
				end}
			
			$status_view.add_to_buffer("#{@name} exploded.")
			$status_view.draw_buffer
			$monsters.delete(self)
			
			$main_view.clear
			$map.draw($main_view)
			$items.each {|item| item.draw($main_view)}
			$player.draw($main_view)
			$monsters.each {|monster| monster.draw($main_view)}
			$main_view.refresh
		end
	end
end
