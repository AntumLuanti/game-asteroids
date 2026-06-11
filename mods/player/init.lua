
core.register_on_joinplayer(function(player, last_login)
	player:set_physics_override({gravity=0})
end)
