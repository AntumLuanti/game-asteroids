
local time_ms = core.get_us_time() / 1000

local rand = PcgRandom(time_ms)

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
		local c_id = rand:next(1, 300) == 1 and core.get_content_id("vacuum_particle") or core.get_content_id("vacuum")
		vm_data[idx] = c_id
	end
	vm:set_data(vm_data)
	vm:write_to_map()
end)


local spawned = 0

local a_types = {"rock", "ice", "molten"}
local a_sizes = {"small", "medium", "large"}

core.register_globalstep(function(dtime)
	-- make light persist
	core.set_timeofday(0.5)

	if asteroids.is_paused() or asteroids.is_classic_gameplay() then
		return
	end

	local step_time = core.get_us_time() / 1000
	if step_time - time_ms > 3000 and asteroids.can_spawn() then
		if rand:next(1, 10) == 1 then
			time_ms = step_time
			local a_type = a_types[rand:next(1, 3)]
			local a_size = a_sizes[rand:next(1, 3)]
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
