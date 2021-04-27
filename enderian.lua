local GRAVITY = tonumber(minetest.settings:get("movement_gravity"))

-- Ender pearl entity
local pearl_ENTITY={
	physical = false,
	timer=0,
	textures = {"mcl_throwing_ender_pearl.png"},
	visual_size = {x=0.9, y=0.9},
	collisionbox = {0,0,0,0,0,0},
	pointable = false,

	get_staticdata = mcl_throwing.get_staticdata,
	on_activate = mcl_throwing.on_activate,

	_lastpos={},
	_thrower = nil,		-- Player ObjectRef of the player who threw the ender pearl
}

-- Movement function of ender pearl
local pearl_on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:get_pos()
	pos.y = math.floor(pos.y)
	local node = minetest.get_node(pos)
	local nn = node.name
	local def = minetest.registered_nodes[node.name]

	-- Destroy when hitting a solid node
	if self._lastpos.x~=nil then
		local walkable = (def and def.walkable)

		-- No teleport for hitting ignore for now. Otherwise the player could get stuck.
		-- FIXME: This also means the player loses an ender pearl for throwing into unloaded areas
		if node.name == "ignore" then
			self.object:remove()
		-- Activate when hitting a solid node or a plant
		elseif walkable or nn == "mcl_core:vine" or nn == "mcl_core:deadbush" or minetest.get_item_group(nn, "flower") ~= 0 or minetest.get_item_group(nn, "sapling") ~= 0 or minetest.get_item_group(nn, "plant") ~= 0 or minetest.get_item_group(nn, "mushroom") ~= 0 or not def then
			local player = self._thrower and minetest.get_player_by_name(self._thrower)
			if player then
				-- Teleport and hurt player

				-- First determine good teleport position
				local dir = {x=0, y=0, z=0}

				local v = self.object:get_velocity()
				if walkable then
					local vc = table.copy(v) -- vector for calculating
					-- Node is walkable, we have to find a place somewhere outside of that node
					vc = vector.normalize(vc)

					-- Zero-out the two axes with a lower absolute value than
					-- the axis with the strongest force
					local lv, ld
					lv, ld = math.abs(vc.y), "y"
					if math.abs(vc.x) > lv then
						lv, ld = math.abs(vc.x), "x"
					end
					if math.abs(vc.z) > lv then
						ld = "z" --math.abs(vc.z)
					end
					if ld ~= "x" then vc.x = 0 end
					if ld ~= "y" then vc.y = 0 end
					if ld ~= "z" then vc.z = 0 end

					-- Final tweaks to the teleporting pos, based on direction
					-- Impact from the side
					dir.x = vc.x * -1
					dir.z = vc.z * -1

					-- Special case: top or bottom of node
					if vc.y > 0 then
						-- We need more space when impact is from below
						dir.y = -2.3
					elseif vc.y < 0 then
						-- Standing on top
						dir.y = 0.5
					end
				end
				-- If node was not walkable, no modification to pos is made.

				-- Final teleportation position
				local telepos = vector.add(pos, dir)
				local telenode = minetest.get_node(telepos)

				--[[ It may be possible that telepos is walkable due to the algorithm.
				Especially when the ender pearl is faster horizontally than vertical.
				This applies final fixing, just to be sure we're not in a walkable node ]]
				if not minetest.registered_nodes[telenode.name] or minetest.registered_nodes[telenode.name].walkable then
					if v.y < 0 then
						telepos.y = telepos.y + 0.5
					else
						telepos.y = telepos.y - 2.3
					end
				end

				local oldpos = player:get_pos()
				-- Teleport and hurt player
				player:set_pos(telepos)

				-- 5% chance to spawn endermite at the player's origin
				local r = math.random(1,20)
				if r == 1 then
					minetest.add_entity(oldpos, "mobs_mc:endermite")
				end

			end
			self.object:remove()
			return
		end
	end
	self._lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set lastpos-->Node will be added at last pos outside the node
end

pearl_ENTITY.on_step = pearl_on_step

minetest.register_entity("origins:ender_pearl_entity", pearl_ENTITY)

local enderian_cooldown = {}

minetest.register_on_joinplayer(function(player)
	enderian_cooldown[player:get_player_name()] = false
end)

minetest.register_on_leaveplayer(function(player)
	enderian_cooldown[player:get_player_name()] = false
end)

local function spawn_pearl(player)
	local pname = player:get_player_name()
	if enderian_cooldown[pname] then
		return
	end
	enderian_cooldown[pname] = true
	minetest.after(3, function()
		enderian_cooldown[pname] = false
	end)
	local pos = player:get_pos()
      	local dir = player:get_look_dir()
      	local obj = minetest.add_entity(pos, "origins:ender_pearl_entity")
	if obj then
		minetest.sound_play("mcl_throwing_throw", {pos=pos, gain=0.4, max_hear_distance=16}, true)
      		obj:set_velocity(vector.multiply(dir, 22))
      		obj:set_acceleration({x=dir.x*-3, y=-GRAVITY, z=dir.z*-3})
		obj:get_luaentity()._thrower = pname
	end
end


minetest.register_globalstep(function(dtime)
	for _,player in pairs(minetest.get_connected_players()) do
		local pname = player:get_player_name()
		local team = origins.get_player_team(pname)
		if team ~= "enderian" then return end
		local control = player:get_player_control()
		if control.zoom then
			spawn_pearl(player)
		end
	end
end)


local water_timer = 0
minetest.register_globalstep(function(dtime)
	water_timer = water_timer + dtime;
	if water_timer >= 1 then
		for _,player in pairs(minetest.get_connected_players()) do
			local pname = player:get_player_name()
			local team = origins.get_player_team(pname)
			if team ~= "enderian" then return end
			local headpos = vector.add(player:get_pos(), {x = 0, y = 1, z = 0})
			local legpos = player:get_pos()
			minetest.chat_send_all(dump(minetest.get_item_group(minetest.get_node(headpos), "water")))
			if minetest.get_item_group(minetest.get_node(headpos), "water") ~= 0 or minetest.get_item_group(minetest.get_node(legpos), "water") ~= 0 then
				minetest.chat_send_all("yaya")
				player:set_hp(player:get_hp()-math.random(0.5, 1), { type = "allergies", from = "mod" })
			end
		end
		water_timer = 0
	end
end)

minetest.register_on_player_hpchange(function(player, hp_change, reason)
	local name = player:get_player_name()
	if name and hp_change < 0 then
		if reason.type == "allergies" then
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
