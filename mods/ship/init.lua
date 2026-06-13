
dofile(core.get_modpath(core.get_current_modname()).."/weapon.lua")


core.register_on_joinplayer(function(player, last_login)
	-- make player fly
	player:set_physics_override({gravity=0})
	-- disable sun, moon, & clouds
	player:set_sun({visible=false, sunrise_visible=false})
	player:set_moon({visible=false})
	player:set_stars({visible=false})
	player:set_sky({
		type = "skybox",
		textures = {
			"asteroids_stars.png", "asteroids_stars.png",
			"asteroids_stars.png", "asteroids_stars.png",
			"asteroids_stars.png", "asteroids_stars.png"
		},
		clouds = false
	})
	-- TODO: disable fog

	-- disable inventory
	player:set_inventory_formspec("")

	-- disable hotbar
	player:hud_set_flags({hotbar=false})

	local props = player:get_properties()
	-- set player model & mesh
	props.visual = "mesh"
	props.mesh = "asteroids_ship.obj"
	props.textures = {"asteroids_ship.png"}
	props.visual_size = {x=1, y=1, z=1}
	props.eye_height = 0
	player:set_properties(props)
end)

-- disable fog by default
core.settings:set_bool("enable_fog", false)
