
asteroids = {
	modname = core.get_current_modname()
}
asteroids.modpath = core.get_modpath(asteroids.modname)

local register_asteroid = dofile(asteroids.modpath.."/api.lua")


local rand = asteroids.rand
local rand_thousandth = asteroids.rand_thousandth


--- Creates a rate of rotation.
--
--  @return
--    Vector defining random rotation rate & direction for each axis.
local next_rot_rate = function()
	-- rotation direction for each axis (0 = no rotation, 1 = clockwise, -1 = counter-clockwise)
	local rot_dir_x = rand:next(-1, 1)
	local rot_dir_y = rand:next(-1, 1)
	local rot_dir_z = rand:next(-1, 1)

	return {
		x = rand_thousandth(0.001, 0.01) * rot_dir_x,
		y = rand_thousandth(0.001, 0.01) * rot_dir_y,
		z = rand_thousandth(0.001, 0.01) * rot_dir_z
	}
end


--- Rotates an asteroid according to its rotation rate vector.
--
--  @param ref
--    Asteroid `ObjectRef` to be rotated.
local rotate_step = function(ref)
	-- object's current rotation
	local rot = ref.object:get_rotation()
	for k, v in pairs(ref.rot_rate) do
		-- update axis rotation from rotation rate vector
		rot[k] = rot[k] + v
	end
	-- apply new rotation to asteroid
	ref.object:set_rotation(rot)
end


-- node radius of gameplay boundaries
local gameplay_radius = 50

-- positional center of gameplay boundaries
local gameplay_center = {x=0, y=0, z=0}

-- maxium age of asteroids in minutes
local age_limit_minutes = 5


-- list of active asteroids
local active_asteroids = {}
-- max limit of number of active asteroids
local active_limit = 20


--- Clears game world of asteroids.
asteroids.clear = function()
	for idx = #active_asteroids, 1, -1 do
		local ast = active_asteroids[idx]
		ast.object:remove()
		ast:on_removed()
	end

	if #active_asteroids ~= 0 then
		core.log("error", "failed to remove "..#active_asteroids.." asteroids")
	end
end


--- Checks if spawning a new asteroid should be allowed.
--
--  @return
--    `true` if number of active asteroids doesn't meet limit.
asteroids.can_spawn = function()
	return #active_asteroids < active_limit
end


local game_paused = false
local stored_velocities = {}
asteroids.set_paused = function(pause)
	if pause and not game_paused then
		stored_velocities = {}
		-- stop asteroids movement
		for idx, ast in ipairs(active_asteroids) do
			table.insert(stored_velocities, ast.object:get_velocity())
			ast.object:set_velocity({x=0, y=0, z=0})
		end
	elseif not pause and game_paused then
		-- restore asteroids movement
		for idx, ast in ipairs(active_asteroids) do
			local velo = stored_velocities[idx]
			if velo then
				ast.object:set_velocity(velo)
			end
		end
		stored_velocities = {}
	end

	game_paused = pause
end

asteroids.is_paused = function()
	return game_paused
end


--- Calculates direction between two points.
--
--  @param A
--    Vector point of origin.
--  @param B
--    Vector point of target.
local direction_between = function(A, B)
	local disp = {
		x = B.x - A.x,
		y = B.y - A.y,
		z = B.z - A.z
	}
	local dist = math.sqrt((disp.x * disp.x) + (disp.y * disp.y) + (disp.z * disp.z))
	local norm = {
		x = disp.x / dist,
		y = disp.y / dist,
		z = disp.z / dist
	}

	return {
		yaw = math.atan2(norm.x, norm.z),
		pitch = math.asin(norm.y)
	}
end


--- Spawns a new asteroid in vicinity of player.
--
--  @param player
--    Active player.
--  @param a_type
--    Asteroid type definition.
--  @param pos
--    Position vector at which asteroid will be spawned. If omitted, will spawn near player.
--  @return
--    `ObjectRef` of spawned asteroid.
asteroids.spawn = function(player, a_type, pos)
	if pos == nil then
		pos = player ~= nil and player:get_pos() or {x=0, y=0, z=0}

		-- calculate to within 20 nodes (5 node min to prevent spawning on player)
		pos.x = pos.x + math.max(5, rand:next(-20, 20))
		pos.y = pos.y + math.max(5, rand:next(-20, 20))
		pos.z = pos.z + math.max(5, rand:next(-20, 20))
	end

	local obj = core.add_entity(pos, "asteroids:"..a_type.material.."_"..a_type.size)
	if not obj then
		core.log("error", "failed to spawn asteroid")
	end

	return obj
end


--- Retrieves available asteroid materials.
asteroids.get_materials = function()
	return {"rock", "ice", "molten"}
end


--- Retrieves available asteroid sizes.
asteroids.get_sizes = function()
	return {"small", "medium", "large"}
end


for _, a_type in pairs(asteroids.get_materials()) do
	for _, a_size in pairs(asteroids.get_sizes()) do
		register_asteroid(a_type, a_size)
	end
end


core.register_globalstep(function(dtime)
	if game_paused then
		return
	end

	local hit = false
	for _, ref in pairs(active_asteroids) do
		local pos = ref.object:get_pos()
		for _, t in pairs(core.get_objects_inside_radius(pos, 1)) do
			if t:is_player() then
				-- TODO: play sound
				t:set_hp(0)
				hit = true
				break
			end
		end

		if hit then
			break
		end
	end
end)
