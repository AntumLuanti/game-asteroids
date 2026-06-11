
core.register_on_joinplayer(function(player, last_login)
	-- make player fly
	player:set_physics_override({gravity=0})
	-- disable sun, moon, & clouds
	player:set_sun({visible=false})
	player:set_moon({visible=false})
	player:set_sky({clouds=false})
	-- TODO: disable fog
end)
