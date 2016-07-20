require_relative "output.rb"
require_relative "input.rb"
require_relative "mapping.rb"
require_relative "creatures.rb"

#player generation
$player = Creatures::Player.new(0, 0, 0)

#player customization
puts "What's your name?"
pname = gets.chop.capitalize
puts "What's your class?"
pclass = gets.chop.capitalize

$player.name = pname
$player.class = pclass

#level generation
MAP_SIZE = [100, 100]
Mapping.level_generator(MAP_SIZE[0], MAP_SIZE[1], rand(15..30), $player)

#item generation

#initialize console
Output.setup_console

#constants
MAIN_SIZE = [60, 18]
STATUS_SIZE = [MAIN_SIZE[0], 6]
PLAYER_SIZE = [20, MAIN_SIZE[1] + STATUS_SIZE[1]]

#initialize views
$main_view = Output::View.new(0, 0, MAIN_SIZE[0], MAIN_SIZE[1])
$status_view = Output::StatusView.new(0, MAIN_SIZE[1], STATUS_SIZE[0], STATUS_SIZE[1])
$player_view = Output::View.new(MAIN_SIZE[0], 0, PLAYER_SIZE[0], PLAYER_SIZE[1])

#inital status
$status_view.add_to_buffer("Welcome to Welmish Woundikins!")
$status_view.add_to_buffer("If you can't see entire screen resize it to 80x24.")
$status_view.add_to_buffer("A nazgul is terrorizing your homeland.")
$status_view.add_to_buffer("Press '?' for help.")
$status_view.draw_buffer

#pregame calculations
$monsters.each {|monster| monster.recalc_fov($map)}

#main loop
while 1
	#clear views
	$player_view.clear
	$main_view.clear
	
	#update views
	$map.draw($player)
	$monsters.each {|monster| monster.draw($player)}
	$player.state
	
	Output.draw_gui_decorations($player)
	
	#refresh views
	$player_view.refresh
	$main_view.refresh
	$status_view.refresh

	#actors processing
	$monsters.each {|monster|
		monster.recalc_fov($map)
		monster.regen
		monster.act($map)
		monster.death if monster.hp < 0}
	
	#other processing
	$map.mirrors.each {|mirror| mirror.teleport($player)} #check if player stands on mirror and teleport him if he does
end

#closure
Output.close_console
exit
