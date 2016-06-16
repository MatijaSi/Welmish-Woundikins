require_relative "BearLibTerminal.rb"
require_relative "creatures.rb"

module CharCreation
	def self.create_player(x, y)
		return Creatures::Player.new(x, y)
	end
end
