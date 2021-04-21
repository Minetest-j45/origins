local GRAVITY = tonumber(minetest.settings:get("movement_gravity"))

minetest.register_globalstep(function(dtime)
	for _, pname in ipairs(origins.origin.enderian) do
		local player = minetest.get_player_by_name(pname)
		local control = player:get_player_control()
		if control.jump then
			local pos = player:get_pos()
      local dir = player:get_look_dir()
      local obj = minetest.add_entity(pos, "mcl_throwing:ender_pearl_entity")
      obj:set_velocity(vector.multiply(dir, 22))
      obj:set_acceleration({x=dir.x*-3, y=-GRAVITY, z=dir.z*-3})
		end
	end
end)


