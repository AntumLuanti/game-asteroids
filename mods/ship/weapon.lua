
core.register_entity("asteroids_ship:projectile", {
	physical = true,
	collide_with_objects = false,
	collisionbox = {-0.125, -0.125, -0.125, 0.125, 0.125, 0.125},
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

core.register_globalstep(function(dtime)
	if asteroids.is_paused() then
		-- FIXME: projectiles still age
		return
	end

	local step_time = getTimeMS()
	for idx = #projectiles, 1, -1 do
		proj = projectiles[idx]

		local pos = proj.obj:get_pos()
		local targets = core.get_objects_inside_radius(pos, 1)

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

		if step_time - proj.birth >= 2000 then
			-- remove projectile from world
			proj.obj:remove()
			table.remove(projectiles, idx)
			if proj.obj:is_valid() then
				core.log("error", "failed to remove projectile at system time "..step_time.."ms")
			end
		end

		-- TODO: handle collision with asteroids
	end
end)
