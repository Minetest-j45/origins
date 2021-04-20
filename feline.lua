minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if not player then return end
    local name = player:get_player_name()
    if hp_change < 0 then
        local team = origins.get_player_team(name)
        if reason.type == "fall" and team == "feline" then
					return 0
				end
    end
end)
