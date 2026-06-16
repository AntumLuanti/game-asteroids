
core.register_entity("asteroids_ship:projectile", {
	physical = true,
	collide_with_objects = true,
	pointable = false,
	visual = "sprite",
	visual_size = {x=0.25, y=0.25, z=0.25},
	textures = {"asteroids_ship_projectile.png"},
	static_save = false
})

local projectiles = {}

local getTimeMS = function()
	return math.floor(core.get_us_time() / 1000)
end

local shoot = function(itemstack, user, pointed)
	core.sound_play({name="asteroids_ship_shoot"})

	if user then
		-- FIXME: sometimes projectiles move at wrong angle during rapid fire
		local fire_time = getTimeMS()
		local speed = 40
		local upos = user:get_pos()
		local ulook = user:get_look_dir()

		local obj = core.add_entity({x=upos.x+ulook.x, y=upos.y+ulook.y, z=upos.z+ulook.z},
				"asteroids_ship:projectile")
		if obj then
			obj:set_velocity({x=ulook.x*speed, y=ulook.y*speed, z=ulook.z*speed})
			table.insert(projectiles, {obj=obj, birth=fire_time})
		else
			core.log("error", "failed to create projectile at system time "..fire_time.."ms")
		end
	end
end

-- hide hand
core.override_item("", {
	wield_image="asteroids_empty.png",
	on_use = shoot,
	on_secondary_use = shoot,
	on_place = shoot,
})
