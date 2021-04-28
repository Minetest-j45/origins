minetest.register_on_player_hpchange(function(player, hp_change, reason)
	if not player then return end
	local name = player:get_player_name()
	if hp_change < 0 then
		local team = origins.get_player_team(name)
		if (damage_type == "burning" or reason.type == "node_damage" and 
		(reason.node == "mcl_fire:fire" or reason.node == "mcl_core:lava_source" or reason.node == "mcl_core:lava_flowing")) and team == "blazeborn" then
			hp_change = 0
		end
	end
	return hp_change
end, true)



local water_timer = 0
minetest.register_globalstep(function(dtime)
	water_timer = water_timer + dtime;
	if water_timer >= 1 then
		for _, player in pairs(minetest.get_connected_players()) do
			local pname = player:get_player_name()
			local team = origins.get_player_team(pname)
			if team ~= "enderian" or team ~= "blazeborn" then return end
			if minetest.get_item_group(mcl_playerinfo[pname].node_head, "water") ~= 0 or minetest.get_item_group(mcl_playerinfo[pname].node_feet, "water") > 0 then
				player:set_hp(player:get_hp()-math.random(0.5, 1), {type = "set_hp", from = "mod", allergies = "tru"})
			end
		end
		water_timer = 0
	end
end)

minetest.register_on_player_hpchange(function(player, hp_change, reason)
	local name = player:get_player_name()
	if name and hp_change < 0 then
		if reason.allergies == "tru" then
			for i=1, 6 do
				local stack = player:get_inventory():get_stack("armor", i)
				if stack:get_count() > 0 then
					local enchantments = mcl_enchanting.get_enchantments(stack)
					if enchantments.water_protection then
						hp_change = 0
					end
				end
			end
		end
	end
	return hp_change
end, true)
