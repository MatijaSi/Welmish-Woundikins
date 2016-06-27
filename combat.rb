module Combat
	def self.attack(attacker, defender)
		if rand(1..6) > 2
			damage = rand(3..attacker.dmg)
			defender.hp -= damage
			$status_view.add_to_buffer("#{defender.name} was struck by #{attacker.name} for #{damage} points of damage!")
		else
			$status_view.add_to_buffer("#{attacker.name} missed!")
		end
		
		$status_view.draw_buffer
	end
end
