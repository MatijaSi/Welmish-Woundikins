require_relative "output.rb"
require_relative "input.rb"
require_relative "mapping.rb"
require_relative "creatures.rb"
require_relative "items.rb"

#get player name
print "What's your name? > "
name = gets.chomp

pclass = 0
until pclass == 'a' || pclass == 'b' || pclass == 'c'
	puts "Classes: a - rogue, b - warrior, c - barbarian"
	print "> "
	pclass = gets.chomp
end

#initialize console
Output.setup_console

#constants
MAIN_SIZE = [80, 20]
STATUS_SIZE = [MAIN_SIZE[0], 10]
PLAYER_SIZE = [20, MAIN_SIZE[1] + STATUS_SIZE[1]]

#initialize views
$main_view = Output::View.new(0, 0, MAIN_SIZE[0], MAIN_SIZE[1])
$status_view = Output::StatusView.new(0, MAIN_SIZE[1], STATUS_SIZE[0], STATUS_SIZE[1])
$player_view = Output::View.new(MAIN_SIZE[0], 0, PLAYER_SIZE[0], PLAYER_SIZE[1])

#generate map
$map = Mapping::Map.new(0, 0, 100, 100)
coords = $map.populate

#generate player
$player = Creatures::Player.new(coords[0], coords[1], name, pclass)

#spawn items
$items = []
number = rand(5..15)
i = 0
until i >= number
	tile = false
	until tile
		ntile = $map.tiles.sample
		tile = ntile unless ntile.blocked
	end
	
	item = rand(1..10)
	
	case item
	when 1 , 2
		$items.push(Items::Wearable.new(tile.x, tile.y, '|', "Sword", 3, 0))
	when 3 , 4
		$items.push(Items::Wearable.new(tile.x, tile.y, '|', "Mace", 5, 0))
	when 5 , 6
		$items.push(Items::Wearable.new(tile.x, tile.y, '[', "Light armour", 0, 10))
	when 7 , 8
		$items.push(Items::Potion.new(tile.x, tile.y, '!', "Potion"))
	when 9 , 10
		$items.push(Items::Scroll.new(tile.x, tile.y, '~', "Scroll"))
	else
		$items.push(Items::Wearable.new(tile.x, tile.y, 'æ', "Shield of Wonders", 7, 20))
	end
	i += 1
end

#spawn monsters
$monsters = []
number = rand(7..21)
i = 0
until i >= number
	tile = false
	until tile
		ntile = $map.tiles.sample
		tile = ntile unless ntile.blocked
	end
	if rand(1..10) > 8
		$monsters.push(Creatures::GoblinWarlord.new(tile.x, tile.y))
	elsif rand(1..10) > 4
		$monsters.push(Creatures::Goblin.new(tile.x, tile.y))
	elsif rand(1..10) > 3
		$monsters.push(Creatures::Scoundrel.new(tile.x, tile.y))
	else
		$monsters.push(Creatures::Bomber.new(tile.x, tile.y))
	end
	i += 1
end

tile = false
until tile
	ntile = $map.tiles.sample
	tile = ntile unless ntile.blocked
end

$monsters.push(Creatures::Nazgul.new(tile.x, tile.y))

#initial draw (so screen isn't empty before input)
$map.draw($main_view)
$player.draw($main_view)
$items.each {|item| item.draw($main_view)}
$monsters.each {|monster| monster.draw($main_view)}

#status
$status_view.add_to_buffer("Welcome to Welmish Woundikins!")
$status_view.add_to_buffer("If you can't see the player menu, exit the game and resize screen.")
$status_view.add_to_buffer("A nazgul is terrorizing your homeland.")
$status_view.draw_buffer

#main loop
while 1
	$main_view.window.box('*', '*') #give the window border
	
	$player_view.clear
	$player.state($player_view)
	$player_view.refresh
	
	key = Input.get_key($main_view.window)
	
	#check if the player moved
	x = $player.x
	y = $player.y
	
	$player.check_if_dead
	$player.act(key) #give player control
	
	$monsters.each {|monster|
		if monster.hp <= 0
			monster.death
			$player.kills += 1
		end}
	
	$main_view.clear
	$map.draw($main_view)
	$items.each {|item| item.draw($main_view)}
	$player.draw($main_view)
	$main_view.refresh
	
	$monsters.each {|monster|
		monster.draw($main_view)
		monster.act
		monster.regen}
	
	$player.regen
	break if key == 'Q'
end

Output.close_console
exit
