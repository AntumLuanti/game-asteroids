
asteroids = {
	modname = core.get_current_modname()
}
asteroids.modpath = core.get_modpath(asteroids.modname)

dofile(asteroids.modpath.."/logic.lua")
local register_asteroid = dofile(asteroids.modpath.."/api.lua")


for _, a_type in pairs(asteroids.get_materials()) do
	for _, a_size in pairs(asteroids.get_sizes()) do
		register_asteroid(a_type, a_size)
	end
end


--- Current game duration.
--  TODO: rename to level time
asteroids.game_time = 0

asteroids.register_logic(function(dtime)
	-- track game duration
	asteroids.game_time = asteroids.game_time + dtime
end)
