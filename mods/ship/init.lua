
core.register_on_joinplayer(function(player, last_login)
	-- make player fly
	player:set_physics_override({gravity=0})
	-- disable sun, moon, & clouds
	player:set_sun({visible=false})
	player:set_moon({visible=false})
	player:set_sky({clouds=false})
	-- TODO: disable fog

	-- disable inventory
	player:set_inventory_formspec("")

	-- disable hotbar
	player:hud_set_flags({hotbar=false})

	-- set player model & mesh
	local model = "rocket.obj"
	--~ player.animation, player.animation_speed, player.animation_loop = nil, nil, nil
	local props = player:get_properties()
	props.mesh = model
	props.textures = {"rocket.png"}
	props.visual = "mesh"
	player:set_properties(props)
end)

-- hide hand
core.override_item("", {wield_image="asteroids_empty.png"})
