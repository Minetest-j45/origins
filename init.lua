origins = {}


origins.origin = {
	enderian = {},
	merling = {},
	phantom = {},
	elytrian = {},
	blazeborn = {},
	avian = {},
	arachnid = {},
	shulk = {},
	feline = {},
	player = {},
}


origins.fs = "size[3,4]" ..
	"image_button[0,0;1,1;mcl_throwing_ender_pearl.png;enderian;Enderian]" ..
	"image_button[1,0;1,1;mcl_fishing_fish_cooked.png;merling;Merling]" ..
	"image_button[2,0;1,1;TEXTURE;phantom;Phantom]" ..
	"image_button[0,1;1,1;mcl_armor_inv_elytra.png;elytrian;Elytrian]" ..
	"image_button[1,1;1,1;TEXTURE;blazeborn;Blazeborn]" ..
	"image_button[2,1;1,1;TEXTURE;avian;Avian]" ..
	"image_button[0,2;1,1;TEXTURE;arachnid;Arachnid]" ..
	"image_button[1,2;1,1;TEXTURE;shulk;Shulk]" ..
	"image_button[2,2;1,1;TEXTURE;feline;Feline]" ..
	"image_button[1,3;1,1;TEXTURE;player;Player]"

local storage = minetest.get_mod_storage()
if storage:contains("origins") then
	origins = minetest.deserialize(storage:get_string("origins"))
end

local mp = minetest.get_modpath("origins")
local modules = {"enderian", "merling", "phantom", "elytrian", "blazeborn", "avian", "arachnid", "shulk", "feline",}

for _, module in pairs(modules) do
    dofile(mp .. "/" .. module .. ".lua")
end

origins.get_player_team = function(name)
	for k, team in pairs(origins.origin) do
		for _, pname in ipairs(team) do
			if name == pname then return k end
		end
	end
end

local function tablefind(tab,el)
	for index, value in pairs(tab) do
		if value == el then
			return index
		end
	end
end

origins.set = function(pname, wanted, fancy)
	local current = origins.get_player_team(pname)
	local tablenumber = tablefind(origins.origin[current], pname)
	table.remove(origins.origin[current], tonumber(tablenumber))
	table.insert(origins.origin[wanted], pname)
	minetest.chat_send_all(pname .. " is now " .. fancy)
	local player = minetest.get_player_by_name(pname)
	local properties = player:get_properties()
	if wanted == "phantom"  or wanted == "arachnid" then
		properties.hp_max = 17
	elseif wanted == "feline" then
		properties.hp_max = 19
	else
		properties.hp_max = 20
	end
	player:set_properties(properties)
end

minetest.register_craftitem("origins:orb", {
	description = "Origins Orb",
	inventory_image = "orb.png",
 
	on_use = function(itemstack, user, pointed_thing)
		minetest.show_formspec(user:get_player_name(), "origins:orb_fs", origins.fs)
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "origins:orb_fs" then
		local pname = player:get_player_name()
		local current = origins.get_player_team(pname)
		local tablenumber = tablefind(origins.origin[current], pname)
		if fields.enderian then --enderian
			table.remove(origins.origin[current], tonumber(tablenumber))
			table.insert(origins.origin.enderian, pname)
			minetest.chat_send_all(pname .. " is now an Enderian")
		elseif fields.merling then --merling
			table.remove(origins.origin[current], tonumber(tablenumber))
			table.insert(origins.origin.merling, pname)
			minetest.chat_send_all(pname .. " is now a Merling")
		elseif fields.phantom then --phantom
			table.remove(origins.origin[current], tonumber(tablenumber))
			table.insert(origins.origin.phantom, pname)
			minetest.chat_send_all(pname .. " is now a Phantom")
		elseif fields.elytrian then --elytrian
			table.remove(origins.origin[current], tonumber(tablenumber))
			table.insert(origins.origin.elytrian, pname)
			minetest.chat_send_all(pname .. " is now an Elytrian")
		elseif fields.blazeborn then --blazeborn
			table.remove(origins.origin[current], tonumber(tablenumber))
			table.insert(origins.origin.blazeborn, pname)
			minetest.chat_send_all(pname .. " is now a Blazeborn")
		elseif fields.avian then --avian
			table.remove(origins.origin[current], tonumber(tablenumber))
			table.insert(origins.origin.avian, pname)
			minetest.chat_send_all(pname .. " is now an Avian")
		elseif fields.arachnid then --arachnid
			table.remove(origins.origin[current], tonumber(tablenumber))
			table.insert(origins.origin.arachnid, pname)
			minetest.chat_send_all(pname .. " is now an Arachnid")
		elseif fields.shulk then --shulk
			table.remove(origins.origin[current], tonumber(tablenumber))
			table.insert(origins.origin.shulk, pname)
			minetest.chat_send_all(pname .. " is now a Shulk")
		elseif fields.feline then --feline
			table.remove(origins.origin[current], tonumber(tablenumber))
			table.insert(origins.origin.feline, pname)
			minetest.chat_send_all(pname .. " is now a Feline")
		elseif fields.player then
			table.remove(origins.origin[current], tonumber(tablenumber))
			table.insert(origins.origin.player, pname)
			minetest.chat_send_all(pname .. " is now a player")
		end
	end
end)

minetest.register_on_newplayer(function(player)
	player:get_inventory():add_item("main", ItemStack("origins:orb"))
	table.insert(origins.origin.player, player:get_player_name())
end)

minetest.register_on_shutdown(function()
	storage:set_string("origins", minetest.serialize(origins))
end)
