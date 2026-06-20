
asteroids = {
	modname = core.get_current_modname()
}
asteroids.modpath = core.get_modpath(asteroids.modname)

local register_asteroid = dofile(asteroids.modpath.."/api.lua")


local rand = asteroids.rand
local rand_thousandth = asteroids.rand_thousandth


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
	if asteroids.is_paused() then
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
