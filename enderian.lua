local GRAVITY = tonumber(minetest.settings:get("movement_gravity"))
  
local enderian_cooldown = {}

minetest.register_on_joinplayer(function(player)
	enderian_cooldown[player:get_player_name()] = false
end)

minetest.register_on_leaveplayer(function(player)
	enderian_cooldown[player:get_player_name()] = false
end)

local function spawn_pearl(player)
	if enderian_cooldown[player:get_player_name()] then
		minetest.chat_send_player(player:get_player_name(), "Please wait for your 3 second cooldown to end")
		return
	end
	enderian_cooldown[player:get_player_name()] = true
	minetest.after(3, function()
		enderian_cooldown[player:get_player_name()] = false
	end)
	local pos = player:get_pos()
      	local dir = player:get_look_dir()
      	local obj = minetest.add_entity(pos, "mcl_throwing:ender_pearl_entity")
	if obj then
      		obj:set_velocity(vector.multiply(dir, 22))
      		obj:set_acceleration({x=dir.x*-3, y=-GRAVITY, z=dir.z*-3})
	end
end


minetest.register_globalstep(function(dtime)
	for _,player in pairs(minetest.get_connected_players()) do
		local pname = player:get_player_name()
		local team = origins.get_player_team(pname)
		if not team == "enderian" then return end
		local control = player:get_player_control()
		if control.zoom then
			spawn_pearl(player)
		end
	end
end)


