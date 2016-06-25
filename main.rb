require_relative "output.rb"
require_relative "input.rb"
require_relative "mapping.rb"
require_relative "creatures.rb"

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
$player = Creatures::Player.new(coords[0], coords[1])

#spawn monsters
$monsters = []
number = rand(3..7)
i = 0
until i >= number
	tile = false
	until tile
		ntile = $map.tiles.sample
		tile = ntile unless ntile.blocked
	end
	$monsters.push(Creatures::Goblin.new(tile.x, tile.y))
	i += 1
end

tile = false
until tile
	ntile = $map.tiles.sample
	tile = ntile unless ntile.blocked
end

x = tile.x
y = tile.y

$boss = Creatures::Nazgul.new(x, y)

#initial draw (so screen isn't empty before input)
$map.draw($main_view)
$player.draw($main_view)

#status
$status_view.add_to_buffer("Welcome to Welmish Woundikins!")
$status_view.add_to_buffer("If you can't see the player menu, exit the game and resize screen.")
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
	
	$main_view.clear
	$map.draw($main_view)
	$player.draw($main_view)
	$main_view.refresh

	
	$monsters.each {|monster|
		if monster.hp <= 0
			$status_view.add_to_buffer("#{monster.name} died.")
			$status_view.draw_buffer
			$monsters.delete(monster)
		end}
	
	if $boss.hp <= 0
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
	
	$monsters.each {|monster| monster.draw($main_view)}
	$boss.draw($main_view)
	$monsters.each {|monster| monster.act}
	$boss.act
	
	break if key == 'q'
end

Output.close_console
