require_relative "BearLibTerminal.rb"

require_relative "display.rb"
require_relative "input.rb"
require_relative "creatures.rb"
require_relative "mapping.rb"
require_relative "utilities.rb"
require_relative "char_creation.rb"

#window size
$window_x = 80
$window_y = 40

#views
$status_view = [0, $window_y - 11, $window_x - 31, $window_y]
$map_view = [0, 0, $window_x - 14, $window_y - 10]
$player_view = [$window_x - 15, 0, $window_x, $window_y]

#status buffer
$status = ["Welcome to Welmish Woundikins!", "Nethack keys to move."]

$map = Mapping::Map.new(1000)
$map.populate()

coords = Utilities.find_free_coords($map.tiles, 500)
$player = CharCreation.create_player(coords[0], coords[1])

$monsters = []
i = 0
while i < 10
	coords = Utilities.find_free_coords($map.tiles, rand(200..700))
	$monsters.push(Creatures::Goblin.new(coords[0], coords[1]))
	i += 1
end

Terminal.open() #open the terminal window
Terminal.set("window: size=#{$window_x}x#{$window_y}, title='Welmish Woundikins'; font: ./fonts/terminal12x12.png, size=12x12; input.filter = [keyboard]") #configure it
Terminal.refresh()

until Terminal.read() == Terminal::TK_ESCAPE
	Terminal.clear()
	
	$player.state()
	Display.print_status($status)
	
	$map.draw($player)
	$player.draw()
	
	$monsters.each {|monster| monster.draw($player)}
	$monsters.each {|monster| monster.act($player)}
	$monsters.each {|monster|
		if monster.hp <= 0
			$status.push("Goblin died!")
			$monsters.delete(monster)
		end}
		
	if $player.hp <= 0
		$status.push("You died.")
		Display.print_status($status)
		sleep(5)
		abort
	end
	
	Terminal.refresh()
	Input.handle_keys($player, $status)
end
Terminal.close()
