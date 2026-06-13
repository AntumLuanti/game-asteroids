
core.register_entity("asteroids_ship:projectile", {
	physical = true,
	collide_with_objects = true,
	pointable = false,
	visual = "sprite",
	visual_size = {x=0.5, y=0.5, z=0.5},
	textures = {"asteroids_ship_projectile.png"},
	static_save = false
})

local shoot = function(itemstack, user, pointed)
	core.sound_play({name="asteroids_ship_shoot"})

	if user then
		-- FIXME: sometimes projectiles move at wrong angle during rapid fire
		local speed = 10
		local upos = user:get_pos()
		local ulook = user:get_look_dir()

		local proj = core.add_entity({x=upos.x+ulook.x, y=upos.y+ulook.y, z=upos.z+ulook.z},
				"asteroids_ship:projectile")
		proj:set_velocity({x=ulook.x*speed, y=ulook.y*speed, z=ulook.z*speed})
	end

	-- TODO:
end

-- hide hand
core.override_item("", {
	wield_image="asteroids_empty.png",
	on_use = shoot,
	on_secondary_use = shoot,
	on_place = shoot,
})
