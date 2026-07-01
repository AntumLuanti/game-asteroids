
asteroids = {
	modname = core.get_current_modname()
}
asteroids.modpath = core.get_modpath(asteroids.modname)

local register_asteroid = dofile(asteroids.modpath.."/api.lua")


for _, a_type in pairs(asteroids.get_materials()) do
	for _, a_size in pairs(asteroids.get_sizes()) do
		register_asteroid(a_type, a_size)
	end
end


--- Current game duration.
asteroids.game_time = 0

core.register_globalstep(function(dtime)
	if asteroids.is_paused() then
		return
	end

	asteroids.game_time = asteroids.game_time + dtime
end)
