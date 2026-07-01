
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
