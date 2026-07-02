
core.register_entity("asteroids_ship:projectile", {
	initial_properties = {
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.125, -0.125, -0.125, 0.125, 0.125, 0.125},
		pointable = false,
		visual = "sprite",
		visual_size = {x=0.25, y=0.25, z=0.25},
		textures = {"asteroids_ship_projectile.png"},
		static_save = false
	}
})

local projectiles = {}

local shoot = function(itemstack, user, pointed)
	if (asteroids.is_classic_gameplay() and #projectiles > 1) or #projectiles > 4 then
		-- limit active projectiles to 2 in classic gameplay & 5 otherwise
		return
	end

	core.sound_play({name="asteroids_ship_shoot"})

	if user then
		local fire_time = asteroids.game_time
		local speed = 40
		local upos = user:get_pos()
		local ulook = user:get_look_dir()

		local obj = core.add_entity({x=upos.x+ulook.x, y=upos.y+ulook.y, z=upos.z+ulook.z},
				"asteroids_ship:projectile")
		if obj then
			obj:set_velocity({x=ulook.x*speed, y=ulook.y*speed, z=ulook.z*speed})
			table.insert(projectiles, {obj=obj, birth=fire_time})
		else
			core.log("error", "failed to create projectile at game time "..fire_time.."s")
		end
	end
end

core.override_item("", {
	on_use = shoot,
	on_secondary_use = shoot,
	on_place = shoot,
})

-- TODO: move to entity def `on_step` method
asteroids.register_logic(function(dtime)
	local step_time = asteroids.game_time
	for idx = #projectiles, 1, -1 do
		local proj = projectiles[idx]

		local pos = proj.obj:get_pos()
		-- FIXME: need better collision detection
		local targets = pos and core.get_objects_inside_radius(pos, 1) or {}

		for _, obj in pairs(targets) do
			if obj ~= proj.obj and not obj:is_player() then
				core.sound_play({name="asteroids_hit"})
				obj:set_hp(obj:get_hp()-1)
				proj.obj:remove()
				table.remove(projectiles, idx)
				if proj.obj:is_valid() then
					core.log("error", "failed to remove projectile on impact")
				end
				-- projectile can only affect 1 target
				break
			end
		end

		-- projectile lifespan is limited to 1 second
		if proj.obj:is_valid() and step_time - proj.birth >= 1 then
			-- remove projectile from world
			proj.obj:remove()
			table.remove(projectiles, idx)
			if proj.obj:is_valid() then
				core.log("error", "failed to remove projectile at game time "..step_time.."s")
			end
		end
	end
end)
