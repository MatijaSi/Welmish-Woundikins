module Combat
	def self.attack(attacker, defender)
		if rand(1..6) > 2
			defender.hp -= attacker.dmg
			$status_view.add_to_buffer("#{defender.name} was struck by #{attacker.name}")
		else
			$status_view.add_to_buffer("#{attacker.name} missed!")
		end
		
		$status_view.draw_buffer
	end
end
