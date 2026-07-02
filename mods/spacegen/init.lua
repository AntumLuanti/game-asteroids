
-- limit viewing range to omit distance particles
core.settings:set("max_block_send_distance", 0)

-- no air in space
core.unregister_item("air")

-- override mapgen to only use space nodes
core.set_mapgen_setting("mg_name", "singlenode", true)
core.set_mapgen_setting("mg_flags", "nomountains, nocurves, noridges, nobiomes", true)
core.register_on_generated(function(vmanip, minp, maxp, blockseed)
	local vm = core.get_mapgen_object("voxelmanip")
	local vm_data = vm:get_data()
	for idx in ipairs(vm_data) do
		-- randomly place vacuum or particle nodes
		vm_data[idx] = asteroids.rand(1, 150) == 1 and core.get_content_id("vacuum_particle")
				or core.get_content_id("vacuum")
	end
	vm:set_data(vm_data)
	vm:write_to_map()
end)


local spawned = 0

local a_types = asteroids.get_materials()
local a_sizes = asteroids.get_sizes()


-- determines how many asteroids to spawn at a game level
local asteroids_per_level = {
	[1] = 4
}

-- temporary reference to active player
local player_ref


--- Callback to spawn asteroids when player spawns.
--
--  @param dtime
--    Time since last globalstep.
local on_first_step
on_first_step = function(dtime)
	-- without this delay asteroids disappear after spawn
	if asteroids.game_time < 0.5 then
		return
	end

	-- spawn 4 asteroids for level 1, 6 for every other level
	for _ = 1, asteroids_per_level[asteroids.get_game_level()] or 6, 1 do
		local a_material = a_types[asteroids.rand(1, #a_types)]
		asteroids.spawn(player_ref, {material=a_material, size="large"})
	end

	-- don't spawn more asteroids until game restarts
	asteroids.unregister_logic(on_first_step)
	player_ref = nil
end


--- Sets a temporary globalstep callback to spawn asteroids.
--
--  @param player
--    The player for whom asteroids are being spawned.
asteroids.init_classic_spawn = function(player)
	player_ref = player
	asteroids.register_logic(on_first_step)
end


if not asteroids.is_classic_gameplay() then
	local time_ms = math.floor(asteroids.game_time * 1000)

	asteroids.register_logic(function(dtime)
		local step_time = math.floor(asteroids.game_time * 1000)
		if step_time - time_ms > 3000 and asteroids.can_spawn() then
			if asteroids.rand(1, 10) == 1 then
				time_ms = step_time
				local a_type = a_types[asteroids.rand(1, #a_types)]
				local a_size = a_sizes[asteroids.rand(1, #a_sizes)]
				local player = core.get_player_by_name("singleplayer")

				local obj = asteroids.spawn(player, {material=a_type, size=a_size})
				if obj then
					spawned = spawned + 1
					-- DEBUG:
					core.log("spawned asteroid "..spawned.." ("..a_type.."_"..a_size..")")
				end
			end
		end
	end)
end

core.register_globalstep(function(dtime)
	-- make light persist
	core.set_timeofday(0.5)
end)
