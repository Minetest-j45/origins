minetest.register_globalstep(function(dtime)
  for _, pname in pairs(origins.origin.enderian) do
    local player = minetest.get_player_by_name(pname)
   if player:get_control().zoom then
     mcl_throwing.get_player_throw_function("mcl_throwing:ender_pearl_entity")
    end
  end
end)
