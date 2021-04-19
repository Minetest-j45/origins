origins.elytra = {}

local player_vel_yaws = {}
local dir_to_yaw = minetest.dir_to_yaw
local player_collision = function(player)

	local pos = player:get_pos()
	--local vel = player:get_velocity()
	local x = 0
	local z = 0
	local width = .75

	for _,object in pairs(minetest.get_objects_inside_radius(pos, width)) do

		if object and (object:is_player()
		or (object:get_luaentity()._cmi_is_mob == true and object ~= player)) then

			local pos2 = object:get_pos()
			local vec  = {x = pos.x - pos2.x, z = pos.z - pos2.z}
			local force = (width + 0.5) - vector.distance(
				{x = pos.x, y = 0, z = pos.z},
				{x = pos2.x, y = 0, z = pos2.z})

			x = x + (vec.x * force)
			z = z + (vec.z * force)
		end
	end

	return({x,z})
end

local function degrees(rad)
	return rad * 180.0 / math.pi
end

--elytra effect
minetest.register_globalstep(function(dtime)
	for _, pname in pairs(origins.origin.elytrian) do
		local player = minetest.get_player_by_name(pname)
		local control = player:get_player_control()
		local player_velocity = player:get_velocity() or player:get_player_velocity()
			
		local c_x, c_y = unpack(player_collision(player))

		if player_velocity.x + player_velocity.y < .5 and c_x + c_y > 0 then
			local add_velocity = player.add_player_velocity or player.add_velocity
			add_velocity(player, {x = c_x, y = 0, z = c_y})
			player_velocity = player:get_velocity() or player:get_player_velocity()
		end

		-- control head bone
		local pitch = - degrees(player:get_look_vertical())
		local yaw = degrees(player:get_look_horizontal())

		local player_vel_yaw = degrees(dir_to_yaw(player_velocity))
		if player_vel_yaw == 0 then
			player_vel_yaw = player_vel_yaws[pname] or yaw
		end
		player_vel_yaw = limit_vel_yaw(player_vel_yaw, yaw)
		player_vel_yaws[pname] = player_vel_yaw

		local fly_pos = player:get_pos()
		local fly_node = minetest.get_node({x = fly_pos.x, y = fly_pos.y - 0.5, z = fly_pos.z}).name
		local elytra = origins.elytra[player]
		elytra.active = (elytra.active or control.jump and player_velocity.y < -6) and not player:get_attach() and (fly_node == "air" or fly_node == "ignore")
			
		if elytra.active then
			mcl_player.player_set_animation(player, "fly")
			if player_velocity.y < -1.5 then
				player:add_velocity({x=0, y=0.17, z=0})
			end
			if math.abs(player_velocity.x) + math.abs(player_velocity.z) < 20 then
				local dir = minetest.yaw_to_dir(player:get_look_horizontal())
				if degrees(player:get_look_vertical()) * -.01 < .1 then
					look_pitch = degrees(player:get_look_vertical()) * -.01
				else
					look_pitch = .1
				end
				player:add_velocity({x=dir.x, y=look_pitch, z=dir.z})
			end
			playerphysics.add_physics_factor(player, "gravity", "origins:elytra", 0.1)

			if elytra.rocketing > 0 then
				elytra.rocketing = elytra.rocketing - dtime
				if vector.length(player_velocity) < 40 then
					local add_velocity = player.add_velocity or player.add_player_velocity
					add_velocity(player, vector.multiply(player:get_look_dir(), 4))
				end
			end
		else
			elytra.rocketing = 0
			playerphysics.remove_physics_factor(player, "gravity", "origins:elytra")
		end
	end
end)
