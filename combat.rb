module Combat
	def self.attack(attacker, defender)
		damage_dealt = rand(1..attacker.dmg)
		defender.hp -= damage_dealt
	end
end
