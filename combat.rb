module Combat
	def self.attack(attacker, defender)
		if rand(1..6) > 2
			f_dmg = attacker.dmg[0] * ((100.0 - defender.res[0]) / 100.0)
			i_dmg = attacker.dmg[1] * ((100.0 - defender.res[1]) / 100.0)
			p_dmg = attacker.dmg[2] * ((100.0 - defender.res[2]) / 100.0)
			l_dmg = attacker.dmg[3] * ((100.0 - defender.res[3]) / 100.0)
			
			dmg = f_dmg + i_dmg + p_dmg + l_dmg
			
			damage = rand((dmg / 3)..dmg)
			
			if damage <= 0
				damage = 1
			end
			
			defender.hp -= damage.round
			$status_view.add_to_buffer("#{defender.name} was struck by #{attacker.name} for #{damage.round} points of damage!")
		else
			$status_view.add_to_buffer("#{attacker.name} missed!")
		end
		
		$status_view.draw_buffer
	end
end
