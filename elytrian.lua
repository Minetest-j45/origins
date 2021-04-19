--elytra effect
minetest.register_globalstep(function(dtime)
	for _, player in pairs(origins.origin.elytrian) do
		local control = player:get_player_controls()
		local player_velocity = player:get_velocity() or player:get_player_velocity()
		local fly_pos = player:get_pos()
		local fly_node = minetest.get_node({x = fly_pos.x, y = fly_pos.y - 0.5, z = fly_pos.z}).name
		local elytra = mcl_playerplus.elytra[player]
		elytra.active = (elytra.active or control.jump and player_velocity.y < -6) and not player:get_attach() and (fly_node == "air" or fly_node == "ignore")
	end
end)
