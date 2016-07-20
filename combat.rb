module Combat
	def self.attack(attacker, defender)
		if rand(1..6) > 2
			f_dmg = attacker.damages[:fire] * ((100.0 - defender.resistances[:fire]) / 100.0)
			i_dmg = attacker.damages[:ice] * ((100.0 - defender.resistances[:ice]) / 100.0)
			p_dmg = attacker.damages[:light] * ((100.0 - defender.resistances[:light]) / 100.0)
			l_dmg = attacker.damages[:dark] * ((100.0 - defender.resistances[:dark]) / 100.0)
			
			dmg = f_dmg + i_dmg + p_dmg + l_dmg
			
			damage = rand((dmg / 3)..dmg)
			
			if damage <= 0
				damage = 1
			end
			
			defender.hp -= damage.round
			message = "#{attacker.name} hit #{defender.name} for #{damage.round}."
		else
			message = "#{attacker.name} missed!"
		end
		if $player.in_fov?(attacker) || $player.in_fov?(defender)
			$status_view.add_to_buffer(message)
			$status_view.draw_buffer
		end
		
		if defender.hp < 0
			attacker.kills += 1
			defender.death
		end
	end
end
