minetest.register_on_player_hpchange(function(player, hp_change, reason)
	if not player then return end
	local name = player:get_player_name()
	if hp_change < 0 then
		local team = origins.get_player_team(name)
		if (damage_type == "burning" or damage_type == "fireball" or reason.type == "node_damage" and 
		(reason.node == "mcl_fire:fire" or reason.node == "mcl_core:lava_source" or reason.node == "mcl_core:lava_flowing")) and team == "blazeborn" then
			hp_change = 0
		end
	end
	return hp_change
end, true)
