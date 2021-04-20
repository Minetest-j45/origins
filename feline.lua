minetest.register_on_player_hpchange(function(player, hp_change, reason)
	if not player then return end
	local name = player:get_player_name()
	if hp_change < 0 then
		local fall_dmg = false
		local team = origins.get_player_team(name)
		if reason.type == "fall" and team == "feline" then
			hp_change = 0
		end
	end
	hp_change = -math.abs(hp_change)
	return hp_change
end, true)
